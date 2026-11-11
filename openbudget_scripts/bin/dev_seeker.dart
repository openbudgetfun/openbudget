import 'dart:io';

import 'package:openbudget_scripts/dev_seeker.dart';

Future<void> main(List<String> arguments) async {
  final paths = SeekerPaths(_root());
  final command = arguments.isEmpty ? 'start' : arguments.first;

  try {
    switch (command) {
      case 'start':
        await _withLock(paths, () => _start(paths));
      case 'stop':
        await _withLock(paths, () => _stop(paths));
      case 'status':
        await _status(paths);
      case 'reload':
        await _signal(paths, 'r', 'hot reload');
      case 'hot-restart':
        await _signal(paths, 'R', 'hot restart');
      case 'signal':
        if (arguments.length < 2) {
          throw const SeekerException(
            'usage: dev_seeker signal <key> [label]',
            exitCode: seekerUsageExitCode,
          );
        }

        await _signal(
          paths,
          arguments[1],
          arguments.length > 2 ? arguments[2] : 'signal',
        );
      case 'restart':
        await _withLock(paths, () async {
          await _stop(paths);
          await _start(paths);
        });
      default:
        throw SeekerException(
          'Unknown command "$command".',
          exitCode: seekerUsageExitCode,
        );
    }
  } on SeekerException catch (error) {
    stderr.writeln(error.message);
    exitCode = error.exitCode;
  }
}

/// Serializes start, stop, and restart for this checkout only.
Future<void> _withLock(
  SeekerPaths paths,
  Future<void> Function() action,
) async {
  final lock = await SeekerLock.acquire(paths);
  try {
    await action();
  } finally {
    await lock.release();
  }
}

Future<void> _start(SeekerPaths paths) async {
  final explicit = explicitApiUrl();
  final device = await resolveSeekerDevice(
    preferredSerial: Platform.environment['SEEKER_DEVICE_ID'],
  );
  final state = await readSeekerState(paths);
  if (state.hasRunner) {
    stdout
      ..writeln(
        'Seeker Flutter app is already running (pid ${state.runnerPid}).',
      )
      ..writeln('Log: ${paths.flutterLog}')
      ..writeln('Status: devenv shell dev:seeker:status');
    return;
  }

  final previousSerial = readStateFile(paths.deviceSerialFile);
  final cleanup = await removeStaleSeekerState(paths, state: state);
  _printCleanup(cleanup);
  if (previousSerial != null) {
    await _removeRecordedForwards(
      paths,
      device: await _resolveDeviceOrNull(previousSerial),
      quiet: true,
    );
  }

  writeStateFile(paths.deviceSerialFile, device.serial);
  writeStateFile(paths.activeFlag, '$pid');

  try {
    stdout.writeln('Starting Postgres, Redis, and Serverpod...');
    await _runInherited(
      'start:up',
      const [],
      environment: const {'OPENBUDGET_DEVENV_UP_DETACH': '1'},
    );

    final generated = readGeneratedApiUrl(paths.generatedEnv);
    final apiPort = explicit != null
        ? portForUri(explicit)
        : generated == null
        ? 8080
        : portForUri(generated);

    if (explicit == null || isLoopbackApiHost(explicit.host)) {
      stdout.writeln('Waiting for Serverpod on port $apiPort...');
      await waitForApiPort(apiPort);
    }

    final endpoint = await chooseSeekerEndpoint(
      apiPort: apiPort,
      candidates: candidateApiUrls(
        await localIpv4Addresses(),
        apiPort,
      ),
      explicitApiUrl: explicit,
      canReachFromDevice: (url) =>
          deviceCanReachApi(device: device, apiUrl: url),
      openUsbForward: (port) async {
        final forward = await ensureUsbForward(device: device, port: port);
        if (forward.created) {
          recordReverseForward(paths, forward.forward);
        }
        return forward.created;
      },
      closeUsbForward: (port) async {
        final forward = _recordedForward(paths, device.serial, port);
        if (forward == null) {
          return;
        }

        await removeUsbForward(device: device, forward: forward);
        forgetReverseForward(paths, forward);
      },
    );

    if (explicit == null) {
      writeStateFile(
        paths.generatedEnv,
        'OPENBUDGET_API_URL="${endpoint.apiUrl}"',
      );
    }

    writeStateFile(paths.apiUrlFile, endpoint.apiUrl.toString());
    stdout.writeln(
      'Launching Flutter on ${device.serial} against ${endpoint.apiUrl}',
    );

    final launch = await launchFlutter(
      paths: paths,
      device: device,
      apiUrl: endpoint.apiUrl,
    );
    final exited = await waitForProcessExit(
      launch.runner.pid,
      grace: seekerStartupGrace(),
    );
    final failure = launchFailureFor(
      exited: exited,
      log: _readLog(paths.flutterLog),
      logPath: paths.flutterLog,
    );
    if (failure != null) {
      throw SeekerException(failure);
    }

    writeStateFile(paths.activeFlag, '${launch.runner.pid}');
    stdout
      ..writeln('Seeker dev environment is starting.')
      ..writeln('API: ${endpoint.apiUrl}')
      ..writeln('Flutter log: ${paths.flutterLog}')
      ..writeln('Server logs: devenv processes logs server:up')
      ..writeln('Status: devenv shell dev:seeker:status')
      ..writeln('Hot reload: devenv shell dev:seeker:reload')
      ..writeln('Hot restart: devenv shell dev:seeker:hot-restart')
      ..writeln('Stop: devenv shell dev:seeker:stop');
  } on Object {
    await _cleanupAfterFailure(paths, device: device);
    rethrow;
  }
}

Future<void> _stop(SeekerPaths paths) async {
  final state = await readSeekerState(paths);
  final serial = readStateFile(paths.deviceSerialFile);
  var keepState = false;

  if (state.hasRunner) {
    final stopped = await stopSeekerProcess(state.runner!);
    if (!stopped) {
      stdout.writeln(
        'Could not stop Seeker Flutter app (pid ${state.runnerPid}).',
      );
    } else if (await isProcessAlive(state.runnerPid!)) {
      keepState = true;
    } else {
      stdout.writeln('Stopped Seeker Flutter app (pid ${state.runnerPid}).');
    }
  } else if (state.runnerPid != null) {
    stdout.writeln(
      'Ignored stale Flutter PID ${state.runnerPid}; it is not the Seeker '
      'runner.',
    );
  }

  if (state.hasHolder) {
    if (await stopSeekerProcess(state.holder!)) {
      stdout.writeln('Stopped FIFO holder (pid ${state.holderPid}).');
    }
  }

  if (keepState) {
    stdout.writeln(
      'Kept Seeker state and USB forwards because the Flutter runner is still '
      'alive.',
    );
    return;
  }

  if (readReverseForwards(paths).isNotEmpty) {
    await _removeRecordedForwards(
      paths,
      device: serial == null ? null : await _resolveDeviceOrNull(serial),
    );
  }

  _removeSeekerStateFiles(
    paths,
    keepSerial: readReverseForwards(paths).isNotEmpty,
  );

  stdout.writeln(
    'Seeker runner and USB forwards are stopped. Postgres, Redis, and '
    'Serverpod were left running.',
  );
}

Future<void> _status(SeekerPaths paths) async {
  final state = await readSeekerState(paths);
  final storedUrl = readStateFile(paths.apiUrlFile);
  final generated = readGeneratedApiUrl(paths.generatedEnv);
  final explicit = _explicitApiUrlOrNull();
  final apiUrl = explicit?.toString() ?? storedUrl ?? generated?.toString();

  stdout.writeln('API: ${apiUrl ?? 'unknown'}');
  if (state.hasRunner) {
    stdout.writeln(
      'Seeker Flutter app: running (pid ${state.runnerPid})',
    );
  } else if (state.runnerPid != null) {
    stdout.writeln(
      'Seeker Flutter app: stale PID ${state.runnerPid}',
    );
  } else {
    stdout.writeln('Seeker Flutter app: not running');
  }

  stdout.writeln(
    'Control pipe: ${isFifo(paths.controlFifo) ? 'ready' : 'missing'}',
  );

  await _tryRunInherited('devenv', const ['processes', 'list']);
  await _tryRunInherited('adb', const ['devices', '-l']);
}

Future<void> _signal(SeekerPaths paths, String key, String label) async {
  final state = await readSeekerState(paths);
  if (!state.hasRunner) {
    await removeStaleSeekerState(paths, state: state);
    throw const SeekerException(
      'Seeker Flutter runner is not running. '
      'Start it with: devenv shell dev:seeker',
    );
  }

  if (!isFifo(paths.controlFifo)) {
    throw const SeekerException(
      'Seeker Flutter control pipe is missing. '
      'Restart with: devenv shell dev:seeker:restart',
    );
  }

  await writeFifoKey(paths.controlFifo, key);
  stdout.writeln('Requested Flutter $label.');
}

Future<void> _cleanupAfterFailure(
  SeekerPaths paths, {
  required AdbDevice device,
}) async {
  final state = await readSeekerState(paths);
  var keptLiveProcess = false;

  for (final record in [state.runner, state.holder]) {
    if (record == null) {
      continue;
    }

    try {
      final stopped = await stopSeekerProcess(record);
      if (!stopped && await isProcessAlive(record.pid)) {
        keptLiveProcess = true;
      }
    } on SeekerException {
      keptLiveProcess = true;
    }
  }

  if (keptLiveProcess) {
    stdout.writeln(
      'Could not stop an owned Seeker process; keeping its state and USB '
      'forwards so it can be stopped safely.',
    );
    return;
  }

  await _removeRecordedForwards(paths, device: device);
  _removeSeekerStateFiles(
    paths,
    keepSerial: readReverseForwards(paths).isNotEmpty,
  );
}

Future<void> _removeRecordedForwards(
  SeekerPaths paths, {
  required AdbDevice? device,
  bool quiet = false,
}) async {
  final forwards = readReverseForwards(paths);
  if (forwards.isEmpty) {
    return;
  }

  if (device == null) {
    if (!quiet) {
      stdout.writeln(
        'Device is not attached; kept USB forward records for '
        '${forwards.map((forward) => forward.line).join(', ')}.',
      );
    }
    return;
  }

  final kept = <ReverseForward>[];
  for (final forward in forwards) {
    if (forward.serial != device.serial) {
      kept.add(forward);
      continue;
    }

    try {
      await removeUsbForward(device: device, forward: forward);
      forgetReverseForward(paths, forward);
    } on SeekerException catch (error) {
      kept.add(forward);
      if (!quiet) {
        stdout.writeln(error.message);
      }
    }
  }

  if (!quiet && kept.isNotEmpty) {
    stdout.writeln(
      'Kept USB forward records for '
      '${kept.map((forward) => forward.line).join(', ')}.',
    );
  }
}

ReverseForward? _recordedForward(
  SeekerPaths paths,
  String serial,
  int port,
) {
  for (final forward in readReverseForwards(paths)) {
    if (forward.serial == serial && forward.devicePort == port) {
      return forward;
    }
  }

  return null;
}

Future<AdbDevice?> _resolveDeviceOrNull(String serial) async {
  try {
    return await resolveSeekerDevice(preferredSerial: serial);
  } on SeekerException {
    return null;
  }
}

void _removeSeekerStateFiles(SeekerPaths paths, {bool keepSerial = false}) {
  [
    paths.flutterPid,
    paths.fifoHolderPid,
    paths.controlFifo,
    paths.activeFlag,
    if (!keepSerial) paths.deviceSerialFile,
  ].forEach(removeIfExists);
}

void _printCleanup(StaleCleanup cleanup) {
  if (cleanup.stoppedHolderPid != null) {
    stdout.writeln(
      'Stopped stale FIFO holder (pid ${cleanup.stoppedHolderPid}).',
    );
  }

  if (cleanup.removedPaths.isNotEmpty) {
    stdout.writeln('Removed stale Seeker state.');
  }
}

Future<void> _runInherited(
  String executable,
  List<String> arguments, {
  Map<String, String>? environment,
}) async {
  try {
    final process = await Process.start(
      executable,
      arguments,
      environment: environment,
      mode: ProcessStartMode.inheritStdio,
    );
    final exitCode = await process.exitCode;
    if (exitCode != 0) {
      throw SeekerException('$executable exited with code $exitCode.');
    }
  } on ProcessException catch (error) {
    throw SeekerException('Could not run $executable: ${error.message}');
  }
}

Future<void> _tryRunInherited(
  String executable,
  List<String> arguments,
) async {
  try {
    final process = await Process.start(
      executable,
      arguments,
      mode: ProcessStartMode.inheritStdio,
    );
    await process.exitCode;
  } on ProcessException {
    return;
  }
}

String _readLog(String path) {
  final file = File(path);
  if (!file.existsSync()) {
    return '';
  }

  return file.readAsStringSync();
}

Uri? _explicitApiUrlOrNull() {
  try {
    return explicitApiUrl();
  } on SeekerException {
    return null;
  }
}

String _root() {
  final root = Platform.environment['DEVENV_ROOT'];
  if (root != null && root.isNotEmpty) {
    return root;
  }

  return Directory.current.path;
}

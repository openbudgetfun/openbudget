import 'dart:io';

import 'package:openbudget_scripts/dev_seeker.dart';

Future<void> main(List<String> arguments) async {
  final paths = SeekerPaths(_root());
  final command = arguments.isEmpty ? 'start' : arguments.first;

  try {
    switch (command) {
      case 'start':
        await _start(paths);
      case 'stop':
        await _stop(paths);
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
        await _stop(paths);
        await _start(paths);
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

Future<void> _start(SeekerPaths paths) async {
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

  final cleanup = await removeStaleSeekerState(paths, state: state);
  _printCleanup(cleanup);
  final explicit = explicitApiUrl();
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

    stdout.writeln('Waiting for Serverpod on port $apiPort...');
    await waitForApiPort(apiPort);

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
        await setUsbForward(device: device, port: port);
        recordReversePort(paths, port);
      },
      closeUsbForward: (port) async {
        await removeUsbForward(device: device, port: port);
        forgetReversePort(paths, port);
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

    final flutterPid = await launchFlutter(
      paths: paths,
      device: device,
      apiUrl: endpoint.apiUrl,
    );
    final exited = await waitForProcessExit(flutterPid);
    final failure = launchFailureFor(
      exited: exited,
      log: _readLog(paths.flutterLog),
      logPath: paths.flutterLog,
    );
    if (failure != null) {
      await _cleanupAfterFailure(paths, device);
      throw SeekerException(failure);
    }

    writeStateFile(paths.activeFlag, '$flutterPid');
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
    await _cleanupAfterFailure(paths, device);
    rethrow;
  }
}

Future<void> _stop(SeekerPaths paths) async {
  final state = await readSeekerState(paths);

  if (state.hasRunner) {
    if (await stopSeekerProcess(state.runnerPid!)) {
      stdout.writeln('Stopped Seeker Flutter app (pid ${state.runnerPid}).');
    } else {
      stdout.writeln(
        'Could not stop Seeker Flutter app (pid ${state.runnerPid}).',
      );
    }
  } else if (state.runnerPid != null) {
    stdout.writeln(
      'Ignored stale Flutter PID ${state.runnerPid}; it is not the Seeker '
      'runner.',
    );
  }

  if (state.hasHolder) {
    if (await stopSeekerProcess(state.holderPid!)) {
      stdout.writeln('Stopped FIFO holder (pid ${state.holderPid}).');
    }
  }

  final device = await tryResolveSeekerDevice(
    preferredSerial: Platform.environment['SEEKER_DEVICE_ID'],
  );
  final ports = readReversePorts(paths);
  if (ports.isNotEmpty && device != null) {
    for (final port in ports) {
      try {
        await removeUsbForward(device: device, port: port);
      } on SeekerException {
        continue;
      }
    }
    removeIfExists(paths.reversePortsFile);
  } else if (ports.isNotEmpty) {
    stdout.writeln(
      'Device is not attached; kept USB forward records for $ports.',
    );
  }

  if (device != null) {
    try {
      await forceStopSeekerApp(device);
    } on SeekerException {
      // The runner is already stopped; a missing app on the phone is harmless.
    }
  }

  [
    paths.flutterPid,
    paths.fifoHolderPid,
    paths.controlFifo,
    paths.activeFlag,
  ].forEach(removeIfExists);

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
  SeekerPaths paths,
  AdbDevice device,
) async {
  final state = await readSeekerState(paths);
  await removeStaleSeekerState(paths, state: state);

  final ports = readReversePorts(paths);
  if (ports.isEmpty) {
    return;
  }

  for (final port in ports) {
    try {
      await removeUsbForward(device: device, port: port);
    } on SeekerException {
      continue;
    }
  }
  removeIfExists(paths.reversePortsFile);
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

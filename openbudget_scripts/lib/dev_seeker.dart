import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:openbudget_scripts/dev_server_host.dart';

/// Exit code for a command that was used incorrectly.
const int seekerUsageExitCode = 64;

/// Error with a message suitable for printing to the terminal.
class SeekerException implements Exception {
  const SeekerException(this.message, {this.exitCode = 1});

  final String message;
  final int exitCode;

  @override
  String toString() => message;
}

/// One row from `adb devices -l`.
class AdbDevice {
  const AdbDevice({required this.serial, required this.state, this.model});

  final String serial;
  final String state;
  final String? model;

  bool get isReady => state == 'device';

  @override
  String toString() => model == null ? serial : '$serial ($model)';
}

/// Parses the output of `adb devices -l`.
List<AdbDevice> parseAdbDevices(String output) {
  final devices = <AdbDevice>[];

  for (final line in const LineSplitter().convert(output)) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('List of devices')) {
      continue;
    }

    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length < 2) {
      continue;
    }

    devices.add(
      AdbDevice(
        serial: parts.first,
        state: parts[1],
        model: _adbProperty(parts, 'model'),
      ),
    );
  }

  return devices;
}

String? _adbProperty(List<String> parts, String name) {
  final prefix = '$name:';
  for (final part in parts.skip(2)) {
    if (!part.startsWith(prefix)) {
      continue;
    }

    final value = part.substring(prefix.length).replaceAll('_', ' ');
    return value.isEmpty ? null : value;
  }

  return null;
}

/// Picks the one Android device the Seeker runner should use.
///
/// A preferred serial wins when set. Otherwise exactly one ready device must
/// be attached, so a second phone or emulator fails loudly instead of being
/// silently ignored.
AdbDevice selectSeekerDevice(
  Iterable<AdbDevice> devices, {
  String? preferredSerial,
}) {
  final all = devices.toList(growable: false);
  final preferred = preferredSerial?.trim();

  if (preferred != null && preferred.isNotEmpty) {
    for (final device in all) {
      if (device.serial != preferred) {
        continue;
      }

      if (!device.isReady) {
        throw SeekerException(
          'Android device $preferred is ${device.state}. '
          'Reconnect it or fix USB debugging.',
        );
      }

      return device;
    }

    throw SeekerException(
      'No Android device with serial $preferred. '
      'Run `adb devices -l` to list attached devices.',
    );
  }

  final ready = all.where((device) => device.isReady).toList(growable: false);
  if (ready.isEmpty) {
    throw const SeekerException(
      'No ready Android device. Connect the Seeker over USB and enable USB '
      'debugging.',
    );
  }

  if (ready.length > 1) {
    final serials = ready.map((device) => device.serial).join(', ');
    throw SeekerException(
      'Multiple Android devices are ready ($serials). '
      'Set SEEKER_DEVICE_ID to the one to use.',
    );
  }

  return ready.single;
}

/// Builds the API URLs to try from the machine's IPv4 addresses.
List<Uri> candidateApiUrls(Iterable<String> addresses, int apiPort) => [
  for (final host in devServerHostCandidates(addresses))
    Uri(scheme: 'http', host: host, port: apiPort, path: '/'),
];

/// The URL the phone should use and whether it needs USB forwarding.
class SeekerEndpoint {
  const SeekerEndpoint({required this.apiUrl, required this.usedUsb});

  final Uri apiUrl;
  final bool usedUsb;
}

/// Chooses an API URL the attached device can actually reach.
///
/// An explicit URL is preserved and must work. Otherwise the candidates are
/// probed in order; USB forwarding is the last resort because it is slower
/// than a direct network route.
Future<SeekerEndpoint> chooseSeekerEndpoint({
  required int apiPort,
  required Iterable<Uri> candidates,
  required Future<bool> Function(Uri url) canReachFromDevice,
  required Future<void> Function(int port) openUsbForward,
  required Future<void> Function(int port) closeUsbForward,
  Uri? explicitApiUrl,
}) async {
  if (explicitApiUrl != null) {
    if (!await canReachFromDevice(explicitApiUrl)) {
      throw SeekerException(
        'OPENBUDGET_API_URL is set to $explicitApiUrl, but the device cannot '
        'reach it.',
      );
    }

    return SeekerEndpoint(apiUrl: explicitApiUrl, usedUsb: false);
  }

  final tried = <String>{};
  for (final candidate in candidates) {
    if (!tried.add(candidate.toString())) {
      continue;
    }

    if (await canReachFromDevice(candidate)) {
      return SeekerEndpoint(apiUrl: candidate, usedUsb: false);
    }
  }

  await openUsbForward(apiPort);
  final usbUrl = Uri(
    scheme: 'http',
    host: '127.0.0.1',
    port: apiPort,
    path: '/',
  );

  try {
    if (!await canReachFromDevice(usbUrl)) {
      throw const SeekerException(
        'USB forwarding is active, but the device still cannot reach the API.',
      );
    }
  } on Object {
    await closeUsbForward(apiPort);
    rethrow;
  }

  return SeekerEndpoint(apiUrl: usbUrl, usedUsb: true);
}

/// Files shared by the `dev:seeker` commands.
class SeekerPaths {
  SeekerPaths(String root) : root = root.replaceAll(RegExp(r'/+$'), '');

  final String root;

  String get logDirectory => '$root/.devlogs';
  String get flutterLog => '$logDirectory/seeker-flutter.log';
  String get flutterPid => '$logDirectory/seeker-flutter.pid';
  String get fifoHolderPid => '$logDirectory/seeker-fifo-holder.pid';
  String get controlFifo => '$logDirectory/seeker-flutter.stdin';
  String get apiUrlFile => '$logDirectory/seeker-api-url';
  String get reversePortsFile => '$logDirectory/seeker-reverse-ports';
  String get activeFlag => '$root/.tmp/dev-seeker.active';
  String get generatedEnv => '$root/.tmp/flutter.env';
  String get appDirectory => '$root/openbudget_app';
}

/// Snapshot of the PID files and what those processes are actually running.
class SeekerState {
  const SeekerState({
    this.runnerPid,
    this.runnerCommand,
    this.holderPid,
    this.holderCommand,
  });

  final int? runnerPid;
  final String? runnerCommand;
  final int? holderPid;
  final String? holderCommand;

  bool get hasRunner =>
      runnerPid != null &&
      runnerCommand != null &&
      isSeekerRunnerCommand(runnerCommand!);

  bool get hasHolder =>
      holderPid != null &&
      holderCommand != null &&
      isSeekerFifoHolderCommand(holderCommand!);
}

typedef ProcessCommandLookup = Future<String?> Function(int pid);

/// Whether [command] is the Flutter runner this tool started.
bool isSeekerRunnerCommand(String command) =>
    command.contains('main_dev.dart') && command.contains('flutter');

/// Whether [command] is the FIFO holder this tool started.
bool isSeekerFifoHolderCommand(String command) =>
    command.contains('openbudget-seeker-fifo-holder');

/// Reads both PID files and resolves what those processes are running.
Future<SeekerState> readSeekerState(
  SeekerPaths paths, {
  ProcessCommandLookup? commandForPid,
}) async {
  final lookup = commandForPid ?? processCommand;
  final runnerPid = _readPid(paths.flutterPid);
  final holderPid = _readPid(paths.fifoHolderPid);

  return SeekerState(
    runnerPid: runnerPid,
    runnerCommand: runnerPid == null ? null : await lookup(runnerPid),
    holderPid: holderPid,
    holderCommand: holderPid == null ? null : await lookup(holderPid),
  );
}

/// Files removed while clearing state that does not belong to a live runner.
class StaleCleanup {
  const StaleCleanup({
    required this.removedPaths,
    required this.stoppedHolderPid,
  });

  final List<String> removedPaths;
  final int? stoppedHolderPid;
}

/// Removes PID files, the flag, and the FIFO when no runner owns them.
///
/// A live runner is never touched. A stale holder is stopped only after its
/// command line proves it is the holder this tool created.
Future<StaleCleanup> removeStaleSeekerState(
  SeekerPaths paths, {
  required SeekerState state,
  Future<bool> Function(int pid)? stopProcess,
}) async {
  if (state.hasRunner) {
    return const StaleCleanup(removedPaths: [], stoppedHolderPid: null);
  }

  final stop = stopProcess ?? stopSeekerProcess;
  int? stoppedHolderPid;
  if (state.hasHolder) {
    if (await stop(state.holderPid!)) {
      stoppedHolderPid = state.holderPid;
    }
  }

  final removedPaths = <String>[];
  for (final path in [
    paths.flutterPid,
    paths.fifoHolderPid,
    paths.controlFifo,
    paths.activeFlag,
  ]) {
    if (removeIfExists(path)) {
      removedPaths.add(path);
    }
  }

  return StaleCleanup(
    removedPaths: removedPaths,
    stoppedHolderPid: stoppedHolderPid,
  );
}

/// Stops [pid] only when its command line belongs to the Seeker tooling.
///
/// This is the guard against a stale PID file pointing at an unrelated process
/// after the operating system reused the number.
Future<bool> stopSeekerProcess(
  int pid, {
  ProcessCommandLookup? commandForPid,
  Future<void> Function(int pid)? terminate,
}) async {
  final command = await (commandForPid ?? processCommand)(pid);
  if (command == null) {
    return false;
  }

  if (!isSeekerRunnerCommand(command) && !isSeekerFifoHolderCommand(command)) {
    return false;
  }

  await (terminate ?? terminateProcess)(pid);
  return true;
}

/// Sends SIGTERM, waits for [grace], then sends SIGKILL.
Future<void> terminateProcess(
  int pid, {
  Duration grace = const Duration(seconds: 5),
}) async {
  if (!await isProcessAlive(pid)) {
    return;
  }

  Process.killPid(pid);
  final deadline = DateTime.now().add(grace);
  while (DateTime.now().isBefore(deadline)) {
    if (!await isProcessAlive(pid)) {
      return;
    }

    await Future<void>.delayed(const Duration(milliseconds: 100));
  }

  Process.killPid(pid, ProcessSignal.sigkill);
}

/// Whether [pid] currently exists.
Future<bool> isProcessAlive(int pid) async {
  try {
    final result = await runCommand('ps', ['-p', '$pid', '-o', 'pid=']);
    return result.exitCode == 0;
  } on SeekerException {
    return false;
  }
}

/// Returns the full command line for [pid], or `null` when it is gone.
Future<String?> processCommand(int pid) async {
  try {
    final result = await runCommand('ps', ['-p', '$pid', '-o', 'command=']);
    if (result.exitCode != 0) {
      return null;
    }

    final command = (result.stdout as String).trim();
    return command.isEmpty ? null : command;
  } on SeekerException {
    return null;
  }
}

/// Resolves the attached device, honouring `SEEKER_DEVICE_ID` when set.
Future<AdbDevice> resolveSeekerDevice({
  String? preferredSerial,
}) async {
  final result = await runCommand('adb', ['devices', '-l']);
  if (result.exitCode != 0) {
    throw SeekerException(
      'adb devices failed: ${(result.stderr as String).trim()}',
    );
  }

  return selectSeekerDevice(
    parseAdbDevices(result.stdout as String),
    preferredSerial: preferredSerial,
  );
}

/// Resolves the attached device when possible, without failing when absent.
Future<AdbDevice?> tryResolveSeekerDevice({String? preferredSerial}) async {
  try {
    return await resolveSeekerDevice(preferredSerial: preferredSerial);
  } on SeekerException {
    return null;
  }
}

/// Probes the API port from the phone using Android's toybox netcat.
Future<bool> deviceCanReachApi({
  required AdbDevice device,
  required Uri apiUrl,
}) async {
  if (apiUrl.host.isEmpty) {
    return false;
  }

  final port = portForUri(apiUrl);
  final command =
      'toybox nc -w 2 ${_shellQuote(apiUrl.host)} $port < /dev/null';

  try {
    final result = await runCommand(
      'adb',
      ['-s', device.serial, 'shell', command],
      timeout: const Duration(seconds: 6),
    );
    return result.exitCode == 0;
  } on SeekerException {
    return false;
  }
}

/// Adds an adb reverse rule for [port].
Future<void> setUsbForward({
  required AdbDevice device,
  required int port,
}) async {
  final result = await runCommand('adb', [
    '-s',
    device.serial,
    'reverse',
    'tcp:$port',
    'tcp:$port',
  ]);
  if (result.exitCode != 0) {
    throw SeekerException(
      'adb reverse tcp:$port failed: ${(result.stderr as String).trim()}',
    );
  }
}

/// Removes only the adb reverse rule for [port].
Future<void> removeUsbForward({
  required AdbDevice device,
  required int port,
}) async {
  await runCommand('adb', [
    '-s',
    device.serial,
    'reverse',
    '--remove',
    'tcp:$port',
  ]);
}

/// Stops the dev app on the attached device.
Future<void> forceStopSeekerApp(AdbDevice device) async {
  await runCommand('adb', [
    '-s',
    device.serial,
    'shell',
    'am',
    'force-stop',
    'com.openbudget.app.dev',
  ]);
}

/// Whether [port] accepts TCP connections on the loopback interface.
Future<bool> canConnectToPort(String host, int port) async {
  try {
    final socket = await Socket.connect(
      host,
      port,
      timeout: const Duration(seconds: 2),
    );
    socket.destroy();
    return true;
  } on SocketException {
    return false;
  }
}

/// Waits for Serverpod to accept connections on the local API port.
Future<void> waitForApiPort(
  int port, {
  Duration timeout = const Duration(seconds: 90),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    if (await canConnectToPort('127.0.0.1', port)) {
      return;
    }

    await Future<void>.delayed(const Duration(seconds: 1));
  }

  throw SeekerException(
    'Serverpod did not open port $port within ${timeout.inSeconds}s.',
  );
}

/// Starts the Flutter runner behind a FIFO and returns its PID.
///
/// The log is truncated on each launch so a failure reports the current run,
/// not output from an older one.
Future<int> launchFlutter({
  required SeekerPaths paths,
  required AdbDevice device,
  required Uri apiUrl,
}) async {
  await Directory(paths.logDirectory).create(recursive: true);
  removeIfExists(paths.controlFifo);

  final fifo = await runCommand('mkfifo', [paths.controlFifo]);
  if (fifo.exitCode != 0) {
    throw SeekerException(
      'Could not create ${paths.controlFifo}: '
      '${(fifo.stderr as String).trim()}',
    );
  }

  final holder = await _startDetached('bash', [
    '-c',
    r'exec -a openbudget-seeker-fifo-holder sleep 1000000 > "$1"',
    'bash',
    paths.controlFifo,
  ]);
  writeStateFile(paths.fifoHolderPid, '${holder.pid}');

  const command =
      r'exec flutter run --flavor dev -t lib/main_dev.dart -d "$1" '
      r'--dart-define="OPENBUDGET_API_URL=$2" '
      r'--dart-define="API_URL=$2" < "$3" > "$4" 2>&1';
  final process = await _startDetached(
    'bash',
    [
      '-c',
      command,
      'bash',
      device.serial,
      apiUrl.toString(),
      paths.controlFifo,
      paths.flutterLog,
    ],
    workingDirectory: paths.appDirectory,
  );
  writeStateFile(paths.flutterPid, '${process.pid}');
  return process.pid;
}

/// Waits [grace] and reports whether the detached runner exited.
Future<bool> waitForProcessExit(
  int pid, {
  Duration grace = const Duration(seconds: 20),
  Future<bool> Function(int pid)? isAlive,
}) async {
  final alive = isAlive ?? isProcessAlive;
  final deadline = DateTime.now().add(grace);
  while (DateTime.now().isBefore(deadline)) {
    if (!await alive(pid)) {
      return true;
    }

    await Future<void>.delayed(const Duration(milliseconds: 200));
  }

  return false;
}

/// Returns a clear failure message when Flutter exited during the grace period.
String? launchFailureFor({
  required bool exited,
  required String log,
  required String logPath,
}) {
  if (!exited) {
    return null;
  }

  final tail = tailLines(log, 20);
  final detail = tail.isEmpty ? '' : '\n\n$tail';
  return 'Flutter exited before the app started. See $logPath$detail';
}

/// Returns the last [count] lines of [value].
String tailLines(String value, int count) {
  final lines = const LineSplitter().convert(value);
  if (lines.length <= count) {
    return lines.join('\n');
  }

  return lines.skip(lines.length - count).join('\n');
}

/// Writes a key to the Flutter runner's stdin FIFO.
///
/// A stale FIFO has no reader, so opening it blocks forever. The timeout turns
/// that hang into a clear error instead of a stuck terminal.
Future<void> writeFifoKey(
  String path,
  String key, {
  Duration timeout = const Duration(seconds: 2),
}) async {
  final process = await _startProcess('bash', [
    '-c',
    r'printf "%s\n" "$1" > "$2"',
    'bash',
    key,
    path,
  ]);

  try {
    final exitCode = await process.exitCode.timeout(timeout);
    if (exitCode != 0) {
      throw SeekerException('Could not write to $path (exit $exitCode).');
    }
  } on TimeoutException {
    process.kill(ProcessSignal.sigkill);
    await process.exitCode;
    throw SeekerException(
      'The Flutter control pipe at $path has no reader. '
      'Restart with: devenv shell dev:seeker:restart',
    );
  }
}

/// Whether [path] is a FIFO.
bool isFifo(String path) =>
    FileSystemEntity.typeSync(path, followLinks: false) ==
    FileSystemEntityType.pipe;

/// Reads a state file, or returns `null` when it does not exist.
String? readStateFile(String path) {
  final file = File(path);
  if (!file.existsSync()) {
    return null;
  }

  return file.readAsStringSync().trim();
}

/// Writes a state file and ensures its parent directory exists.
void writeStateFile(String path, String value) {
  final file = File(path);
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(value.endsWith('\n') ? value : '$value\n');
}

/// Removes a file, directory, or FIFO when it exists.
bool removeIfExists(String path) {
  final type = FileSystemEntity.typeSync(path, followLinks: false);
  if (type == FileSystemEntityType.notFound) {
    return false;
  }

  if (type == FileSystemEntityType.directory) {
    Directory(path).deleteSync(recursive: true);
  } else {
    File(path).deleteSync();
  }

  return true;
}

/// Reads the API URL generated by `openbudget:url:update`.
Uri? readGeneratedApiUrl(String path) {
  final content = readStateFile(path);
  if (content == null) {
    return null;
  }

  final match = RegExp(
    r'^OPENBUDGET_API_URL="?([^"\n]+)"?$',
    multiLine: true,
  ).firstMatch(content);
  final value = match?.group(1);
  return value == null ? null : Uri.tryParse(value);
}

/// Port used by [uri], including the scheme default.
int portForUri(Uri uri) {
  if (uri.hasPort) {
    return uri.port;
  }

  return uri.scheme == 'https' ? 443 : 80;
}

/// Reads the explicit API URL, rejecting a malformed override.
Uri? explicitApiUrl() {
  final value = Platform.environment['OPENBUDGET_API_URL']?.trim();
  if (value == null || value.isEmpty) {
    return null;
  }

  final uri = Uri.tryParse(value);
  if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
    throw const SeekerException(
      'OPENBUDGET_API_URL is not a valid URL.',
      exitCode: seekerUsageExitCode,
    );
  }

  return uri;
}

/// The machine's non-loopback IPv4 addresses.
Future<List<String>> localIpv4Addresses() async {
  final interfaces = await NetworkInterface.list(
    type: InternetAddressType.IPv4,
  );
  return [
    for (final interface in interfaces)
      for (final address in interface.addresses)
        if (address.type == InternetAddressType.IPv4) address.address,
  ];
}

/// Ports currently recorded as adb reverse rules.
Set<int> readReversePorts(SeekerPaths paths) {
  final value = readStateFile(paths.reversePortsFile);
  if (value == null || value.isEmpty) {
    return <int>{};
  }

  final ports = <int>{};
  for (final part in value.split(RegExp(r'\s+'))) {
    final port = int.tryParse(part);
    if (port != null) {
      ports.add(port);
    }
  }

  return ports;
}

/// Records [port] so `dev:seeker:stop` removes only this rule.
void recordReversePort(SeekerPaths paths, int port) {
  final ports = readReversePorts(paths)..add(port);
  final sorted = ports.toList()..sort();
  writeStateFile(paths.reversePortsFile, sorted.join(' '));
}

/// Forgets a recorded reverse rule after it has been removed.
void forgetReversePort(SeekerPaths paths, int port) {
  final ports = readReversePorts(paths)..remove(port);
  if (ports.isEmpty) {
    removeIfExists(paths.reversePortsFile);
    return;
  }

  final sorted = ports.toList()..sort();
  writeStateFile(paths.reversePortsFile, sorted.join(' '));
}

Future<Process> _startProcess(
  String executable,
  List<String> arguments, {
  Map<String, String>? environment,
  String? workingDirectory,
}) async {
  try {
    return await Process.start(
      executable,
      arguments,
      environment: environment,
      workingDirectory: workingDirectory,
    );
  } on ProcessException catch (error) {
    throw SeekerException('Could not run $executable: ${error.message}');
  }
}

Future<Process> _startDetached(
  String executable,
  List<String> arguments, {
  String? workingDirectory,
}) async {
  try {
    return await Process.start(
      executable,
      arguments,
      workingDirectory: workingDirectory,
      mode: ProcessStartMode.detached,
    );
  } on ProcessException catch (error) {
    throw SeekerException('Could not run $executable: ${error.message}');
  }
}

/// Runs a command and captures its output, killing it after [timeout].
Future<ProcessResult> runCommand(
  String executable,
  List<String> arguments, {
  Duration timeout = const Duration(seconds: 5),
  Map<String, String>? environment,
  String? workingDirectory,
}) async {
  final process = await _startProcess(
    executable,
    arguments,
    environment: environment,
    workingDirectory: workingDirectory,
  );
  final stdoutFuture = process.stdout.transform(utf8.decoder).join();
  final stderrFuture = process.stderr.transform(utf8.decoder).join();

  try {
    final exitCode = await process.exitCode.timeout(timeout);
    return ProcessResult(
      process.pid,
      exitCode,
      await stdoutFuture,
      await stderrFuture,
    );
  } on TimeoutException {
    process.kill(ProcessSignal.sigkill);
    await process.exitCode;
    await stdoutFuture;
    await stderrFuture;
    throw SeekerException(
      '$executable did not finish within ${timeout.inSeconds}s.',
    );
  }
}

int? _readPid(String path) {
  final value = readStateFile(path);
  if (value == null) {
    return null;
  }

  final pid = int.tryParse(value);
  return pid != null && pid > 0 ? pid : null;
}

String _shellQuote(String value) => "'${value.replaceAll("'", r"'\''")}'";

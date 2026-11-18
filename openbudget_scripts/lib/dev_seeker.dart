import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:openbudget_scripts/dev_server_host.dart';

/// Exit code for a command that was used incorrectly.
const int seekerUsageExitCode = 64;

/// Environment override for the startup grace period, in milliseconds.
///
/// The default is 20 seconds. Tests set a smaller value so executable coverage
/// does not have to wait for the real grace period.
const String seekerStartupGraceEnv = 'SEEKER_STARTUP_GRACE_MS';

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
/// than a direct network route. [openUsbForward] reports whether this call
/// created the rule, so a preexisting mapping is never claimed or removed.
Future<SeekerEndpoint> chooseSeekerEndpoint({
  required int apiPort,
  required Iterable<Uri> candidates,
  required Future<bool> Function(Uri url) canReachFromDevice,
  required Future<bool> Function(int port) openUsbForward,
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

  final created = await openUsbForward(apiPort);
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
    if (created) {
      await closeUsbForward(apiPort);
    }
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
  String get deviceSerialFile => '$logDirectory/seeker-device';
  String get reverseForwardsFile => '$logDirectory/seeker-reverse-forwards';
  String get lockFile => '$logDirectory/seeker.lock';
  String get activeFlag => '$root/.tmp/dev-seeker.active';
  String get generatedEnv => '$root/.tmp/flutter.env';
  String get appDirectory => '$root/openbudget_app';
}

/// A process this tool started, including the identity needed to verify it
/// before signalling.
///
/// [token] is unique to one launch and appears in the process command line.
/// [startedAt] is the process start time reported by `ps`, so a reused PID is
/// never mistaken for the original process.
class SeekerProcessRecord {
  const SeekerProcessRecord({
    required this.pid,
    required this.startedAt,
    required this.token,
  });

  final int pid;
  final String startedAt;
  final String token;

  String encode() => jsonEncode({
    'pid': pid,
    'startedAt': startedAt,
    'token': token,
  });

  static SeekerProcessRecord? decode(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(value);
      if (decoded is! Map<String, Object?>) {
        return null;
      }

      final pid = decoded['pid'];
      final startedAt = decoded['startedAt'];
      final token = decoded['token'];
      if (pid is! int ||
          pid <= 0 ||
          startedAt is! String ||
          startedAt.isEmpty ||
          token is! String ||
          token.isEmpty) {
        return null;
      }

      return SeekerProcessRecord(
        pid: pid,
        startedAt: startedAt,
        token: token,
      );
    } on FormatException {
      return null;
    }
  }

  static SeekerProcessRecord? read(String path) => decode(readStateFile(path));

  void write(String path) => writeStateFile(path, encode());
}

/// Snapshot of the PID files and what those processes are actually running.
class SeekerState {
  const SeekerState({
    this.runner,
    this.runnerCommand,
    this.runnerStartVerified = true,
    this.holder,
    this.holderCommand,
    this.holderStartVerified = true,
  });

  final SeekerProcessRecord? runner;
  final String? runnerCommand;
  final bool runnerStartVerified;
  final SeekerProcessRecord? holder;
  final String? holderCommand;
  final bool holderStartVerified;

  int? get runnerPid => runner?.pid;
  int? get holderPid => holder?.pid;

  bool get hasRunner =>
      runner != null &&
      runnerStartVerified &&
      runnerCommand != null &&
      isSeekerRunnerCommand(runnerCommand!, ownerToken: runner!.token);

  bool get hasHolder =>
      holder != null &&
      holderStartVerified &&
      holderCommand != null &&
      isSeekerFifoHolderCommand(holderCommand!, ownerToken: holder!.token);
}

typedef ProcessCommandLookup = Future<String?> Function(int pid);
typedef ProcessStartLookup = Future<String?> Function(int pid);

/// Whether [command] is the Flutter runner this tool started for [ownerToken].
bool isSeekerRunnerCommand(String command, {required String ownerToken}) =>
    ownerToken.isNotEmpty &&
    command.contains('main_dev.dart') &&
    command.contains('flutter') &&
    command.contains(ownerToken);

/// Whether [command] is the FIFO holder this tool started for [ownerToken].
bool isSeekerFifoHolderCommand(String command, {required String ownerToken}) =>
    ownerToken.isNotEmpty &&
    command.contains('openbudget-seeker-fifo-holder') &&
    command.contains(ownerToken);

/// Reads both PID files and verifies each process against its recorded
/// command token and start time.
Future<SeekerState> readSeekerState(
  SeekerPaths paths, {
  ProcessCommandLookup? commandForPid,
  ProcessStartLookup? startForPid,
}) async {
  final lookupCommand = commandForPid ?? processCommand;
  final lookupStart = startForPid ?? processStartTime;
  final runner = SeekerProcessRecord.read(paths.flutterPid);
  final holder = SeekerProcessRecord.read(paths.fifoHolderPid);
  final runnerStart = runner == null ? null : await lookupStart(runner.pid);
  final holderStart = holder == null ? null : await lookupStart(holder.pid);

  return SeekerState(
    runner: runner,
    runnerCommand: runner == null ? null : await lookupCommand(runner.pid),
    runnerStartVerified: runner != null && runnerStart == runner.startedAt,
    holder: holder,
    holderCommand: holder == null ? null : await lookupCommand(holder.pid),
    holderStartVerified: holder != null && holderStart == holder.startedAt,
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
/// recorded command token and start time prove it is the holder this tool
/// created.
Future<StaleCleanup> removeStaleSeekerState(
  SeekerPaths paths, {
  required SeekerState state,
  Future<bool> Function(SeekerProcessRecord record)? stopProcess,
}) async {
  if (state.hasRunner) {
    return const StaleCleanup(removedPaths: [], stoppedHolderPid: null);
  }

  final stop = stopProcess ?? stopSeekerProcess;
  int? stoppedHolderPid;
  if (state.hasHolder) {
    if (await stop(state.holder!)) {
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

/// Stops [record] only when its command token and start time still match.
///
/// This is the guard against a stale PID file pointing at an unrelated process
/// after the operating system reused the number.
Future<bool> stopSeekerProcess(
  SeekerProcessRecord record, {
  ProcessCommandLookup? commandForPid,
  ProcessStartLookup? startForPid,
  Future<void> Function(int pid)? terminate,
}) async {
  final lookupCommand = commandForPid ?? processCommand;
  final lookupStart = startForPid ?? processStartTime;

  Future<bool> stillOwned() async {
    if (await lookupStart(record.pid) != record.startedAt) {
      return false;
    }

    final command = await lookupCommand(record.pid);
    if (command == null) {
      return false;
    }

    return isSeekerRunnerCommand(command, ownerToken: record.token) ||
        isSeekerFifoHolderCommand(command, ownerToken: record.token);
  }

  if (!await stillOwned()) {
    return false;
  }

  await (terminate ?? (pid) => terminateProcess(pid, stillOwned: stillOwned))(
    record.pid,
  );
  return true;
}

/// Sends SIGTERM, waits for [grace], then sends SIGKILL.
///
/// [stillOwned] is checked again before each signal so a process that exited
/// and had its PID reused is never killed by the escalation.
Future<void> terminateProcess(
  int pid, {
  Duration grace = const Duration(seconds: 5),
  Future<bool> Function()? stillOwned,
}) async {
  if (!await isProcessAlive(pid)) {
    return;
  }

  if (stillOwned != null && !await stillOwned()) {
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

  if (!await isProcessAlive(pid)) {
    return;
  }

  if (stillOwned != null && !await stillOwned()) {
    return;
  }

  Process.killPid(pid, ProcessSignal.sigkill);
  final killDeadline = DateTime.now().add(const Duration(seconds: 2));
  while (DateTime.now().isBefore(killDeadline)) {
    if (!await isProcessAlive(pid)) {
      return;
    }

    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
}

/// Whether [pid] currently exists and is not a zombie.
Future<bool> isProcessAlive(int pid) async {
  try {
    final result = await runCommand('ps', ['-p', '$pid', '-o', 'stat=']);
    if (result.exitCode != 0) {
      return false;
    }

    final state = (result.stdout as String).trim();
    return state.isNotEmpty && !state.startsWith('Z');
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

/// Returns the process start time for [pid], or `null` when it is gone.
Future<String?> processStartTime(int pid) async {
  try {
    final result = await runCommand('ps', ['-p', '$pid', '-o', 'lstart=']);
    if (result.exitCode != 0) {
      return null;
    }

    final startedAt = (result.stdout as String).trim();
    return startedAt.isEmpty ? null : startedAt;
  } on SeekerException {
    return null;
  }
}

/// Serializes start, stop, and restart for one checkout.
///
/// The lock lives under the checkout's `.devlogs` directory, so it never
/// blocks another worktree. Status, reload, and signal do not take it.
class SeekerLock {
  SeekerLock._(this._file);

  final RandomAccessFile _file;

  static Future<SeekerLock> acquire(SeekerPaths paths) async {
    await Directory(paths.logDirectory).create(recursive: true);
    final file = await File(paths.lockFile).open(mode: FileMode.append);
    try {
      await file.lock(FileLock.blockingExclusive);
    } on Object catch (error) {
      await file.close();
      throw SeekerException(
        'Could not lock ${paths.lockFile}: $error',
      );
    }

    return SeekerLock._(file);
  }

  Future<void> release() async {
    await _file.unlock();
    await _file.close();
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

/// One adb reverse rule owned by this checkout.
class ReverseForward {
  const ReverseForward({
    required this.serial,
    required this.devicePort,
    required this.hostPort,
  });

  final String serial;
  final int devicePort;
  final int hostPort;

  String get deviceSpec => 'tcp:$devicePort';
  String get hostSpec => 'tcp:$hostPort';
  String get line => '$serial $deviceSpec $hostSpec';

  @override
  String toString() => line;
}

/// The result of ensuring one adb reverse rule exists.
class UsbForward {
  const UsbForward({required this.forward, required this.created});

  final ReverseForward forward;
  final bool created;
}

/// Parses `adb reverse --list` output for [serial].
List<ReverseForward> parseReverseForwardList(
  String output, {
  required String serial,
}) {
  final forwards = <ReverseForward>[];
  final pattern = RegExp(r'tcp:(\d+)\s+tcp:(\d+)');

  for (final line in const LineSplitter().convert(output)) {
    final matches = pattern.allMatches(line).toList(growable: false);
    if (matches.isEmpty) {
      continue;
    }

    final match = matches.last;
    forwards.add(
      ReverseForward(
        serial: serial,
        devicePort: int.parse(match.group(1)!),
        hostPort: int.parse(match.group(2)!),
      ),
    );
  }

  return forwards;
}

/// Lists the adb reverse rules currently active on [device].
Future<List<ReverseForward>> listUsbForwards(AdbDevice device) async {
  final result = await runCommand('adb', [
    '-s',
    device.serial,
    'reverse',
    '--list',
  ]);
  if (result.exitCode != 0) {
    throw SeekerException(
      'adb reverse --list failed: ${(result.stderr as String).trim()}',
    );
  }

  return parseReverseForwardList(
    result.stdout as String,
    serial: device.serial,
  );
}

/// Ensures [port] is forwarded on [device] without overwriting another rule.
///
/// An identical preexisting mapping is reused and reported as not created.
/// A different mapping for the same device port fails clearly instead of being
/// replaced. `--no-rebind` closes the race between the list and the add.
Future<UsbForward> ensureUsbForward({
  required AdbDevice device,
  required int port,
}) async {
  final wanted = ReverseForward(
    serial: device.serial,
    devicePort: port,
    hostPort: port,
  );
  final existing = await listUsbForwards(device);

  for (final forward in existing) {
    if (forward.devicePort != port) {
      continue;
    }

    if (forward.hostPort == port) {
      return UsbForward(forward: forward, created: false);
    }

    throw SeekerException(
      'adb reverse ${wanted.deviceSpec} on ${device.serial} already maps to '
      '${forward.hostSpec}. Remove that rule before starting dev:seeker.',
    );
  }

  final result = await runCommand('adb', [
    '-s',
    device.serial,
    'reverse',
    '--no-rebind',
    wanted.deviceSpec,
    wanted.hostSpec,
  ]);
  if (result.exitCode != 0) {
    final after = await listUsbForwards(device);
    for (final forward in after) {
      if (forward.devicePort != port) {
        continue;
      }

      if (forward.hostPort == port) {
        return UsbForward(forward: forward, created: false);
      }

      throw SeekerException(
        'adb reverse ${wanted.deviceSpec} on ${device.serial} already maps to '
        '${forward.hostSpec}. Remove that rule before starting dev:seeker.',
      );
    }

    throw SeekerException(
      'adb reverse ${wanted.deviceSpec} failed: '
      '${(result.stderr as String).trim()}',
    );
  }

  return UsbForward(forward: wanted, created: true);
}

/// Removes [forward] only when the device still has that exact mapping.
///
/// Returns `true` when the rule is gone. A mapping that changed since it was
/// recorded is left alone and reported as an error so the record is preserved.
Future<bool> removeUsbForward({
  required AdbDevice device,
  required ReverseForward forward,
}) async {
  if (forward.serial != device.serial) {
    throw SeekerException(
      'Refusing to remove ${forward.deviceSpec} recorded for '
      '${forward.serial} from ${device.serial}.',
    );
  }

  final existing = await listUsbForwards(device);
  final matching = existing
      .where((candidate) => candidate.devicePort == forward.devicePort)
      .toList(growable: false);
  if (matching.isEmpty) {
    return true;
  }

  for (final candidate in matching) {
    if (candidate.hostPort != forward.hostPort) {
      throw SeekerException(
        'adb reverse ${forward.deviceSpec} on ${device.serial} now maps to '
        '${candidate.hostSpec}; leaving it alone.',
      );
    }
  }

  final result = await runCommand('adb', [
    '-s',
    device.serial,
    'reverse',
    '--remove',
    forward.deviceSpec,
  ]);
  if (result.exitCode != 0) {
    throw SeekerException(
      'adb reverse --remove ${forward.deviceSpec} failed: '
      '${(result.stderr as String).trim()}',
    );
  }

  return true;
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

/// The processes created by one [launchFlutter] call.
class SeekerLaunch {
  const SeekerLaunch({required this.runner, required this.holder});

  final SeekerProcessRecord runner;
  final SeekerProcessRecord holder;
}

/// Starts the Flutter runner behind a FIFO and returns its identity.
///
/// The log is truncated on each launch so a failure reports the current run,
/// not output from an older one.
Future<SeekerLaunch> launchFlutter({
  required SeekerPaths paths,
  required AdbDevice device,
  required Uri apiUrl,
}) async {
  await Directory(paths.logDirectory).create(recursive: true);
  removeIfExists(paths.controlFifo);

  final token = _newOwnerToken();
  final fifo = await runCommand('mkfifo', [paths.controlFifo]);
  if (fifo.exitCode != 0) {
    throw SeekerException(
      'Could not create ${paths.controlFifo}: '
      '${(fifo.stderr as String).trim()}',
    );
  }

  final holder = await _startDetached('bash', [
    '-c',
    r'exec -a "openbudget-seeker-fifo-holder:$1" /bin/sleep 1000000 > "$2"',
    'bash',
    token,
    paths.controlFifo,
  ]);
  final holderRecord = SeekerProcessRecord(
    pid: holder.pid,
    startedAt: await _startedAtOrKill(holder, label: 'FIFO holder'),
    token: token,
  )..write(paths.fifoHolderPid);

  const command =
      r'exec flutter run --flavor dev -t lib/main_dev.dart -d "$1" '
      r'--dart-define="OPENBUDGET_API_URL=$2" '
      r'--dart-define="API_URL=$2" '
      r'--dart-define="SEEKER_OWNER_TOKEN=$5" < "$3" > "$4" 2>&1';
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
      token,
    ],
    workingDirectory: paths.appDirectory,
  );
  final runnerRecord = SeekerProcessRecord(
    pid: process.pid,
    startedAt: await _startedAtOrKill(
      process,
      label: 'Flutter runner',
      logPath: paths.flutterLog,
    ),
    token: token,
  )..write(paths.flutterPid);
  return SeekerLaunch(runner: runnerRecord, holder: holderRecord);
}

Future<String> _startedAtOrKill(
  Process process, {
  required String label,
  String? logPath,
}) async {
  try {
    return await _requireProcessStart(
      process.pid,
      label: label,
      logPath: logPath,
    );
  } on SeekerException {
    process.kill(ProcessSignal.sigkill);
    rethrow;
  }
}

Future<String> _requireProcessStart(
  int pid, {
  required String label,
  String? logPath,
}) async {
  for (var attempt = 0; attempt < 10; attempt++) {
    final startedAt = await processStartTime(pid);
    if (startedAt != null) {
      return startedAt;
    }

    if (!await isProcessAlive(pid)) {
      break;
    }

    await Future<void>.delayed(const Duration(milliseconds: 50));
  }

  final log = logPath == null ? '' : '\n\n${_logTail(logPath)}';
  throw SeekerException('$label exited before it could be tracked.$log');
}

String _logTail(String path) {
  final file = File(path);
  if (!file.existsSync()) {
    return '';
  }

  return tailLines(file.readAsStringSync(), 20);
}

String _newOwnerToken() {
  final random = Random.secure().nextInt(1 << 32).toRadixString(16);
  final now = DateTime.now().microsecondsSinceEpoch.toRadixString(16);
  return '$now-$random';
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

  return !await alive(pid);
}

/// The grace period before a new runner is considered healthy.
Duration seekerStartupGrace() {
  final milliseconds = int.tryParse(
    Platform.environment[seekerStartupGraceEnv] ?? '',
  );
  if (milliseconds == null || milliseconds <= 0) {
    return const Duration(seconds: 20);
  }

  return Duration(milliseconds: milliseconds);
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

/// Whether [host] points back at this machine.
bool isLoopbackApiHost(String host) =>
    host == 'localhost' ||
    host == '::1' ||
    host == '127.0.0.1' ||
    host.startsWith('127.');

/// Parses an explicit API URL, rejecting unsupported schemes and malformed
/// values.
Uri? parseExplicitApiUrl(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }

  final uri = Uri.tryParse(trimmed);
  if (uri == null ||
      !uri.hasScheme ||
      uri.host.isEmpty ||
      (uri.scheme != 'http' && uri.scheme != 'https')) {
    throw const SeekerException(
      'OPENBUDGET_API_URL must be an http or https URL.',
      exitCode: seekerUsageExitCode,
    );
  }

  return uri;
}

/// Reads the explicit API URL, rejecting a malformed override.
Uri? explicitApiUrl() =>
    parseExplicitApiUrl(Platform.environment['OPENBUDGET_API_URL']);

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

/// Reverse rules recorded by this checkout.
List<ReverseForward> readReverseForwards(SeekerPaths paths) {
  final value = readStateFile(paths.reverseForwardsFile);
  if (value == null || value.isEmpty) {
    return [];
  }

  final forwards = <ReverseForward>[];
  final pattern = RegExp(r'^(\S+)\s+tcp:(\d+)\s+tcp:(\d+)$');
  for (final line in const LineSplitter().convert(value)) {
    final match = pattern.firstMatch(line.trim());
    if (match == null) {
      continue;
    }

    forwards.add(
      ReverseForward(
        serial: match.group(1)!,
        devicePort: int.parse(match.group(2)!),
        hostPort: int.parse(match.group(3)!),
      ),
    );
  }

  return forwards;
}

/// Records [forward] so cleanup removes only a rule this checkout created.
void recordReverseForward(SeekerPaths paths, ReverseForward forward) {
  final forwards = readReverseForwards(paths)
    ..removeWhere(
      (candidate) =>
          candidate.serial == forward.serial &&
          candidate.devicePort == forward.devicePort,
    )
    ..add(forward)
    ..sort((a, b) {
      final bySerial = a.serial.compareTo(b.serial);
      return bySerial != 0 ? bySerial : a.devicePort.compareTo(b.devicePort);
    });
  writeStateFile(
    paths.reverseForwardsFile,
    forwards.map((candidate) => candidate.line).join('\n'),
  );
}

/// Forgets a recorded reverse rule after it has been removed.
void forgetReverseForward(SeekerPaths paths, ReverseForward forward) {
  final forwards = readReverseForwards(paths)
    ..removeWhere(
      (candidate) =>
          candidate.serial == forward.serial &&
          candidate.devicePort == forward.devicePort &&
          candidate.hostPort == forward.hostPort,
    );
  if (forwards.isEmpty) {
    removeIfExists(paths.reverseForwardsFile);
    return;
  }

  writeStateFile(
    paths.reverseForwardsFile,
    forwards.map((candidate) => candidate.line).join('\n'),
  );
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

String _shellQuote(String value) => "'${value.replaceAll("'", r"'\''")}'";

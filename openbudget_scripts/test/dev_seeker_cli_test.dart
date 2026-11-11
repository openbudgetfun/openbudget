import 'dart:convert';
import 'dart:io';

import 'package:openbudget_scripts/dev_seeker.dart';
import 'package:test/test.dart';

void main() {
  group('dev_seeker CLI', () {
    test('stop without an owned runner is harmless', () async {
      final fixture = await SeekerCliFixture.create();
      addTearDown(fixture.dispose);

      const command =
          'exec -a "flutter run -t lib/main_dev.dart '
          '--dart-define=SEEKER_OWNER_TOKEN=other" /bin/sleep 30';
      final unrelated = await Process.start('bash', ['-c', command]);
      addTearDown(() async {
        unrelated.kill();
        await unrelated.exitCode;
      });
      final startedAt = await processStartTime(unrelated.pid);
      expect(startedAt, isNotNull);

      SeekerProcessRecord(
        pid: unrelated.pid,
        startedAt: startedAt!,
        token: 'this-checkout-token',
      ).write(fixture.paths.flutterPid);
      writeStateFile(fixture.paths.deviceSerialFile, fixture.serial);

      final result = await fixture.run(['stop']);

      expect(result.exitCode, 0, reason: _combined(result));
      expect(await isProcessAlive(unrelated.pid), isTrue);
      expect(
        fixture.adbLog.readAsStringSync(),
        isNot(contains('force-stop')),
      );
      expect(
        fixture.adbLog.readAsStringSync(),
        isNot(contains('reverse --remove')),
      );
      expect(File(fixture.paths.flutterPid).existsSync(), isFalse);
    });

    test('keeps a forward recorded for another device', () async {
      final fixture = await SeekerCliFixture.create();
      addTearDown(fixture.dispose);
      recordReverseForward(
        fixture.paths,
        const ReverseForward(
          serial: 'OTHER-SERIAL',
          devicePort: 8080,
          hostPort: 8080,
        ),
      );
      writeStateFile(fixture.paths.deviceSerialFile, fixture.serial);

      final result = await fixture.run(['stop']);

      expect(result.exitCode, 0, reason: _combined(result));
      expect(_combined(result), contains('Kept USB forward records'));
      expect(
        readReverseForwards(fixture.paths).map((forward) => forward.line),
        ['OTHER-SERIAL tcp:8080 tcp:8080'],
      );
      expect(
        fixture.adbLog.readAsStringSync(),
        isNot(contains('reverse --remove')),
      );
    });

    test('reuses a preexisting identical forward and preserves it', () async {
      final fixture = await SeekerCliFixture.create();
      addTearDown(fixture.dispose);
      final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(server.close);
      fixture.writeGeneratedPort(server.port);
      writeStateFile(
        fixture.adbState.path,
        'tcp:${server.port} tcp:${server.port}\n',
      );

      final result = await fixture.run(
        ['start'],
        overrides: const {
          'FAKE_ADB_DIRECT_PROBE_EXIT': '1',
          seekerStartupGraceEnv: '400',
        },
      );

      expect(result.exitCode, 0, reason: _combined(result));
      expect(fixture.launchCount, 1);
      expect(
        fixture.adbLog.readAsStringSync(),
        isNot(contains('--no-rebind')),
      );
      expect(File(fixture.paths.reverseForwardsFile).existsSync(), isFalse);

      final runner = SeekerProcessRecord.read(fixture.paths.flutterPid);
      expect(runner, isNotNull);
      final stop = await fixture.run(['stop']);
      expect(stop.exitCode, 0, reason: _combined(stop));
      expect(await isProcessAlive(runner!.pid), isFalse);
      expect(
        fixture.adbLog.readAsStringSync(),
        isNot(contains('reverse --remove')),
      );
      expect(
        fixture.adbState.readAsStringSync(),
        contains('tcp:${server.port} tcp:${server.port}'),
      );
    });

    test(
      'fails clearly on a conflicting forward without overwriting it',
      () async {
        final fixture = await SeekerCliFixture.create();
        addTearDown(fixture.dispose);
        final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
        addTearDown(server.close);
        fixture.writeGeneratedPort(server.port);
        writeStateFile(
          fixture.adbState.path,
          'tcp:${server.port} tcp:9999\n',
        );

        final result = await fixture.run(
          ['start'],
          overrides: const {
            'FAKE_ADB_DIRECT_PROBE_EXIT': '1',
            seekerStartupGraceEnv: '400',
          },
        );

        expect(result.exitCode, isNot(0));
        expect(_combined(result), contains('already maps to'));
        expect(
          fixture.adbLog.readAsStringSync(),
          isNot(contains('--no-rebind')),
        );
        expect(
          fixture.adbState.readAsStringSync(),
          'tcp:${server.port} tcp:9999\n',
        );
        expect(File(fixture.paths.reverseForwardsFile).existsSync(), isFalse);
        expect(File(fixture.paths.flutterPid).existsSync(), isFalse);
        expect(File(fixture.paths.fifoHolderPid).existsSync(), isFalse);
        expect(fixture.launchCount, 0);
      },
    );

    test(
      'cleans an owned runner, holder, and forward after a startup failure',
      () async {
        final fixture = await SeekerCliFixture.create();
        addTearDown(fixture.dispose);
        final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
        addTearDown(server.close);
        fixture.writeGeneratedPort(server.port);

        final result = await fixture.run(
          ['start'],
          overrides: const {
            'FAKE_ADB_DIRECT_PROBE_EXIT': '1',
            'FAKE_FLUTTER_FAIL': 'boom: build failed',
            seekerStartupGraceEnv: '400',
          },
        );

        expect(result.exitCode, isNot(0));
        expect(
          _combined(result),
          contains('Flutter exited before the app started'),
        );
        final adbLog = fixture.adbLog.readAsStringSync();
        expect(
          adbLog,
          contains(
            'reverse --no-rebind tcp:${server.port} tcp:${server.port}',
          ),
        );
        expect(adbLog, contains('reverse --remove tcp:${server.port}'));
        expect(File(fixture.paths.reverseForwardsFile).existsSync(), isFalse);
        expect(File(fixture.paths.flutterPid).existsSync(), isFalse);
        expect(File(fixture.paths.fifoHolderPid).existsSync(), isFalse);
        expect(File(fixture.paths.controlFifo).existsSync(), isFalse);
        expect(File(fixture.paths.activeFlag).existsSync(), isFalse);
        expect(File(fixture.paths.deviceSerialFile).existsSync(), isFalse);
        expect(fixture.launchCount, 1);
        expect(
          await isProcessAlive(
            int.parse(fixture.flutterPidFile.readAsStringSync().trim()),
          ),
          isFalse,
        );
      },
    );

    test('serializes concurrent starts and launches one runner', () async {
      final fixture = await SeekerCliFixture.create();
      addTearDown(fixture.dispose);
      const overrides = {
        'OPENBUDGET_API_URL': 'http://100.64.0.9:9000/',
        seekerStartupGraceEnv: '400',
      };

      final results = await Future.wait([
        fixture.run(['start'], overrides: overrides),
        fixture.run(['start'], overrides: overrides),
      ]).timeout(const Duration(seconds: 60));

      for (final result in results) {
        expect(result.exitCode, 0, reason: _combined(result));
      }

      final output = results.map(_combined).join('\n');
      expect(output, contains('Seeker dev environment is starting.'));
      expect(output, contains('already running'));
      expect(output, isNot(contains('Waiting for Serverpod')));
      expect(fixture.launchCount, 1);

      final runner = SeekerProcessRecord.read(fixture.paths.flutterPid);
      expect(runner, isNotNull);
      final stop = await fixture.run(['stop'], overrides: overrides);
      expect(stop.exitCode, 0, reason: _combined(stop));
      expect(await isProcessAlive(runner!.pid), isFalse);
    });
  });
}

class SeekerCliFixture {
  SeekerCliFixture._({
    required this.root,
    required this.bin,
    required this.paths,
    required this.serial,
    required this.adbLog,
    required this.adbState,
    required this.events,
    required this.launches,
    required this.flutterPidFile,
  });

  final Directory root;
  final Directory bin;
  final SeekerPaths paths;
  final String serial;
  final File adbLog;
  final File adbState;
  final File events;
  final File launches;
  final File flutterPidFile;

  int get launchCount => launches.existsSync()
      ? const LineSplitter()
            .convert(launches.readAsStringSync())
            .where((line) => line.isNotEmpty)
            .length
      : 0;

  static Future<SeekerCliFixture> create({
    String serial = 'TEST-SERIAL',
  }) async {
    final root = await Directory.systemTemp.createTemp('dev-seeker-cli-');
    final bin = Directory('${root.path}/fake-bin')..createSync();
    final paths = SeekerPaths(root.path);
    Directory(paths.logDirectory).createSync(recursive: true);
    Directory(paths.appDirectory).createSync(recursive: true);
    final adbLog = File('${root.path}/adb.log')..createSync();
    final adbState = File('${root.path}/adb-state')..createSync();
    final events = File('${root.path}/events.log')..createSync();
    final launches = File('${root.path}/launches.log')..createSync();
    final flutterPidFile = File('${root.path}/flutter.pid');

    await _writeScript(bin, 'adb', _adbScript);
    await _writeScript(bin, 'start:up', _startUpScript);
    await _writeScript(bin, 'flutter', _flutterScript);

    return SeekerCliFixture._(
      root: root,
      bin: bin,
      paths: paths,
      serial: serial,
      adbLog: adbLog,
      adbState: adbState,
      events: events,
      launches: launches,
      flutterPidFile: flutterPidFile,
    );
  }

  void writeGeneratedPort(int port) {
    writeStateFile(
      paths.generatedEnv,
      'OPENBUDGET_API_URL="http://192.168.1.2:$port/"',
    );
  }

  Future<ProcessResult> run(
    List<String> arguments, {
    Map<String, String>? overrides,
  }) => Process.run(
    Platform.resolvedExecutable,
    ['run', 'bin/dev_seeker.dart', ...arguments],
    workingDirectory: Directory.current.path,
    environment: _environment(overrides),
  );

  Map<String, String> _environment(Map<String, String>? overrides) {
    final environment = Map<String, String>.of(Platform.environment)
      ..remove('OPENBUDGET_API_URL')
      ..remove('SEEKER_DEVICE_ID')
      ..remove(seekerStartupGraceEnv)
      ..addAll({
        'DEVENV_ROOT': root.path,
        'PATH': '${bin.path}:${Platform.environment['PATH'] ?? ''}',
        'FAKE_ADB_LOG': adbLog.path,
        'FAKE_ADB_STATE': adbState.path,
        'FAKE_ADB_SERIAL': serial,
        'FAKE_EVENTS': events.path,
        'FAKE_LAUNCH_COUNT': launches.path,
        'FAKE_FLUTTER_PID': flutterPidFile.path,
        'FAKE_FLUTTER_SLEEP': '30',
      });
    if (overrides != null) {
      environment.addAll(overrides);
    }

    return environment;
  }

  Future<void> dispose() async {
    for (final path in [paths.flutterPid, paths.fifoHolderPid]) {
      final record = SeekerProcessRecord.read(path);
      if (record != null) {
        Process.killPid(record.pid);
      }
    }
    await root.delete(recursive: true);
  }
}

Future<void> _writeScript(
  Directory bin,
  String name,
  String content,
) async {
  final file = File('${bin.path}/$name');
  await file.writeAsString(content);
  final chmod = await Process.run('chmod', ['+x', file.path]);
  if (chmod.exitCode != 0) {
    throw StateError('Could not chmod ${file.path}: ${chmod.stderr}');
  }
}

String _combined(ProcessResult result) =>
    '${result.stdout}${result.stderr}'.trim();

// The shebang must stay on the first line.
// ignore: leading_newlines_in_multiline_strings
const _adbScript = r'''#!/bin/bash
set -u
printf '%s\n' "$*" >> "$FAKE_ADB_LOG"
state="$FAKE_ADB_STATE"
case "${1:-}" in
  devices)
    printf 'List of devices attached\n%s device usb:1 product:seeker model:Seeker_Phone device:seeker\n' "$FAKE_ADB_SERIAL"
    exit 0
    ;;
  -s)
    shift 2
    case "${1:-}" in
      shell)
        command="${2:-}"
        if [[ "$command" == *"127.0.0.1"* ]]; then
          exit "${FAKE_ADB_USB_PROBE_EXIT:-0}"
        fi
        exit "${FAKE_ADB_DIRECT_PROBE_EXIT:-0}"
        ;;
      reverse)
        shift
        case "${1:-}" in
          --list)
            if [[ -f "$state" ]]; then
              cat "$state"
            fi
            exit 0
            ;;
          --no-rebind)
            printf '%s %s\n' "${2:-}" "${3:-}" >> "$state"
            exit 0
            ;;
          --remove)
            if [[ -f "$state" ]]; then
              tmp="$(mktemp)"
              grep -v "^${2:-} " "$state" > "$tmp" || true
              mv "$tmp" "$state"
            fi
            exit 0
            ;;
        esac
        ;;
    esac
    ;;
esac
exit 0
''';

// The shebang must stay on the first line.
// ignore: leading_newlines_in_multiline_strings
const _startUpScript = r'''#!/bin/bash
printf 'start:up\n' >> "$FAKE_EVENTS"
exit 0
''';

// The shebang must stay on the first line.
// ignore: leading_newlines_in_multiline_strings
const _flutterScript = r'''#!/bin/bash
printf 'launch\n' >> "$FAKE_LAUNCH_COUNT"
printf '%s\n' "$$" > "$FAKE_FLUTTER_PID"
if [[ -n "${FAKE_FLUTTER_FAIL:-}" ]]; then
  sleep 0.2
  printf '%s\n' "$FAKE_FLUTTER_FAIL" >&2
  exit 1
fi
sleep "${FAKE_FLUTTER_SLEEP:-30}"
''';

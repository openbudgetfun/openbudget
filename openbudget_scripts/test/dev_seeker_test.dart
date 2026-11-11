import 'dart:io';

import 'package:openbudget_scripts/dev_seeker.dart';
import 'package:test/test.dart';

void main() {
  group('parseAdbDevices', () {
    test('parses ready and unavailable devices from adb output', () {
      final devices = parseAdbDevices('''
List of devices attached
SM02E4060324957       device usb:1 product:seeker model:Seeker_Phone device:seeker transport_id:1
emulator-5554         offline
''');

      expect(devices, hasLength(2));
      expect(devices.first.serial, 'SM02E4060324957');
      expect(devices.first.state, 'device');
      expect(devices.first.model, 'Seeker Phone');
      expect(devices.first.isReady, isTrue);
      expect(devices.last.isReady, isFalse);
    });

    test('ignores the header and blank lines', () {
      expect(parseAdbDevices('\nList of devices attached\n\n'), isEmpty);
    });
  });

  group('selectSeekerDevice', () {
    test('returns the only ready device', () {
      final device = selectSeekerDevice(const [
        AdbDevice(serial: 'one', state: 'device'),
      ]);

      expect(device.serial, 'one');
    });

    test('honours the preferred serial', () {
      final device = selectSeekerDevice(
        const [
          AdbDevice(serial: 'one', state: 'device'),
          AdbDevice(serial: 'two', state: 'device'),
        ],
        preferredSerial: 'two',
      );

      expect(device.serial, 'two');
    });

    test('fails when no device is ready', () {
      expect(
        () => selectSeekerDevice(const []),
        throwsA(
          isA<SeekerException>().having(
            (error) => error.message,
            'message',
            contains('No ready Android device'),
          ),
        ),
      );
    });

    test('fails when more than one device is ready', () {
      expect(
        () => selectSeekerDevice(const [
          AdbDevice(serial: 'one', state: 'device'),
          AdbDevice(serial: 'two', state: 'device'),
        ]),
        throwsA(
          isA<SeekerException>().having(
            (error) => error.message,
            'message',
            contains('SEEKER_DEVICE_ID'),
          ),
        ),
      );
    });

    test('fails for a preferred serial that is not attached', () {
      expect(
        () => selectSeekerDevice(
          const [AdbDevice(serial: 'one', state: 'device')],
          preferredSerial: 'missing',
        ),
        throwsA(
          isA<SeekerException>().having(
            (error) => error.message,
            'message',
            contains('No Android device with serial missing'),
          ),
        ),
      );
    });
  });

  group('chooseSeekerEndpoint', () {
    test('preserves a reachable explicit URL', () async {
      final explicit = Uri.parse('http://100.64.0.9:9000/');
      var forwarded = false;

      final endpoint = await chooseSeekerEndpoint(
        apiPort: 8080,
        candidates: [_apiUrl('192.168.1.2')],
        explicitApiUrl: explicit,
        canReachFromDevice: (url) async => url == explicit,
        openUsbForward: (_) async {
          forwarded = true;
          return true;
        },
        closeUsbForward: (_) async {},
      );

      expect(endpoint.apiUrl, explicit);
      expect(endpoint.usedUsb, isFalse);
      expect(forwarded, isFalse);
    });

    test('rejects an explicit URL the device cannot reach', () async {
      final explicit = Uri.parse('http://100.64.0.9:9000/');
      var forwarded = false;

      await expectLater(
        chooseSeekerEndpoint(
          apiPort: 8080,
          candidates: [_apiUrl('192.168.1.2')],
          explicitApiUrl: explicit,
          canReachFromDevice: (_) async => false,
          openUsbForward: (_) async {
            forwarded = true;
            return true;
          },
          closeUsbForward: (_) async {},
        ),
        throwsA(
          isA<SeekerException>().having(
            (error) => error.message,
            'message',
            contains('OPENBUDGET_API_URL'),
          ),
        ),
      );
      expect(forwarded, isFalse);
    });

    test(
      'tries Tailscale before LAN and keeps the first reachable URL',
      () async {
        final tailscale = _apiUrl('100.64.0.9');
        final lan = _apiUrl('192.168.1.2');
        final attempted = <Uri>[];

        final endpoint = await chooseSeekerEndpoint(
          apiPort: 8080,
          candidates: [tailscale, lan],
          canReachFromDevice: (url) async {
            attempted.add(url);
            return url == lan;
          },
          openUsbForward: (_) async => true,
          closeUsbForward: (_) async {},
        );

        expect(attempted, [tailscale, lan]);
        expect(endpoint.apiUrl, lan);
        expect(endpoint.usedUsb, isFalse);
      },
    );

    test('falls back to USB when no direct address is reachable', () async {
      final opened = <int>[];
      final closed = <int>[];

      final endpoint = await chooseSeekerEndpoint(
        apiPort: 8080,
        candidates: [_apiUrl('100.64.0.9'), _apiUrl('192.168.1.2')],
        canReachFromDevice: (url) async => url.host == '127.0.0.1',
        openUsbForward: (port) async {
          opened.add(port);
          return true;
        },
        closeUsbForward: (port) async => closed.add(port),
      );

      expect(opened, [8080]);
      expect(closed, isEmpty);
      expect(endpoint.apiUrl.toString(), 'http://127.0.0.1:8080/');
      expect(endpoint.usedUsb, isTrue);
    });

    test(
      'removes a created USB forward when the loopback probe fails',
      () async {
        final closed = <int>[];

        await expectLater(
          chooseSeekerEndpoint(
            apiPort: 8080,
            candidates: const [],
            canReachFromDevice: (_) async => false,
            openUsbForward: (_) async => true,
            closeUsbForward: (port) async => closed.add(port),
          ),
          throwsA(
            isA<SeekerException>().having(
              (error) => error.message,
              'message',
              contains('USB forwarding'),
            ),
          ),
        );
        expect(closed, [8080]);
      },
    );

    test('keeps a reused USB forward when the loopback probe fails', () async {
      final closed = <int>[];

      await expectLater(
        chooseSeekerEndpoint(
          apiPort: 8080,
          candidates: const [],
          canReachFromDevice: (_) async => false,
          openUsbForward: (_) async => false,
          closeUsbForward: (port) async => closed.add(port),
        ),
        throwsA(isA<SeekerException>()),
      );
      expect(closed, isEmpty);
    });

    test('probes each direct candidate once', () async {
      final candidate = _apiUrl('100.64.0.9');
      final attempted = <Uri>[];

      await chooseSeekerEndpoint(
        apiPort: 8080,
        candidates: [candidate, candidate],
        canReachFromDevice: (url) async {
          attempted.add(url);
          return url.host == '127.0.0.1';
        },
        openUsbForward: (_) async => true,
        closeUsbForward: (_) async {},
      );

      expect(attempted, [candidate, _apiUrl('127.0.0.1')]);
    });
  });

  group('candidateApiUrls', () {
    test('builds URLs in Tailscale-then-LAN order', () {
      expect(
        candidateApiUrls(['192.168.1.2', '100.64.0.9'], 8080),
        [
          Uri.parse('http://100.64.0.9:8080/'),
          Uri.parse('http://192.168.1.2:8080/'),
        ],
      );
    });
  });

  group('SeekerState', () {
    const token = 'owner-token-1';
    const runner = SeekerProcessRecord(
      pid: 101,
      startedAt: 'Wed Nov 11 12:00:00 2026',
      token: token,
    );

    test('recognises only the runner command for this launch token', () {
      expect(
        isSeekerRunnerCommand(
          '/nix/store/flutter/bin/dart --enable-vm-service run '
          '--flavor dev -t lib/main_dev.dart '
          '--dart-define=SEEKER_OWNER_TOKEN=$token',
          ownerToken: token,
        ),
        isTrue,
      );
      expect(
        isSeekerRunnerCommand(
          'flutter run -t lib/main_dev.dart '
          '--dart-define=SEEKER_OWNER_TOKEN=another-token',
          ownerToken: token,
        ),
        isFalse,
      );
      expect(
        isSeekerRunnerCommand(
          'flutter run -t lib/main_dev.dart',
          ownerToken: token,
        ),
        isFalse,
      );
      expect(
        isSeekerRunnerCommand('python3 unrelated.py', ownerToken: token),
        isFalse,
      );
    });

    test('recognises only the FIFO holder for this launch token', () {
      expect(
        isSeekerFifoHolderCommand(
          'openbudget-seeker-fifo-holder:$token 1000000',
          ownerToken: token,
        ),
        isTrue,
      );
      expect(
        isSeekerFifoHolderCommand(
          'openbudget-seeker-fifo-holder:another-token 1000000',
          ownerToken: token,
        ),
        isFalse,
      );
      expect(
        isSeekerFifoHolderCommand('sleep 1000000', ownerToken: token),
        isFalse,
      );
    });

    test('requires both the command token and the recorded start time', () {
      const state = SeekerState(
        runner: runner,
        runnerCommand:
            'flutter run -t lib/main_dev.dart '
            '--dart-define=SEEKER_OWNER_TOKEN=$token',
      );
      const reusedPid = SeekerState(
        runner: runner,
        runnerCommand:
            'flutter run -t lib/main_dev.dart '
            '--dart-define=SEEKER_OWNER_TOKEN=$token',
        runnerStartVerified: false,
      );

      expect(state.hasRunner, isTrue);
      expect(reusedPid.hasRunner, isFalse);
    });
  });

  group('state lifecycle', () {
    late Directory root;
    late SeekerPaths paths;
    const token = 'state-token';
    const runner = SeekerProcessRecord(
      pid: 101,
      startedAt: 'start-101',
      token: token,
    );
    const holder = SeekerProcessRecord(
      pid: 202,
      startedAt: 'start-202',
      token: token,
    );

    setUp(() async {
      root = await Directory.systemTemp.createTemp('dev-seeker-test-');
      paths = SeekerPaths(root.path);
      await Directory(paths.logDirectory).create(recursive: true);
    });

    tearDown(() async {
      await root.delete(recursive: true);
    });

    test('does not remove live runner state', () async {
      runner.write(paths.flutterPid);
      writeStateFile(paths.activeFlag, '101');
      writeStateFile(paths.deviceSerialFile, 'SERIAL-1');
      const state = SeekerState(
        runner: runner,
        runnerCommand:
            'flutter run -t lib/main_dev.dart '
            '--dart-define=SEEKER_OWNER_TOKEN=$token',
        holder: holder,
        holderCommand: 'openbudget-seeker-fifo-holder:$token 1000000',
      );

      final cleanup = await removeStaleSeekerState(
        paths,
        state: state,
        stopProcess: (_) async => false,
      );

      expect(cleanup.removedPaths, isEmpty);
      expect(File(paths.flutterPid).existsSync(), isTrue);
      expect(File(paths.activeFlag).existsSync(), isTrue);
      expect(File(paths.deviceSerialFile).existsSync(), isTrue);
    });

    test(
      'removes stale state and stops a verified FIFO holder while keeping the '
      'device serial',
      () async {
        const staleRunner = SeekerProcessRecord(
          pid: 101,
          startedAt: 'start-101',
          token: token,
        );
        staleRunner.write(paths.flutterPid);
        holder.write(paths.fifoHolderPid);
        writeStateFile(paths.activeFlag, '101');
        writeStateFile(paths.deviceSerialFile, 'SERIAL-1');
        await Process.run('mkfifo', [paths.controlFifo]);
        final stopped = <int>[];
        const state = SeekerState(
          runner: staleRunner,
          runnerCommand: 'python3 unrelated.py',
          holder: holder,
          holderCommand: 'openbudget-seeker-fifo-holder:$token 1000000',
        );

        final cleanup = await removeStaleSeekerState(
          paths,
          state: state,
          stopProcess: (record) async {
            stopped.add(record.pid);
            return true;
          },
        );

        expect(stopped, [202]);
        expect(cleanup.stoppedHolderPid, 202);
        expect(cleanup.removedPaths, isNotEmpty);
        expect(File(paths.flutterPid).existsSync(), isFalse);
        expect(File(paths.fifoHolderPid).existsSync(), isFalse);
        expect(File(paths.activeFlag).existsSync(), isFalse);
        expect(File(paths.deviceSerialFile).existsSync(), isTrue);
        expect(
          FileSystemEntity.typeSync(paths.controlFifo),
          FileSystemEntityType.notFound,
        );
      },
    );

    test('does not kill a reused PID', () async {
      var terminated = false;

      final stopped = await stopSeekerProcess(
        const SeekerProcessRecord(
          pid: 4242,
          startedAt: 'original-start',
          token: token,
        ),
        startForPid: (_) async => 'different-start',
        commandForPid: (_) async =>
            'flutter run -t lib/main_dev.dart '
            '--dart-define=SEEKER_OWNER_TOKEN=$token',
        terminate: (_) async {
          terminated = true;
        },
      );

      expect(stopped, isFalse);
      expect(terminated, isFalse);
    });

    test('does not kill a runner from another checkout token', () async {
      var terminated = false;

      final stopped = await stopSeekerProcess(
        const SeekerProcessRecord(
          pid: 4242,
          startedAt: 'start-4242',
          token: token,
        ),
        startForPid: (_) async => 'start-4242',
        commandForPid: (_) async =>
            'flutter run -t lib/main_dev.dart '
            '--dart-define=SEEKER_OWNER_TOKEN=other-token',
        terminate: (_) async {
          terminated = true;
        },
      );

      expect(stopped, isFalse);
      expect(terminated, isFalse);
    });

    test('stops a verified runner', () async {
      int? terminatedPid;

      final stopped = await stopSeekerProcess(
        const SeekerProcessRecord(
          pid: 4242,
          startedAt: 'start-4242',
          token: token,
        ),
        startForPid: (_) async => 'start-4242',
        commandForPid: (_) async =>
            'flutter run -t lib/main_dev.dart '
            '--dart-define=SEEKER_OWNER_TOKEN=$token',
        terminate: (pid) async {
          terminatedPid = pid;
        },
      );

      expect(stopped, isTrue);
      expect(terminatedPid, 4242);
    });

    test('reads PID files through the supplied lookups', () async {
      runner.write(paths.flutterPid);
      holder.write(paths.fifoHolderPid);

      final state = await readSeekerState(
        paths,
        commandForPid: (pid) async => pid == 101
            ? 'flutter run -t lib/main_dev.dart '
                  '--dart-define=SEEKER_OWNER_TOKEN=$token'
            : 'openbudget-seeker-fifo-holder:$token 1000000',
        startForPid: (pid) async => pid == 101 ? 'start-101' : 'start-202',
      );

      expect(state.hasRunner, isTrue);
      expect(state.hasHolder, isTrue);
    });

    test('rejects a process whose start time no longer matches', () async {
      runner.write(paths.flutterPid);

      final state = await readSeekerState(
        paths,
        commandForPid: (_) async =>
            'flutter run -t lib/main_dev.dart '
            '--dart-define=SEEKER_OWNER_TOKEN=$token',
        startForPid: (_) async => 'reused-start',
      );

      expect(state.hasRunner, isFalse);
    });
  });

  group('FIFO helpers', () {
    late Directory root;
    late SeekerPaths paths;

    setUp(() async {
      root = await Directory.systemTemp.createTemp('dev-seeker-fifo-test-');
      paths = SeekerPaths(root.path);
      await Directory(paths.logDirectory).create(recursive: true);
    });

    tearDown(() async {
      await root.delete(recursive: true);
    });

    test('identifies and removes a FIFO', () async {
      final mkfifo = await Process.run('mkfifo', [paths.controlFifo]);
      expect(mkfifo.exitCode, 0);
      expect(isFifo(paths.controlFifo), isTrue);
      expect(removeIfExists(paths.controlFifo), isTrue);
      expect(
        FileSystemEntity.typeSync(paths.controlFifo),
        FileSystemEntityType.notFound,
      );
    });

    test('removes a regular file and reports a missing path', () async {
      expect(removeIfExists(paths.controlFifo), isFalse);
      writeStateFile(paths.controlFifo, 'not a fifo');
      expect(removeIfExists(paths.controlFifo), isTrue);
    });
  });

  group('launch failures', () {
    test('returns null while the runner is still alive', () {
      expect(
        launchFailureFor(exited: false, log: 'still building', logPath: 'x'),
        isNull,
      );
    });

    test('reports the log tail after an early exit', () {
      final failure = launchFailureFor(
        exited: true,
        log: 'line one\nline two\nline three',
        logPath: '.devlogs/seeker-flutter.log',
      );

      expect(failure, contains('Flutter exited before the app started'));
      expect(failure, contains('.devlogs/seeker-flutter.log'));
      expect(failure, contains('line three'));
    });

    test('keeps only the newest lines', () {
      expect(tailLines('one\ntwo\nthree', 2), 'two\nthree');
      expect(tailLines('one', 2), 'one');
    });
  });

  group('state files', () {
    late Directory root;
    late SeekerPaths paths;

    setUp(() async {
      root = await Directory.systemTemp.createTemp('dev-seeker-file-test-');
      paths = SeekerPaths(root.path);
    });

    tearDown(() async {
      await root.delete(recursive: true);
    });

    test('reads the generated API URL', () async {
      writeStateFile(
        paths.generatedEnv,
        'OPENBUDGET_API_URL="http://100.64.0.9:8080/"',
      );

      expect(
        readGeneratedApiUrl(paths.generatedEnv).toString(),
        'http://100.64.0.9:8080/',
      );
    });

    test('round trips a process record', () {
      const record = SeekerProcessRecord(
        pid: 42,
        startedAt: 'Wed Nov 11 12:00:00 2026',
        token: 'abc-123',
      );
      record.write(paths.flutterPid);

      final decoded = SeekerProcessRecord.read(paths.flutterPid);

      expect(decoded?.pid, 42);
      expect(decoded?.startedAt, 'Wed Nov 11 12:00:00 2026');
      expect(decoded?.token, 'abc-123');
      expect(SeekerProcessRecord.decode('not json'), isNull);
    });

    test('records and forgets only its own reverse forwards', () {
      recordReverseForward(
        paths,
        const ReverseForward(
          serial: 'SERIAL-1',
          devicePort: 8081,
          hostPort: 8081,
        ),
      );
      recordReverseForward(
        paths,
        const ReverseForward(
          serial: 'SERIAL-1',
          devicePort: 8080,
          hostPort: 8080,
        ),
      );
      recordReverseForward(
        paths,
        const ReverseForward(
          serial: 'SERIAL-2',
          devicePort: 8080,
          hostPort: 8080,
        ),
      );

      expect(
        readReverseForwards(paths).map((forward) => forward.line),
        [
          'SERIAL-1 tcp:8080 tcp:8080',
          'SERIAL-1 tcp:8081 tcp:8081',
          'SERIAL-2 tcp:8080 tcp:8080',
        ],
      );

      forgetReverseForward(
        paths,
        const ReverseForward(
          serial: 'SERIAL-1',
          devicePort: 8081,
          hostPort: 8081,
        ),
      );
      expect(
        readReverseForwards(paths).map((forward) => forward.line),
        [
          'SERIAL-1 tcp:8080 tcp:8080',
          'SERIAL-2 tcp:8080 tcp:8080',
        ],
      );
    });

    test('parses adb reverse --list output', () {
      expect(
        parseReverseForwardList(
          'host-1 tcp:8080 tcp:8080\n'
          'tcp:9000 tcp:9001\n'
          'not a mapping\n',
          serial: 'SERIAL-1',
        ).map((forward) => forward.line),
        [
          'SERIAL-1 tcp:8080 tcp:8080',
          'SERIAL-1 tcp:9000 tcp:9001',
        ],
      );
    });

    test('uses the scheme default when a URL has no port', () {
      expect(portForUri(Uri.parse('http://example.test/')), 80);
      expect(portForUri(Uri.parse('https://example.test/')), 443);
      expect(portForUri(Uri.parse('http://example.test:9000/')), 9000);
    });
  });

  group('explicit API URL', () {
    test('accepts http and https URLs', () {
      expect(
        parseExplicitApiUrl(' http://100.64.0.9:8080/ ').toString(),
        'http://100.64.0.9:8080/',
      );
      expect(
        parseExplicitApiUrl('https://api.example.test/').toString(),
        'https://api.example.test/',
      );
    });

    test('returns null for an empty value', () {
      expect(parseExplicitApiUrl(null), isNull);
      expect(parseExplicitApiUrl('   '), isNull);
    });

    test('rejects unsupported schemes clearly', () {
      expect(
        () => parseExplicitApiUrl('ftp://100.64.0.9/'),
        throwsA(
          isA<SeekerException>()
              .having(
                (error) => error.exitCode,
                'exitCode',
                seekerUsageExitCode,
              )
              .having(
                (error) => error.message,
                'message',
                contains('http or https'),
              ),
        ),
      );
    });

    test('rejects a malformed value', () {
      expect(
        () => parseExplicitApiUrl('not-a-url'),
        throwsA(isA<SeekerException>()),
      );
    });

    test('recognises loopback hosts', () {
      expect(isLoopbackApiHost('127.0.0.1'), isTrue);
      expect(isLoopbackApiHost('127.1.2.3'), isTrue);
      expect(isLoopbackApiHost('localhost'), isTrue);
      expect(isLoopbackApiHost('::1'), isTrue);
      expect(isLoopbackApiHost('100.64.0.9'), isFalse);
    });
  });
}

Uri _apiUrl(String host) => Uri(
  scheme: 'http',
  host: host,
  port: 8080,
  path: '/',
);

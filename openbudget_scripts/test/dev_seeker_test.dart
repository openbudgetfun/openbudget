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
          openUsbForward: (_) async {},
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
        openUsbForward: (port) async => opened.add(port),
        closeUsbForward: (port) async => closed.add(port),
      );

      expect(opened, [8080]);
      expect(closed, isEmpty);
      expect(endpoint.apiUrl.toString(), 'http://127.0.0.1:8080/');
      expect(endpoint.usedUsb, isTrue);
    });

    test('removes the USB forward when the loopback probe fails', () async {
      final closed = <int>[];

      await expectLater(
        chooseSeekerEndpoint(
          apiPort: 8080,
          candidates: const [],
          canReachFromDevice: (_) async => false,
          openUsbForward: (_) async {},
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
        openUsbForward: (_) async {},
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
    test('recognises the runner and FIFO holder commands', () {
      expect(
        isSeekerRunnerCommand(
          '/nix/store/flutter/bin/dart --enable-vm-service run '
          '--flavor dev -t lib/main_dev.dart',
        ),
        isTrue,
      );
      expect(isSeekerRunnerCommand('python3 unrelated.py'), isFalse);
      expect(
        isSeekerFifoHolderCommand(
          'bash -c exec -a openbudget-seeker-fifo-holder sleep 1000000',
        ),
        isTrue,
      );
      expect(isSeekerFifoHolderCommand('sleep 1000000'), isFalse);
    });
  });

  group('state lifecycle', () {
    late Directory root;
    late SeekerPaths paths;

    setUp(() async {
      root = await Directory.systemTemp.createTemp('dev-seeker-test-');
      paths = SeekerPaths(root.path);
      await Directory(paths.logDirectory).create(recursive: true);
    });

    tearDown(() async {
      await root.delete(recursive: true);
    });

    test('does not remove live runner state', () async {
      writeStateFile(paths.flutterPid, '101');
      writeStateFile(paths.activeFlag, '101');
      const state = SeekerState(
        runnerPid: 101,
        runnerCommand: 'flutter run -t lib/main_dev.dart',
        holderPid: 202,
        holderCommand: 'openbudget-seeker-fifo-holder',
      );

      final cleanup = await removeStaleSeekerState(
        paths,
        state: state,
        stopProcess: (_) async => false,
      );

      expect(cleanup.removedPaths, isEmpty);
      expect(File(paths.flutterPid).existsSync(), isTrue);
      expect(File(paths.activeFlag).existsSync(), isTrue);
    });

    test('removes stale state and stops a verified FIFO holder', () async {
      writeStateFile(paths.flutterPid, '101');
      writeStateFile(paths.fifoHolderPid, '202');
      writeStateFile(paths.activeFlag, '101');
      await Process.run('mkfifo', [paths.controlFifo]);
      final stopped = <int>[];
      const state = SeekerState(
        runnerPid: 101,
        runnerCommand: 'python3 unrelated.py',
        holderPid: 202,
        holderCommand: 'openbudget-seeker-fifo-holder',
      );

      final cleanup = await removeStaleSeekerState(
        paths,
        state: state,
        stopProcess: (pid) async {
          stopped.add(pid);
          return true;
        },
      );

      expect(stopped, [202]);
      expect(cleanup.stoppedHolderPid, 202);
      expect(cleanup.removedPaths, isNotEmpty);
      expect(File(paths.flutterPid).existsSync(), isFalse);
      expect(File(paths.fifoHolderPid).existsSync(), isFalse);
      expect(File(paths.activeFlag).existsSync(), isFalse);
      expect(
        FileSystemEntity.typeSync(paths.controlFifo),
        FileSystemEntityType.notFound,
      );
    });

    test('does not kill a reused PID', () async {
      var terminated = false;

      final stopped = await stopSeekerProcess(
        4242,
        commandForPid: (_) async => 'python3 unrelated.py',
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
        4242,
        commandForPid: (_) async => 'flutter run -t lib/main_dev.dart',
        terminate: (pid) async {
          terminatedPid = pid;
        },
      );

      expect(stopped, isTrue);
      expect(terminatedPid, 4242);
    });

    test('reads PID files through the supplied command lookup', () async {
      writeStateFile(paths.flutterPid, '101');
      writeStateFile(paths.fifoHolderPid, '202');

      final state = await readSeekerState(
        paths,
        commandForPid: (pid) async => pid == 101
            ? 'flutter run -t lib/main_dev.dart'
            : 'openbudget-seeker-fifo-holder',
      );

      expect(state.hasRunner, isTrue);
      expect(state.hasHolder, isTrue);
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

    test('records and forgets only its own reverse ports', () async {
      recordReversePort(paths, 8081);
      recordReversePort(paths, 8080);

      expect(readReversePorts(paths), {8080, 8081});
      expect(readStateFile(paths.reversePortsFile), '8080 8081');

      forgetReversePort(paths, 8081);
      expect(readReversePorts(paths), {8080});
      expect(readStateFile(paths.reversePortsFile), '8080');

      forgetReversePort(paths, 8080);
      expect(readReversePorts(paths), isEmpty);
      expect(File(paths.reversePortsFile).existsSync(), isFalse);
    });

    test('uses the scheme default when a URL has no port', () {
      expect(portForUri(Uri.parse('http://example.test/')), 80);
      expect(portForUri(Uri.parse('https://example.test/')), 443);
      expect(portForUri(Uri.parse('http://example.test:9000/')), 9000);
    });
  });
}

Uri _apiUrl(String host) => Uri(
  scheme: 'http',
  host: host,
  port: 8080,
  path: '/',
);

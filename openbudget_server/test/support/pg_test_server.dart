import 'dart:io';

import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_test/serverpod_test.dart';

/// Minimal endpoint dispatch: database tests exercise services directly and
/// do not need the unfinished endpoint surface to compile.
class _EmptyEndpointDispatch extends EndpointDispatch {
  @override
  void initializeEndpoints(Server server) {}
}

/// Minimal test endpoint container for [TestServerpod].
class EmptyTestEndpoints implements InternalTestEndpoints {
  @override
  void initialize(
    DatabaseSerializationManager serializationManager,
    EndpointDispatch endpoints,
  ) {}
}

/// A disposable PostgreSQL cluster and Serverpod test server.
class PgTestServer {
  PgTestServer._({
    required this.dataDirectory,
    required this.port,
    required this.serverpod,
    required this.session,
    required this.postgresBin,
  });

  final Directory dataDirectory;
  final int port;
  final TestServerpod<EmptyTestEndpoints> serverpod;

  /// An unauthenticated session for direct database work.
  final InternalServerpodSession session;
  final String postgresBin;

  /// Starts a temporary PostgreSQL cluster and a migrated Serverpod instance.
  ///
  /// Set `OPENBUDGET_TEST_POSTGRES_BIN` to a PostgreSQL `bin` directory when
  /// `initdb`, `pg_ctl` and `postgres` are not the right ones on `PATH`.
  static Future<PgTestServer> start() async {
    final postgresBin =
        Platform.environment['OPENBUDGET_TEST_POSTGRES_BIN']?.trim() ?? '';
    final initdb = _postgresExecutable(postgresBin, 'initdb');
    final pgCtl = _postgresExecutable(postgresBin, 'pg_ctl');
    final dataDirectory = await Directory.systemTemp.createTemp(
      'openbudget-pg-',
    );
    final socketDirectory = Directory(_join(dataDirectory.path, 'socket'))
      ..createSync();
    final dataPath = _join(dataDirectory.path, 'data');
    final logPath = _join(dataDirectory.path, 'postgres.log');
    final port = await _freePort();

    await _run(initdb, [
      '-D',
      dataPath,
      '-U',
      'postgres',
      '--auth=trust',
      '--encoding=UTF8',
      '--locale=C',
      '--no-sync',
    ]);

    // mmap keeps each concurrent test cluster off the machine's small
    // System V shared-memory pool, which a full `dart test` run exhausts.
    const shmSettings =
        '-c shared_memory_type=mmap -c dynamic_shared_memory_type=posix';
    await _run(pgCtl, [
      '-D',
      dataPath,
      '-l',
      logPath,
      '-o',
      '-p $port -k ${socketDirectory.path} -h 127.0.0.1 $shmSettings',
      '-w',
      'start',
    ]);

    ServerpodConfig configOverride(ServerpodConfig config) => config.copyWith(
      database: PostgresDatabaseConfig(
        host: '127.0.0.1',
        port: port,
        user: 'postgres',
        password: 'test',
        name: 'openbudget_test',
      ),
      redis: RedisConfig(
        enabled: false,
        host: '127.0.0.1',
        port: 1,
        password: 'test',
      ),
    );

    final testServerpod = TestServerpod<EmptyTestEndpoints>(
      applyMigrations: true,
      endpoints: _EmptyEndpointDispatch(),
      serializationManager: Protocol(),
      isDatabaseEnabled: true,
      testEndpoints: EmptyTestEndpoints(),
      serverpodLoggingMode: ServerpodLoggingMode.normal,
      runMode: ServerpodRunMode.test,
      testServerOutputMode: TestServerOutputMode.silent,
      configOverride: configOverride,
    );
    await testServerpod.start();
    final session = testServerpod.createSession(
      rollbackDatabase: RollbackDatabase.disabled,
    );

    return PgTestServer._(
      dataDirectory: dataDirectory,
      port: port,
      serverpod: testServerpod,
      session: session,
      postgresBin: postgresBin,
    );
  }

  /// Creates a session with no authentication override.
  Session anonymousSession() => serverpod.createSession(
    rollbackDatabase: RollbackDatabase.disabled,
  );

  /// Creates a session authenticated as [userId].
  Session authenticatedSession(UuidValue userId) =>
      serverpod.createSession(
        rollbackDatabase: RollbackDatabase.disabled,
      )..updateAuthenticated(
        AuthenticationInfo(
          userId.toString(),
          const {},
          authId: 'test-auth',
        ),
      );

  /// Inserts an auth user row so entities can satisfy their owner foreign key.
  Future<UuidValue> insertAuthUser({Session? session}) async {
    final id = const Uuid().v7obj();
    await (session ?? this.session).db.unsafeExecute(
      'INSERT INTO serverpod_auth_core_user '
      '(id, "createdAt", "scopeNames", blocked) '
      "VALUES (@id::uuid, now(), '[]'::json, false)",
      parameters: QueryParameters.named({'id': id.toString()}),
    );
    return id;
  }

  /// Stops Serverpod, the temporary cluster and removes the data directory.
  Future<void> stop() async {
    await session.close();
    await serverpod.shutdown();
    await _run(_postgresExecutable(postgresBin, 'pg_ctl'), [
      '-D',
      _join(dataDirectory.path, 'data'),
      '-m',
      'immediate',
      'stop',
    ]);
    await dataDirectory.delete(recursive: true);
  }

  /// Removes every daily FX row.
  Future<void> clearRates() async {
    await FxRate.db.deleteWhere(
      session,
      where: (table) => table.rateDate > DateTime.utc(1970),
    );
    await session.caches.clear();
  }

  static Future<int> _freePort() async {
    final socket = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    final port = socket.port;
    await socket.close();
    return port;
  }

  static Future<void> _run(String executable, List<String> arguments) async {
    final result = await Process.run(executable, arguments);
    if (result.exitCode != 0) {
      throw StateError(
        '$executable ${arguments.join(' ')} failed (${result.exitCode}):\n'
        '${result.stdout}\n${result.stderr}',
      );
    }
  }

  static String _postgresExecutable(String postgresBin, String name) =>
      postgresBin.isEmpty ? name : _join(postgresBin, name);

  static String _join(String directory, String name) {
    final separator = Platform.pathSeparator;
    return directory.endsWith(separator)
        ? '$directory$name'
        : '$directory$separator$name';
  }
}

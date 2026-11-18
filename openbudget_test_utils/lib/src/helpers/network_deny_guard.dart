import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

/// Prevents OpenBudget tests from silently reaching the real server.
///
/// [installNetworkDenyGuard] sets a global [HttpOverrides] whose HTTP client
/// throws a [StateError] the moment any request starts — naming the HTTP
/// method and the endpoint it was aimed at — instead of letting the request
/// hang until the test harness cancels it and reports
/// "This test failed after it had already completed".
///
/// The guard is installed by the `flutter_test_config.dart` bootstrap of the
/// test trees that talk to the Serverpod API (`openbudget_app/test/` and
/// `openbudget_app/integration_test/`). A call that reaches the guard means a
/// provider was not faked: fix the test fixture with local data (see
/// `integration_test/common/test_data.dart`) rather than expecting the
/// network.
void installNetworkDenyGuard() {
  HttpOverrides.global = _NetworkDeniedOverrides();
}

Never _denyRequest(String method, Uri url) {
  final segments = url.pathSegments;
  final endpoint = segments.isNotEmpty ? segments.first : url.host;
  final rpcMethod = segments.length > 1 ? segments.last : url.host;
  final message =
      'Test tried to reach the real server: $method $url '
      '(Serverpod endpoint "$endpoint", method "$rpcMethod").\n'
      'Fake the provider that owns this call with test data instead — a '
      'request to the live API must never start in a test.';
  debugPrint('NETWORK DENIED: $message');
  throw StateError(message);
}

class _NetworkDeniedOverrides extends HttpOverrides {
  _NetworkDeniedOverrides();

  @override
  HttpClient createHttpClient(SecurityContext? context) => _DeniedHttpClient();
}

/// An [HttpClient] that refuses to start any request.
///
/// Configuration knobs stay settable (Serverpod's request delegate assigns
/// [connectionTimeout]); every request-starting member throws so the failure
/// is attributed to the running test, not to a cancelled socket after it.
class _DeniedHttpClient implements HttpClient {
  @override
  Duration idleTimeout = const Duration(seconds: 15);

  @override
  Duration? connectionTimeout;

  @override
  int? maxConnectionsPerHost;

  @override
  bool autoUncompress = true;

  @override
  String? userAgent;

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) =>
      _denyRequest(method, url);

  @override
  Future<HttpClientRequest> open(
    String method,
    String host,
    int port,
    String path,
  ) => _denyRequest(
    method,
    Uri(scheme: 'http', host: host, port: port, path: path),
  );

  @override
  Future<HttpClientRequest> getUrl(Uri url) => _denyRequest('GET', url);

  @override
  Future<HttpClientRequest> get(String host, int port, String path) =>
      _denyRequest(
        'GET',
        Uri(scheme: 'http', host: host, port: port, path: path),
      );

  @override
  Future<HttpClientRequest> postUrl(Uri url) => _denyRequest('POST', url);

  @override
  Future<HttpClientRequest> post(String host, int port, String path) =>
      _denyRequest(
        'POST',
        Uri(scheme: 'http', host: host, port: port, path: path),
      );

  @override
  Future<HttpClientRequest> putUrl(Uri url) => _denyRequest('PUT', url);

  @override
  Future<HttpClientRequest> put(String host, int port, String path) =>
      _denyRequest(
        'PUT',
        Uri(scheme: 'http', host: host, port: port, path: path),
      );

  @override
  Future<HttpClientRequest> deleteUrl(Uri url) => _denyRequest('DELETE', url);

  @override
  Future<HttpClientRequest> delete(String host, int port, String path) =>
      _denyRequest(
        'DELETE',
        Uri(scheme: 'http', host: host, port: port, path: path),
      );

  @override
  Future<HttpClientRequest> patchUrl(Uri url) => _denyRequest('PATCH', url);

  @override
  Future<HttpClientRequest> patch(String host, int port, String path) =>
      _denyRequest(
        'PATCH',
        Uri(scheme: 'http', host: host, port: port, path: path),
      );

  @override
  Future<HttpClientRequest> headUrl(Uri url) => _denyRequest('HEAD', url);

  @override
  Future<HttpClientRequest> head(String host, int port, String path) =>
      _denyRequest(
        'HEAD',
        Uri(scheme: 'http', host: host, port: port, path: path),
      );

  @override
  void addCredentials(
    Uri url,
    String realm,
    HttpClientCredentials credentials,
  ) {}

  @override
  void addProxyCredentials(
    String host,
    int port,
    String realm,
    HttpClientCredentials credentials,
  ) {}

  @override
  set authenticate(
    Future<bool> Function(Uri url, String scheme, String? realm)? f,
  ) {}

  @override
  set authenticateProxy(
    Future<bool> Function(String host, int port, String scheme, String? realm)?
    f,
  ) {}

  @override
  set badCertificateCallback(
    bool Function(X509Certificate cert, String host, int port)? callback,
  ) {}

  @override
  set connectionFactory(
    Future<ConnectionTask<Socket>> Function(
      Uri url,
      String? proxyHost,
      int? proxyPort,
    )?
    f,
  ) {}

  @override
  set findProxy(String Function(Uri url)? f) {}

  @override
  set keyLog(void Function(String line)? callback) {}

  @override
  void close({bool force = false}) {}
}

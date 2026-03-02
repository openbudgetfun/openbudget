import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';

part 'serverpod_client_provider.g.dart';

final _log = ObLogger('ServerpodClientProvider');

@Riverpod(keepAlive: true)
Client serverpodClient(Ref ref) {
  const apiUrlOverride = String.fromEnvironment('OPENBUDGET_API_URL');
  final apiUrl = resolveServerpodApiUrl(
    isWeb: kIsWeb,
    platform: defaultTargetPlatform,
    apiUrlOverride: apiUrlOverride,
  );
  _log.info(
    'resolvedApiUrl url=$apiUrl isWeb=$kIsWeb platform=$defaultTargetPlatform overrideProvided=${apiUrlOverride.trim().isNotEmpty}',
  );

  final client = Client(apiUrl)
    ..authSessionManager = FlutterAuthSessionManager();

  if (!_isWidgetTestRuntime()) {
    client.connectivityMonitor = FlutterConnectivityMonitor();
  }

  return client;
}

bool _isWidgetTestRuntime() {
  final typeName = WidgetsBinding.instance.runtimeType.toString();
  return typeName.contains('TestWidgetsFlutterBinding') ||
      typeName.contains('IntegrationTestWidgetsFlutterBinding') ||
      typeName.contains('LiveTestWidgetsFlutterBinding');
}

String resolveServerpodApiUrl({
  required bool isWeb,
  required TargetPlatform platform,
  required String apiUrlOverride,
}) {
  final override = apiUrlOverride.trim();
  if (override.isNotEmpty) {
    return override.endsWith('/') ? override : '$override/';
  }

  // Android emulators map host localhost to 10.0.2.2.
  if (!isWeb && platform == TargetPlatform.android) {
    return 'http://10.0.2.2:8080/';
  }

  return 'http://localhost:8080/';
}

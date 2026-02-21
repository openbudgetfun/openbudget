import 'dart:convert';

import 'package:serverpod/serverpod.dart';

/// Handles Apple OAuth callbacks for web and Android clients.
///
/// Apple posts callback fields as `application/x-www-form-urlencoded`.
/// For Android, the callback is redirected to the app via an intent URL.
/// For web, we return a popup-safe HTML response that posts the callback data
/// back to the opener window and then closes itself.
class AppleOauthCallbackRoute extends Route {
  AppleOauthCallbackRoute({required this.androidPackageIdentifier})
    : super(methods: {Method.get, Method.post});

  final String? androidPackageIdentifier;

  @override
  Future<Result> handleCall(Session session, Request request) async {
    final callbackParams = <String, String>{
      ...request.url.queryParameters,
      ...await _readFormBody(request),
    };

    if (_isAndroidRequest(request)) {
      final packageId = androidPackageIdentifier?.trim();
      if (packageId == null || packageId.isEmpty) {
        session.log(
          '[AppleOauthCallbackRoute] Missing appleAndroidPackageIdentifier.',
          level: LogLevel.warning,
        );
        return Response.internalServerError(
          body: Body.fromString(
            'Missing "appleAndroidPackageIdentifier" configuration.',
          ),
        );
      }

      final encodedParams = Uri(queryParameters: callbackParams).query;
      final redirectUri =
          'intent://callback?$encodedParams'
          '#Intent;package=$packageId;scheme=signinwithapple;end';

      return Response.seeOther(Uri.parse(redirectUri));
    }

    return Response.ok(
      body: Body.fromString(
        _buildWebCallbackHtml(callbackParams),
        mimeType: MimeType.html,
      ),
    );
  }

  Future<Map<String, String>> _readFormBody(Request request) async {
    if (request.method != Method.post) return const {};

    final body = await utf8.decodeStream(request.body.read());
    if (body.trim().isEmpty) return const {};

    try {
      return Uri.splitQueryString(body);
    } on FormatException {
      return const {};
    }
  }

  bool _isAndroidRequest(Request request) {
    String normalizeHeader(Iterable<String>? value) {
      if (value == null) return '';
      return value.join(',').toLowerCase();
    }

    final userAgent = normalizeHeader(request.headers['user-agent']);
    final platformHint = normalizeHeader(request.headers['sec-ch-ua-platform']);
    return userAgent.contains('android') || platformHint.contains('android');
  }

  String _buildWebCallbackHtml(Map<String, String> callbackParams) {
    final paramsJson = jsonEncode(callbackParams);
    return '''
<!doctype html>
<html>
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>OpenBudget Sign-In</title>
  </head>
  <body>
    <script>
      (function () {
        const payload = $paramsJson;
        try {
          if (window.opener && !window.opener.closed) {
            window.opener.postMessage(
              { source: 'openbudget.apple.callback', payload: payload },
              window.location.origin
            );
          }
        } catch (_) {}
        window.close();
      })();
    </script>
    <p>Sign-in complete. You can close this window.</p>
  </body>
</html>
''';
  }
}

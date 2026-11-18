import 'package:openbudget_server/src/tax/export/tax_export_service.dart';
import 'package:serverpod/serverpod.dart';

/// Thin Relic adapter for [TaxExportService].
///
/// Serves `GET /tax/export/<token>.zip`. The token is the only authority:
/// the route reads it from the path, asks the service for the download,
/// and answers a bare 404 for every refusal — an invalid or expired token,
/// a foreign owner, or books that cannot be summarised — so nothing about
/// which check failed leaves the server.
class TaxExportRoute extends Route {
  TaxExportRoute() : super(methods: {Method.get});

  @override
  Future<Result> handleCall(Session session, Request request) async {
    final token = _tokenFrom(request);
    final download = token == null
        ? null
        : await TaxExportService.buildDownload(session, token: token);
    if (download == null) {
      return Response(
        404,
        body: Body.fromString('Not found', mimeType: MimeType.plainText),
      );
    }

    return Response(
      200,
      body: Body.fromData(
        download.bytes,
        mimeType: const MimeType('application', 'zip'),
      ),
      headers: Headers.build((headers) {
        headers['content-disposition'] = [
          'attachment; filename="${download.filename}"',
        ];
        headers['cache-control'] = ['no-store'];
      }),
    );
  }

  /// The token sits where a filename would: `/tax/export/<token>.zip`.
  String? _tokenFrom(Request request) {
    final segments = request.url.pathSegments;
    if (segments.isEmpty) return null;
    var last = segments.last;
    const suffix = '.zip';
    if (last.endsWith(suffix)) {
      last = last.substring(0, last.length - suffix.length);
    }
    return last.isEmpty ? null : last;
  }
}

import 'dart:io';
import 'dart:typed_data';

import 'package:serverpod/serverpod.dart';

/// Gzips responses for clients that accept it.
///
/// Serverpod answers endpoint calls and serves files uncompressed. Endpoint
/// bodies are JSON, which gzip shrinks to about a tenth (a month of the plan
/// goes from 21 KB to 2 KB; see `docs/performance.md`), and every client
/// accepts gzip: browsers do, and `dart:io`'s HTTP client asks for it and
/// unpacks it by default.
///
/// Bodies already in memory, such as endpoint results, are compressed as
/// they go out. Streamed files are compressed once per version: the static
/// handler sends an ETag, and the gzipped bytes are kept under it in a small
/// cache, so a file is never compressed on every request.
///
/// A body is left alone when it is small enough that the gzip header would
/// eat the gain, when its type is already compressed (images, woff2), when
/// it is a partial or empty response, or when it already has an encoding.
class CompressionMiddleware {
  CompressionMiddleware({
    this.minBytes = 1024,
    this.maxStreamedBytes = 32 * 1024 * 1024,
    this.cacheBytes = 64 * 1024 * 1024,
    this.level = 6,
  });

  /// Smaller bodies are sent as they are.
  final int minBytes;

  /// Larger streamed files are sent as they are rather than held in memory.
  final int maxStreamedBytes;

  /// The most compressed file bytes kept between requests.
  final int cacheBytes;

  /// The gzip level: 6 is zlib's default balance of size and time.
  final int level;

  // Insertion-ordered, so the first key is the least recently used.
  final _cache = <String, Uint8List>{};
  var _cachedBytes = 0;

  /// The middleware to pass to `addMiddleware`.
  Handler call(Handler next) => (request) async {
    final result = await next(request);
    if (result is! Response || !_acceptsGzip(request)) return result;
    if (result.statusCode != HttpStatus.ok) return result;
    if (result.headers['content-encoding'] != null) return result;
    if (result.headers['content-range'] != null) return result;

    final body = result.body;
    final mimeType = body.bodyType?.mimeType;
    if (mimeType == null || !isCompressible(mimeType)) return result;

    final bytes = body.bytes;
    Uint8List compressed;
    if (bytes != null) {
      if (bytes.length < minBytes) return result;
      compressed = _gzip(bytes);
    } else {
      final length = body.contentLength;
      final etag = result.headers['etag']?.join(',');
      if (length == null || length < minBytes || length > maxStreamedBytes) {
        return result;
      }
      if (etag == null) return result;
      final key = '${request.url.path}|$etag';
      final cached = _cache.remove(key);
      if (cached != null) {
        _cache[key] = cached;
        compressed = cached;
        // Releases the file without reading it.
        body.consume();
      } else {
        final builder = BytesBuilder(copy: false);
        await body.read().forEach(builder.add);
        compressed = _gzip(builder.takeBytes());
        _remember(key, compressed);
      }
    }

    return result.copyWith(
      body: Body(bytes: compressed, bodyType: body.bodyType),
      headers: result.headers.transform((headers) {
        headers['content-encoding'] = ['gzip'];
        headers['content-length'] = null;
        headers['vary'] = [
          ...?result.headers['vary'],
          'Accept-Encoding',
        ];
      }),
    );
  };

  Uint8List _gzip(List<int> bytes) =>
      Uint8List.fromList(GZipCodec(level: level).encode(bytes));

  void _remember(String key, Uint8List compressed) {
    if (compressed.length > cacheBytes) return;
    _cache[key] = compressed;
    _cachedBytes += compressed.length;
    while (_cachedBytes > cacheBytes && _cache.isNotEmpty) {
      final oldest = _cache.keys.first;
      _cachedBytes -= _cache.remove(oldest)!.length;
    }
  }

  static bool _acceptsGzip(Request request) {
    final header = request.headers['accept-encoding'];
    if (header == null) return false;
    for (final value in header) {
      for (final part in value.split(',')) {
        final pieces = part.trim().split(';');
        final coding = pieces.first.trim().toLowerCase();
        if (coding != 'gzip' && coding != '*') continue;
        final q = pieces
            .skip(1)
            .map((p) => p.trim())
            .where((p) => p.startsWith('q='))
            .map((p) => double.tryParse(p.substring(2)))
            .firstOrNull;
        if (q == null || q > 0) return true;
      }
    }
    return false;
  }

  /// Whether a body of [mimeType] gets smaller under gzip.
  static bool isCompressible(MimeType mimeType) {
    if (mimeType.isText) return true;
    final subType = mimeType.subType.toLowerCase();
    return switch (mimeType.primaryType.toLowerCase()) {
      'application' => subType == 'wasm' || subType == 'manifest+json',
      'image' => subType == 'svg+xml',
      'font' => subType == 'ttf' || subType == 'otf',
      _ => false,
    };
  }
}

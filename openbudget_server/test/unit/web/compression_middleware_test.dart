import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:openbudget_server/src/web/compression_middleware.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

void main() {
  late Directory directory;
  late RelicServer server;
  late HttpClient client;
  final json = jsonEncode({
    'envelopes': [
      for (var i = 0; i < 200; i++) {'name': 'Envelope $i', 'available': i},
    ],
  });

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('compression-test-');
    File('${directory.path}/main.dart.js').writeAsStringSync('var a=1;' * 4000);
    File('${directory.path}/mark.png').writeAsBytesSync(
      Uint8List.fromList(List.filled(4000, 7)),
    );
    final app = RelicApp()
      ..use('/', CompressionMiddleware().call)
      ..get(
        '/json',
        (request) => Response.ok(
          body: Body.fromData(
            utf8.encode(json),
            mimeType: MimeType.json,
            encoding: utf8,
          ),
        ),
      )
      ..get(
        '/tiny',
        (request) => Response.ok(
          body: Body.fromString('{}', mimeType: MimeType.json),
        ),
      )
      ..anyOf(
        {Method.get, Method.head},
        '/files/**',
        StaticHandler.directory(
          directory,
          cacheControl: (_, _) => null,
        ).asHandler,
      );
    server = await app.serve(port: 0);
    client = HttpClient()..autoUncompress = false;
  });

  tearDown(() async {
    client.close(force: true);
    await server.close();
    await directory.delete(recursive: true);
  });

  Future<HttpClientResponse> get(String path, {String? acceptEncoding}) async {
    final request = await client.get('127.0.0.1', server.port, path);
    request.headers.removeAll(HttpHeaders.acceptEncodingHeader);
    if (acceptEncoding != null) {
      request.headers.set(HttpHeaders.acceptEncodingHeader, acceptEncoding);
    }
    return request.close();
  }

  Future<List<int>> bodyOf(HttpClientResponse response) =>
      response.fold<List<int>>(<int>[], (all, chunk) => all..addAll(chunk));

  test('given a client that accepts gzip when JSON is returned then it is '
      'gzipped and unpacks to the same bytes', () async {
    final response = await get('/json', acceptEncoding: 'gzip, deflate, br');
    final bytes = await bodyOf(response);

    expect(response.headers.value('content-encoding'), 'gzip');
    expect(response.headers.value('vary'), contains('Accept-Encoding'));
    expect(bytes.length, lessThan(utf8.encode(json).length ~/ 4));
    expect(utf8.decode(gzip.decode(bytes)), json);
  });

  test('given a client that does not accept gzip when JSON is returned then '
      'it is sent as it is', () async {
    for (final acceptEncoding in [null, 'identity', 'gzip;q=0']) {
      final response = await get('/json', acceptEncoding: acceptEncoding);
      expect(response.headers.value('content-encoding'), isNull);
      expect(utf8.decode(await bodyOf(response)), json);
    }
  });

  test('given a body under a kilobyte when returned then it is not '
      'compressed', () async {
    final response = await get('/tiny', acceptEncoding: 'gzip');
    expect(response.headers.value('content-encoding'), isNull);
    expect(utf8.decode(await bodyOf(response)), '{}');
  });

  test('given a static script when fetched twice then both answers are the '
      'same gzipped bytes', () async {
    final source = File('${directory.path}/main.dart.js').readAsStringSync();
    final first = await get('/files/main.dart.js', acceptEncoding: 'gzip');
    final firstBytes = await bodyOf(first);
    final second = await get('/files/main.dart.js', acceptEncoding: 'gzip');
    final secondBytes = await bodyOf(second);

    expect(first.headers.value('content-encoding'), 'gzip');
    expect(first.headers.value('etag'), isNotNull);
    expect(utf8.decode(gzip.decode(firstBytes)), source);
    expect(secondBytes, firstBytes);
  });

  test('given an image when fetched then it is not compressed again', () async {
    final response = await get('/files/mark.png', acceptEncoding: 'gzip');
    expect(response.headers.value('content-encoding'), isNull);
    expect((await bodyOf(response)).length, 4000);
  });

  test('given mime types when checked then only compressible ones pass', () {
    expect(CompressionMiddleware.isCompressible(MimeType.json), isTrue);
    expect(CompressionMiddleware.isCompressible(MimeType.html), isTrue);
    expect(
      CompressionMiddleware.isCompressible(MimeType.parse('application/wasm')),
      isTrue,
    );
    expect(
      CompressionMiddleware.isCompressible(MimeType.parse('font/ttf')),
      isTrue,
    );
    expect(
      CompressionMiddleware.isCompressible(MimeType.parse('image/svg+xml')),
      isTrue,
    );
    expect(
      CompressionMiddleware.isCompressible(MimeType.parse('image/png')),
      isFalse,
    );
    expect(
      CompressionMiddleware.isCompressible(MimeType.parse('font/woff2')),
      isFalse,
    );
  });
}

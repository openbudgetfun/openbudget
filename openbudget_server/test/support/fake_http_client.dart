import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// A captured HTTP response returned by [FakeHttpClient].
class FakeHttpResponse {
  const FakeHttpResponse({
    this.statusCode = 200,
    this.body = '{}',
    this.headers = const {},
  });

  final int statusCode;
  final String body;
  final Map<String, String> headers;
}

/// A minimal [HttpClient] fake for unit tests. [handler] receives the
/// requested URI and the outgoing request and returns a [FakeHttpResponse].
class FakeHttpClient implements HttpClient {
  FakeHttpClient({required this.handler});

  final Future<FakeHttpResponse> Function(
    Uri uri,
    FakeHttpClientRequest request,
  )
  handler;

  final List<Uri> requestedUris = [];
  final List<FakeHttpClientRequest> requests = [];

  Future<HttpClientResponse> _handle(
    Uri uri,
    FakeHttpClientRequest request,
  ) async {
    requestedUris.add(uri);
    requests.add(request);
    final response = await handler(uri, request);
    return FakeHttpClientResponse(response);
  }

  @override
  Future<HttpClientRequest> getUrl(Uri url) async =>
      FakeHttpClientRequest(this, url);

  @override
  void close({bool force = false}) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class FakeHttpClientRequest implements HttpClientRequest {
  FakeHttpClientRequest(this.client, this.uri);

  final FakeHttpClient client;
  @override
  final Uri uri;

  @override
  final HttpHeaders headers = _FakeHttpHeaders();

  @override
  Future<HttpClientResponse> close() => client._handle(uri, this);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class FakeHttpClientResponse implements HttpClientResponse {
  FakeHttpClientResponse(this._response);

  final FakeHttpResponse _response;

  @override
  int get statusCode => _response.statusCode;

  @override
  HttpHeaders get headers => _FakeHttpHeaders.from(_response.headers);

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    final controller = StreamController<List<int>>();
    final addChunk = controller.add;
    addChunk(utf8.encode(_response.body));
    final closeController = controller.close;
    unawaited(closeController());
    return controller.stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  Stream<T> transform<T>(StreamTransformer<List<int>, T> streamTransformer) =>
      streamTransformer.bind(this);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeHttpHeaders implements HttpHeaders {
  _FakeHttpHeaders() : _values = {};
  _FakeHttpHeaders.from(Map<String, String> values) : _values = {...values};

  final Map<String, String> _values;

  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {
    _values[name] = value.toString();
  }

  @override
  List<String> operator [](String name) => [_values[name] ?? ''];

  @override
  String? value(String name) => _values[name];

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

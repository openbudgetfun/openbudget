import 'dart:convert';
import 'dart:typed_data';

import 'package:openbudget_server/src/agent/mcp/agent_mcp_handler.dart';
import 'package:openbudget_server/src/agent/mcp/agent_mcp_response.dart';
import 'package:serverpod/serverpod.dart';

/// Thin Relic adapter for [AgentMcpHandler].
///
/// It copies the method, body and the two headers the protocol uses, then
/// turns the handler's result into an HTTP response. It never logs request
/// bodies or credentials.
class AgentMcpRoute extends Route {
  AgentMcpRoute({AgentMcpHandler? handler})
    : _handler = handler ?? AgentMcpHandler(),
      super(methods: {Method.post, Method.get, Method.delete});

  final AgentMcpHandler _handler;

  @override
  Future<Result> handleCall(Session session, Request request) async {
    final body = utf8.decode(await _readBody(request), allowMalformed: true);
    final headers = _headers(request);
    final result = await _handler.handle(
      session,
      httpMethod: request.method.value,
      rawBody: body,
      authorization: headers['authorization'],
      origin: headers['origin'],
    );
    return _response(result);
  }
}

Future<Uint8List> _readBody(Request request) async {
  final buffered = request.body.bytes;
  if (buffered != null) return buffered;
  final chunks = await request.read().toList();
  return Uint8List.fromList([
    for (final chunk in chunks) ...chunk,
  ]);
}

Map<String, String> _headers(Request request) => {
  for (final entry in request.headers.toMap().entries)
    entry.key.toLowerCase(): entry.value.first,
};

Result _response(AgentMcpResponse result) => Response(
  result.statusCode,
  body: result.body.isEmpty ? null : Body.fromString(result.body),
  headers: Headers.fromMap({
    for (final entry in result.headers.entries) entry.key: [entry.value],
  }),
);

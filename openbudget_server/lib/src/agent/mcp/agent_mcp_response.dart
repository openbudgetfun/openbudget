/// One HTTP answer from `AgentMcpHandler`.
///
/// The route adapter turns this into a Relic response without knowing anything
/// about the protocol.
class AgentMcpResponse {
  const AgentMcpResponse({
    required this.statusCode,
    this.body = '',
    this.headers = const {},
  });

  final int statusCode;

  /// The JSON-RPC body, or an empty string when the response has no body.
  final String body;

  /// Extra response headers, keyed by their lower-case names.
  final Map<String, String> headers;
}

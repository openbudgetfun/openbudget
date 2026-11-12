import 'dart:convert';

import 'package:openbudget_server/src/agent/agent_tool_registry.dart';
import 'package:openbudget_server/src/agent/mcp/agent_access_token_service.dart';
import 'package:openbudget_server/src/agent/mcp/agent_mcp_rate_limiter.dart';
import 'package:openbudget_server/src/agent/mcp/agent_mcp_response.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

/// The MCP Streamable HTTP protocol for OpenBudget.
///
/// The handler is deliberately independent of HTTP: the route adapter passes
/// the request method, headers and body, and gets back a status, body and
/// headers. That keeps the protocol testable without a running web server.
///
/// Every request is authorised by a personal access token from
/// [AgentAccessTokenService]. Tool calls run through [AgentToolRegistry] with
/// the token owner's id, so they see exactly the data the in-app assistant
/// sees and nothing else.
class AgentMcpHandler {
  AgentMcpHandler({
    this.registry = const AgentToolRegistry(),
    AgentAccessTokenService? tokens,
    AgentMcpRateLimiter? rateLimiter,
    DateTime Function()? clock,
  }) : _tokens = tokens ?? AgentAccessTokenService(clock: clock),
       _rateLimiter = rateLimiter ?? AgentMcpRateLimiter(clock: clock);

  static const String serverName = 'openbudget';
  static const String serverVersion = '1.0.0';
  static const String defaultProtocolVersion = '2025-06-18';
  static const List<String> supportedProtocolVersions = [
    '2025-06-18',
    '2025-03-26',
    '2024-11-05',
  ];

  /// The password holding the comma-separated origins allowed to call `/mcp`.
  static const String allowedOriginsPassword = 'mcpAllowedOrigins';

  static const String instructions =
      "These tools read the user's entities, plans and tax reports. Changes "
      'are proposals the user applies in the OpenBudget app. Answers are '
      'guidance, not regulated financial or tax advice.';

  final AgentToolRegistry registry;
  final AgentAccessTokenService _tokens;
  final AgentMcpRateLimiter _rateLimiter;

  /// Handles one MCP request.
  ///
  /// [authorization] is the raw `Authorization` header, [origin] the raw
  /// `Origin` header. Tokens, headers and tool results are never logged.
  Future<AgentMcpResponse> handle(
    Session session, {
    required String httpMethod,
    required String rawBody,
    String? authorization,
    String? origin,
  }) async {
    if (httpMethod.toUpperCase() != 'POST') {
      return _error(
        405,
        null,
        -32600,
        'Method not allowed',
        headers: const {'allow': 'POST'},
      );
    }

    if (!_originAllowed(session, origin)) {
      return _error(403, null, -32600, 'Origin not allowed');
    }

    final token = await _tokens.authenticate(session, authorization);
    if (token == null) {
      return _error(
        401,
        null,
        -32600,
        'Unauthorized',
        headers: const {'www-authenticate': 'Bearer'},
      );
    }

    if (!_rateLimiter.allow(token.id!)) {
      return _error(
        429,
        null,
        -32600,
        'Too many requests',
        headers: const {'retry-after': '60'},
      );
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(rawBody);
    } on FormatException {
      return _error(400, null, -32700, 'Parse error');
    }
    if (decoded is! Map<String, Object?>) {
      return _error(400, null, -32600, 'Invalid Request');
    }
    return _dispatch(session, token, decoded);
  }

  Future<AgentMcpResponse> _dispatch(
    Session session,
    AgentAccessToken token,
    Map<String, Object?> request,
  ) async {
    final id = request['id'];
    final method = request['method'];
    final isNotification = !request.containsKey('id');
    final validId = id == null || id is String || id is num;
    if (request['jsonrpc'] != '2.0' ||
        method is! String ||
        method.isEmpty ||
        (!isNotification && !validId)) {
      return _error(400, isNotification ? null : id, -32600, 'Invalid Request');
    }

    // Notifications never receive a response body.
    if (isNotification) return const AgentMcpResponse(statusCode: 202);

    switch (method) {
      case 'initialize':
        return _initialize(id, request['params']);
      case 'ping':
        return _result(id, const <String, Object?>{});
      case 'tools/list':
        return _result(id, {'tools': _tools(canPropose: token.canPropose)});
      case 'tools/call':
        return _callTool(session, token, id, request['params']);
      default:
        return _error(200, id, -32601, 'Method not found');
    }
  }

  AgentMcpResponse _initialize(Object? id, Object? params) {
    final values = _asMap(params);
    if (params != null && values == null) {
      return _error(200, id, -32602, 'Invalid params');
    }

    final requested = values?['protocolVersion'];
    final version =
        requested is String && supportedProtocolVersions.contains(requested)
        ? requested
        : defaultProtocolVersion;
    return _result(id, {
      'protocolVersion': version,
      'capabilities': {
        'tools': {'listChanged': false},
      },
      'serverInfo': {'name': serverName, 'version': serverVersion},
      'instructions': instructions,
    });
  }

  Future<AgentMcpResponse> _callTool(
    Session session,
    AgentAccessToken token,
    Object? id,
    Object? params,
  ) async {
    final values = _asMap(params);
    if (values == null) return _error(200, id, -32602, 'Invalid params');

    final name = values['name'];
    if (name is! String || name.trim().isEmpty) {
      return _error(200, id, -32602, 'Invalid params');
    }
    final argumentsValue = values['arguments'];
    final arguments = _asMap(argumentsValue);
    if (argumentsValue != null && arguments == null) {
      return _error(200, id, -32602, 'Invalid params');
    }

    final toolName = name.trim();
    final available = _toolNames(canPropose: token.canPropose);
    if (!available.contains(toolName)) {
      if (!token.canPropose &&
          _toolNames(canPropose: true).contains(toolName)) {
        return _result(id, {
          'content': [
            {
              'type': 'text',
              'text':
                  'This access token is read-only, so it cannot use '
                  '"$toolName". Create a token with proposal access in '
                  'OpenBudget to let your agent suggest changes.',
            },
          ],
          'isError': true,
        });
      }
      return _error(200, id, -32602, 'Unknown tool "$toolName"');
    }

    // The tools and every service they call read the caller's identity from
    // the session. A valid access token stands in for its owner's session,
    // so the MCP path sees exactly the authority the in-app assistant has.
    session.updateAuthenticated(
      AuthenticationInfo(
        token.userId.toString(),
        const {},
        authId: 'agent-access-token:${token.id}',
      ),
    );

    final text = await registry.call(
      AgentToolContext(
        session: session,
        userId: token.userId,
        canPropose: token.canPropose,
      ),
      toolName,
      arguments ?? const <String, Object?>{},
    );
    return _result(id, {
      'content': [
        {'type': 'text', 'text': text},
      ],
      'isError': _isToolError(text),
    });
  }

  /// The registry's OpenAI function definitions, in MCP tool shape.
  List<Map<String, Object?>> _tools({required bool canPropose}) => [
    for (final tool in registry.definitions(canPropose: canPropose))
      _mcpTool(tool),
  ];

  Set<String> _toolNames({required bool canPropose}) => {
    for (final tool in _tools(canPropose: canPropose)) tool['name']! as String,
  };

  static Map<String, Object?> _mcpTool(Map<String, Object?> tool) {
    final function = tool['function']! as Map<String, Object?>;
    return {
      'name': function['name'],
      'description': function['description'],
      'inputSchema': function['parameters'],
    };
  }

  static bool _isToolError(String text) {
    final Object? decoded;
    try {
      decoded = jsonDecode(text);
    } on FormatException {
      return true;
    }
    return decoded is Map<String, Object?> && decoded.containsKey('error');
  }

  static Map<String, Object?>? _asMap(Object? value) {
    if (value is Map<String, Object?>) return value;
    return null;
  }

  static bool _originAllowed(Session session, String? origin) {
    if (origin == null) return true;
    final configured = session.passwords[allowedOriginsPassword];
    if (configured == null) return false;
    final allowed = configured
        .split(',')
        .map((entry) => entry.trim())
        .where((entry) => entry.isNotEmpty);
    return allowed.contains(origin.trim());
  }

  static AgentMcpResponse _result(Object? id, Object? result) =>
      AgentMcpResponse(
        statusCode: 200,
        body: jsonEncode({'jsonrpc': '2.0', 'id': id, 'result': result}),
        headers: const {'content-type': 'application/json'},
      );

  static AgentMcpResponse _error(
    int statusCode,
    Object? id,
    int code,
    String message, {
    Map<String, String> headers = const {},
  }) => AgentMcpResponse(
    statusCode: statusCode,
    body: jsonEncode({
      'jsonrpc': '2.0',
      'id': id,
      'error': {'code': code, 'message': message},
    }),
    headers: {'content-type': 'application/json', ...headers},
  );
}

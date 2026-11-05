/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:openbudget_server/src/generated/protocol.dart' as _is0sbm8r;
import 'package:serverpod/serverpod.dart' as _is;

import '../../agent/mcp/agent_access_token_view.dart' as _io2w7gw2;

/// A newly created personal access token, with its secret shown once.
abstract class AgentAccessTokenCreated
    implements _is.SerializableModel, _is.ProtocolSerialization {
  AgentAccessTokenCreated._({
    required this.token,
    required this.view,
  });

  factory AgentAccessTokenCreated({
    required String token,
    required _io2w7gw2.AgentAccessTokenView view,
  }) = _AgentAccessTokenCreatedImpl;

  factory AgentAccessTokenCreated.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return AgentAccessTokenCreated(
      token: jsonSerialization['token'] as String,
      view: _is0sbm8r.Protocol().deserialize<_io2w7gw2.AgentAccessTokenView>(
        jsonSerialization['view'],
      ),
    );
  }

  /// The full token to copy into the client. It cannot be shown again.
  String token;

  _io2w7gw2.AgentAccessTokenView view;

  /// Returns a shallow copy of this [AgentAccessTokenCreated]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  AgentAccessTokenCreated copyWith({
    String? token,
    _io2w7gw2.AgentAccessTokenView? view,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AgentAccessTokenCreated',
      'token': token,
      'view': view.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AgentAccessTokenCreated',
      'token': token,
      'view': view.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _AgentAccessTokenCreatedImpl extends AgentAccessTokenCreated {
  _AgentAccessTokenCreatedImpl({
    required String token,
    required _io2w7gw2.AgentAccessTokenView view,
  }) : super._(
         token: token,
         view: view,
       );

  /// Returns a shallow copy of this [AgentAccessTokenCreated]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  AgentAccessTokenCreated copyWith({
    String? token,
    _io2w7gw2.AgentAccessTokenView? view,
  }) {
    return AgentAccessTokenCreated(
      token: token ?? this.token,
      view: view ?? this.view.copyWith(),
    );
  }
}

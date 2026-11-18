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
import 'package:openbudget_core/openbudget_core.dart' as _ifz8weqz;
import 'package:openbudget_server/src/generated/protocol.dart' as _is0sbm8r;
import 'package:serverpod/serverpod.dart' as _is;

import '../wallets/wallet_preview_network.dart' as _isxnhv4k;

/// What one address holds, before it is connected: one row per network of
/// its chain family, so the app can offer a picker (multichain-wallets.md
/// 5.5). A preview reads and rate limits; it writes nothing.
abstract class WalletPreview
    implements _is.SerializableModel, _is.ProtocolSerialization {
  WalletPreview._({
    required this.network,
    required this.address,
    required this.networks,
    required this.warnings,
  });

  factory WalletPreview({
    required _ifz8weqz.WalletNetwork network,
    required String address,
    required List<_isxnhv4k.WalletPreviewNetwork> networks,
    required List<String> warnings,
  }) = _WalletPreviewImpl;

  factory WalletPreview.fromJson(Map<String, dynamic> jsonSerialization) {
    return WalletPreview(
      network: _ifz8weqz.WalletNetwork.fromJson(
        (jsonSerialization['network'] as String),
      ),
      address: jsonSerialization['address'] as String,
      networks: _is0sbm8r.Protocol()
          .deserialize<List<_isxnhv4k.WalletPreviewNetwork>>(
            jsonSerialization['networks'],
          ),
      warnings: _is0sbm8r.Protocol().deserialize<List<String>>(
        jsonSerialization['warnings'],
      ),
    );
  }

  /// The parsed input's home network: the first supported network of its
  /// chain family.
  _ifz8weqz.WalletNetwork network;

  /// The address in its family's canonical form (core WalletAddressParser).
  String address;

  /// One row per network the preview tried, in display order.
  List<_isxnhv4k.WalletPreviewNetwork> networks;

  List<String> warnings;

  /// Returns a shallow copy of this [WalletPreview]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  WalletPreview copyWith({
    _ifz8weqz.WalletNetwork? network,
    String? address,
    List<_isxnhv4k.WalletPreviewNetwork>? networks,
    List<String>? warnings,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'WalletPreview',
      'network': network.toJson(),
      'address': address,
      'networks': networks.toJson(valueToJson: (v) => v.toJson()),
      'warnings': warnings.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'WalletPreview',
      'network': network.toJson(),
      'address': address,
      'networks': networks.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'warnings': warnings.toJson(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _WalletPreviewImpl extends WalletPreview {
  _WalletPreviewImpl({
    required _ifz8weqz.WalletNetwork network,
    required String address,
    required List<_isxnhv4k.WalletPreviewNetwork> networks,
    required List<String> warnings,
  }) : super._(
         network: network,
         address: address,
         networks: networks,
         warnings: warnings,
       );

  /// Returns a shallow copy of this [WalletPreview]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  WalletPreview copyWith({
    _ifz8weqz.WalletNetwork? network,
    String? address,
    List<_isxnhv4k.WalletPreviewNetwork>? networks,
    List<String>? warnings,
  }) {
    return WalletPreview(
      network: network ?? this.network,
      address: address ?? this.address,
      networks: networks ?? this.networks.map((e0) => e0.copyWith()).toList(),
      warnings: warnings ?? this.warnings.map((e0) => e0).toList(),
    );
  }
}

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
import 'package:openbudget_client/src/protocol/protocol.dart' as _irkl4crj;
import 'package:serverpod_client/serverpod_client.dart' as _isc;

import '../transactions/transaction_view.dart' as _i3vif776;

/// One page of transactions.
abstract class TransactionPage
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  TransactionPage._({
    required this.items,
    this.nextCursor,
  });

  factory TransactionPage({
    required List<_i3vif776.TransactionView> items,
    String? nextCursor,
  }) = _TransactionPageImpl;

  factory TransactionPage.fromJson(Map<String, dynamic> jsonSerialization) {
    return TransactionPage(
      items: _irkl4crj.Protocol().deserialize<List<_i3vif776.TransactionView>>(
        jsonSerialization['items'],
      ),
      nextCursor: jsonSerialization['nextCursor'] as String?,
    );
  }

  List<_i3vif776.TransactionView> items;

  /// Opaque cursor for the next page; null on the last page.
  String? nextCursor;

  /// Returns a shallow copy of this [TransactionPage]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  TransactionPage copyWith({
    List<_i3vif776.TransactionView>? items,
    String? nextCursor,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TransactionPage',
      'items': items.toJson(valueToJson: (v) => v.toJson()),
      if (nextCursor != null) 'nextCursor': nextCursor,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TransactionPage',
      'items': items.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      if (nextCursor != null) 'nextCursor': nextCursor,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TransactionPageImpl extends TransactionPage {
  _TransactionPageImpl({
    required List<_i3vif776.TransactionView> items,
    String? nextCursor,
  }) : super._(
         items: items,
         nextCursor: nextCursor,
       );

  /// Returns a shallow copy of this [TransactionPage]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  TransactionPage copyWith({
    List<_i3vif776.TransactionView>? items,
    Object? nextCursor = _Undefined,
  }) {
    return TransactionPage(
      items: items ?? this.items.map((e0) => e0.copyWith()).toList(),
      nextCursor: nextCursor is String? ? nextCursor : this.nextCursor,
    );
  }
}

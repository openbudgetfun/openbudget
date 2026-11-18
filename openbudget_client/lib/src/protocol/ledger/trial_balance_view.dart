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

import '../ledger/trial_balance_row_view.dart' as _ijohnc57;

/// The computed trial balance for one entity as of one date. An unbalanced
/// result is a hard error, so the endpoint throws instead of returning one.
abstract class TrialBalanceView
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  TrialBalanceView._({
    required this.entityId,
    required this.currencyCode,
    required this.asOf,
    required this.rows,
    required this.totalDebitMinor,
    required this.totalCreditMinor,
  });

  factory TrialBalanceView({
    required _isc.UuidValue entityId,
    required String currencyCode,
    required DateTime asOf,
    required List<_ijohnc57.TrialBalanceRowView> rows,
    required int totalDebitMinor,
    required int totalCreditMinor,
  }) = _TrialBalanceViewImpl;

  factory TrialBalanceView.fromJson(Map<String, dynamic> jsonSerialization) {
    return TrialBalanceView(
      entityId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['entityId'],
      ),
      currencyCode: jsonSerialization['currencyCode'] as String,
      asOf: _isc.DateTimeJsonExtension.fromJson(jsonSerialization['asOf']),
      rows: _irkl4crj.Protocol()
          .deserialize<List<_ijohnc57.TrialBalanceRowView>>(
            jsonSerialization['rows'],
          ),
      totalDebitMinor: jsonSerialization['totalDebitMinor'] as int,
      totalCreditMinor: jsonSerialization['totalCreditMinor'] as int,
    );
  }

  _isc.UuidValue entityId;

  /// ISO 4217 base currency code.
  String currencyCode;

  /// Inclusive calendar date the figures run through.
  DateTime asOf;

  List<_ijohnc57.TrialBalanceRowView> rows;

  int totalDebitMinor;

  int totalCreditMinor;

  /// Returns a shallow copy of this [TrialBalanceView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  TrialBalanceView copyWith({
    _isc.UuidValue? entityId,
    String? currencyCode,
    DateTime? asOf,
    List<_ijohnc57.TrialBalanceRowView>? rows,
    int? totalDebitMinor,
    int? totalCreditMinor,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TrialBalanceView',
      'entityId': entityId.toJson(),
      'currencyCode': currencyCode,
      'asOf': asOf.toJson(),
      'rows': rows.toJson(valueToJson: (v) => v.toJson()),
      'totalDebitMinor': totalDebitMinor,
      'totalCreditMinor': totalCreditMinor,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TrialBalanceView',
      'entityId': entityId.toJson(),
      'currencyCode': currencyCode,
      'asOf': asOf.toJson(),
      'rows': rows.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'totalDebitMinor': totalDebitMinor,
      'totalCreditMinor': totalCreditMinor,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _TrialBalanceViewImpl extends TrialBalanceView {
  _TrialBalanceViewImpl({
    required _isc.UuidValue entityId,
    required String currencyCode,
    required DateTime asOf,
    required List<_ijohnc57.TrialBalanceRowView> rows,
    required int totalDebitMinor,
    required int totalCreditMinor,
  }) : super._(
         entityId: entityId,
         currencyCode: currencyCode,
         asOf: asOf,
         rows: rows,
         totalDebitMinor: totalDebitMinor,
         totalCreditMinor: totalCreditMinor,
       );

  /// Returns a shallow copy of this [TrialBalanceView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  TrialBalanceView copyWith({
    _isc.UuidValue? entityId,
    String? currencyCode,
    DateTime? asOf,
    List<_ijohnc57.TrialBalanceRowView>? rows,
    int? totalDebitMinor,
    int? totalCreditMinor,
  }) {
    return TrialBalanceView(
      entityId: entityId ?? this.entityId,
      currencyCode: currencyCode ?? this.currencyCode,
      asOf: asOf ?? this.asOf,
      rows: rows ?? this.rows.map((e0) => e0.copyWith()).toList(),
      totalDebitMinor: totalDebitMinor ?? this.totalDebitMinor,
      totalCreditMinor: totalCreditMinor ?? this.totalCreditMinor,
    );
  }
}

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
import 'package:serverpod/serverpod.dart' as _is;

/// What `transaction.reconcile` found and did.
abstract class ReconcileResult
    implements _is.SerializableModel, _is.ProtocolSerialization {
  ReconcileResult._({
    required this.clearedBalanceMinor,
    required this.differenceMinor,
    this.adjustmentTransactionId,
    required this.reconciledCount,
  });

  factory ReconcileResult({
    required int clearedBalanceMinor,
    required int differenceMinor,
    _is.UuidValue? adjustmentTransactionId,
    required int reconciledCount,
  }) = _ReconcileResultImpl;

  factory ReconcileResult.fromJson(Map<String, dynamic> jsonSerialization) {
    return ReconcileResult(
      clearedBalanceMinor: jsonSerialization['clearedBalanceMinor'] as int,
      differenceMinor: jsonSerialization['differenceMinor'] as int,
      adjustmentTransactionId:
          jsonSerialization['adjustmentTransactionId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['adjustmentTransactionId'],
            ),
      reconciledCount: jsonSerialization['reconciledCount'] as int,
    );
  }

  /// Cleared and reconciled total up to the statement date, before any
  /// adjustment, in account minor units.
  int clearedBalanceMinor;

  /// statementBalanceMinor - clearedBalanceMinor.
  int differenceMinor;

  /// The balanceAdjustment created, when one was asked for and needed.
  _is.UuidValue? adjustmentTransactionId;

  /// Transactions moved from cleared to reconciled. 0 when the difference
  /// was non-zero and no adjustment was asked for.
  int reconciledCount;

  /// Returns a shallow copy of this [ReconcileResult]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  ReconcileResult copyWith({
    int? clearedBalanceMinor,
    int? differenceMinor,
    _is.UuidValue? adjustmentTransactionId = const _is.$UndefinedUuidValue(),
    int? reconciledCount,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ReconcileResult',
      'clearedBalanceMinor': clearedBalanceMinor,
      'differenceMinor': differenceMinor,
      if (adjustmentTransactionId != null)
        'adjustmentTransactionId': adjustmentTransactionId?.toJson(),
      'reconciledCount': reconciledCount,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ReconcileResult',
      'clearedBalanceMinor': clearedBalanceMinor,
      'differenceMinor': differenceMinor,
      if (adjustmentTransactionId != null)
        'adjustmentTransactionId': adjustmentTransactionId?.toJson(),
      'reconciledCount': reconciledCount,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _ReconcileResultImpl extends ReconcileResult {
  _ReconcileResultImpl({
    required int clearedBalanceMinor,
    required int differenceMinor,
    _is.UuidValue? adjustmentTransactionId,
    required int reconciledCount,
  }) : super._(
         clearedBalanceMinor: clearedBalanceMinor,
         differenceMinor: differenceMinor,
         adjustmentTransactionId: adjustmentTransactionId,
         reconciledCount: reconciledCount,
       );

  /// Returns a shallow copy of this [ReconcileResult]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  ReconcileResult copyWith({
    int? clearedBalanceMinor,
    int? differenceMinor,
    _is.UuidValue? adjustmentTransactionId = const _is.$UndefinedUuidValue(),
    int? reconciledCount,
  }) {
    return ReconcileResult(
      clearedBalanceMinor: clearedBalanceMinor ?? this.clearedBalanceMinor,
      differenceMinor: differenceMinor ?? this.differenceMinor,
      adjustmentTransactionId: adjustmentTransactionId is _is.UndefinedSentinel
          ? this.adjustmentTransactionId
          : adjustmentTransactionId,
      reconciledCount: reconciledCount ?? this.reconciledCount,
    );
  }
}

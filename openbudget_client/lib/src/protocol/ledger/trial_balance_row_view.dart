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
import 'package:serverpod_client/serverpod_client.dart' as _isc;

/// One row of a computed trial balance.
abstract class TrialBalanceRowView
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  TrialBalanceRowView._({
    required this.accountCode,
    required this.accountName,
    required this.accountType,
    this.systemRole,
    required this.debitMinor,
    required this.creditMinor,
    required this.netMinor,
  });

  factory TrialBalanceRowView({
    required String accountCode,
    required String accountName,
    required String accountType,
    String? systemRole,
    required int debitMinor,
    required int creditMinor,
    required int netMinor,
  }) = _TrialBalanceRowViewImpl;

  factory TrialBalanceRowView.fromJson(Map<String, dynamic> jsonSerialization) {
    return TrialBalanceRowView(
      accountCode: jsonSerialization['accountCode'] as String,
      accountName: jsonSerialization['accountName'] as String,
      accountType: jsonSerialization['accountType'] as String,
      systemRole: jsonSerialization['systemRole'] as String?,
      debitMinor: jsonSerialization['debitMinor'] as int,
      creditMinor: jsonSerialization['creditMinor'] as int,
      netMinor: jsonSerialization['netMinor'] as int,
    );
  }

  /// LedgerAccount code.
  String accountCode;

  /// LedgerAccount name.
  String accountName;

  /// LedgerAccountType name.
  String accountType;

  /// LedgerSystemRole name, when the account is a system account.
  String? systemRole;

  /// Total debits in functional minor units.
  int debitMinor;

  /// Total credits in functional minor units.
  int creditMinor;

  /// Balance with debits positive.
  int netMinor;

  /// Returns a shallow copy of this [TrialBalanceRowView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  TrialBalanceRowView copyWith({
    String? accountCode,
    String? accountName,
    String? accountType,
    String? systemRole,
    int? debitMinor,
    int? creditMinor,
    int? netMinor,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TrialBalanceRowView',
      'accountCode': accountCode,
      'accountName': accountName,
      'accountType': accountType,
      if (systemRole != null) 'systemRole': systemRole,
      'debitMinor': debitMinor,
      'creditMinor': creditMinor,
      'netMinor': netMinor,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TrialBalanceRowView',
      'accountCode': accountCode,
      'accountName': accountName,
      'accountType': accountType,
      if (systemRole != null) 'systemRole': systemRole,
      'debitMinor': debitMinor,
      'creditMinor': creditMinor,
      'netMinor': netMinor,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TrialBalanceRowViewImpl extends TrialBalanceRowView {
  _TrialBalanceRowViewImpl({
    required String accountCode,
    required String accountName,
    required String accountType,
    String? systemRole,
    required int debitMinor,
    required int creditMinor,
    required int netMinor,
  }) : super._(
         accountCode: accountCode,
         accountName: accountName,
         accountType: accountType,
         systemRole: systemRole,
         debitMinor: debitMinor,
         creditMinor: creditMinor,
         netMinor: netMinor,
       );

  /// Returns a shallow copy of this [TrialBalanceRowView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  TrialBalanceRowView copyWith({
    String? accountCode,
    String? accountName,
    String? accountType,
    Object? systemRole = _Undefined,
    int? debitMinor,
    int? creditMinor,
    int? netMinor,
  }) {
    return TrialBalanceRowView(
      accountCode: accountCode ?? this.accountCode,
      accountName: accountName ?? this.accountName,
      accountType: accountType ?? this.accountType,
      systemRole: systemRole is String? ? systemRole : this.systemRole,
      debitMinor: debitMinor ?? this.debitMinor,
      creditMinor: creditMinor ?? this.creditMinor,
      netMinor: netMinor ?? this.netMinor,
    );
  }
}

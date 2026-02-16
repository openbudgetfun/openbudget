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
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'accounts/account.dart' as _i2;
import 'budgets/budget.dart' as _i3;
import 'categories/category.dart' as _i4;
import 'envelope_goals/envelope_goal.dart' as _i5;
import 'envelopes/envelope.dart' as _i6;
import 'monthly_allocations/monthly_allocation.dart' as _i7;
import 'payees/payee.dart' as _i8;
import 'recurring_transactions/recurring_transaction.dart' as _i9;
import 'transactions/import_row.dart' as _i10;
import 'transactions/split_item.dart' as _i11;
import 'transactions/transaction.dart' as _i12;
import 'package:openbudget_client/src/protocol/accounts/account.dart' as _i13;
import 'package:openbudget_client/src/protocol/budgets/budget.dart' as _i14;
import 'package:openbudget_client/src/protocol/categories/category.dart'
    as _i15;
import 'package:openbudget_client/src/protocol/envelope_goals/envelope_goal.dart'
    as _i16;
import 'package:openbudget_client/src/protocol/envelopes/envelope.dart' as _i17;
import 'package:openbudget_client/src/protocol/monthly_allocations/monthly_allocation.dart'
    as _i18;
import 'package:openbudget_client/src/protocol/payees/payee.dart' as _i19;
import 'package:openbudget_client/src/protocol/recurring_transactions/recurring_transaction.dart'
    as _i20;
import 'package:openbudget_client/src/protocol/transactions/transaction.dart'
    as _i21;
import 'package:openbudget_client/src/protocol/transactions/split_item.dart'
    as _i22;
import 'package:openbudget_client/src/protocol/transactions/import_row.dart'
    as _i23;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i24;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i25;
export 'accounts/account.dart';
export 'budgets/budget.dart';
export 'categories/category.dart';
export 'envelope_goals/envelope_goal.dart';
export 'envelopes/envelope.dart';
export 'monthly_allocations/monthly_allocation.dart';
export 'payees/payee.dart';
export 'recurring_transactions/recurring_transaction.dart';
export 'transactions/import_row.dart';
export 'transactions/split_item.dart';
export 'transactions/transaction.dart';
export 'client.dart';

class Protocol extends _i1.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(dynamic data, [Type? t]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on FormatException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _i2.Account) {
      return _i2.Account.fromJson(data) as T;
    }
    if (t == _i3.Budget) {
      return _i3.Budget.fromJson(data) as T;
    }
    if (t == _i4.Category) {
      return _i4.Category.fromJson(data) as T;
    }
    if (t == _i5.EnvelopeGoal) {
      return _i5.EnvelopeGoal.fromJson(data) as T;
    }
    if (t == _i6.Envelope) {
      return _i6.Envelope.fromJson(data) as T;
    }
    if (t == _i7.MonthlyAllocation) {
      return _i7.MonthlyAllocation.fromJson(data) as T;
    }
    if (t == _i8.Payee) {
      return _i8.Payee.fromJson(data) as T;
    }
    if (t == _i9.RecurringTransaction) {
      return _i9.RecurringTransaction.fromJson(data) as T;
    }
    if (t == _i10.ImportRow) {
      return _i10.ImportRow.fromJson(data) as T;
    }
    if (t == _i11.SplitItem) {
      return _i11.SplitItem.fromJson(data) as T;
    }
    if (t == _i12.Transaction) {
      return _i12.Transaction.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.Account?>()) {
      return (data != null ? _i2.Account.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.Budget?>()) {
      return (data != null ? _i3.Budget.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.Category?>()) {
      return (data != null ? _i4.Category.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.EnvelopeGoal?>()) {
      return (data != null ? _i5.EnvelopeGoal.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.Envelope?>()) {
      return (data != null ? _i6.Envelope.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.MonthlyAllocation?>()) {
      return (data != null ? _i7.MonthlyAllocation.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.Payee?>()) {
      return (data != null ? _i8.Payee.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.RecurringTransaction?>()) {
      return (data != null ? _i9.RecurringTransaction.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i10.ImportRow?>()) {
      return (data != null ? _i10.ImportRow.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i11.SplitItem?>()) {
      return (data != null ? _i11.SplitItem.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i12.Transaction?>()) {
      return (data != null ? _i12.Transaction.fromJson(data) : null) as T;
    }
    if (t == List<_i13.Account>) {
      return (data as List).map((e) => deserialize<_i13.Account>(e)).toList()
          as T;
    }
    if (t == List<_i14.Budget>) {
      return (data as List).map((e) => deserialize<_i14.Budget>(e)).toList()
          as T;
    }
    if (t == List<_i15.Category>) {
      return (data as List).map((e) => deserialize<_i15.Category>(e)).toList()
          as T;
    }
    if (t == List<_i16.EnvelopeGoal>) {
      return (data as List)
              .map((e) => deserialize<_i16.EnvelopeGoal>(e))
              .toList()
          as T;
    }
    if (t == List<_i1.UuidValue>) {
      return (data as List).map((e) => deserialize<_i1.UuidValue>(e)).toList()
          as T;
    }
    if (t == List<_i17.Envelope>) {
      return (data as List).map((e) => deserialize<_i17.Envelope>(e)).toList()
          as T;
    }
    if (t == List<_i18.MonthlyAllocation>) {
      return (data as List)
              .map((e) => deserialize<_i18.MonthlyAllocation>(e))
              .toList()
          as T;
    }
    if (t == List<_i19.Payee>) {
      return (data as List).map((e) => deserialize<_i19.Payee>(e)).toList()
          as T;
    }
    if (t == List<_i20.RecurringTransaction>) {
      return (data as List)
              .map((e) => deserialize<_i20.RecurringTransaction>(e))
              .toList()
          as T;
    }
    if (t == List<_i21.Transaction>) {
      return (data as List)
              .map((e) => deserialize<_i21.Transaction>(e))
              .toList()
          as T;
    }
    if (t == List<_i22.SplitItem>) {
      return (data as List).map((e) => deserialize<_i22.SplitItem>(e)).toList()
          as T;
    }
    if (t == List<_i23.ImportRow>) {
      return (data as List).map((e) => deserialize<_i23.ImportRow>(e)).toList()
          as T;
    }
    try {
      return _i24.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i25.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i2.Account => 'Account',
      _i3.Budget => 'Budget',
      _i4.Category => 'Category',
      _i5.EnvelopeGoal => 'EnvelopeGoal',
      _i6.Envelope => 'Envelope',
      _i7.MonthlyAllocation => 'MonthlyAllocation',
      _i8.Payee => 'Payee',
      _i9.RecurringTransaction => 'RecurringTransaction',
      _i10.ImportRow => 'ImportRow',
      _i11.SplitItem => 'SplitItem',
      _i12.Transaction => 'Transaction',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('openbudget.', '');
    }

    switch (data) {
      case _i2.Account():
        return 'Account';
      case _i3.Budget():
        return 'Budget';
      case _i4.Category():
        return 'Category';
      case _i5.EnvelopeGoal():
        return 'EnvelopeGoal';
      case _i6.Envelope():
        return 'Envelope';
      case _i7.MonthlyAllocation():
        return 'MonthlyAllocation';
      case _i8.Payee():
        return 'Payee';
      case _i9.RecurringTransaction():
        return 'RecurringTransaction';
      case _i10.ImportRow():
        return 'ImportRow';
      case _i11.SplitItem():
        return 'SplitItem';
      case _i12.Transaction():
        return 'Transaction';
    }
    className = _i24.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_idp.$className';
    }
    className = _i25.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_core.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'Account') {
      return deserialize<_i2.Account>(data['data']);
    }
    if (dataClassName == 'Budget') {
      return deserialize<_i3.Budget>(data['data']);
    }
    if (dataClassName == 'Category') {
      return deserialize<_i4.Category>(data['data']);
    }
    if (dataClassName == 'EnvelopeGoal') {
      return deserialize<_i5.EnvelopeGoal>(data['data']);
    }
    if (dataClassName == 'Envelope') {
      return deserialize<_i6.Envelope>(data['data']);
    }
    if (dataClassName == 'MonthlyAllocation') {
      return deserialize<_i7.MonthlyAllocation>(data['data']);
    }
    if (dataClassName == 'Payee') {
      return deserialize<_i8.Payee>(data['data']);
    }
    if (dataClassName == 'RecurringTransaction') {
      return deserialize<_i9.RecurringTransaction>(data['data']);
    }
    if (dataClassName == 'ImportRow') {
      return deserialize<_i10.ImportRow>(data['data']);
    }
    if (dataClassName == 'SplitItem') {
      return deserialize<_i11.SplitItem>(data['data']);
    }
    if (dataClassName == 'Transaction') {
      return deserialize<_i12.Transaction>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i24.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i25.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _i24.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i25.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}

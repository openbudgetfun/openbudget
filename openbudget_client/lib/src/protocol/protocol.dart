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
import 'budgets/budget.dart' as _i2;
import 'categories/category.dart' as _i3;
import 'envelopes/envelope.dart' as _i4;
import 'transactions/transaction.dart' as _i5;
import 'package:openbudget_client/src/protocol/budgets/budget.dart' as _i6;
import 'package:openbudget_client/src/protocol/categories/category.dart' as _i7;
import 'package:openbudget_client/src/protocol/envelopes/envelope.dart' as _i8;
import 'package:openbudget_client/src/protocol/transactions/transaction.dart'
    as _i9;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i10;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i11;
export 'budgets/budget.dart';
export 'categories/category.dart';
export 'envelopes/envelope.dart';
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

    if (t == _i2.Budget) {
      return _i2.Budget.fromJson(data) as T;
    }
    if (t == _i3.Category) {
      return _i3.Category.fromJson(data) as T;
    }
    if (t == _i4.Envelope) {
      return _i4.Envelope.fromJson(data) as T;
    }
    if (t == _i5.Transaction) {
      return _i5.Transaction.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.Budget?>()) {
      return (data != null ? _i2.Budget.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.Category?>()) {
      return (data != null ? _i3.Category.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.Envelope?>()) {
      return (data != null ? _i4.Envelope.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.Transaction?>()) {
      return (data != null ? _i5.Transaction.fromJson(data) : null) as T;
    }
    if (t == List<_i6.Budget>) {
      return (data as List).map((e) => deserialize<_i6.Budget>(e)).toList()
          as T;
    }
    if (t == List<_i7.Category>) {
      return (data as List).map((e) => deserialize<_i7.Category>(e)).toList()
          as T;
    }
    if (t == List<_i8.Envelope>) {
      return (data as List).map((e) => deserialize<_i8.Envelope>(e)).toList()
          as T;
    }
    if (t == List<_i9.Transaction>) {
      return (data as List).map((e) => deserialize<_i9.Transaction>(e)).toList()
          as T;
    }
    try {
      return _i10.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i11.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i2.Budget => 'Budget',
      _i3.Category => 'Category',
      _i4.Envelope => 'Envelope',
      _i5.Transaction => 'Transaction',
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
      case _i2.Budget():
        return 'Budget';
      case _i3.Category():
        return 'Category';
      case _i4.Envelope():
        return 'Envelope';
      case _i5.Transaction():
        return 'Transaction';
    }
    className = _i10.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_idp.$className';
    }
    className = _i11.Protocol().getClassNameForObject(data);
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
    if (dataClassName == 'Budget') {
      return deserialize<_i2.Budget>(data['data']);
    }
    if (dataClassName == 'Category') {
      return deserialize<_i3.Category>(data['data']);
    }
    if (dataClassName == 'Envelope') {
      return deserialize<_i4.Envelope>(data['data']);
    }
    if (dataClassName == 'Transaction') {
      return deserialize<_i5.Transaction>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i10.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i11.Protocol().deserializeByClassName(data);
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
      return _i10.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i11.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}

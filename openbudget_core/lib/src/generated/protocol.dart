/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: dead_code, unnecessary_type_check

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_serialization/serverpod_serialization.dart' as _iss;

import 'account_balance_source.dart' as _iajlz9u3;
import 'account_kind.dart' as _ifkquxga;
import 'accounting_mode.dart' as _inp9sd6t;
import 'entity_kind.dart' as _iuzzio6g;
import 'fx_rate_source.dart' as _i0thn26m;
import 'journal_source.dart' as _i7l4hts2;
import 'journal_status.dart' as _ivhj1h0b;
import 'ledger_account_type.dart' as _itr586k3;
import 'ledger_system_role.dart' as _if8rpjam;
import 'recurrence_frequency.dart' as _ieaa5lpg;
export 'account_balance_source.dart';
export 'account_kind.dart';
export 'accounting_mode.dart';
export 'entity_kind.dart';
export 'fx_rate_source.dart';
export 'journal_source.dart';
export 'journal_status.dart';
export 'ledger_account_type.dart';
export 'ledger_system_role.dart';
export 'recurrence_frequency.dart';

class Protocol extends _iss.SerializationManager
    implements _iss.ProtocolDeserializationProvider {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  final Set<_iss.SerializationManager> _hostProtocols = {};

  @override
  _iss.ProtocolDeserialization get deserializationMetadata =>
      _iss.ProtocolDeserialization.cached(
        this,
        types: const [
          _iss.getType<_iajlz9u3.AccountBalanceSource>,
          _iss.getType<_ifkquxga.AccountKind>,
          _iss.getType<_inp9sd6t.AccountingMode>,
          _iss.getType<_iuzzio6g.EntityKind>,
          _iss.getType<_i0thn26m.FxRateSource>,
          _iss.getType<_i7l4hts2.JournalSource>,
          _iss.getType<_ivhj1h0b.JournalStatus>,
          _iss.getType<_itr586k3.LedgerAccountType>,
          _iss.getType<_if8rpjam.LedgerSystemRole>,
          _iss.getType<_ieaa5lpg.RecurrenceFrequency>,
          _iss.getType<_iajlz9u3.AccountBalanceSource?>,
          _iss.getType<_ifkquxga.AccountKind?>,
          _iss.getType<_inp9sd6t.AccountingMode?>,
          _iss.getType<_iuzzio6g.EntityKind?>,
          _iss.getType<_i0thn26m.FxRateSource?>,
          _iss.getType<_i7l4hts2.JournalSource?>,
          _iss.getType<_ivhj1h0b.JournalStatus?>,
          _iss.getType<_itr586k3.LedgerAccountType?>,
          _iss.getType<_if8rpjam.LedgerSystemRole?>,
          _iss.getType<_ieaa5lpg.RecurrenceFrequency?>,
        ],
        modules: const [],
        classNames: const [
          'AccountBalanceSource',
          'AccountKind',
          'AccountingMode',
          'EntityKind',
          'FxRateSource',
          'JournalSource',
          'JournalStatus',
          'LedgerAccountType',
          'LedgerSystemRole',
          'RecurrenceFrequency',
        ],
      );

  void registerHostProtocol(
    String projectName,
    _iss.SerializationManager protocol,
  ) {
    _hostProtocols.add(protocol);
  }

  static String? getClassNameFromObjectJson(dynamic data) =>
      _iss.ProtocolDeserialization.readClassName(data);

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;
    final rawDataClassName = _iss.ProtocolDeserialization.readClassName(data);
    final dataClassName = rawDataClassName;
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on _iss.DeserializationClassNameNotFoundException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _iajlz9u3.AccountBalanceSource) {
      return _iajlz9u3.AccountBalanceSource.fromJson(data) as T;
    }
    if (t == _ifkquxga.AccountKind) {
      return _ifkquxga.AccountKind.fromJson(data) as T;
    }
    if (t == _inp9sd6t.AccountingMode) {
      return _inp9sd6t.AccountingMode.fromJson(data) as T;
    }
    if (t == _iuzzio6g.EntityKind) {
      return _iuzzio6g.EntityKind.fromJson(data) as T;
    }
    if (t == _i0thn26m.FxRateSource) {
      return _i0thn26m.FxRateSource.fromJson(data) as T;
    }
    if (t == _i7l4hts2.JournalSource) {
      return _i7l4hts2.JournalSource.fromJson(data) as T;
    }
    if (t == _ivhj1h0b.JournalStatus) {
      return _ivhj1h0b.JournalStatus.fromJson(data) as T;
    }
    if (t == _itr586k3.LedgerAccountType) {
      return _itr586k3.LedgerAccountType.fromJson(data) as T;
    }
    if (t == _if8rpjam.LedgerSystemRole) {
      return _if8rpjam.LedgerSystemRole.fromJson(data) as T;
    }
    if (t == _ieaa5lpg.RecurrenceFrequency) {
      return _ieaa5lpg.RecurrenceFrequency.fromJson(data) as T;
    }
    if (t == _iss.getType<_iajlz9u3.AccountBalanceSource?>()) {
      return (data != null
              ? _iajlz9u3.AccountBalanceSource.fromJson(data)
              : null)
          as T;
    }
    if (t == _iss.getType<_ifkquxga.AccountKind?>()) {
      return (data != null ? _ifkquxga.AccountKind.fromJson(data) : null) as T;
    }
    if (t == _iss.getType<_inp9sd6t.AccountingMode?>()) {
      return (data != null ? _inp9sd6t.AccountingMode.fromJson(data) : null)
          as T;
    }
    if (t == _iss.getType<_iuzzio6g.EntityKind?>()) {
      return (data != null ? _iuzzio6g.EntityKind.fromJson(data) : null) as T;
    }
    if (t == _iss.getType<_i0thn26m.FxRateSource?>()) {
      return (data != null ? _i0thn26m.FxRateSource.fromJson(data) : null) as T;
    }
    if (t == _iss.getType<_i7l4hts2.JournalSource?>()) {
      return (data != null ? _i7l4hts2.JournalSource.fromJson(data) : null)
          as T;
    }
    if (t == _iss.getType<_ivhj1h0b.JournalStatus?>()) {
      return (data != null ? _ivhj1h0b.JournalStatus.fromJson(data) : null)
          as T;
    }
    if (t == _iss.getType<_itr586k3.LedgerAccountType?>()) {
      return (data != null ? _itr586k3.LedgerAccountType.fromJson(data) : null)
          as T;
    }
    if (t == _iss.getType<_if8rpjam.LedgerSystemRole?>()) {
      return (data != null ? _if8rpjam.LedgerSystemRole.fromJson(data) : null)
          as T;
    }
    if (t == _iss.getType<_ieaa5lpg.RecurrenceFrequency?>()) {
      return (data != null
              ? _ieaa5lpg.RecurrenceFrequency.fromJson(data)
              : null)
          as T;
    }
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _iajlz9u3.AccountBalanceSource => 'AccountBalanceSource',
      _ifkquxga.AccountKind => 'AccountKind',
      _inp9sd6t.AccountingMode => 'AccountingMode',
      _iuzzio6g.EntityKind => 'EntityKind',
      _i0thn26m.FxRateSource => 'FxRateSource',
      _i7l4hts2.JournalSource => 'JournalSource',
      _ivhj1h0b.JournalStatus => 'JournalStatus',
      _itr586k3.LedgerAccountType => 'LedgerAccountType',
      _if8rpjam.LedgerSystemRole => 'LedgerSystemRole',
      _ieaa5lpg.RecurrenceFrequency => 'RecurrenceFrequency',
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
      case _iajlz9u3.AccountBalanceSource():
        return 'AccountBalanceSource';
      case _ifkquxga.AccountKind():
        return 'AccountKind';
      case _inp9sd6t.AccountingMode():
        return 'AccountingMode';
      case _iuzzio6g.EntityKind():
        return 'EntityKind';
      case _i0thn26m.FxRateSource():
        return 'FxRateSource';
      case _i7l4hts2.JournalSource():
        return 'JournalSource';
      case _ivhj1h0b.JournalStatus():
        return 'JournalStatus';
      case _itr586k3.LedgerAccountType():
        return 'LedgerAccountType';
      case _if8rpjam.LedgerSystemRole():
        return 'LedgerSystemRole';
      case _ieaa5lpg.RecurrenceFrequency():
        return 'RecurrenceFrequency';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'AccountBalanceSource') {
      return deserialize<_iajlz9u3.AccountBalanceSource>(data['data']);
    }
    if (dataClassName == 'AccountKind') {
      return deserialize<_ifkquxga.AccountKind>(data['data']);
    }
    if (dataClassName == 'AccountingMode') {
      return deserialize<_inp9sd6t.AccountingMode>(data['data']);
    }
    if (dataClassName == 'EntityKind') {
      return deserialize<_iuzzio6g.EntityKind>(data['data']);
    }
    if (dataClassName == 'FxRateSource') {
      return deserialize<_i0thn26m.FxRateSource>(data['data']);
    }
    if (dataClassName == 'JournalSource') {
      return deserialize<_i7l4hts2.JournalSource>(data['data']);
    }
    if (dataClassName == 'JournalStatus') {
      return deserialize<_ivhj1h0b.JournalStatus>(data['data']);
    }
    if (dataClassName == 'LedgerAccountType') {
      return deserialize<_itr586k3.LedgerAccountType>(data['data']);
    }
    if (dataClassName == 'LedgerSystemRole') {
      return deserialize<_if8rpjam.LedgerSystemRole>(data['data']);
    }
    if (dataClassName == 'RecurrenceFrequency') {
      return deserialize<_ieaa5lpg.RecurrenceFrequency>(data['data']);
    }
    return super.deserializeByClassName(data);
  }

  @override
  Object? dynamicFieldToJson(
    Object? object, {
    bool forProtocol = false,
  }) {
    if ((object is List || object is Set || object is Map) ||
        getClassNameForObject(object) != null) {
      return super.dynamicFieldToJson(object, forProtocol: forProtocol);
    }
    for (final protocol in _hostProtocols) {
      final className = protocol.getClassNameForObject(object);
      if (className == null) continue;
      final host = protocol.getModuleName();
      final wrapped = {
        'className': className.contains('.') ? className : '$host.$className',
        'data': object,
      };
      return forProtocol
          ? _iss.SerializationManager.toEncodableForProtocol(wrapped)
          : _iss.SerializationManager.toEncodable(wrapped);
    }
    return super.dynamicFieldToJson(object, forProtocol: forProtocol);
  }

  @override
  dynamic deserializeDynamicFieldValue(Object? value) {
    if (value == null) return null;
    if (value is! Map<String, dynamic> || value['className'] is! String) {
      throw FormatException(
        'Dynamic fields are encoded as a Map with className and data, but got '
        '${value.runtimeType} instead.',
      );
    }
    final className = value['className'] as String;
    for (final protocol in _hostProtocols) {
      final host = protocol.getModuleName();
      final hostPrefix = '$host.';
      if (className.startsWith(hostPrefix)) {
        final strippedClassName = className.substring(hostPrefix.length);
        if (strippedClassName.contains('.')) {
          throw FormatException(
            'Dynamic field className must not use multiple prefixes: $className',
          );
        }
        final hostData = Map<String, dynamic>.from(value);
        hostData['className'] = strippedClassName;
        return protocol.deserializeByClassName(hostData);
      }
    }
    if (className.contains('.')) {
      for (final protocol in _hostProtocols) {
        try {
          return protocol.deserializeByClassName(value);
        } on _iss.DeserializationClassNameNotFoundException catch (_) {}
      }
    }
    return deserializeByClassName(value);
  }

  @override
  String getModuleName() => 'openbudget';

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}

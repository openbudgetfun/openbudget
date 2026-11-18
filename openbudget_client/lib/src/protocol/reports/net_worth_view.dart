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

import '../reports/net_worth_account_row.dart' as _izaolq5z;
import '../reports/net_worth_currency_row.dart' as _ic9lb1mk;
import '../reports/net_worth_entity_row.dart' as _ij119jre;

/// Net worth of a set of entities on one date in one reporting currency.
/// Every total is a sum of the same per-account conversions (section 6.5),
/// so the breakdowns always add up.
abstract class NetWorthView
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  NetWorthView._({
    required this.currencyCode,
    required this.asOf,
    required this.assetsMinor,
    required this.liabilitiesMinor,
    required this.netWorthMinor,
    required this.isComplete,
    required this.missingCurrencyCodes,
    required this.hasStaleRates,
    required this.currencies,
    required this.entities,
    required this.accounts,
  });

  factory NetWorthView({
    required String currencyCode,
    required DateTime asOf,
    required int assetsMinor,
    required int liabilitiesMinor,
    required int netWorthMinor,
    required bool isComplete,
    required List<String> missingCurrencyCodes,
    required bool hasStaleRates,
    required List<_ic9lb1mk.NetWorthCurrencyRow> currencies,
    required List<_ij119jre.NetWorthEntityRow> entities,
    required List<_izaolq5z.NetWorthAccountRow> accounts,
  }) = _NetWorthViewImpl;

  factory NetWorthView.fromJson(Map<String, dynamic> jsonSerialization) {
    return NetWorthView(
      currencyCode: jsonSerialization['currencyCode'] as String,
      asOf: _isc.DateTimeJsonExtension.fromJson(jsonSerialization['asOf']),
      assetsMinor: jsonSerialization['assetsMinor'] as int,
      liabilitiesMinor: jsonSerialization['liabilitiesMinor'] as int,
      netWorthMinor: jsonSerialization['netWorthMinor'] as int,
      isComplete: _isc.BoolJsonExtension.fromJson(
        jsonSerialization['isComplete'],
      ),
      missingCurrencyCodes: _irkl4crj.Protocol().deserialize<List<String>>(
        jsonSerialization['missingCurrencyCodes'],
      ),
      hasStaleRates: _isc.BoolJsonExtension.fromJson(
        jsonSerialization['hasStaleRates'],
      ),
      currencies: _irkl4crj.Protocol()
          .deserialize<List<_ic9lb1mk.NetWorthCurrencyRow>>(
            jsonSerialization['currencies'],
          ),
      entities: _irkl4crj.Protocol()
          .deserialize<List<_ij119jre.NetWorthEntityRow>>(
            jsonSerialization['entities'],
          ),
      accounts: _irkl4crj.Protocol()
          .deserialize<List<_izaolq5z.NetWorthAccountRow>>(
            jsonSerialization['accounts'],
          ),
    );
  }

  /// ISO 4217 reporting currency.
  String currencyCode;

  /// Calendar date the balances and rates are for.
  DateTime asOf;

  /// Non-liability accounts, converted.
  int assetsMinor;

  /// Liability accounts, converted; normally negative.
  int liabilitiesMinor;

  /// assetsMinor + liabilitiesMinor.
  int netWorthMinor;

  /// False when some currency had no rate; its accounts are left out of
  /// the totals and listed in missingCurrencyCodes.
  bool isComplete;

  List<String> missingCurrencyCodes;

  /// True when any rate used is stale.
  bool hasStaleRates;

  List<_ic9lb1mk.NetWorthCurrencyRow> currencies;

  List<_ij119jre.NetWorthEntityRow> entities;

  List<_izaolq5z.NetWorthAccountRow> accounts;

  /// Returns a shallow copy of this [NetWorthView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  NetWorthView copyWith({
    String? currencyCode,
    DateTime? asOf,
    int? assetsMinor,
    int? liabilitiesMinor,
    int? netWorthMinor,
    bool? isComplete,
    List<String>? missingCurrencyCodes,
    bool? hasStaleRates,
    List<_ic9lb1mk.NetWorthCurrencyRow>? currencies,
    List<_ij119jre.NetWorthEntityRow>? entities,
    List<_izaolq5z.NetWorthAccountRow>? accounts,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'NetWorthView',
      'currencyCode': currencyCode,
      'asOf': asOf.toJson(),
      'assetsMinor': assetsMinor,
      'liabilitiesMinor': liabilitiesMinor,
      'netWorthMinor': netWorthMinor,
      'isComplete': isComplete,
      'missingCurrencyCodes': missingCurrencyCodes.toJson(),
      'hasStaleRates': hasStaleRates,
      'currencies': currencies.toJson(valueToJson: (v) => v.toJson()),
      'entities': entities.toJson(valueToJson: (v) => v.toJson()),
      'accounts': accounts.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'NetWorthView',
      'currencyCode': currencyCode,
      'asOf': asOf.toJson(),
      'assetsMinor': assetsMinor,
      'liabilitiesMinor': liabilitiesMinor,
      'netWorthMinor': netWorthMinor,
      'isComplete': isComplete,
      'missingCurrencyCodes': missingCurrencyCodes.toJson(),
      'hasStaleRates': hasStaleRates,
      'currencies': currencies.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
      'entities': entities.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'accounts': accounts.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _NetWorthViewImpl extends NetWorthView {
  _NetWorthViewImpl({
    required String currencyCode,
    required DateTime asOf,
    required int assetsMinor,
    required int liabilitiesMinor,
    required int netWorthMinor,
    required bool isComplete,
    required List<String> missingCurrencyCodes,
    required bool hasStaleRates,
    required List<_ic9lb1mk.NetWorthCurrencyRow> currencies,
    required List<_ij119jre.NetWorthEntityRow> entities,
    required List<_izaolq5z.NetWorthAccountRow> accounts,
  }) : super._(
         currencyCode: currencyCode,
         asOf: asOf,
         assetsMinor: assetsMinor,
         liabilitiesMinor: liabilitiesMinor,
         netWorthMinor: netWorthMinor,
         isComplete: isComplete,
         missingCurrencyCodes: missingCurrencyCodes,
         hasStaleRates: hasStaleRates,
         currencies: currencies,
         entities: entities,
         accounts: accounts,
       );

  /// Returns a shallow copy of this [NetWorthView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  NetWorthView copyWith({
    String? currencyCode,
    DateTime? asOf,
    int? assetsMinor,
    int? liabilitiesMinor,
    int? netWorthMinor,
    bool? isComplete,
    List<String>? missingCurrencyCodes,
    bool? hasStaleRates,
    List<_ic9lb1mk.NetWorthCurrencyRow>? currencies,
    List<_ij119jre.NetWorthEntityRow>? entities,
    List<_izaolq5z.NetWorthAccountRow>? accounts,
  }) {
    return NetWorthView(
      currencyCode: currencyCode ?? this.currencyCode,
      asOf: asOf ?? this.asOf,
      assetsMinor: assetsMinor ?? this.assetsMinor,
      liabilitiesMinor: liabilitiesMinor ?? this.liabilitiesMinor,
      netWorthMinor: netWorthMinor ?? this.netWorthMinor,
      isComplete: isComplete ?? this.isComplete,
      missingCurrencyCodes:
          missingCurrencyCodes ??
          this.missingCurrencyCodes.map((e0) => e0).toList(),
      hasStaleRates: hasStaleRates ?? this.hasStaleRates,
      currencies:
          currencies ?? this.currencies.map((e0) => e0.copyWith()).toList(),
      entities: entities ?? this.entities.map((e0) => e0.copyWith()).toList(),
      accounts: accounts ?? this.accounts.map((e0) => e0.copyWith()).toList(),
    );
  }
}

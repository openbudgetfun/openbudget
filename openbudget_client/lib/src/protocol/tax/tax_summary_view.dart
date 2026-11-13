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
import 'package:openbudget_core/openbudget_core.dart' as _ifz8weqz;
import 'package:serverpod_client/serverpod_client.dart' as _isc;

import '../tax/tax_summary_category_total_view.dart' as _i1qtpxp4;
import '../tax/tax_summary_fx_note_view.dart' as _ilzzyqne;
import '../tax/tax_summary_sales_tax_quarter_view.dart' as _ifw624tr;
import '../tax/tax_summary_sales_tax_rate_view.dart' as _i1ccn0xl;
import '../tax/tax_summary_wallet_view.dart' as _i1s21zo4;

/// The tax-ready summary for one entity and year (docs/tax-jurisdictions.md, 8.7).
///
/// Every amount except the wallet figures is in [currencyCode], the entity's
/// base currency for a universal-layer country and the pack's currency for a
/// pack country. Wallet figures carry their own stored P&L currency.
abstract class TaxSummaryView
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  TaxSummaryView._({
    required this.entityId,
    required this.entityKind,
    required this.countryCode,
    required this.currencyCode,
    required this.startYear,
    required this.yearLabel,
    required this.yearStart,
    required this.yearEnd,
    required this.generatedAt,
    required this.isUniversal,
    this.rulesVersion,
    this.rulesVerifiedOn,
    required this.disclaimerKey,
    required this.incomeTotals,
    required this.expenseTotals,
    required this.reliefTotals,
    required this.taxPaidTotals,
    required this.totalIncomeMinor,
    required this.totalExpenseMinor,
    required this.totalReliefMinor,
    required this.totalTaxPaidMinor,
    required this.salesTaxCollectedMinor,
    required this.salesTaxPaidMinor,
    required this.salesTaxByRate,
    required this.salesTaxByQuarter,
    required this.wallets,
    required this.fxNotes,
    required this.rateSourcesUsed,
    required this.uncategorizedCount,
  });

  factory TaxSummaryView({
    required _isc.UuidValue entityId,
    required _ifz8weqz.EntityKind entityKind,
    required String countryCode,
    required String currencyCode,
    required int startYear,
    required String yearLabel,
    required DateTime yearStart,
    required DateTime yearEnd,
    required DateTime generatedAt,
    required bool isUniversal,
    String? rulesVersion,
    DateTime? rulesVerifiedOn,
    required String disclaimerKey,
    required List<_i1qtpxp4.TaxSummaryCategoryTotalView> incomeTotals,
    required List<_i1qtpxp4.TaxSummaryCategoryTotalView> expenseTotals,
    required List<_i1qtpxp4.TaxSummaryCategoryTotalView> reliefTotals,
    required List<_i1qtpxp4.TaxSummaryCategoryTotalView> taxPaidTotals,
    required int totalIncomeMinor,
    required int totalExpenseMinor,
    required int totalReliefMinor,
    required int totalTaxPaidMinor,
    required int salesTaxCollectedMinor,
    required int salesTaxPaidMinor,
    required List<_i1ccn0xl.TaxSummarySalesTaxRateView> salesTaxByRate,
    required List<_ifw624tr.TaxSummarySalesTaxQuarterView> salesTaxByQuarter,
    required List<_i1s21zo4.TaxSummaryWalletView> wallets,
    required List<_ilzzyqne.TaxSummaryFxNoteView> fxNotes,
    required List<String> rateSourcesUsed,
    required int uncategorizedCount,
  }) = _TaxSummaryViewImpl;

  factory TaxSummaryView.fromJson(Map<String, dynamic> jsonSerialization) {
    return TaxSummaryView(
      entityId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['entityId'],
      ),
      entityKind: _ifz8weqz.EntityKind.fromJson(
        (jsonSerialization['entityKind'] as String),
      ),
      countryCode: jsonSerialization['countryCode'] as String,
      currencyCode: jsonSerialization['currencyCode'] as String,
      startYear: jsonSerialization['startYear'] as int,
      yearLabel: jsonSerialization['yearLabel'] as String,
      yearStart: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['yearStart'],
      ),
      yearEnd: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['yearEnd'],
      ),
      generatedAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['generatedAt'],
      ),
      isUniversal: _isc.BoolJsonExtension.fromJson(
        jsonSerialization['isUniversal'],
      ),
      rulesVersion: jsonSerialization['rulesVersion'] as String?,
      rulesVerifiedOn: jsonSerialization['rulesVerifiedOn'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['rulesVerifiedOn'],
            ),
      disclaimerKey: jsonSerialization['disclaimerKey'] as String,
      incomeTotals: _irkl4crj.Protocol()
          .deserialize<List<_i1qtpxp4.TaxSummaryCategoryTotalView>>(
            jsonSerialization['incomeTotals'],
          ),
      expenseTotals: _irkl4crj.Protocol()
          .deserialize<List<_i1qtpxp4.TaxSummaryCategoryTotalView>>(
            jsonSerialization['expenseTotals'],
          ),
      reliefTotals: _irkl4crj.Protocol()
          .deserialize<List<_i1qtpxp4.TaxSummaryCategoryTotalView>>(
            jsonSerialization['reliefTotals'],
          ),
      taxPaidTotals: _irkl4crj.Protocol()
          .deserialize<List<_i1qtpxp4.TaxSummaryCategoryTotalView>>(
            jsonSerialization['taxPaidTotals'],
          ),
      totalIncomeMinor: jsonSerialization['totalIncomeMinor'] as int,
      totalExpenseMinor: jsonSerialization['totalExpenseMinor'] as int,
      totalReliefMinor: jsonSerialization['totalReliefMinor'] as int,
      totalTaxPaidMinor: jsonSerialization['totalTaxPaidMinor'] as int,
      salesTaxCollectedMinor:
          jsonSerialization['salesTaxCollectedMinor'] as int,
      salesTaxPaidMinor: jsonSerialization['salesTaxPaidMinor'] as int,
      salesTaxByRate: _irkl4crj.Protocol()
          .deserialize<List<_i1ccn0xl.TaxSummarySalesTaxRateView>>(
            jsonSerialization['salesTaxByRate'],
          ),
      salesTaxByQuarter: _irkl4crj.Protocol()
          .deserialize<List<_ifw624tr.TaxSummarySalesTaxQuarterView>>(
            jsonSerialization['salesTaxByQuarter'],
          ),
      wallets: _irkl4crj.Protocol()
          .deserialize<List<_i1s21zo4.TaxSummaryWalletView>>(
            jsonSerialization['wallets'],
          ),
      fxNotes: _irkl4crj.Protocol()
          .deserialize<List<_ilzzyqne.TaxSummaryFxNoteView>>(
            jsonSerialization['fxNotes'],
          ),
      rateSourcesUsed: _irkl4crj.Protocol().deserialize<List<String>>(
        jsonSerialization['rateSourcesUsed'],
      ),
      uncategorizedCount: jsonSerialization['uncategorizedCount'] as int,
    );
  }

  _isc.UuidValue entityId;

  /// The entity kind.
  _ifz8weqz.EntityKind entityKind;

  /// ISO 3166-1 alpha-2 country code.
  String countryCode;

  /// ISO 4217 code every amount except the wallet figures is in.
  String currencyCode;

  /// The calendar year the summary period starts in.
  int startYear;

  /// How the year is written: `2026/27` or `2026`.
  String yearLabel;

  /// First day of the period, at midnight, as a date-only UTC value.
  DateTime yearStart;

  /// First day of the next period, exclusive.
  DateTime yearEnd;

  /// When this summary was built.
  DateTime generatedAt;

  /// True when the summary comes from the universal layer, because the
  /// entity's country has no rule pack.
  bool isUniversal;

  /// The rule pack version that owns the figures: `gb-2026-r1`. Null for a
  /// universal-layer country, where [rulesVerifiedOn] says how current the
  /// country data is.
  String? rulesVersion;

  /// When the figures were last checked against their sources: the pack
  /// rule set's date, or the country data's `verifiedOn`.
  DateTime? rulesVerifiedOn;

  /// The ARB key of the disclaimer to show beside the summary.
  String disclaimerKey;

  /// Income totals by category, in catalogue order.
  List<_i1qtpxp4.TaxSummaryCategoryTotalView> incomeTotals;

  /// Expense totals by category, after business-use share, in catalogue
  /// order.
  List<_i1qtpxp4.TaxSummaryCategoryTotalView> expenseTotals;

  /// Relief totals by category, in catalogue order.
  List<_i1qtpxp4.TaxSummaryCategoryTotalView> reliefTotals;

  /// Tax already paid or withheld, by category, in catalogue order.
  List<_i1qtpxp4.TaxSummaryCategoryTotalView> taxPaidTotals;

  int totalIncomeMinor;

  int totalExpenseMinor;

  int totalReliefMinor;

  int totalTaxPaidMinor;

  /// Sales tax charged to customers, after business-use share.
  int salesTaxCollectedMinor;

  /// Sales tax paid on purchases, after business-use share.
  int salesTaxPaidMinor;

  /// The same sales tax grouped by the rate each line implies.
  List<_i1ccn0xl.TaxSummarySalesTaxRateView> salesTaxByRate;

  /// The same sales tax grouped by quarter of the summary period.
  List<_ifw624tr.TaxSummarySalesTaxQuarterView> salesTaxByQuarter;

  /// Estimated wallet disposals, one row per wallet and P&L currency.
  List<_i1s21zo4.TaxSummaryWalletView> wallets;

  /// The exchange rates the converted lines used, one row per distinct
  /// rate.
  List<_ilzzyqne.TaxSummaryFxNoteView> fxNotes;

  /// The distinct rate sources the converted lines used: `market`,
  /// `manual`, `identity`.
  List<String> rateSourcesUsed;

  /// Lines dated in the period that carry no tax category.
  int uncategorizedCount;

  /// Returns a shallow copy of this [TaxSummaryView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  TaxSummaryView copyWith({
    _isc.UuidValue? entityId,
    _ifz8weqz.EntityKind? entityKind,
    String? countryCode,
    String? currencyCode,
    int? startYear,
    String? yearLabel,
    DateTime? yearStart,
    DateTime? yearEnd,
    DateTime? generatedAt,
    bool? isUniversal,
    String? rulesVersion,
    DateTime? rulesVerifiedOn = const _isc.$UndefinedDateTime(),
    String? disclaimerKey,
    List<_i1qtpxp4.TaxSummaryCategoryTotalView>? incomeTotals,
    List<_i1qtpxp4.TaxSummaryCategoryTotalView>? expenseTotals,
    List<_i1qtpxp4.TaxSummaryCategoryTotalView>? reliefTotals,
    List<_i1qtpxp4.TaxSummaryCategoryTotalView>? taxPaidTotals,
    int? totalIncomeMinor,
    int? totalExpenseMinor,
    int? totalReliefMinor,
    int? totalTaxPaidMinor,
    int? salesTaxCollectedMinor,
    int? salesTaxPaidMinor,
    List<_i1ccn0xl.TaxSummarySalesTaxRateView>? salesTaxByRate,
    List<_ifw624tr.TaxSummarySalesTaxQuarterView>? salesTaxByQuarter,
    List<_i1s21zo4.TaxSummaryWalletView>? wallets,
    List<_ilzzyqne.TaxSummaryFxNoteView>? fxNotes,
    List<String>? rateSourcesUsed,
    int? uncategorizedCount,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TaxSummaryView',
      'entityId': entityId.toJson(),
      'entityKind': entityKind.toJson(),
      'countryCode': countryCode,
      'currencyCode': currencyCode,
      'startYear': startYear,
      'yearLabel': yearLabel,
      'yearStart': yearStart.toJson(),
      'yearEnd': yearEnd.toJson(),
      'generatedAt': generatedAt.toJson(),
      'isUniversal': isUniversal,
      if (rulesVersion != null) 'rulesVersion': rulesVersion,
      if (rulesVerifiedOn != null) 'rulesVerifiedOn': rulesVerifiedOn?.toJson(),
      'disclaimerKey': disclaimerKey,
      'incomeTotals': incomeTotals.toJson(valueToJson: (v) => v.toJson()),
      'expenseTotals': expenseTotals.toJson(valueToJson: (v) => v.toJson()),
      'reliefTotals': reliefTotals.toJson(valueToJson: (v) => v.toJson()),
      'taxPaidTotals': taxPaidTotals.toJson(valueToJson: (v) => v.toJson()),
      'totalIncomeMinor': totalIncomeMinor,
      'totalExpenseMinor': totalExpenseMinor,
      'totalReliefMinor': totalReliefMinor,
      'totalTaxPaidMinor': totalTaxPaidMinor,
      'salesTaxCollectedMinor': salesTaxCollectedMinor,
      'salesTaxPaidMinor': salesTaxPaidMinor,
      'salesTaxByRate': salesTaxByRate.toJson(valueToJson: (v) => v.toJson()),
      'salesTaxByQuarter': salesTaxByQuarter.toJson(
        valueToJson: (v) => v.toJson(),
      ),
      'wallets': wallets.toJson(valueToJson: (v) => v.toJson()),
      'fxNotes': fxNotes.toJson(valueToJson: (v) => v.toJson()),
      'rateSourcesUsed': rateSourcesUsed.toJson(),
      'uncategorizedCount': uncategorizedCount,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TaxSummaryView',
      'entityId': entityId.toJson(),
      'entityKind': entityKind.toJson(),
      'countryCode': countryCode,
      'currencyCode': currencyCode,
      'startYear': startYear,
      'yearLabel': yearLabel,
      'yearStart': yearStart.toJson(),
      'yearEnd': yearEnd.toJson(),
      'generatedAt': generatedAt.toJson(),
      'isUniversal': isUniversal,
      if (rulesVersion != null) 'rulesVersion': rulesVersion,
      if (rulesVerifiedOn != null) 'rulesVerifiedOn': rulesVerifiedOn?.toJson(),
      'disclaimerKey': disclaimerKey,
      'incomeTotals': incomeTotals.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
      'expenseTotals': expenseTotals.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
      'reliefTotals': reliefTotals.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
      'taxPaidTotals': taxPaidTotals.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
      'totalIncomeMinor': totalIncomeMinor,
      'totalExpenseMinor': totalExpenseMinor,
      'totalReliefMinor': totalReliefMinor,
      'totalTaxPaidMinor': totalTaxPaidMinor,
      'salesTaxCollectedMinor': salesTaxCollectedMinor,
      'salesTaxPaidMinor': salesTaxPaidMinor,
      'salesTaxByRate': salesTaxByRate.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
      'salesTaxByQuarter': salesTaxByQuarter.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
      'wallets': wallets.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'fxNotes': fxNotes.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'rateSourcesUsed': rateSourcesUsed.toJson(),
      'uncategorizedCount': uncategorizedCount,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TaxSummaryViewImpl extends TaxSummaryView {
  _TaxSummaryViewImpl({
    required _isc.UuidValue entityId,
    required _ifz8weqz.EntityKind entityKind,
    required String countryCode,
    required String currencyCode,
    required int startYear,
    required String yearLabel,
    required DateTime yearStart,
    required DateTime yearEnd,
    required DateTime generatedAt,
    required bool isUniversal,
    String? rulesVersion,
    DateTime? rulesVerifiedOn,
    required String disclaimerKey,
    required List<_i1qtpxp4.TaxSummaryCategoryTotalView> incomeTotals,
    required List<_i1qtpxp4.TaxSummaryCategoryTotalView> expenseTotals,
    required List<_i1qtpxp4.TaxSummaryCategoryTotalView> reliefTotals,
    required List<_i1qtpxp4.TaxSummaryCategoryTotalView> taxPaidTotals,
    required int totalIncomeMinor,
    required int totalExpenseMinor,
    required int totalReliefMinor,
    required int totalTaxPaidMinor,
    required int salesTaxCollectedMinor,
    required int salesTaxPaidMinor,
    required List<_i1ccn0xl.TaxSummarySalesTaxRateView> salesTaxByRate,
    required List<_ifw624tr.TaxSummarySalesTaxQuarterView> salesTaxByQuarter,
    required List<_i1s21zo4.TaxSummaryWalletView> wallets,
    required List<_ilzzyqne.TaxSummaryFxNoteView> fxNotes,
    required List<String> rateSourcesUsed,
    required int uncategorizedCount,
  }) : super._(
         entityId: entityId,
         entityKind: entityKind,
         countryCode: countryCode,
         currencyCode: currencyCode,
         startYear: startYear,
         yearLabel: yearLabel,
         yearStart: yearStart,
         yearEnd: yearEnd,
         generatedAt: generatedAt,
         isUniversal: isUniversal,
         rulesVersion: rulesVersion,
         rulesVerifiedOn: rulesVerifiedOn,
         disclaimerKey: disclaimerKey,
         incomeTotals: incomeTotals,
         expenseTotals: expenseTotals,
         reliefTotals: reliefTotals,
         taxPaidTotals: taxPaidTotals,
         totalIncomeMinor: totalIncomeMinor,
         totalExpenseMinor: totalExpenseMinor,
         totalReliefMinor: totalReliefMinor,
         totalTaxPaidMinor: totalTaxPaidMinor,
         salesTaxCollectedMinor: salesTaxCollectedMinor,
         salesTaxPaidMinor: salesTaxPaidMinor,
         salesTaxByRate: salesTaxByRate,
         salesTaxByQuarter: salesTaxByQuarter,
         wallets: wallets,
         fxNotes: fxNotes,
         rateSourcesUsed: rateSourcesUsed,
         uncategorizedCount: uncategorizedCount,
       );

  /// Returns a shallow copy of this [TaxSummaryView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  TaxSummaryView copyWith({
    _isc.UuidValue? entityId,
    _ifz8weqz.EntityKind? entityKind,
    String? countryCode,
    String? currencyCode,
    int? startYear,
    String? yearLabel,
    DateTime? yearStart,
    DateTime? yearEnd,
    DateTime? generatedAt,
    bool? isUniversal,
    Object? rulesVersion = _Undefined,
    DateTime? rulesVerifiedOn = const _isc.$UndefinedDateTime(),
    String? disclaimerKey,
    List<_i1qtpxp4.TaxSummaryCategoryTotalView>? incomeTotals,
    List<_i1qtpxp4.TaxSummaryCategoryTotalView>? expenseTotals,
    List<_i1qtpxp4.TaxSummaryCategoryTotalView>? reliefTotals,
    List<_i1qtpxp4.TaxSummaryCategoryTotalView>? taxPaidTotals,
    int? totalIncomeMinor,
    int? totalExpenseMinor,
    int? totalReliefMinor,
    int? totalTaxPaidMinor,
    int? salesTaxCollectedMinor,
    int? salesTaxPaidMinor,
    List<_i1ccn0xl.TaxSummarySalesTaxRateView>? salesTaxByRate,
    List<_ifw624tr.TaxSummarySalesTaxQuarterView>? salesTaxByQuarter,
    List<_i1s21zo4.TaxSummaryWalletView>? wallets,
    List<_ilzzyqne.TaxSummaryFxNoteView>? fxNotes,
    List<String>? rateSourcesUsed,
    int? uncategorizedCount,
  }) {
    return TaxSummaryView(
      entityId: entityId ?? this.entityId,
      entityKind: entityKind ?? this.entityKind,
      countryCode: countryCode ?? this.countryCode,
      currencyCode: currencyCode ?? this.currencyCode,
      startYear: startYear ?? this.startYear,
      yearLabel: yearLabel ?? this.yearLabel,
      yearStart: yearStart ?? this.yearStart,
      yearEnd: yearEnd ?? this.yearEnd,
      generatedAt: generatedAt ?? this.generatedAt,
      isUniversal: isUniversal ?? this.isUniversal,
      rulesVersion: rulesVersion is String? ? rulesVersion : this.rulesVersion,
      rulesVerifiedOn: rulesVerifiedOn is _isc.UndefinedSentinel
          ? this.rulesVerifiedOn
          : rulesVerifiedOn,
      disclaimerKey: disclaimerKey ?? this.disclaimerKey,
      incomeTotals:
          incomeTotals ?? this.incomeTotals.map((e0) => e0.copyWith()).toList(),
      expenseTotals:
          expenseTotals ??
          this.expenseTotals.map((e0) => e0.copyWith()).toList(),
      reliefTotals:
          reliefTotals ?? this.reliefTotals.map((e0) => e0.copyWith()).toList(),
      taxPaidTotals:
          taxPaidTotals ??
          this.taxPaidTotals.map((e0) => e0.copyWith()).toList(),
      totalIncomeMinor: totalIncomeMinor ?? this.totalIncomeMinor,
      totalExpenseMinor: totalExpenseMinor ?? this.totalExpenseMinor,
      totalReliefMinor: totalReliefMinor ?? this.totalReliefMinor,
      totalTaxPaidMinor: totalTaxPaidMinor ?? this.totalTaxPaidMinor,
      salesTaxCollectedMinor:
          salesTaxCollectedMinor ?? this.salesTaxCollectedMinor,
      salesTaxPaidMinor: salesTaxPaidMinor ?? this.salesTaxPaidMinor,
      salesTaxByRate:
          salesTaxByRate ??
          this.salesTaxByRate.map((e0) => e0.copyWith()).toList(),
      salesTaxByQuarter:
          salesTaxByQuarter ??
          this.salesTaxByQuarter.map((e0) => e0.copyWith()).toList(),
      wallets: wallets ?? this.wallets.map((e0) => e0.copyWith()).toList(),
      fxNotes: fxNotes ?? this.fxNotes.map((e0) => e0.copyWith()).toList(),
      rateSourcesUsed:
          rateSourcesUsed ?? this.rateSourcesUsed.map((e0) => e0).toList(),
      uncategorizedCount: uncategorizedCount ?? this.uncategorizedCount,
    );
  }
}

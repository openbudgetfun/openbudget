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

import '../tax/tax_liability_view.dart' as _iyg1xvx7;
import '../tax/tax_opportunity_view.dart' as _i7gx5xr1;
import '../tax/tax_report_line_view.dart' as _i8pphqdm;

/// The computed tax position for one entity and tax year.
abstract class TaxReportView
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  TaxReportView._({
    required this.jurisdiction,
    required this.startYear,
    required this.yearLabel,
    required this.yearStart,
    required this.yearEnd,
    required this.entityKind,
    required this.currencyCode,
    required this.lines,
    required this.liabilities,
    required this.totalLiabilityMinor,
    required this.alreadyPaidMinor,
    required this.balanceDueMinor,
    required this.assumptions,
    required this.sources,
    required this.rulesVerifiedOn,
    required this.rulesVersion,
    required this.maturity,
    required this.coverage,
    required this.uncategorizedCount,
    required this.convertedEntryCount,
    required this.opportunities,
  });

  factory TaxReportView({
    required String jurisdiction,
    required int startYear,
    required String yearLabel,
    required DateTime yearStart,
    required DateTime yearEnd,
    required _ifz8weqz.EntityKind entityKind,
    required String currencyCode,
    required List<_i8pphqdm.TaxReportLineView> lines,
    required List<_iyg1xvx7.TaxLiabilityView> liabilities,
    required int totalLiabilityMinor,
    required int alreadyPaidMinor,
    required int balanceDueMinor,
    required List<String> assumptions,
    required List<String> sources,
    required DateTime rulesVerifiedOn,
    required String rulesVersion,
    required String maturity,
    required Map<String, String> coverage,
    required int uncategorizedCount,
    required int convertedEntryCount,
    required List<_i7gx5xr1.TaxOpportunityView> opportunities,
  }) = _TaxReportViewImpl;

  factory TaxReportView.fromJson(Map<String, dynamic> jsonSerialization) {
    return TaxReportView(
      jurisdiction: jsonSerialization['jurisdiction'] as String,
      startYear: jsonSerialization['startYear'] as int,
      yearLabel: jsonSerialization['yearLabel'] as String,
      yearStart: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['yearStart'],
      ),
      yearEnd: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['yearEnd'],
      ),
      entityKind: _ifz8weqz.EntityKind.fromJson(
        (jsonSerialization['entityKind'] as String),
      ),
      currencyCode: jsonSerialization['currencyCode'] as String,
      lines: _irkl4crj.Protocol()
          .deserialize<List<_i8pphqdm.TaxReportLineView>>(
            jsonSerialization['lines'],
          ),
      liabilities: _irkl4crj.Protocol()
          .deserialize<List<_iyg1xvx7.TaxLiabilityView>>(
            jsonSerialization['liabilities'],
          ),
      totalLiabilityMinor: jsonSerialization['totalLiabilityMinor'] as int,
      alreadyPaidMinor: jsonSerialization['alreadyPaidMinor'] as int,
      balanceDueMinor: jsonSerialization['balanceDueMinor'] as int,
      assumptions: _irkl4crj.Protocol().deserialize<List<String>>(
        jsonSerialization['assumptions'],
      ),
      sources: _irkl4crj.Protocol().deserialize<List<String>>(
        jsonSerialization['sources'],
      ),
      rulesVerifiedOn: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['rulesVerifiedOn'],
      ),
      rulesVersion: jsonSerialization['rulesVersion'] as String,
      maturity: jsonSerialization['maturity'] as String,
      coverage: _irkl4crj.Protocol().deserialize<Map<String, String>>(
        jsonSerialization['coverage'],
      ),
      uncategorizedCount: jsonSerialization['uncategorizedCount'] as int,
      convertedEntryCount: jsonSerialization['convertedEntryCount'] as int,
      opportunities: _irkl4crj.Protocol()
          .deserialize<List<_i7gx5xr1.TaxOpportunityView>>(
            jsonSerialization['opportunities'],
          ),
    );
  }

  /// ISO 3166-1 alpha-2 country code.
  String jurisdiction;

  /// The calendar year the tax year starts in.
  int startYear;

  /// How the authority writes the year: `2026/27` or `2026`.
  String yearLabel;

  DateTime yearStart;

  DateTime yearEnd;

  /// The entity kind.
  _ifz8weqz.EntityKind entityKind;

  /// ISO 4217 code every amount in this report is in.
  String currencyCode;

  /// Category totals and computed figures, in return order.
  List<_i8pphqdm.TaxReportLineView> lines;

  List<_iyg1xvx7.TaxLiabilityView> liabilities;

  int totalLiabilityMinor;

  int alreadyPaidMinor;

  /// Positive when more is owed, negative when a refund is due.
  int balanceDueMinor;

  /// Plain statements of what the computation assumed.
  List<String> assumptions;

  /// The authority pages the rates came from.
  List<String> sources;

  /// When the rule figures were last checked against the sources.
  DateTime rulesVerifiedOn;

  /// The rule pack version that produced the report: `gb-2026-r1`.
  String rulesVersion;

  /// Whether the pack's figures have been checked by a tax professional.
  String maturity;

  /// How completely the pack covers each section, by section name.
  Map<String, String> coverage;

  /// Entries the rule pack does not know, plus transactions with no category.
  int uncategorizedCount;

  /// Entries converted from another currency at their transaction date.
  int convertedEntryCount;

  List<_i7gx5xr1.TaxOpportunityView> opportunities;

  /// Returns a shallow copy of this [TaxReportView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  TaxReportView copyWith({
    String? jurisdiction,
    int? startYear,
    String? yearLabel,
    DateTime? yearStart,
    DateTime? yearEnd,
    _ifz8weqz.EntityKind? entityKind,
    String? currencyCode,
    List<_i8pphqdm.TaxReportLineView>? lines,
    List<_iyg1xvx7.TaxLiabilityView>? liabilities,
    int? totalLiabilityMinor,
    int? alreadyPaidMinor,
    int? balanceDueMinor,
    List<String>? assumptions,
    List<String>? sources,
    DateTime? rulesVerifiedOn,
    String? rulesVersion,
    String? maturity,
    Map<String, String>? coverage,
    int? uncategorizedCount,
    int? convertedEntryCount,
    List<_i7gx5xr1.TaxOpportunityView>? opportunities,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TaxReportView',
      'jurisdiction': jurisdiction,
      'startYear': startYear,
      'yearLabel': yearLabel,
      'yearStart': yearStart.toJson(),
      'yearEnd': yearEnd.toJson(),
      'entityKind': entityKind.toJson(),
      'currencyCode': currencyCode,
      'lines': lines.toJson(valueToJson: (v) => v.toJson()),
      'liabilities': liabilities.toJson(valueToJson: (v) => v.toJson()),
      'totalLiabilityMinor': totalLiabilityMinor,
      'alreadyPaidMinor': alreadyPaidMinor,
      'balanceDueMinor': balanceDueMinor,
      'assumptions': assumptions.toJson(),
      'sources': sources.toJson(),
      'rulesVerifiedOn': rulesVerifiedOn.toJson(),
      'rulesVersion': rulesVersion,
      'maturity': maturity,
      'coverage': coverage.toJson(),
      'uncategorizedCount': uncategorizedCount,
      'convertedEntryCount': convertedEntryCount,
      'opportunities': opportunities.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TaxReportView',
      'jurisdiction': jurisdiction,
      'startYear': startYear,
      'yearLabel': yearLabel,
      'yearStart': yearStart.toJson(),
      'yearEnd': yearEnd.toJson(),
      'entityKind': entityKind.toJson(),
      'currencyCode': currencyCode,
      'lines': lines.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'liabilities': liabilities.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
      'totalLiabilityMinor': totalLiabilityMinor,
      'alreadyPaidMinor': alreadyPaidMinor,
      'balanceDueMinor': balanceDueMinor,
      'assumptions': assumptions.toJson(),
      'sources': sources.toJson(),
      'rulesVerifiedOn': rulesVerifiedOn.toJson(),
      'rulesVersion': rulesVersion,
      'maturity': maturity,
      'coverage': coverage.toJson(),
      'uncategorizedCount': uncategorizedCount,
      'convertedEntryCount': convertedEntryCount,
      'opportunities': opportunities.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _TaxReportViewImpl extends TaxReportView {
  _TaxReportViewImpl({
    required String jurisdiction,
    required int startYear,
    required String yearLabel,
    required DateTime yearStart,
    required DateTime yearEnd,
    required _ifz8weqz.EntityKind entityKind,
    required String currencyCode,
    required List<_i8pphqdm.TaxReportLineView> lines,
    required List<_iyg1xvx7.TaxLiabilityView> liabilities,
    required int totalLiabilityMinor,
    required int alreadyPaidMinor,
    required int balanceDueMinor,
    required List<String> assumptions,
    required List<String> sources,
    required DateTime rulesVerifiedOn,
    required String rulesVersion,
    required String maturity,
    required Map<String, String> coverage,
    required int uncategorizedCount,
    required int convertedEntryCount,
    required List<_i7gx5xr1.TaxOpportunityView> opportunities,
  }) : super._(
         jurisdiction: jurisdiction,
         startYear: startYear,
         yearLabel: yearLabel,
         yearStart: yearStart,
         yearEnd: yearEnd,
         entityKind: entityKind,
         currencyCode: currencyCode,
         lines: lines,
         liabilities: liabilities,
         totalLiabilityMinor: totalLiabilityMinor,
         alreadyPaidMinor: alreadyPaidMinor,
         balanceDueMinor: balanceDueMinor,
         assumptions: assumptions,
         sources: sources,
         rulesVerifiedOn: rulesVerifiedOn,
         rulesVersion: rulesVersion,
         maturity: maturity,
         coverage: coverage,
         uncategorizedCount: uncategorizedCount,
         convertedEntryCount: convertedEntryCount,
         opportunities: opportunities,
       );

  /// Returns a shallow copy of this [TaxReportView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  TaxReportView copyWith({
    String? jurisdiction,
    int? startYear,
    String? yearLabel,
    DateTime? yearStart,
    DateTime? yearEnd,
    _ifz8weqz.EntityKind? entityKind,
    String? currencyCode,
    List<_i8pphqdm.TaxReportLineView>? lines,
    List<_iyg1xvx7.TaxLiabilityView>? liabilities,
    int? totalLiabilityMinor,
    int? alreadyPaidMinor,
    int? balanceDueMinor,
    List<String>? assumptions,
    List<String>? sources,
    DateTime? rulesVerifiedOn,
    String? rulesVersion,
    String? maturity,
    Map<String, String>? coverage,
    int? uncategorizedCount,
    int? convertedEntryCount,
    List<_i7gx5xr1.TaxOpportunityView>? opportunities,
  }) {
    return TaxReportView(
      jurisdiction: jurisdiction ?? this.jurisdiction,
      startYear: startYear ?? this.startYear,
      yearLabel: yearLabel ?? this.yearLabel,
      yearStart: yearStart ?? this.yearStart,
      yearEnd: yearEnd ?? this.yearEnd,
      entityKind: entityKind ?? this.entityKind,
      currencyCode: currencyCode ?? this.currencyCode,
      lines: lines ?? this.lines.map((e0) => e0.copyWith()).toList(),
      liabilities:
          liabilities ?? this.liabilities.map((e0) => e0.copyWith()).toList(),
      totalLiabilityMinor: totalLiabilityMinor ?? this.totalLiabilityMinor,
      alreadyPaidMinor: alreadyPaidMinor ?? this.alreadyPaidMinor,
      balanceDueMinor: balanceDueMinor ?? this.balanceDueMinor,
      assumptions: assumptions ?? this.assumptions.map((e0) => e0).toList(),
      sources: sources ?? this.sources.map((e0) => e0).toList(),
      rulesVerifiedOn: rulesVerifiedOn ?? this.rulesVerifiedOn,
      rulesVersion: rulesVersion ?? this.rulesVersion,
      maturity: maturity ?? this.maturity,
      coverage:
          coverage ??
          this.coverage.map(
            (
              key0,
              value0,
            ) => MapEntry(
              key0,
              value0,
            ),
          ),
      uncategorizedCount: uncategorizedCount ?? this.uncategorizedCount,
      convertedEntryCount: convertedEntryCount ?? this.convertedEntryCount,
      opportunities:
          opportunities ??
          this.opportunities.map((e0) => e0.copyWith()).toList(),
    );
  }
}

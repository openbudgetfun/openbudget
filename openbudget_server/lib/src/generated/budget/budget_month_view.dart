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
import 'package:openbudget_server/src/generated/protocol.dart' as _is0sbm8r;
import 'package:serverpod/serverpod.dart' as _is;

import '../budget/budget_month_summary.dart' as _i0uqacxt;
import '../budget/envelope_month_view.dart' as _iz4lb5a2;
import '../categories/category.dart' as _igagfyw0;

/// The whole Plan screen for one month: one call, computed by section 6.4.
abstract class BudgetMonthView
    implements _is.SerializableModel, _is.ProtocolSerialization {
  BudgetMonthView._({
    required this.entityId,
    required this.month,
    required this.currencyCode,
    required this.summary,
    required this.categories,
    required this.envelopes,
  });

  factory BudgetMonthView({
    required _is.UuidValue entityId,
    required int month,
    required String currencyCode,
    required _i0uqacxt.BudgetMonthSummary summary,
    required List<_igagfyw0.Category> categories,
    required List<_iz4lb5a2.EnvelopeMonthView> envelopes,
  }) = _BudgetMonthViewImpl;

  factory BudgetMonthView.fromJson(Map<String, dynamic> jsonSerialization) {
    return BudgetMonthView(
      entityId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['entityId'],
      ),
      month: jsonSerialization['month'] as int,
      currencyCode: jsonSerialization['currencyCode'] as String,
      summary: _is0sbm8r.Protocol().deserialize<_i0uqacxt.BudgetMonthSummary>(
        jsonSerialization['summary'],
      ),
      categories: _is0sbm8r.Protocol().deserialize<List<_igagfyw0.Category>>(
        jsonSerialization['categories'],
      ),
      envelopes: _is0sbm8r.Protocol()
          .deserialize<List<_iz4lb5a2.EnvelopeMonthView>>(
            jsonSerialization['envelopes'],
          ),
    );
  }

  _is.UuidValue entityId;

  /// yyyymm.
  int month;

  /// ISO 4217 base currency every amount here is in.
  String currencyCode;

  _i0uqacxt.BudgetMonthSummary summary;

  /// Every category, hidden ones included, in sortOrder.
  List<_igagfyw0.Category> categories;

  /// One row per envelope, hidden ones included, in category then envelope
  /// sortOrder.
  List<_iz4lb5a2.EnvelopeMonthView> envelopes;

  /// Returns a shallow copy of this [BudgetMonthView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  BudgetMonthView copyWith({
    _is.UuidValue? entityId,
    int? month,
    String? currencyCode,
    _i0uqacxt.BudgetMonthSummary? summary,
    List<_igagfyw0.Category>? categories,
    List<_iz4lb5a2.EnvelopeMonthView>? envelopes,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'BudgetMonthView',
      'entityId': entityId.toJson(),
      'month': month,
      'currencyCode': currencyCode,
      'summary': summary.toJson(),
      'categories': categories.toJson(valueToJson: (v) => v.toJson()),
      'envelopes': envelopes.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'BudgetMonthView',
      'entityId': entityId.toJson(),
      'month': month,
      'currencyCode': currencyCode,
      'summary': summary.toJsonForProtocol(),
      'categories': categories.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
      'envelopes': envelopes.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _BudgetMonthViewImpl extends BudgetMonthView {
  _BudgetMonthViewImpl({
    required _is.UuidValue entityId,
    required int month,
    required String currencyCode,
    required _i0uqacxt.BudgetMonthSummary summary,
    required List<_igagfyw0.Category> categories,
    required List<_iz4lb5a2.EnvelopeMonthView> envelopes,
  }) : super._(
         entityId: entityId,
         month: month,
         currencyCode: currencyCode,
         summary: summary,
         categories: categories,
         envelopes: envelopes,
       );

  /// Returns a shallow copy of this [BudgetMonthView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  BudgetMonthView copyWith({
    _is.UuidValue? entityId,
    int? month,
    String? currencyCode,
    _i0uqacxt.BudgetMonthSummary? summary,
    List<_igagfyw0.Category>? categories,
    List<_iz4lb5a2.EnvelopeMonthView>? envelopes,
  }) {
    return BudgetMonthView(
      entityId: entityId ?? this.entityId,
      month: month ?? this.month,
      currencyCode: currencyCode ?? this.currencyCode,
      summary: summary ?? this.summary.copyWith(),
      categories:
          categories ?? this.categories.map((e0) => e0.copyWith()).toList(),
      envelopes:
          envelopes ?? this.envelopes.map((e0) => e0.copyWith()).toList(),
    );
  }
}

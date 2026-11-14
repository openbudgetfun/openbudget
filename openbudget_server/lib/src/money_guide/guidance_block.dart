import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;

/// Builds the `guidance` block that travels with every tax, knowledge and
/// summary tool result (docs/money-guide.md, section 7.4, rule 9).
///
/// The block carries the regulatory perimeter, the disclaimer key, the
/// signpost targets and the jurisdiction state, so MCP clients and
/// bring-your-own providers receive the guardrails even without the system
/// prompt.
Map<String, Object?> buildGuidanceBlock({
  required Entity entity,
  String? rulesVersion,
  String? maturity,
  bool crossBorder = false,
}) {
  final jurisdiction = TaxJurisdiction.fromCountryCode(entity.countryCode);
  final perimeter = jurisdiction == null
      ? null
      : guidancePerimeterFor(jurisdiction);

  final packMaturity =
      maturity ??
      (jurisdiction == null
          ? null
          : TaxRules.forJurisdiction(jurisdiction).manifest.maturity.name);
  final jurisdictionState = jurisdiction == null
      ? 'universal'
      : (packMaturity == 'reviewed' ? 'full' : 'preview');

  final signposts = <String>[
    if (perimeter != null) perimeter.professional,
    if (perimeter != null)
      for (final topic in perimeter.signpostOnlyTopics) topic.title,
  ];

  final block = <String, Object?>{
    'disclaimerKey': perimeter?.disclaimerKey,
    'scopeStatement': perimeter?.scopeStatement,
    'professional': perimeter?.professional,
    'signposts': signposts,
    'reservedTopics': [
      if (perimeter != null)
        for (final topic in perimeter.reservedTopics) topic.id,
    ],
    'jurisdictionState': jurisdictionState,
    'crossBorder': crossBorder,
  };
  if (rulesVersion != null) {
    block['rulesVersion'] = rulesVersion;
  }
  return block;
}

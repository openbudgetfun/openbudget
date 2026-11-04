import 'package:openbudget_core/src/tax/gb/gb_tax_rules.dart';
import 'package:openbudget_core/src/tax/tax_model.dart';
import 'package:openbudget_core/src/tax/tax_rule_pack.dart';
import 'package:openbudget_core/src/tax/us/us_tax_rules.dart';

/// The rule packs OpenBudget ships, by jurisdiction.
///
/// The server, the app, and the agent all compute with these, so a figure
/// never differs between a report and an answer.
abstract final class TaxRules {
  /// The pack for [jurisdiction], or null while its rules are not built.
  static TaxRulePack? forJurisdiction(TaxJurisdiction jurisdiction) =>
      switch (jurisdiction) {
        TaxJurisdiction.gb => const GbTaxRules(),
        TaxJurisdiction.us => const UsTaxRules(),
        TaxJurisdiction.ng => null,
        TaxJurisdiction.de => null,
      };
}

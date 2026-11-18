import 'package:meta/meta.dart';
import 'package:openbudget_core/src/tax/tax_model.dart';

/// A pattern the Money guide must never propose, design, quantify as a
/// plan, or encourage. If the user raises one, the guide says the app does
/// not help design it and signposts a qualified adviser.
///
/// From the `tax-planning-guardrails` skill's anti-avoidance reference:
/// each item is a "main purpose is a tax advantage" or "lacks substance"
/// pattern, and the design inference behind them must be reviewed by
/// counsel.
@immutable
final class NeverSuggestItem {
  const NeverSuggestItem({
    required this.id,
    required this.pattern,
    required this.why,
  });

  /// Stable identifier: `income-splitting`.
  final String id;

  /// The pattern, in one line.
  final String pattern;

  /// The rule the pattern trips or the substance it lacks.
  final String why;
}

/// The never-suggest list. The assistant, the packs and every MCP client
/// share this one source (money-guide section 7.4, rule 4).
const List<NeverSuggestItem> neverSuggestList = [
  NeverSuggestItem(
    id: 'marketeted-avoidance',
    pattern:
        'Schemes promoted as an "HMRC-approved loophole", marketed contrived '
        'avoidance, loan-charge style remuneration trusts, or anything '
        'notifiable under DOTAS or counteractable by the GAAR.',
    why: 'Marketed avoidance the anti-abuse rules exist to counter.',
  ),
  NeverSuggestItem(
    id: 'income-splitting',
    pattern:
        'Income splitting to a spouse or family member through shares or a '
        'role without genuine work or capital.',
    why: 'Settlements legislation risk (ITTOIA 2005 ss.624-628).',
  ),
  NeverSuggestItem(
    id: 'disguised-employment',
    pattern:
        'Disguised employment through a personal service company or other '
        'artificial intermediary structures.',
    why: 'IR35 and the off-payroll rules.',
  ),
  NeverSuggestItem(
    id: 'below-market-owner-pay',
    pattern:
        'Paying a controlling owner a below-market salary in an S '
        'corporation or GmbH.',
    why:
        'Reasonable compensation case law in the US; verdeckte '
        'Gewinnausschüttung in Germany.',
  ),
  NeverSuggestItem(
    id: 'wash-sales',
    pattern:
        'Wash sales; round-tripping charitable gifts or donor-advised-fund '
        'arrangements that give back control; transactions without economic '
        'substance.',
    why: 'Economic substance doctrine and the wash sale rules.',
  ),
  NeverSuggestItem(
    id: 'concealment',
    pattern:
        'Undeclared foreign accounts, nominee structures, suppression of '
        'income, false residence claims, falsified rent receipts or '
        'home-office days.',
    why: 'Concealment is evasion, not planning.',
  ),
  NeverSuggestItem(
    id: 'residence-of-convenience',
    pattern:
        'Moving money, assets or residence for the primary purpose of a tax '
        "result without genuine change in the user's life.",
    why: 'Lacks the substance the residence and anti-abuse rules test for.',
  ),
  NeverSuggestItem(
    id: 'personal-costs-as-business',
    pattern:
        'Charging personal costs to a company, or recording private spending '
        'as business use, to reduce profit.',
    why:
        "Not a deductible expense; applies to every pack's business-use "
        'percentage.',
  ),
  NeverSuggestItem(
    id: 'director-loan-bed-and-breakfast',
    pattern:
        'Borrowing from a company repeatedly to avoid dividend tax, or '
        "repaying and redrawing a director's loan to dodge s455.",
    why: "Bed-and-breakfasting a director's loan account.",
  ),
  NeverSuggestItem(
    id: 'backdating',
    pattern: 'Backdating documents, dividend minutes or vouchers.',
    why: 'A backdated document is not evidence of what happened.',
  ),
];

/// One statutory anti-abuse rule behind the never-suggest list, per
/// country. The statutes are pointers for counsel, not text to quote: the
/// skill could not read most of them.
@immutable
final class AntiAvoidanceRule {
  const AntiAvoidanceRule({
    required this.jurisdiction,
    required this.id,
    required this.name,
  });

  final TaxJurisdiction jurisdiction;

  /// Stable identifier, prefixed by country: `gb.settlements`.
  final String id;

  /// The rule's usual name.
  final String name;
}

/// The anti-abuse rules each country enforces behind the list.
const List<AntiAvoidanceRule> antiAvoidanceRules = [
  AntiAvoidanceRule(
    jurisdiction: TaxJurisdiction.gb,
    id: 'gb.gaar',
    name: 'General Anti-Abuse Rule (Finance Act 2013 Part 5)',
  ),
  AntiAvoidanceRule(
    jurisdiction: TaxJurisdiction.gb,
    id: 'gb.dotas',
    name: 'DOTAS and POTAS (FA 2004 Part 7)',
  ),
  AntiAvoidanceRule(
    jurisdiction: TaxJurisdiction.gb,
    id: 'gb.ir35',
    name: 'IR35 and the off-payroll rules (ITEPA Part 2 Chapter 10)',
  ),
  AntiAvoidanceRule(
    jurisdiction: TaxJurisdiction.gb,
    id: 'gb.settlements',
    name: 'Settlements legislation (ITTOIA 2005 ss.624 to 628)',
  ),
  AntiAvoidanceRule(
    jurisdiction: TaxJurisdiction.gb,
    id: 'gb.cfa2017',
    name: 'Failure to prevent facilitation of tax evasion (CFA 2017)',
  ),
  AntiAvoidanceRule(
    jurisdiction: TaxJurisdiction.us,
    id: 'us.economic-substance',
    name: 'Economic substance doctrine (IRC §7701(o))',
  ),
  AntiAvoidanceRule(
    jurisdiction: TaxJurisdiction.us,
    id: 'us.reasonable-compensation',
    name: 'S-corporation reasonable compensation case law',
  ),
  AntiAvoidanceRule(
    jurisdiction: TaxJurisdiction.us,
    id: 'us.wash-sale',
    name: 'Wash sale rules',
  ),
  AntiAvoidanceRule(
    jurisdiction: TaxJurisdiction.de,
    id: 'de.ao-42',
    name: 'Gestaltungsmissbrauch (§42 AO)',
  ),
  AntiAvoidanceRule(
    jurisdiction: TaxJurisdiction.de,
    id: 'de.vga',
    name: 'Verdeckte Gewinnausschüttung',
  ),
  AntiAvoidanceRule(
    jurisdiction: TaxJurisdiction.de,
    id: 'de.ao-370',
    name: 'Steuerhinterziehung (§370 AO)',
  ),
  AntiAvoidanceRule(
    jurisdiction: TaxJurisdiction.ng,
    id: 'ng.ntaa-46',
    name: 'Artificial transactions (NTAA 2025 s.46)',
  ),
  AntiAvoidanceRule(
    jurisdiction: TaxJurisdiction.ng,
    id: 'ng.ntaa-47',
    name: 'Prohibited tax avoidance arrangement (NTAA 2025 s.47)',
  ),
  AntiAvoidanceRule(
    jurisdiction: TaxJurisdiction.ng,
    id: 'ng.nta-artificial',
    name:
        'Artificial transactions between connected persons (NTA 2025 s.191 '
        'or s.193)',
  ),
];

/// The anti-abuse rules [jurisdiction] enforces.
Iterable<AntiAvoidanceRule> antiAvoidanceRulesFor(
  TaxJurisdiction jurisdiction,
) => antiAvoidanceRules.where((rule) => rule.jurisdiction == jurisdiction);

/// The never-suggest item with [id], or null.
NeverSuggestItem? neverSuggestItem(String id) {
  for (final item in neverSuggestList) {
    if (item.id == id) {
      return item;
    }
  }
  return null;
}

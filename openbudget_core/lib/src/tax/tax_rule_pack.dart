import 'package:meta/meta.dart';
import 'package:openbudget_core/src/tax/tax_model.dart';
import 'package:openbudget_core/src/tax/tax_profile.dart';

/// Everything one computation needs: whose books, which year, what happened.
@immutable
class TaxInput {
  const TaxInput({
    required this.profile,
    required this.year,
    required this.entries,
    this.linked = const [],
  });

  final TaxProfile profile;
  final TaxYear year;

  /// Entries dated inside [year], in the jurisdiction's currency.
  final List<TaxEntry> entries;

  /// Books that feed this one. An individual's input links the sole-trade
  /// businesses they own, so their profit lands on the personal return. A
  /// company's input may link its director's personal books so salary and
  /// dividend choices can be weighed together.
  final List<TaxInput> linked;
}

/// The tax rules of one jurisdiction.
///
/// A rule pack is pure: the same input always gives the same report. Rates
/// live in per-year tables inside the pack, each with the authority pages
/// they came from and the date they were last checked.
abstract interface class TaxRulePack {
  TaxJurisdiction get jurisdiction;

  /// What this pack covers, per section, and how mature it is.
  TaxPackManifest get manifest;

  /// Tax years whose rates this pack knows, by [TaxYear.startYear].
  Set<int> get supportedStartYears;

  /// The tax year [date] falls in.
  TaxYear taxYearFor(DateTime date);

  /// The tax year that starts in [startYear].
  TaxYear taxYear(int startYear);

  /// Version, sources and verified-on date for [startYear].
  ///
  /// Throws [UnsupportedTaxYearException] when the year's rates are not in
  /// this pack.
  TaxRuleSet ruleSet(int startYear);

  /// Decodes this pack's profile from its stored JSON shape.
  /// [TaxProfile.fromJson] delegates here, so this is the single
  /// definition of which fields the pack stores.
  ///
  /// Throws [FormatException] naming the field for a wrong type, an
  /// unknown enum value, a negative count or a missing required one.
  TaxProfile profileFromJson(Map<String, Object?> json);

  /// The questions the app asks to build the profile for books of [kind]:
  /// [commonTaxProfileQuestions] first, then the pack's own, keeping only
  /// the questions that kind answers, in form order. Each answer is stored
  /// under the question's [TaxProfileQuestion.key].
  List<TaxProfileQuestion> profileQuestions(EntityKind kind);

  /// Categories that may appear in books of [kind], in return order.
  List<TaxCategory> categoriesFor(EntityKind kind);

  /// The category with [code], or null when this pack does not know it.
  TaxCategory? category(String code);

  /// Maps a universal category code onto this pack's own code for books
  /// of [kind], or returns null when the pack has no home for it. A
  /// universal entry whose code maps lands in the report under the pack's
  /// code; one that does not map counts as uncategorised. Codes outside
  /// the universal catalogue return null.
  String? mapUniversalCategory(String universalCode, EntityKind kind);

  /// Computes the position for [input].
  ///
  /// Throws [UnsupportedTaxYearException] when the year's rates are not in
  /// this pack.
  TaxReport report(TaxInput input);

  /// Legal ways to owe less, given [input] and its [report].
  List<TaxOpportunity> opportunities(TaxInput input, TaxReport report);

  /// The filing and payment dates [period] creates for [profile], sorted by
  /// due date.
  ///
  /// A year's dates fall inside it and after it: the return for the year
  /// is due after it ends, and its instalments fall inside it. The dates
  /// come from the country's skill, with any weekend or holiday
  /// roll-forward the skill specifies. A deadline the profile's answers
  /// decide says so.
  ///
  /// Throws [UnsupportedTaxYearException] when [period] is not a year this
  /// pack knows, and [ArgumentError] for another country's year or profile.
  List<TaxDeadline> deadlines(TaxYear period, TaxProfile profile);
}

/// Checks the arguments of [TaxRulePack.deadlines] for [pack].
void requireTaxDeadlineInput(
  TaxRulePack pack,
  TaxYear period,
  TaxProfile profile,
) {
  if (period.jurisdiction != pack.jurisdiction) {
    throw ArgumentError.value(
      period,
      'period',
      'is not a ${pack.jurisdiction.countryCode} tax year',
    );
  }
  if (profile.jurisdiction != pack.jurisdiction) {
    throw ArgumentError.value(
      profile,
      'profile',
      'is not a ${pack.jurisdiction.countryCode} tax profile',
    );
  }
  if (!pack.supportedStartYears.contains(period.startYear)) {
    throw UnsupportedTaxYearException(pack.jurisdiction, period.startYear);
  }
}

/// Thrown when a pack has no rates for the requested year.
class UnsupportedTaxYearException implements Exception {
  const UnsupportedTaxYearException(this.jurisdiction, this.startYear);

  final TaxJurisdiction jurisdiction;
  final int startYear;

  @override
  String toString() =>
      'No ${jurisdiction.countryCode} tax rates for the year starting '
      '$startYear.';
}

/// One rate band: income above the previous band's ceiling up to
/// [ceilingMinor] is taxed at [rateBasisPoints].
@immutable
class TaxBand {
  const TaxBand({
    required this.label,
    required this.rateBasisPoints,
    this.ceilingMinor,
  });

  final String label;

  /// 2000 is 20%.
  final int rateBasisPoints;

  /// The top of the band, or null for the open-ended top band.
  final int? ceilingMinor;
}

/// Applies progressive [bands] to [baseMinor], starting [startMinor] up the
/// bands (for income already taxed lower down, such as non-savings income
/// below savings income).
///
/// Each slice's tax is rounded down to whole minor units, as authorities
/// compute in the taxpayer's favour.
List<TaxBandSlice> applyTaxBands(
  int baseMinor,
  List<TaxBand> bands, {
  int startMinor = 0,
}) {
  final slices = <TaxBandSlice>[];
  var remaining = baseMinor;
  var position = startMinor;
  for (final band in bands) {
    if (remaining <= 0) {
      break;
    }
    final ceiling = band.ceilingMinor;
    if (ceiling != null && position >= ceiling) {
      continue;
    }
    final room = ceiling == null ? remaining : ceiling - position;
    final slice = room < remaining ? room : remaining;
    if (slice > 0) {
      slices.add(
        TaxBandSlice(
          label: band.label,
          baseMinor: slice,
          rateBasisPoints: band.rateBasisPoints,
          taxMinor: slice * band.rateBasisPoints ~/ 10000,
        ),
      );
    }
    remaining -= slice;
    position += slice;
  }
  return slices;
}

/// Sums the tax across [slices].
int sumBandTax(List<TaxBandSlice> slices) =>
    slices.fold(0, (sum, slice) => sum + slice.taxMinor);

/// Totals [entries] by category code.
Map<String, int> totalsByCategory(
  Iterable<TaxEntry> entries, {
  int Function(TaxEntry entry)? amountOf,
}) {
  final totals = <String, int>{};
  for (final entry in entries) {
    final amount = amountOf?.call(entry) ?? entry.allowableMinor;
    totals.update(
      entry.categoryCode,
      (sum) => sum + amount,
      ifAbsent: () => amount,
    );
  }
  return totals;
}

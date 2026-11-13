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

  /// Categories that may appear in books of [kind], in return order.
  List<TaxCategory> categoriesFor(EntityKind kind);

  /// The category with [code], or null when this pack does not know it.
  TaxCategory? category(String code);

  /// Computes the position for [input].
  ///
  /// Throws [UnsupportedTaxYearException] when the year's rates are not in
  /// this pack.
  TaxReport report(TaxInput input);

  /// Legal ways to owe less, given [input] and its [report].
  List<TaxOpportunity> opportunities(TaxInput input, TaxReport report);
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

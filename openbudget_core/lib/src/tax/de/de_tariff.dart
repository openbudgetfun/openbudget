import 'package:meta/meta.dart';
import 'package:openbudget_core/src/tax/tax_model.dart';

/// The § 32a EStG tariff for one Veranlagungszeitraum.
///
/// The coefficients are stored as whole hundredths so the quadratic zones can
/// be evaluated with integer arithmetic; the law prescribes the formula, not a
/// float approximation, and an exact evaluation never loses a euro to binary
/// rounding.
@immutable
final class DeTariff {
  const DeTariff({
    required this.grundfreibetrag,
    required this.zoneOneEnd,
    required this.zoneTwoEnd,
    required this.topZoneStart,
    required this.zoneOneCoefficientHundredths,
    required this.zoneTwoCoefficientHundredths,
    required this.zoneTwoOffsetHundredths,
    required this.zoneThreeOffsetHundredths,
    required this.zoneFourOffsetHundredths,
  });

  /// Income up to and including this many whole euros is untaxed.
  final int grundfreibetrag;

  /// Last whole euro of the first progressive zone. `z` is measured from here.
  final int zoneOneEnd;

  /// Last whole euro of the second progressive zone.
  final int zoneTwoEnd;

  /// Last whole euro taxed at 42 %. The next euro is taxed at 45 %.
  final int topZoneStart;

  /// `914.51` is stored as `91451`.
  final int zoneOneCoefficientHundredths;

  /// `173.10` is stored as `17310`.
  final int zoneTwoCoefficientHundredths;

  /// The constant added inside the second zone: `1 034.87` is `103487`.
  final int zoneTwoOffsetHundredths;

  /// The constant subtracted in the 42 % zone: `11 135.63` is `1113563`.
  final int zoneThreeOffsetHundredths;

  /// The constant subtracted in the 45 % zone: `19 470.38` is `1947038`.
  final int zoneFourOffsetHundredths;
}

/// The constant `1 400` of the first progressive zone, in whole euros.
const int _zoneOneOffset = 1400;

/// The constant `2 397` of the second progressive zone, in whole euros.
const int _zoneTwoSlopeOffset = 2397;

/// Ten thousand, squared: y and z are ten-thousandths, the same again in the
/// denominator, so every quadratic zone is divided by this once.
const int _quadraticDenominator = 10000000000;

/// The tarifliche Einkommensteuer for [taxableIncomeMinor], in cents.
///
/// § 32a Abs. 1 EStG: the zu versteuernde Einkommen and the tax it produces are
/// both rounded down to whole euros. `x` is therefore the income in whole
/// euros, floored once, and the result comes back in cents for the report.
int deIncomeTaxMinor(int taxableIncomeMinor, DeTariff tariff) {
  final income = taxableIncomeMinor ~/ 100;
  if (income <= tariff.grundfreibetrag) {
    return 0;
  }
  final euros = switch (income) {
    final value when value <= tariff.zoneOneEnd => _firstZone(value, tariff),
    final value when value <= tariff.zoneTwoEnd => _secondZone(value, tariff),
    final value when value <= tariff.topZoneStart => _linearZone(
      value,
      42,
      tariff.zoneThreeOffsetHundredths,
    ),
    final value => _linearZone(value, 45, tariff.zoneFourOffsetHundredths),
  };
  return euros * 100;
}

/// The marginal rate at [taxableIncomeMinor] in basis points.
///
/// This is the derivative of the § 32a formula, used to estimate what an extra
/// euro of income costs. It is not part of the statutory computation.
int deMarginalRateBasisPoints(int taxableIncomeMinor, DeTariff tariff) {
  final income = taxableIncomeMinor ~/ 100;
  if (income <= tariff.grundfreibetrag) {
    return 0;
  }
  if (income <= tariff.zoneOneEnd) {
    final excess = income - tariff.grundfreibetrag;
    return (2 * tariff.zoneOneCoefficientHundredths * excess) ~/ 1000000 +
        _zoneOneOffset;
  }
  if (income <= tariff.zoneTwoEnd) {
    final excess = income - tariff.zoneOneEnd;
    return (2 * tariff.zoneTwoCoefficientHundredths * excess) ~/ 1000000 +
        _zoneTwoSlopeOffset;
  }
  return income <= tariff.topZoneStart ? 4200 : 4500;
}

/// The tariff split into its four statutory zones, for display.
///
/// Each slice's [TaxBandSlice.rateBasisPoints] is the zone's effective rate
/// rounded down; [TaxBandSlice.taxMinor] is exact and sums to
/// [deIncomeTaxMinor].
List<TaxBandSlice> deTariffSlices(int taxableIncomeMinor, DeTariff tariff) {
  final income = taxableIncomeMinor ~/ 100;
  if (income <= tariff.grundfreibetrag) {
    return const [];
  }
  final boundaries = [
    tariff.grundfreibetrag,
    tariff.zoneOneEnd,
    tariff.zoneTwoEnd,
    tariff.topZoneStart,
    income,
  ].map((value) => value > income ? income : value).toList();
  const labels = [
    'Stufe 1: Eingangssatz 14 %',
    'Stufe 2: Progressionsstufe',
    'Stufe 3: 42 %',
    'Stufe 4: 45 %',
  ];
  final slices = <TaxBandSlice>[];
  for (var index = 0; index < labels.length; index++) {
    final start = boundaries[index];
    final end = boundaries[index + 1];
    if (end <= start) {
      continue;
    }
    final base = end - start;
    final tax =
        deIncomeTaxMinor(end * 100, tariff) -
        deIncomeTaxMinor(start * 100, tariff);
    slices.add(
      TaxBandSlice(
        label: labels[index],
        baseMinor: base * 100,
        rateBasisPoints: tax * 10000 ~/ (base * 100),
        taxMinor: tax,
      ),
    );
  }
  return slices;
}

int _firstZone(int income, DeTariff tariff) {
  final excess = BigInt.from(income - tariff.grundfreibetrag);
  final numerator =
      (BigInt.from(tariff.zoneOneCoefficientHundredths) * excess +
          BigInt.from(_zoneOneOffset * 1000000)) *
      excess;
  return _divide(numerator);
}

int _secondZone(int income, DeTariff tariff) {
  final excess = BigInt.from(income - tariff.zoneOneEnd);
  final numerator =
      (BigInt.from(tariff.zoneTwoCoefficientHundredths) * excess +
              BigInt.from(_zoneTwoSlopeOffset * 1000000)) *
          excess +
      BigInt.from(tariff.zoneTwoOffsetHundredths * 100000000);
  return _divide(numerator);
}

int _linearZone(int income, int ratePercent, int offsetHundredths) =>
    (ratePercent * income - offsetHundredths) ~/ 100;

int _divide(BigInt numerator) =>
    (numerator ~/ BigInt.from(_quadraticDenominator)).toInt();

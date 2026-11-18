import 'package:openbudget_core/src/ledger/exchange_rate.dart';

/// Converts split lines and assigns residue to the first largest line.
List<int> splitBaseAmounts({
  required List<int> lineAmounts,
  required int baseTotal,
  required ExactDecimal rate,
  required int fromExponent,
  required int toExponent,
}) {
  requireSafeMinor(baseTotal);
  if (lineAmounts.isEmpty) {
    throw ArgumentError('A split needs at least one line.');
  }
  final converted = <int>[];
  var largest = 0;
  var sum = BigInt.zero;
  for (var i = 0; i < lineAmounts.length; i++) {
    final amount = convertMinorUnits(
      amountMinor: lineAmounts[i],
      exchangeRate: rate,
      transactionExponent: fromExponent,
      functionalExponent: toExponent,
    );
    converted.add(amount);
    sum += BigInt.from(amount);
    if (lineAmounts[i].abs() > lineAmounts[largest].abs()) largest = i;
  }
  final corrected =
      BigInt.from(converted[largest]) + BigInt.from(baseTotal) - sum;
  if (corrected.abs() > BigInt.from(maxSafeMinor)) {
    throw RangeError('Split residue exceeds the web-safe range.');
  }
  converted[largest] = corrected.toInt();
  return converted;
}

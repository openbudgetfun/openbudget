import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/generated/protocol.dart';

/// Input rules shared by the budget read and write services.
abstract final class BudgetValidation {
  /// Rejects a month that is not a real yyyymm calendar month.
  static void requireMonth(int month) {
    if (!MonthKey.isValid(month)) {
      throw ValidationException(
        message: 'Month must be a valid yyyymm calendar month',
      );
    }
  }

  /// Returns [month] after checking it, so a tested loop stays explicit.
  static int checkedMonth(int month) {
    requireMonth(month);
    return month;
  }

  /// Rejects an amount that would lose precision on a web client.
  static int requireSafeMinor(int value, String field) {
    if (BigInt.from(value).abs() > BigInt.from(maxSafeMinor)) {
      throw ValidationException(
        message: '$field exceeds the safe minor-unit range',
      );
    }
    return value;
  }

  /// Adds two safe minor amounts without wrapping or clamping.
  static int checkedSum(int first, int second, String context) {
    final sum = BigInt.from(first) + BigInt.from(second);
    if (sum.abs() > BigInt.from(maxSafeMinor)) {
      throw ValidationException(
        message: '$context exceeds the safe minor-unit range',
      );
    }
    return sum.toInt();
  }

  /// The first civil day after the month, including across a year boundary.
  static DateTime firstDayOfNextMonth(int month) =>
      DateTime.utc(month ~/ 100, month % 100 + 1);
}

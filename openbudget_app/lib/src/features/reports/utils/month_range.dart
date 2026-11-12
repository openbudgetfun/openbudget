import 'package:openbudget_core/openbudget_core.dart';

/// The first month in a range of [monthCount] months ending at [endMonth].
///
/// A count below one still covers [endMonth], matching the server's
/// requirement that `fromMonth` never comes after `toMonth`.
int monthRangeStart(int endMonth, int monthCount) {
  var start = endMonth;
  for (var index = 1; index < monthCount; index++) {
    start = MonthKey.previous(start);
  }
  return start;
}

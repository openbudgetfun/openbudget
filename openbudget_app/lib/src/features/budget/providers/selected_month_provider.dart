import 'package:openbudget_core/openbudget_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'selected_month_provider.g.dart';

/// The month the plan screens show, as an int yyyymm (202611).
///
/// An integer has no time-zone ambiguity, compares directly, and goes
/// straight into `budget.getMonth` and `MonthKey`.
@riverpod
class SelectedMonth extends _$SelectedMonth {
  @override
  int build(String entityId) => MonthKey.fromDate(DateTime.now());

  /// Jumps to an exact month.
  void setMonth(int month) {
    MonthKey.validate(month);
    state = month;
  }

  void goToPreviousMonth() {
    state = MonthKey.previous(state);
  }

  void goToNextMonth() {
    state = MonthKey.next(state);
  }

  /// The month's first civil day, for date pickers and ranges.
  DateTime get firstDate => MonthKey.toFirstDate(state);

  /// The month's label data as (year, month) for header widgets.
  ({int year, int month}) get yearMonth => (year: state ~/ 100, month: state % 100);
}

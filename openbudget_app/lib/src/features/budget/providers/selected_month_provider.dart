import 'package:equatable/equatable.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'selected_month_provider.g.dart';

class BudgetMonth extends Equatable {
  const BudgetMonth({required this.year, required this.month});

  final int year;
  final int month;

  @override
  List<Object?> get props => [year, month];
}

@riverpod
class SelectedMonth extends _$SelectedMonth {
  @override
  BudgetMonth build(String budgetId) {
    final now = DateTime.now();
    return BudgetMonth(year: now.year, month: now.month);
  }

  void setMonth(int year, int month) {
    state = BudgetMonth(year: year, month: month);
  }

  void goToPreviousMonth() {
    final current = state;
    if (current.month == 1) {
      state = BudgetMonth(year: current.year - 1, month: 12);
    } else {
      state = BudgetMonth(year: current.year, month: current.month - 1);
    }
  }

  void goToNextMonth() {
    final current = state;
    if (current.month == 12) {
      state = BudgetMonth(year: current.year + 1, month: 1);
    } else {
      state = BudgetMonth(year: current.year, month: current.month + 1);
    }
  }
}

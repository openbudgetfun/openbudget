import 'package:hooks_riverpod/hooks_riverpod.dart';

enum BalanceStyle { standard, differentiateWithoutColor }

enum NumberFormatStyle { standard, european }

enum CurrencyPlacementStyle { beforeAmount, afterAmount }

enum DateFormatStyle { monthDayYear, dayMonthYear, yearMonthDay }

final balanceStyleProvider =
    NotifierProvider<BalanceStyleNotifier, BalanceStyle>(
      BalanceStyleNotifier.new,
    );

class BalanceStyleNotifier extends Notifier<BalanceStyle> {
  @override
  BalanceStyle build() => BalanceStyle.standard;

  // ignore: use_setters_to_change_properties, Keep explicit command-style API for consistency with other notifiers.
  void setBalanceStyle(BalanceStyle style) {
    state = style;
  }
}

final numberFormatStyleProvider =
    NotifierProvider<NumberFormatStyleNotifier, NumberFormatStyle>(
      NumberFormatStyleNotifier.new,
    );

class NumberFormatStyleNotifier extends Notifier<NumberFormatStyle> {
  @override
  NumberFormatStyle build() => NumberFormatStyle.standard;

  // ignore: use_setters_to_change_properties, Keep explicit command-style API for consistency with other notifiers.
  void setNumberFormat(NumberFormatStyle style) {
    state = style;
  }
}

final currencyPlacementStyleProvider =
    NotifierProvider<CurrencyPlacementStyleNotifier, CurrencyPlacementStyle>(
      CurrencyPlacementStyleNotifier.new,
    );

class CurrencyPlacementStyleNotifier extends Notifier<CurrencyPlacementStyle> {
  @override
  CurrencyPlacementStyle build() => CurrencyPlacementStyle.beforeAmount;

  // ignore: use_setters_to_change_properties, Keep explicit command-style API for consistency with other notifiers.
  void setCurrencyPlacement(CurrencyPlacementStyle style) {
    state = style;
  }
}

final dateFormatStyleProvider =
    NotifierProvider<DateFormatStyleNotifier, DateFormatStyle>(
      DateFormatStyleNotifier.new,
    );

class DateFormatStyleNotifier extends Notifier<DateFormatStyle> {
  @override
  DateFormatStyle build() => DateFormatStyle.monthDayYear;

  // ignore: use_setters_to_change_properties, Keep explicit command-style API for consistency with other notifiers.
  void setDateFormat(DateFormatStyle style) {
    state = style;
  }
}

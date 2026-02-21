import 'package:hooks_riverpod/hooks_riverpod.dart';

enum BalanceStyle { standard, differentiateWithoutColor }

enum AppIconStyle { primary, v1, v2, v3, v4, v5 }

enum NumberFormatStyle { standard, european }

enum CurrencyPlacementStyle { beforeAmount, afterAmount }

enum DateFormatStyle { monthDayYear, dayMonthYear, yearMonthDay }

const hiddenAmountPlaceholder = '••••';

extension AppIconStyleAssets on AppIconStyle {
  String get previewAssetPath => switch (this) {
    AppIconStyle.primary => 'assets/branding/logos/ob_primary_light_512.png',
    AppIconStyle.v1 => 'assets/branding/logos/ob_v1_light_preview.png',
    AppIconStyle.v2 => 'assets/branding/logos/ob_v2_light_preview.png',
    AppIconStyle.v3 => 'assets/branding/logos/ob_v3_light_preview.png',
    AppIconStyle.v4 => 'assets/branding/logos/ob_v4_light_preview.png',
    AppIconStyle.v5 => 'assets/branding/logos/ob_v5_light_preview.png',
  };
}

final balanceStyleProvider =
    NotifierProvider<BalanceStyleNotifier, BalanceStyle>(
      BalanceStyleNotifier.new,
    );

final appIconStyleProvider =
    NotifierProvider<AppIconStyleNotifier, AppIconStyle>(
      AppIconStyleNotifier.new,
    );

final hideAmountsProvider = NotifierProvider<HideAmountsNotifier, bool>(
  HideAmountsNotifier.new,
);

final hideProgressBarsProvider =
    NotifierProvider<HideProgressBarsNotifier, bool>(
      HideProgressBarsNotifier.new,
    );

class BalanceStyleNotifier extends Notifier<BalanceStyle> {
  @override
  BalanceStyle build() => BalanceStyle.standard;

  // ignore: use_setters_to_change_properties, Keep explicit command-style API for consistency with other notifiers.
  void setBalanceStyle(BalanceStyle style) {
    state = style;
  }
}

class AppIconStyleNotifier extends Notifier<AppIconStyle> {
  @override
  AppIconStyle build() => AppIconStyle.primary;

  // ignore: use_setters_to_change_properties, Keep explicit command-style API for consistency with other notifiers.
  void setAppIconStyle(AppIconStyle style) {
    state = style;
  }
}

class HideAmountsNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  // ignore: use_setters_to_change_properties, Keep explicit command-style API for consistency with other notifiers.
  void setHideAmounts({required bool value}) {
    state = value;
  }
}

class HideProgressBarsNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  // ignore: use_setters_to_change_properties, Keep explicit command-style API for consistency with other notifiers.
  void setHideProgressBars({required bool value}) {
    state = value;
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

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/src/features/settings/providers/ui_preferences_store.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

enum BalanceStyle { standard, differentiateWithoutColor }

/// The colourways of the OpenBudget mark someone can pick for the app's
/// in-app branding. `primary` is the paper mark, the shipped app icon.
enum AppIconStyle { primary, night, ink }

enum NumberFormatStyle { standard, european }

enum CurrencyPlacementStyle { beforeAmount, afterAmount }

enum DateFormatStyle { monthDayYear, dayMonthYear, yearMonthDay }

const hiddenAmountPlaceholder = '••••';

extension AppIconStyleMark on AppIconStyle {
  /// The colourway [ObMark] draws this style in.
  ObMarkVariant get markVariant => switch (this) {
    AppIconStyle.primary => ObMarkVariant.paper,
    AppIconStyle.night => ObMarkVariant.night,
    AppIconStyle.ink => ObMarkVariant.ink,
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
  BalanceStyle build() {
    final rawValue = ref
        .watch(uiPreferencesStoreProvider)
        .readString(UiPreferenceKeys.balanceStyle);
    return enumFromName(BalanceStyle.values, rawValue, BalanceStyle.standard);
  }

  // Keep explicit command-style API for consistency with other notifiers.
  void setBalanceStyle(BalanceStyle style) {
    state = style;
    persistString(ref, key: UiPreferenceKeys.balanceStyle, value: style.name);
  }
}

class AppIconStyleNotifier extends Notifier<AppIconStyle> {
  @override
  AppIconStyle build() {
    final rawValue = ref
        .watch(uiPreferencesStoreProvider)
        .readString(UiPreferenceKeys.appIconStyle);
    return enumFromName(AppIconStyle.values, rawValue, AppIconStyle.primary);
  }

  // Keep explicit command-style API for consistency with other notifiers.
  void setAppIconStyle(AppIconStyle style) {
    state = style;
    persistString(ref, key: UiPreferenceKeys.appIconStyle, value: style.name);
  }
}

class HideAmountsNotifier extends Notifier<bool> {
  @override
  bool build() =>
      ref
          .watch(uiPreferencesStoreProvider)
          .readBool(UiPreferenceKeys.hideAmounts) ??
      false;

  // Keep explicit command-style API for consistency with other notifiers.
  void setHideAmounts({required bool value}) {
    state = value;
    persistBool(ref, key: UiPreferenceKeys.hideAmounts, value: value);
  }
}

class HideProgressBarsNotifier extends Notifier<bool> {
  @override
  bool build() =>
      ref
          .watch(uiPreferencesStoreProvider)
          .readBool(UiPreferenceKeys.hideProgressBars) ??
      false;

  // Keep explicit command-style API for consistency with other notifiers.
  void setHideProgressBars({required bool value}) {
    state = value;
    persistBool(ref, key: UiPreferenceKeys.hideProgressBars, value: value);
  }
}

final numberFormatStyleProvider =
    NotifierProvider<NumberFormatStyleNotifier, NumberFormatStyle>(
      NumberFormatStyleNotifier.new,
    );

class NumberFormatStyleNotifier extends Notifier<NumberFormatStyle> {
  @override
  NumberFormatStyle build() {
    final rawValue = ref
        .watch(uiPreferencesStoreProvider)
        .readString(UiPreferenceKeys.numberFormatStyle);
    return enumFromName(
      NumberFormatStyle.values,
      rawValue,
      NumberFormatStyle.standard,
    );
  }

  // Keep explicit command-style API for consistency with other notifiers.
  void setNumberFormat(NumberFormatStyle style) {
    state = style;
    persistString(
      ref,
      key: UiPreferenceKeys.numberFormatStyle,
      value: style.name,
    );
  }
}

final currencyPlacementStyleProvider =
    NotifierProvider<CurrencyPlacementStyleNotifier, CurrencyPlacementStyle>(
      CurrencyPlacementStyleNotifier.new,
    );

class CurrencyPlacementStyleNotifier extends Notifier<CurrencyPlacementStyle> {
  @override
  CurrencyPlacementStyle build() {
    final rawValue = ref
        .watch(uiPreferencesStoreProvider)
        .readString(UiPreferenceKeys.currencyPlacementStyle);
    return enumFromName(
      CurrencyPlacementStyle.values,
      rawValue,
      CurrencyPlacementStyle.beforeAmount,
    );
  }

  // Keep explicit command-style API for consistency with other notifiers.
  void setCurrencyPlacement(CurrencyPlacementStyle style) {
    state = style;
    persistString(
      ref,
      key: UiPreferenceKeys.currencyPlacementStyle,
      value: style.name,
    );
  }
}

final dateFormatStyleProvider =
    NotifierProvider<DateFormatStyleNotifier, DateFormatStyle>(
      DateFormatStyleNotifier.new,
    );

class DateFormatStyleNotifier extends Notifier<DateFormatStyle> {
  @override
  DateFormatStyle build() {
    final rawValue = ref
        .watch(uiPreferencesStoreProvider)
        .readString(UiPreferenceKeys.dateFormatStyle);
    return enumFromName(
      DateFormatStyle.values,
      rawValue,
      DateFormatStyle.monthDayYear,
    );
  }

  // Keep explicit command-style API for consistency with other notifiers.
  void setDateFormat(DateFormatStyle style) {
    state = style;
    persistString(
      ref,
      key: UiPreferenceKeys.dateFormatStyle,
      value: style.name,
    );
  }
}

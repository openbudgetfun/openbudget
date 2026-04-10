import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/src/features/settings/providers/ui_preferences_store.dart';

enum BalanceStyle { standard, differentiateWithoutColor }

enum AppIconStyle { primary, v1, v2, v3, v4, v5 }

enum NumberFormatStyle { standard, european }

enum CurrencyPlacementStyle { beforeAmount, afterAmount }

enum DateFormatStyle { monthDayYear, dayMonthYear, yearMonthDay }

const hiddenAmountPlaceholder = '••••';

extension AppIconStyleAssets on AppIconStyle {
  String get previewAssetPath => previewAssetPathFor(Brightness.light);

  String previewAssetPathFor(Brightness brightness) =>
      switch ((this, brightness)) {
        (AppIconStyle.primary, Brightness.light) =>
          'assets/branding/logos/ob_primary_light_512.png',
        (AppIconStyle.primary, Brightness.dark) =>
          'assets/branding/logos/ob_primary_dark_512.png',
        (AppIconStyle.v1, Brightness.light) =>
          'assets/branding/logos/ob_v1_light_preview.png',
        (AppIconStyle.v1, Brightness.dark) =>
          'assets/branding/logos/ob_v1_dark_preview.png',
        (AppIconStyle.v2, Brightness.light) =>
          'assets/branding/logos/ob_v2_light_preview.png',
        (AppIconStyle.v2, Brightness.dark) =>
          'assets/branding/logos/ob_v2_dark_preview.png',
        (AppIconStyle.v3, Brightness.light) =>
          'assets/branding/logos/ob_v3_light_preview.png',
        (AppIconStyle.v3, Brightness.dark) =>
          'assets/branding/logos/ob_v3_dark_preview.png',
        (AppIconStyle.v4, Brightness.light) =>
          'assets/branding/logos/ob_v4_light_preview.png',
        (AppIconStyle.v4, Brightness.dark) =>
          'assets/branding/logos/ob_v4_dark_preview.png',
        (AppIconStyle.v5, Brightness.light) =>
          'assets/branding/logos/ob_v5_light_preview.png',
        (AppIconStyle.v5, Brightness.dark) =>
          'assets/branding/logos/ob_v5_dark_preview.png',
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

  // ignore: use_setters_to_change_properties, Keep explicit command-style API for consistency with other notifiers.
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

  // ignore: use_setters_to_change_properties, Keep explicit command-style API for consistency with other notifiers.
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

  // ignore: use_setters_to_change_properties, Keep explicit command-style API for consistency with other notifiers.
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

  // ignore: use_setters_to_change_properties, Keep explicit command-style API for consistency with other notifiers.
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

  // ignore: use_setters_to_change_properties, Keep explicit command-style API for consistency with other notifiers.
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

  // ignore: use_setters_to_change_properties, Keep explicit command-style API for consistency with other notifiers.
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

  // ignore: use_setters_to_change_properties, Keep explicit command-style API for consistency with other notifiers.
  void setDateFormat(DateFormatStyle style) {
    state = style;
    persistString(
      ref,
      key: UiPreferenceKeys.dateFormatStyle,
      value: style.name,
    );
  }
}

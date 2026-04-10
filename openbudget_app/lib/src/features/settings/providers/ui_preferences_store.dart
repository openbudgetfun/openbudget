import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract final class UiPreferenceKeys {
  static const themeMode = 'ui.themeMode';
  static const appIconStyle = 'ui.appIconStyle';
  static const balanceStyle = 'ui.balanceStyle';
  static const hideAmounts = 'ui.hideAmounts';
  static const hideProgressBars = 'ui.hideProgressBars';
  static const numberFormatStyle = 'ui.numberFormatStyle';
  static const currencyPlacementStyle = 'ui.currencyPlacementStyle';
  static const dateFormatStyle = 'ui.dateFormatStyle';
}

abstract interface class UiPreferencesStore {
  String? readString(String key);

  bool? readBool(String key);

  Future<void> writeString({required String key, required String value});

  Future<void> writeBool({required String key, required bool value});
}

class SharedPrefsUiPreferencesStore implements UiPreferencesStore {
  SharedPrefsUiPreferencesStore(this._preferences);

  final SharedPreferences _preferences;

  @override
  String? readString(String key) => _preferences.getString(key);

  @override
  bool? readBool(String key) => _preferences.getBool(key);

  @override
  Future<void> writeString({required String key, required String value}) => _preferences.setString(key, value);

  @override
  Future<void> writeBool({required String key, required bool value}) => _preferences.setBool(key, value);
}

class InMemoryUiPreferencesStore implements UiPreferencesStore {
  final _values = <String, Object>{};

  @override
  String? readString(String key) {
    final value = _values[key];
    return value is String ? value : null;
  }

  @override
  bool? readBool(String key) {
    final value = _values[key];
    return value is bool ? value : null;
  }

  @override
  Future<void> writeString({required String key, required String value}) async {
    _values[key] = value;
  }

  @override
  Future<void> writeBool({required String key, required bool value}) async {
    _values[key] = value;
  }
}

final uiPreferencesStoreProvider = Provider<UiPreferencesStore>(
  (ref) => InMemoryUiPreferencesStore(),
);

T enumFromName<T extends Enum>(Iterable<T> values, String? raw, T fallback) {
  if (raw == null || raw.isEmpty) {
    return fallback;
  }

  for (final value in values) {
    if (value.name == raw) {
      return value;
    }
  }

  return fallback;
}

void persistString(Ref ref, {required String key, required String value}) {
  unawaited(
    ref.read(uiPreferencesStoreProvider).writeString(key: key, value: value),
  );
}

void persistBool(Ref ref, {required String key, required bool value}) {
  unawaited(
    ref.read(uiPreferencesStoreProvider).writeBool(key: key, value: value),
  );
}

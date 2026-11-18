import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reporting_currency_provider.g.dart';

/// The user's reporting currency: every converted figure in the app — net
/// worth, entity summaries — is expressed in it by the server.
@riverpod
Future<UserSettings> userSettings(Ref ref) async {
  final client = ref.read(serverpodClientProvider);
  return client.settings.get();
}

/// The reporting currency code itself, for call sites that only format.
@riverpod
Future<String> reportingCurrency(Ref ref) async {
  final settings = await ref.watch(userSettingsProvider.future);
  return settings.reportingCurrencyCode;
}

@riverpod
class ReportingCurrencyActions extends _$ReportingCurrencyActions {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  /// Persists a new reporting currency. Converted figures are re-queried;
  /// the app never converts anything itself.
  Future<void> setReportingCurrency(String currencyCode) async {
    state = const AsyncValue.loading();
    final client = ref.read(serverpodClientProvider);
    try {
      await client.settings.setReportingCurrency(currencyCode);
      if (ref.mounted) {
        ref
          ..invalidate(userSettingsProvider)
          ..invalidate(reportingCurrencyProvider);
        state = const AsyncValue.data(null);
      }
    } on Exception catch (e, st) {
      if (ref.mounted) {
        state = AsyncValue.error(e, st);
      }
      rethrow;
    }
  }
}

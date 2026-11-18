import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'fx_rate_provider.g.dart';

/// The market quote the server would use between two currencies on a date.
///
/// Throws [FxRateUnavailableException] when no rate exists; catch it to open
/// the manual-rate sheet. The app never computes rates itself.
@riverpod
Future<FxQuoteView> fxQuote(
  Ref ref,
  String fromCurrencyCode,
  String toCurrencyCode,
  DateTime date,
) async {
  final client = ref.read(serverpodClientProvider);
  return client.fxRate.quote(fromCurrencyCode, toCurrencyCode, date);
}

import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/fx_rates/fx_provider_client.dart';
import 'package:openbudget_server/src/fx_rates/fx_service.dart';
import 'package:serverpod/serverpod.dart';

/// Fetches one missing historical day from the provider.
class FxBackfillFutureCall extends FutureCall {
  static final _log = ObLogger('FxBackfillFutureCall');

  /// Backfills exactly [date]. Never substitutes a newer day's rates.
  Future<void> fetch(Session session, DateTime date) async {
    if (!FxService.hasProviderCredentials(session)) {
      _log.warning(
        'Skipping FX backfill for $date; missing $currencyApiKeyName in '
        'passwords.',
      );
      return;
    }
    await FxService.backfill(session, date);
  }
}

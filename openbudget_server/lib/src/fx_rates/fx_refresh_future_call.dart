import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/fx_rates/fx_provider_client.dart';
import 'package:openbudget_server/src/fx_rates/fx_service.dart';
import 'package:serverpod/serverpod.dart';

/// Hourly refresh of today's daily FX rows.
class FxRefreshFutureCall extends FutureCall {
  static final _log = ObLogger('FxRefreshFutureCall');

  /// Fetches the provider's latest rates and upserts today's rows.
  ///
  /// A missing provider key skips the sweep. Provider failures propagate so a
  /// broken upstream is visible instead of silently serving stale rates.
  Future<void> refresh(Session session) async {
    if (!FxService.hasProviderCredentials(session)) {
      _log.warning(
        'Skipping FX refresh; missing $currencyApiKeyName in passwords.',
      );
      return;
    }
    await FxService.refreshNow(session);
  }
}

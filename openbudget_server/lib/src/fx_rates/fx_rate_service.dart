import 'package:openbudget_server/src/fx_rates/fx_service.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

/// Temporary facade for the unported wallet service.
///
/// The wallet service still calls the old class name. It forwards to
/// [FxService] and holds no snapshot state; remove it when wallets move to
/// [FxService].
class FxRateService {
  /// Returns the latest stored daily rates.
  static Future<FxLatestSnapshot> latest(Session session) =>
      FxService.latest(session);

  /// Fetches the provider's latest rates and upserts today's rows.
  static Future<FxLatestSnapshot> refreshNow(Session session) =>
      FxService.refreshNow(session);
}

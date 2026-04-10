import 'package:openbudget_server/src/fx_rates/fx_rate_service.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

/// API surface for exchange rates used by display-currency conversion.
class FxRateEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Returns the latest FX snapshot persisted by the backend.
  Future<FxLatestSnapshot> latest(Session session) async =>
      FxRateService.latest(session);

  /// Forces an immediate refresh from the upstream FX provider and persists it.
  Future<FxLatestSnapshot> refresh(Session session) async =>
      FxRateService.refreshNow(session);
}

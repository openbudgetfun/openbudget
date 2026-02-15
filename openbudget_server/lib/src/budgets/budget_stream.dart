import 'package:openbudget_server/src/budgets/budget_service.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

/// Streaming endpoint for real-time budget updates.
///
/// Client sends budget IDs, server streams back the current budget state.
class BudgetStreamEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Streams budget updates to the connected client.
  ///
  /// Client sends [UuidValue] budget IDs, server responds with the current
  /// [Budget] state for each requested ID. Ownership is verified on each
  /// request.
  Stream<Budget> budgetUpdates(
    Session session,
    Stream<UuidValue> budgetIdStream,
  ) async* {
    await for (final budgetId in budgetIdStream) {
      final budget = await BudgetService.getById(session, budgetId: budgetId);
      yield budget;
    }
  }
}

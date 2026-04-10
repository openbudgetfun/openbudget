import 'dart:async';

import 'package:openbudget_server/src/budgets/budget_realtime_notifier.dart';
import 'package:openbudget_server/src/budgets/budget_service.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

/// Streaming endpoint for real-time budget updates.
///
/// Client sends a budget ID once, server streams live budget snapshots.
class BudgetStreamEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Streams budget updates to the connected client.
  ///
  /// Client sends a [UuidValue] budget ID. The stream yields an initial
  /// [Budget] snapshot and then emits fresh snapshots whenever that budget
  /// changes.
  Stream<Budget> budgetUpdates(
    Session session,
    Stream<UuidValue> budgetIdStream,
  ) async* {
    final budgetIdIterator = StreamIterator(budgetIdStream);
    final hasBudgetId = await budgetIdIterator.moveNext();
    if (!hasBudgetId) {
      await budgetIdIterator.cancel();
      return;
    }
    final budgetId = budgetIdIterator.current;
    await budgetIdIterator.cancel();

    yield await BudgetService.getById(session, budgetId: budgetId);

    await for (final _ in BudgetRealtimeNotifier.watchBudget(budgetId)) {
      yield await BudgetService.getById(session, budgetId: budgetId);
    }
  }
}

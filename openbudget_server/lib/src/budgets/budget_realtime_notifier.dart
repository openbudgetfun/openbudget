import 'dart:async';

import 'package:openbudget_server/src/categories/category_service.dart';
import 'package:openbudget_server/src/envelopes/envelope_service.dart';
import 'package:serverpod/serverpod.dart';

/// Broadcasts budget-level mutation events to realtime stream subscribers.
class BudgetRealtimeNotifier {
  BudgetRealtimeNotifier._();

  static final StreamController<UuidValue> _budgetChanges =
      StreamController<UuidValue>.broadcast();

  /// Emits a budget change event.
  static void notifyBudgetChanged(UuidValue budgetId) {
    if (_budgetChanges.isClosed) return;
    _budgetChanges.add(budgetId);
  }

  /// Streams change events for a single budget.
  static Stream<UuidValue> watchBudget(UuidValue budgetId) {
    final budgetIdString = budgetId.toString();
    return _budgetChanges.stream.where(
      (changedBudgetId) => changedBudgetId.toString() == budgetIdString,
    );
  }

  /// Resolves a category and emits its owning budget as changed.
  static Future<void> notifyCategoryChanged(
    Session session,
    UuidValue categoryId,
  ) async {
    final category = await CategoryService.getById(
      session,
      categoryId: categoryId,
    );
    notifyBudgetChanged(category.budgetId);
  }

  /// Resolves an envelope and emits its owning budget as changed.
  static Future<void> notifyEnvelopeChanged(
    Session session,
    UuidValue envelopeId,
  ) async {
    final envelope = await EnvelopeService.getById(
      session,
      envelopeId: envelopeId,
    );
    await notifyCategoryChanged(session, envelope.categoryId);
  }
}

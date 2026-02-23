import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/src/features/budget/providers/recent_moves_provider.dart';

void main() {
  group('RecentMovesNotifier.undoLast', () {
    test('removes most recent events and returns false when empty', () {
      const budgetId = 'budget-1';
      const envelopeA = 'envelope-a';
      const envelopeB = 'envelope-b';

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(recentMovesProvider.notifier)
        ..recordAssigned(
          budgetId: budgetId,
          envelopeId: envelopeA,
          amountCents: 5000,
        )
        ..recordMove(
          budgetId: budgetId,
          fromEnvelopeId: envelopeA,
          toEnvelopeId: envelopeB,
          amountCents: 1200,
        );

      expect(
        container.read(recentMovesForBudgetProvider(budgetId)).length,
        equals(2),
      );

      expect(notifier.undoLast(budgetId: budgetId), isTrue);
      final afterFirstUndo = container.read(
        recentMovesForBudgetProvider(budgetId),
      );
      expect(afterFirstUndo.length, equals(1));
      expect(afterFirstUndo.first.type, equals(RecentMoveType.assigned));

      expect(notifier.undoLast(budgetId: budgetId), isTrue);
      expect(container.read(recentMovesForBudgetProvider(budgetId)), isEmpty);

      expect(notifier.undoLast(budgetId: budgetId), isFalse);
    });
  });
}

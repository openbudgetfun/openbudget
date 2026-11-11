import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/src/features/budget/providers/recent_moves_provider.dart';

void main() {
  group('RecentMovesNotifier.undoLast', () {
    test('removes most recent events and returns false when empty', () {
      const entityId = 'budget-1';
      const envelopeA = 'envelope-a';
      const envelopeB = 'envelope-b';

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(recentMovesProvider.notifier)
        ..recordAssigned(
          entityId: entityId,
          envelopeId: envelopeA,
          amountMinor: 5000,
        )
        ..recordMove(
          entityId: entityId,
          fromEnvelopeId: envelopeA,
          toEnvelopeId: envelopeB,
          amountMinor: 1200,
        );

      expect(
        container.read(recentMovesForBudgetProvider(entityId)).length,
        equals(2),
      );

      expect(notifier.undoLast(entityId: entityId), isTrue);
      final afterFirstUndo = container.read(
        recentMovesForBudgetProvider(entityId),
      );
      expect(afterFirstUndo.length, equals(1));
      expect(afterFirstUndo.first.type, equals(RecentMoveType.assigned));

      expect(notifier.undoLast(entityId: entityId), isTrue);
      expect(container.read(recentMovesForBudgetProvider(entityId)), isEmpty);

      expect(notifier.undoLast(entityId: entityId), isFalse);
    });
  });
}

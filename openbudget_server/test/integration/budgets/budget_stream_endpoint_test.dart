import 'dart:async';

import 'package:test/test.dart';

import '../helpers/auth_helper.dart';
import '../test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given BudgetStreamEndpoint', (sessionBuilder, endpoints) {
    late TestSessionBuilder authedSession;

    setUp(() async {
      authedSession = createAuthenticatedSession(sessionBuilder);
    });

    test(
      'when budget data changes then stream emits another snapshot',
      () async {
        final budget = await endpoints.budget.create(
          authedSession,
          'Realtime Budget',
          'USD',
        );

        final updates = endpoints.budgetStream.budgetUpdates(
          authedSession,
          Stream.value(budget.id!),
        );
        final iterator = StreamIterator(updates);

        expect(await iterator.moveNext(), isTrue);
        expect(iterator.current.id, budget.id);

        await endpoints.category.create(
          authedSession,
          'Realtime Category',
          budget.id!,
          0,
        );

        final hasNext = await iterator.moveNext().timeout(
          const Duration(seconds: 2),
        );
        expect(hasNext, isTrue);
        expect(iterator.current.id, budget.id);

        await iterator.cancel();
      },
    );
  });
}

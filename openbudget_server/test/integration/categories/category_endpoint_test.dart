import 'package:openbudget_server/src/exceptions/exceptions.dart';
import 'package:test/test.dart';

import '../helpers/auth_helper.dart';
import '../test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given CategoryEndpoint', (sessionBuilder, endpoints) {
    late TestSessionBuilder authedSession;

    setUp(() async {
      authedSession = createAuthenticatedSession(sessionBuilder);
    });

    test('when creating a category then returns created category', () async {
      final budget = await endpoints.budget.create(
        authedSession,
        'Test Budget',
        'USD',
      );

      final category = await endpoints.category.create(
        authedSession,
        'Groceries',
        budget.id!,
        0,
      );
      expect(category.name, 'Groceries');
      expect(category.budgetId, budget.id);
      expect(category.sortOrder, 0);
    });

    test('when listing categories then returns all for budget', () async {
      final budget = await endpoints.budget.create(
        authedSession,
        'Test Budget',
        'USD',
      );

      await endpoints.category.create(authedSession, 'Food', budget.id!, 0);
      await endpoints.category.create(
        authedSession,
        'Transport',
        budget.id!,
        1,
      );

      final categories = await endpoints.category.list(
        authedSession,
        budget.id!,
      );
      expect(categories, hasLength(2));
    });

    test('when listing categories then returns ordered by sortOrder', () async {
      final budget = await endpoints.budget.create(
        authedSession,
        'Test Budget',
        'USD',
      );

      await endpoints.category.create(authedSession, 'Second', budget.id!, 1);
      await endpoints.category.create(authedSession, 'First', budget.id!, 0);

      final categories = await endpoints.category.list(
        authedSession,
        budget.id!,
      );
      expect(categories.first.name, 'First');
      expect(categories.last.name, 'Second');
    });

    test('when updating a category then returns updated category', () async {
      final budget = await endpoints.budget.create(
        authedSession,
        'Test Budget',
        'USD',
      );
      final category = await endpoints.category.create(
        authedSession,
        'Original',
        budget.id!,
        0,
      );

      final updated = await endpoints.category.update(
        authedSession,
        category.id!,
        name: 'Updated',
      );
      expect(updated.name, 'Updated');
    });

    test('when deleting a category then it is removed', () async {
      final budget = await endpoints.budget.create(
        authedSession,
        'Test Budget',
        'USD',
      );
      final category = await endpoints.category.create(
        authedSession,
        'Delete Me',
        budget.id!,
        0,
      );

      await endpoints.category.delete(authedSession, category.id!);

      expect(
        () => endpoints.category.get(authedSession, category.id!),
        throwsA(isA<NotFoundException>()),
      );
    });

    test(
      "when accessing category in another user's budget then throws",
      () async {
        final budget = await endpoints.budget.create(
          authedSession,
          'Private Budget',
          'USD',
        );
        final category = await endpoints.category.create(
          authedSession,
          'Private Category',
          budget.id!,
          0,
        );

        final otherSession = createAuthenticatedSession(sessionBuilder);

        expect(
          () => endpoints.category.get(otherSession, category.id!),
          throwsA(isA<NotFoundException>()),
        );
      },
    );
  });
}

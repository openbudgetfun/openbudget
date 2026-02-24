import 'package:openbudget_server/src/exceptions/exceptions.dart';
import 'package:test/test.dart';

import '../helpers/auth_helper.dart';
import '../test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given MonthlyAllocationEndpoint', (sessionBuilder, endpoints) {
    late TestSessionBuilder authedSession;

    setUp(() async {
      authedSession = createAuthenticatedSession(sessionBuilder);
    });

    test(
      'when upserting allocation then list returns the allocation for month',
      () async {
        final budget = await endpoints.budget.create(
          authedSession,
          'Allocation Budget',
          'USD',
        );
        final category = await endpoints.category.create(
          authedSession,
          'Bills',
          budget.id!,
          0,
        );
        final envelope = await endpoints.envelope.create(
          authedSession,
          'Rent',
          category.id!,
          0,
          'USD',
        );

        final created = await endpoints.monthlyAllocation.upsert(
          authedSession,
          envelope.id!,
          budget.id!,
          2026,
          2,
          280000,
          carryoverCents: 0,
        );

        expect(created.budgetId, budget.id);
        expect(created.envelopeId, envelope.id);
        expect(created.allocatedCents, 280000);

        final listed = await endpoints.monthlyAllocation.list(
          authedSession,
          budget.id!,
          2026,
          2,
        );
        expect(listed, hasLength(1));
        expect(listed.first.id, created.id);
      },
    );

    test('when upserting with envelope outside budget then throws', () async {
      final primaryBudget = await endpoints.budget.create(
        authedSession,
        'Primary Budget',
        'USD',
      );
      final foreignBudget = await endpoints.budget.create(
        authedSession,
        'Foreign Budget',
        'USD',
      );
      final primaryCategory = await endpoints.category.create(
        authedSession,
        'Primary Category',
        primaryBudget.id!,
        0,
      );
      final foreignCategory = await endpoints.category.create(
        authedSession,
        'Foreign Category',
        foreignBudget.id!,
        0,
      );
      await endpoints.envelope.create(
        authedSession,
        'Primary Envelope',
        primaryCategory.id!,
        0,
        'USD',
      );
      final foreignEnvelope = await endpoints.envelope.create(
        authedSession,
        'Foreign Envelope',
        foreignCategory.id!,
        0,
        'USD',
      );

      await expectLater(
        endpoints.monthlyAllocation.upsert(
          authedSession,
          foreignEnvelope.id!,
          primaryBudget.id!,
          2026,
          2,
          1000,
          carryoverCents: 0,
        ),
        throwsA(isA<NotFoundException>()),
      );
    });

    test(
      'when moving money then source and target allocations are updated',
      () async {
        final budget = await endpoints.budget.create(
          authedSession,
          'Move Budget',
          'USD',
        );
        final category = await endpoints.category.create(
          authedSession,
          'Bills',
          budget.id!,
          0,
        );
        final fromEnvelope = await endpoints.envelope.create(
          authedSession,
          'From',
          category.id!,
          0,
          'USD',
        );
        final toEnvelope = await endpoints.envelope.create(
          authedSession,
          'To',
          category.id!,
          0,
          'USD',
        );

        await endpoints.monthlyAllocation.upsert(
          authedSession,
          fromEnvelope.id!,
          budget.id!,
          2026,
          2,
          5000,
          carryoverCents: 0,
        );
        await endpoints.monthlyAllocation.upsert(
          authedSession,
          toEnvelope.id!,
          budget.id!,
          2026,
          2,
          1000,
          carryoverCents: 0,
        );

        final moved = await endpoints.monthlyAllocation.moveMoney(
          authedSession,
          fromEnvelope.id!,
          toEnvelope.id!,
          budget.id!,
          2026,
          2,
          1500,
        );

        final updatedFrom = moved.firstWhere(
          (allocation) => allocation.envelopeId == fromEnvelope.id,
        );
        final updatedTo = moved.firstWhere(
          (allocation) => allocation.envelopeId == toEnvelope.id,
        );
        expect(updatedFrom.allocatedCents, 3500);
        expect(updatedTo.allocatedCents, 2500);
      },
    );

    test('when moving money to envelope outside budget then throws', () async {
      final primaryBudget = await endpoints.budget.create(
        authedSession,
        'Primary Move Budget',
        'USD',
      );
      final foreignBudget = await endpoints.budget.create(
        authedSession,
        'Foreign Move Budget',
        'USD',
      );
      final primaryCategory = await endpoints.category.create(
        authedSession,
        'Primary Category',
        primaryBudget.id!,
        0,
      );
      final foreignCategory = await endpoints.category.create(
        authedSession,
        'Foreign Category',
        foreignBudget.id!,
        0,
      );
      final fromEnvelope = await endpoints.envelope.create(
        authedSession,
        'From',
        primaryCategory.id!,
        0,
        'USD',
      );
      final foreignEnvelope = await endpoints.envelope.create(
        authedSession,
        'Foreign',
        foreignCategory.id!,
        0,
        'USD',
      );

      await expectLater(
        endpoints.monthlyAllocation.moveMoney(
          authedSession,
          fromEnvelope.id!,
          foreignEnvelope.id!,
          primaryBudget.id!,
          2026,
          2,
          100,
        ),
        throwsA(isA<NotFoundException>()),
      );
    });

    test(
      'when deleting allocation twice then second call throws not found',
      () async {
        final budget = await endpoints.budget.create(
          authedSession,
          'Delete Allocation Budget',
          'USD',
        );
        final category = await endpoints.category.create(
          authedSession,
          'Bills',
          budget.id!,
          0,
        );
        final envelope = await endpoints.envelope.create(
          authedSession,
          'Rent',
          category.id!,
          0,
          'USD',
        );

        final allocation = await endpoints.monthlyAllocation.upsert(
          authedSession,
          envelope.id!,
          budget.id!,
          2026,
          2,
          1000,
          carryoverCents: 0,
        );

        await endpoints.monthlyAllocation.delete(authedSession, allocation.id!);

        await expectLater(
          endpoints.monthlyAllocation.delete(authedSession, allocation.id!),
          throwsA(isA<NotFoundException>()),
        );
      },
    );
  });
}

// Calendar dates are naturally written with their day component.
// ignore_for_file: avoid_redundant_argument_values

import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/budget/budget_month_service.dart';
import 'package:openbudget_server/src/budget/budget_service.dart';
import 'package:openbudget_server/src/entities/entity_realtime_notifier.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/transactions/transaction_writer.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import '../support/pg_test_server.dart';
import 'budget_helpers.dart';

void main() {
  late PgTestServer server;
  late BudgetFixture fixture;
  late List<EntityChangedEvent> events;
  var serverStarted = false;

  setUpAll(() async {
    server = await PgTestServer.start();
    serverStarted = true;
  });

  tearDownAll(() async {
    if (serverStarted) await server.stop();
  });

  setUp(() async {
    events = [];
    TransactionWriter.debugPublisher = (
      session,
      entityId,
      scope, {
      month,
      accountId,
    }) async {};
    EntityRealtimeNotifier.debugPublisher =
        (session, entityId, scope, {month, accountId}) async {
          events.add(
            EntityChangedEvent(
              entityId: entityId,
              scope: scope,
              month: month,
              accountId: accountId,
            ),
          );
        };
    fixture = await BudgetFixture.create(
      server.anonymousSession(),
      envelopeCount: 3,
    );
    addTearDown(fixture.book.expectBalancesConsistent);
  });

  tearDown(() {
    TransactionWriter.resetForTests();
    EntityRealtimeNotifier.resetForTests();
    BudgetMonthService.debugAfterActivityQuery = null;
    BudgetService.debugBeforeCommit = null;
  });

  Future<int> allocationRows(int month, {UuidValue? envelopeId}) =>
      MonthlyAllocation.db.count(
        fixture.session,
        where: (t) =>
            t.entityId.equals(fixture.entityId) &
            t.month.equals(month) &
            (envelopeId == null
                ? Constant.bool(true)
                : t.envelopeId.equals(envelopeId)),
      );

  test(
    'given an exact set when allocations change then only named envelopes '
    'replace and zero deletes',
    () async {
      final first = fixture.envelopes[0];
      final second = fixture.envelopes[1];
      final third = fixture.envelopes[2];

      final initial = await fixture.allocate(202610, {
        first: 1000,
        second: 2000,
      });
      expect(initial.summary.allocatedMinor, 3000);
      expect(await allocationRows(202610), 2);
      expect(events.single.month, 202610);
      expect(events.single.scope, ChangeScope.plan);
      await fixture.expectInvariant(initial);

      final partial = await fixture.allocate(202610, {first: 3000});
      expect(partial.envelopes[0].allocatedMinor, 3000);
      expect(partial.envelopes[1].allocatedMinor, 2000);
      expect(partial.summary.allocatedMinor, 5000);
      await fixture.expectInvariant(partial);

      final removed = await fixture.allocate(202610, {first: 0});
      expect(removed.envelopes[0].allocatedMinor, 0);
      expect(removed.envelopes[1].allocatedMinor, 2000);
      expect(await allocationRows(202610, envelopeId: first.id), 0);
      expect(await allocationRows(202610), 1);
      await fixture.expectInvariant(removed);

      final negative = await fixture.allocate(202610, {third: -500});
      expect(negative.envelopes[2].allocatedMinor, -500);
      expect(negative.summary.allocatedMinor, 1500);
      await fixture.expectInvariant(negative);
      expect(events, hasLength(4));
    },
  );

  test(
    'given duplicate, foreign, archived, bad-month or unsafe input then '
    'nothing mutates and no event is published',
    () async {
      final first = fixture.envelopes.first;
      final otherEntity = await fixture.book.addEntity(name: 'Other plan');
      final foreignEnvelope = await fixture.book.addEnvelope(
        name: 'Foreign',
        entity: otherEntity,
      );

      await expectLater(
        BudgetService.setAllocations(
          fixture.session,
          entityId: fixture.entityId,
          month: 202610,
          allocations: [
            AllocationInput(envelopeId: first.id!, allocatedMinor: 100),
            AllocationInput(envelopeId: first.id!, allocatedMinor: 200),
          ],
        ),
        throwsA(isA<ValidationException>()),
      );
      await expectLater(
        BudgetService.setAllocations(
          fixture.session,
          entityId: fixture.entityId,
          month: 202610,
          allocations: [
            AllocationInput(
              envelopeId: first.id!,
              allocatedMinor: maxSafeMinor + 1,
            ),
          ],
        ),
        throwsA(isA<ValidationException>()),
      );
      await expectLater(
        BudgetService.setAllocations(
          fixture.session,
          entityId: fixture.entityId,
          month: 202610,
          allocations: [
            AllocationInput(
              envelopeId: foreignEnvelope.id!,
              allocatedMinor: 100,
            ),
          ],
        ),
        throwsA(isA<ForbiddenException>()),
      );
      await expectLater(
        fixture.allocate(202613, {first: 100}),
        throwsA(isA<ValidationException>()),
      );

      final archived = await fixture.book.addEntity(
        name: 'Archived',
        archivedAt: DateTime.utc(2026, 1, 1),
      );
      final archivedEnvelope = await fixture.book.addEnvelope(
        name: 'Archived envelope',
        entity: archived,
      );
      await expectLater(
        BudgetService.setAllocations(
          fixture.session,
          entityId: archived.id!,
          month: 202610,
          allocations: [
            AllocationInput(
              envelopeId: archivedEnvelope.id!,
              allocatedMinor: 100,
            ),
          ],
        ),
        throwsA(isA<ValidationException>()),
      );

      expect(await allocationRows(202610), 0);
      expect(events, isEmpty);
    },
  );

  test(
    'given an owned entity from another user when read or written then '
    'ownership is enforced',
    () async {
      final otherUser = await server.insertAuthUser();
      final foreignEntity = await Entity.db.insertRow(
        fixture.session,
        Entity(
          id: const Uuid().v7obj(),
          ownerId: otherUser,
          name: 'Someone else',
          kind: EntityKind.individual,
          countryCode: 'GB',
          baseCurrencyCode: 'GBP',
          timeZone: 'Europe/London',
          accountingMode: AccountingMode.envelope,
          fiscalYearEndMonth: 4,
          fiscalYearEndDay: 5,
        ),
      );

      await expectLater(
        BudgetService.listTemplates(
          fixture.session,
          entityId: foreignEntity.id!,
        ),
        throwsA(isA<ForbiddenException>()),
      );
      await expectLater(
        BudgetService.setAllocations(
          fixture.session,
          entityId: foreignEntity.id!,
          month: 202610,
          allocations: const [],
        ),
        throwsA(isA<ForbiddenException>()),
      );
      expect(events, isEmpty);
    },
  );

  test(
    'given a move in each direction when applied then allocations and Ready '
    'to Assign move atomically',
    () async {
      final first = fixture.envelopes[0];
      final second = fixture.envelopes[1];
      await fixture.income(5000, date: DateTime.utc(2026, 10, 1));
      await fixture.allocate(202610, {first: 1000, second: 500});

      final both = await fixture.move(
        202610,
        from: first,
        to: second,
        amountMinor: 300,
      );
      expect(both.envelopes[0].allocatedMinor, 700);
      expect(both.envelopes[1].allocatedMinor, 800);
      await fixture.expectInvariant(both);

      final intoEnvelope = await fixture.move(
        202610,
        to: first,
        amountMinor: 200,
      );
      expect(intoEnvelope.envelopes[0].allocatedMinor, 900);
      expect(intoEnvelope.summary.readyToAssignMinor, 3300);
      await fixture.expectInvariant(intoEnvelope);

      final outOfEnvelope = await fixture.move(
        202610,
        from: first,
        amountMinor: 400,
      );
      expect(outOfEnvelope.envelopes[0].allocatedMinor, 500);
      expect(outOfEnvelope.summary.readyToAssignMinor, 3700);
      await fixture.expectInvariant(outOfEnvelope);

      final emptied = await fixture.move(
        202610,
        from: first,
        to: second,
        amountMinor: 500,
      );
      expect(emptied.envelopes[0].allocatedMinor, 0);
      expect(await allocationRows(202610, envelopeId: first.id), 0);
      expect(emptied.envelopes[1].allocatedMinor, 1300);
      await fixture.expectInvariant(emptied);

      await expectLater(
        fixture.move(202610, from: first, to: first, amountMinor: 1),
        throwsA(isA<ValidationException>()),
      );
      await expectLater(
        fixture.move(202610, amountMinor: 1),
        throwsA(isA<ValidationException>()),
      );
      await expectLater(
        fixture.move(202610, to: second, amountMinor: 0),
        throwsA(isA<ValidationException>()),
      );
      await expectLater(
        fixture.move(202610, to: second, amountMinor: maxSafeMinor + 1),
        throwsA(isA<ValidationException>()),
      );
    },
  );

  test(
    'given two months when copied then the target is replaced exactly and '
    'the source is untouched',
    () async {
      final first = fixture.envelopes[0];
      final second = fixture.envelopes[1];
      final third = fixture.envelopes[2];
      await fixture.allocate(202609, {first: 1000, second: 2000});
      await fixture.allocate(202610, {first: 500, third: 700});

      final copied = await BudgetService.copyMonth(
        fixture.session,
        entityId: fixture.entityId,
        fromMonth: 202609,
        toMonth: 202610,
      );

      expect(copied.envelopes[0].allocatedMinor, 1000);
      expect(copied.envelopes[1].allocatedMinor, 2000);
      expect(copied.envelopes[2].allocatedMinor, 0);
      expect(await allocationRows(202610), 2);
      expect(copied.summary.assignedInFutureMinor, 0);
      await fixture.expectInvariant(copied);

      final source = await fixture.month(202609);
      expect(source.envelopes[0].allocatedMinor, 1000);
      expect(source.envelopes[1].allocatedMinor, 2000);
      await fixture.expectInvariant(source);

      final self = await BudgetService.copyMonth(
        fixture.session,
        entityId: fixture.entityId,
        fromMonth: 202609,
        toMonth: 202609,
      );
      expect(self.envelopes[0].allocatedMinor, 1000);
      expect(await allocationRows(202609), 2);
      await fixture.expectInvariant(self);

      final emptySource = await BudgetService.copyMonth(
        fixture.session,
        entityId: fixture.entityId,
        fromMonth: 202608,
        toMonth: 202610,
      );
      expect(emptySource.summary.allocatedMinor, 0);
      expect(await allocationRows(202610), 0);
      await fixture.expectInvariant(emptySource);

      await fixture.allocate(202512, {first: 100});
      final yearBoundary = await BudgetService.copyMonth(
        fixture.session,
        entityId: fixture.entityId,
        fromMonth: 202512,
        toMonth: 202601,
      );
      expect(yearBoundary.envelopes[0].allocatedMinor, 100);
      await fixture.expectInvariant(yearBoundary);

      expect(
        events.where((event) => event.month == 202610),
        hasLength(3),
      );
    },
  );

  test(
    'given a saved template when applied then it replaces the month, keeps '
    'goals and does not lose an older same-name plan',
    () async {
      final first = fixture.envelopes[0];
      final second = fixture.envelopes[1];
      final third = fixture.envelopes[2];
      await fixture.allocate(202609, {first: 1000, second: -200});
      await EnvelopeGoal.db.insertRow(
        fixture.session,
        EnvelopeGoal(
          entityId: fixture.entityId,
          envelopeId: first.id!,
          kind: EnvelopeGoalKind.targetBalance,
          amountMinor: 5000,
        ),
      );

      final template = await BudgetService.saveTemplate(
        fixture.session,
        entityId: fixture.entityId,
        month: 202609,
        name: '  Standard month  ',
      );
      expect(template.name, 'Standard month');
      expect(events.last.month, isNull);
      final lines = await BudgetService.getTemplateLines(
        fixture.session,
        templateId: template.id!,
      );
      expect(lines, hasLength(2));
      expect(lines.map((line) => line.allocatedMinor).toSet(), {-200, 1000});

      final secondTemplate = await BudgetService.saveTemplate(
        fixture.session,
        entityId: fixture.entityId,
        month: 202609,
        name: 'Standard month',
      );
      expect(secondTemplate.id, isNot(template.id));
      final templates = await BudgetService.listTemplates(
        fixture.session,
        entityId: fixture.entityId,
      );
      expect(templates, hasLength(2));

      await fixture.allocate(202610, {first: 500, third: 700});
      final applied = await BudgetService.applyTemplate(
        fixture.session,
        templateId: template.id!,
        month: 202610,
      );
      expect(applied.envelopes[0].allocatedMinor, 1000);
      expect(applied.envelopes[1].allocatedMinor, -200);
      expect(applied.envelopes[2].allocatedMinor, 0);
      expect(applied.envelopes[0].goal?.amountMinor, 5000);
      expect(await allocationRows(202610), 2);
      await fixture.expectInvariant(applied);

      final emptyTemplate = await BudgetService.saveTemplate(
        fixture.session,
        entityId: fixture.entityId,
        month: 202608,
        name: 'Empty',
      );
      final cleared = await BudgetService.applyTemplate(
        fixture.session,
        templateId: emptyTemplate.id!,
        month: 202610,
      );
      expect(cleared.summary.allocatedMinor, 0);
      expect(await allocationRows(202610), 0);
      await fixture.expectInvariant(cleared);

      await BudgetService.deleteTemplate(
        fixture.session,
        templateId: template.id!,
      );
      expect(events.last.month, isNull);
      await expectLater(
        BudgetService.getTemplateLines(
          fixture.session,
          templateId: template.id!,
        ),
        throwsA(isA<NotFoundException>()),
      );
      expect(
        await BudgetTemplateLine.db.count(
          fixture.session,
          where: (t) => t.templateId.equals(template.id),
        ),
        0,
      );
      expect(
        await BudgetService.listTemplates(
          fixture.session,
          entityId: fixture.entityId,
        ),
        hasLength(2),
      );
    },
  );

  test(
    'given a foreign or archived template when applied then the target month '
    'is untouched',
    () async {
      final first = fixture.envelopes.first;
      await fixture.allocate(202610, {first: 900});

      final otherEntity = await fixture.book.addEntity(name: 'Other plan');
      final foreignEnvelope = await fixture.book.addEnvelope(
        name: 'Foreign envelope',
        entity: otherEntity,
      );
      final foreignTemplate = await BudgetTemplate.db.insertRow(
        fixture.session,
        BudgetTemplate(
          entityId: otherEntity.id!,
          name: 'Foreign template',
        ),
      );
      await BudgetTemplateLine.db.insertRow(
        fixture.session,
        BudgetTemplateLine(
          templateId: foreignTemplate.id!,
          envelopeId: foreignEnvelope.id!,
          allocatedMinor: 400,
        ),
      );
      final otherView = await BudgetService.applyTemplate(
        fixture.session,
        templateId: foreignTemplate.id!,
        month: 202610,
      );
      expect(otherView.entityId, otherEntity.id);
      expect(otherView.envelopes.first.allocatedMinor, 400);
      expect(
        await BudgetService.getTemplateLines(
          fixture.session,
          templateId: foreignTemplate.id!,
        ),
        hasLength(1),
      );

      final otherUser = await server.insertAuthUser();
      final stranger = await Entity.db.insertRow(
        fixture.session,
        Entity(
          id: const Uuid().v7obj(),
          ownerId: otherUser,
          name: 'Stranger plan',
          kind: EntityKind.individual,
          countryCode: 'GB',
          baseCurrencyCode: 'GBP',
          timeZone: 'Europe/London',
          accountingMode: AccountingMode.envelope,
          fiscalYearEndMonth: 4,
          fiscalYearEndDay: 5,
        ),
      );
      final strangerTemplate = await BudgetTemplate.db.insertRow(
        fixture.session,
        BudgetTemplate(entityId: stranger.id!, name: 'Stranger template'),
      );
      await expectLater(
        BudgetService.applyTemplate(
          fixture.session,
          templateId: strangerTemplate.id!,
          month: 202610,
        ),
        throwsA(isA<ForbiddenException>()),
      );
      await expectLater(
        BudgetService.getTemplateLines(
          fixture.session,
          templateId: strangerTemplate.id!,
        ),
        throwsA(isA<ForbiddenException>()),
      );
      await expectLater(
        BudgetService.deleteTemplate(
          fixture.session,
          templateId: strangerTemplate.id!,
        ),
        throwsA(isA<ForbiddenException>()),
      );

      // A template owned by the entity can still hold a foreign envelope id
      // if it was built outside this service. Applying it must fail before the
      // delete and keep the previous month intact.
      final corrupt = await BudgetTemplate.db.insertRow(
        fixture.session,
        BudgetTemplate(entityId: fixture.entityId, name: 'Corrupt'),
      );
      await BudgetTemplateLine.db.insertRow(
        fixture.session,
        BudgetTemplateLine(
          templateId: corrupt.id!,
          envelopeId: foreignEnvelope.id!,
          allocatedMinor: 400,
        ),
      );
      await expectLater(
        BudgetService.applyTemplate(
          fixture.session,
          templateId: corrupt.id!,
          month: 202610,
        ),
        throwsA(isA<ForbiddenException>()),
      );

      final archived = await fixture.book.addEntity(
        name: 'Archived',
        archivedAt: DateTime.utc(2026, 1, 1),
      );
      final archivedTemplate = await BudgetTemplate.db.insertRow(
        fixture.session,
        BudgetTemplate(entityId: archived.id!, name: 'Archived template'),
      );
      await expectLater(
        BudgetService.applyTemplate(
          fixture.session,
          templateId: archivedTemplate.id!,
          month: 202610,
        ),
        throwsA(isA<ValidationException>()),
      );
      await expectLater(
        BudgetService.applyTemplate(
          fixture.session,
          templateId: corrupt.id!,
          month: 202613,
        ),
        throwsA(isA<ValidationException>()),
      );

      final unchanged = await fixture.month(202610);
      expect(unchanged.envelopes.first.allocatedMinor, 900);
      expect(await allocationRows(202610), 1);
    },
  );

  test(
    'given a template save with an invalid name then it is rejected',
    () async {
      await expectLater(
        BudgetService.saveTemplate(
          fixture.session,
          entityId: fixture.entityId,
          month: 202610,
          name: '   ',
        ),
        throwsA(isA<ValidationException>()),
      );
      await expectLater(
        BudgetService.saveTemplate(
          fixture.session,
          entityId: fixture.entityId,
          month: 202613,
          name: 'Bad month',
        ),
        throwsA(isA<ValidationException>()),
      );
      expect(
        await BudgetTemplate.db.count(
          fixture.session,
          where: (t) => t.entityId.equals(fixture.entityId),
        ),
        0,
      );
    },
  );

  test(
    'given a failure after mutation when the transaction rolls back then no '
    'row or event survives',
    () async {
      BudgetService.debugBeforeCommit = () async {
        throw StateError('forced rollback');
      };
      await expectLater(
        fixture.allocate(202610, {fixture.envelopes.first: 1000}),
        throwsA(isA<StateError>()),
      );

      BudgetService.debugBeforeCommit = null;
      expect(await allocationRows(202610), 0);
      expect(events, isEmpty);
      final view = await fixture.month(202610);
      expect(view.summary.allocatedMinor, 0);
      await fixture.expectInvariant(view);
    },
  );

  test(
    'given concurrent moves when they race then every move lands and no '
    'update is lost',
    () async {
      final first = fixture.envelopes[0];
      final second = fixture.envelopes[1];
      await fixture.allocate(202610, {first: 1000, second: 1000});
      final before = await fixture.month(202610);
      await fixture.expectInvariant(before);

      final sessions = [
        for (var index = 0; index < 4; index++)
          server.authenticatedSession(fixture.book.userId),
      ];
      addTearDown(() async {
        for (final session in sessions) {
          await session.close();
        }
      });

      events.clear();
      final moves = <Future<BudgetMonthView>>[];
      for (var index = 0; index < 20; index++) {
        final forward = index.isEven;
        moves.add(
          BudgetService.moveMoney(
            sessions[index % sessions.length],
            entityId: fixture.entityId,
            month: 202610,
            fromEnvelopeId: forward ? first.id : second.id,
            toEnvelopeId: forward ? second.id : first.id,
            amountMinor: 10,
          ),
        );
      }
      await Future.wait(moves);

      final after = await fixture.month(202610);
      expect(after.envelopes[0].allocatedMinor, 1000);
      expect(after.envelopes[1].allocatedMinor, 1000);
      expect(await allocationRows(202610), 2);
      expect(events, hasLength(20));
      await fixture.expectInvariant(after);
    },
  );

  test(
    'given a competing split posted after the first aggregate when a plan '
    'write returns its view then the view is one coherent snapshot',
    () async {
      final first = fixture.envelopes[0];
      final second = fixture.envelopes[1];
      await fixture.income(5000, date: DateTime.utc(2026, 10, 1));
      await fixture.allocate(202610, {first: 500, second: 1000});
      final seeded = await TransactionWriter.create(
        fixture.session,
        TransactionInput(
          accountId: fixture.account.id!,
          date: DateTime.utc(2026, 10, 15),
          amountMinor: -500,
          description: 'Seed for split',
          lines: const [],
        ),
      );
      final writer = server.authenticatedSession(fixture.book.userId);
      addTearDown(writer.close);

      var splitPosted = false;
      BudgetMonthService.debugAfterActivityQuery = () async {
        if (splitPosted) return;
        splitPosted = true;
        await TransactionWriter.updateLines(
          writer,
          seeded.transaction.id!,
          [
            TransactionLineInput(amountMinor: -300, envelopeId: second.id),
            TransactionLineInput(amountMinor: -200),
          ],
        );
      };

      final view = await BudgetService.setAllocations(
        fixture.session,
        entityId: fixture.entityId,
        month: 202610,
        allocations: [
          AllocationInput(envelopeId: first.id!, allocatedMinor: 1000),
        ],
      );

      expect(splitPosted, isTrue);
      expect(view.envelopes[0].allocatedMinor, 1000);
      final activity = view.envelopes[1].activityMinor;
      final uncategorised = view.summary.uncategorizedMinor;
      expect(
        (activity == 0 && uncategorised == -500) ||
            (activity == -300 && uncategorised == -200),
        isTrue,
        reason:
            'the write response mixed facts from before and after the split: '
            'envelope activity $activity, uncategorised $uncategorised',
      );

      final later = await fixture.month(202610);
      expect(later.envelopes[1].activityMinor, -300);
      expect(later.summary.uncategorizedMinor, -200);
      await fixture.expectInvariant(later);
    },
  );
}

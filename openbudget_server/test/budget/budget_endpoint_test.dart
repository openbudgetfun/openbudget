import 'package:openbudget_server/src/budget/budget_endpoint.dart';
import 'package:openbudget_server/src/entities/entity_realtime_notifier.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/transactions/transaction_writer.dart';
import 'package:test/test.dart';

import '../support/pg_test_server.dart';
import 'budget_helpers.dart';

void main() {
  late PgTestServer server;
  late BudgetFixture fixture;
  var serverStarted = false;

  setUpAll(() async {
    server = await PgTestServer.start();
    serverStarted = true;
  });

  tearDownAll(() async {
    if (serverStarted) await server.stop();
  });

  setUp(() async {
    TransactionWriter.debugPublisher = (
      session,
      entityId,
      scope, {
      month,
      accountId,
    }) async {};
    EntityRealtimeNotifier.debugPublisher = (
      session,
      entityId,
      scope, {
      month,
      accountId,
    }) async {};
    fixture = await BudgetFixture.create(server.anonymousSession());
    addTearDown(fixture.book.expectBalancesConsistent);
  });

  tearDown(() {
    TransactionWriter.resetForTests();
    EntityRealtimeNotifier.resetForTests();
  });

  test(
    'given the budget endpoint when each plan method runs then it exposes '
    'the section 7.1 contract',
    () async {
      final endpoint = BudgetEndpoint();
      final first = fixture.envelopes[0];
      final second = fixture.envelopes[1];
      expect(endpoint.requireLogin, isTrue);

      final empty = await endpoint.getMonth(
        fixture.session,
        fixture.entityId,
        202610,
      );
      expect(empty.summary.readyToAssignMinor, 0);

      final allocated = await endpoint.setAllocations(
        fixture.session,
        fixture.entityId,
        202610,
        [
          AllocationInput(envelopeId: first.id!, allocatedMinor: 1000),
          AllocationInput(envelopeId: second.id!, allocatedMinor: 500),
        ],
      );
      expect(allocated.summary.allocatedMinor, 1500);

      final moved = await endpoint.moveMoney(
        fixture.session,
        fixture.entityId,
        202610,
        first.id,
        second.id,
        200,
      );
      expect(moved.envelopes[0].allocatedMinor, 800);
      expect(moved.envelopes[1].allocatedMinor, 700);

      final copied = await endpoint.copyMonth(
        fixture.session,
        fixture.entityId,
        202610,
        202611,
      );
      expect(copied.envelopes[0].allocatedMinor, 800);
      expect(copied.envelopes[1].allocatedMinor, 700);

      final template = await endpoint.saveTemplate(
        fixture.session,
        fixture.entityId,
        202610,
        'Endpoint plan',
      );
      final templates = await endpoint.listTemplates(
        fixture.session,
        fixture.entityId,
      );
      expect(templates.map((row) => row.id), contains(template.id));
      final lines = await endpoint.getTemplateLines(
        fixture.session,
        template.id!,
      );
      expect(lines, hasLength(2));

      final applied = await endpoint.applyTemplate(
        fixture.session,
        template.id!,
        202612,
      );
      expect(applied.summary.allocatedMinor, 1500);

      await endpoint.deleteTemplate(fixture.session, template.id!);
      expect(
        await endpoint.listTemplates(fixture.session, fixture.entityId),
        isEmpty,
      );
      await fixture.expectInvariant(applied);
    },
  );
}

import 'package:openbudget_server/src/billing/entitlement_service.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart' show UuidValue;
import 'package:test/test.dart';

import '../helpers/auth_helper.dart';
import '../test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given EntitlementService', (sessionBuilder, endpoints) {
    final userId = UuidValue.fromString('20000000-0000-4000-a000-000000000001');
    final otherUserId = UuidValue.fromString(
      '20000000-0000-4000-a000-000000000002',
    );
    final periodStart = DateTime.utc(2026, 11);
    final periodEnd = DateTime.utc(2026, 12);
    final midPeriod = DateTime.utc(2026, 11, 15);

    Future<Entitlement> record({
      UuidValue? user,
      EntitlementSource source = EntitlementSource.stripe,
      String externalId = 'sub_1',
      EntitlementStatus status = EntitlementStatus.active,
      DateTime? start,
      DateTime? end,
    }) => EntitlementService.record(
      sessionBuilder.build(),
      userId: user ?? userId,
      source: source,
      externalId: externalId,
      status: status,
      currentPeriodStart: start ?? periodStart,
      currentPeriodEnd: end ?? periodEnd,
    );

    Future<Entitlement?> activeAt(DateTime now, {UuidValue? user}) =>
        EntitlementService.activeFor(
          sessionBuilder.build(),
          user ?? userId,
          now: now,
        );

    group('when recording', () {
      test('then the first event inserts a row', () async {
        final entitlement = await record();

        expect(entitlement.id, isNotNull);
        expect(entitlement.status, EntitlementStatus.active);
        expect(entitlement.currentPeriodEnd, periodEnd);
      });

      test(
        'then replaying the same subscription updates it in place',
        () async {
          final first = await record();
          final renewed = await record(
            start: periodEnd,
            end: DateTime.utc(2027),
          );

          expect(renewed.id, first.id);
          expect(renewed.currentPeriodEnd, DateTime.utc(2027));
          final rows = await Entitlement.db.find(sessionBuilder.build());
          expect(rows, hasLength(1));
        },
      );

      test('then the same id on another rail is a separate row', () async {
        await record();
        await record(source: EntitlementSource.solana);

        final rows = await Entitlement.db.find(sessionBuilder.build());
        expect(rows, hasLength(2));
      });

      test('then a subscription cannot move to another user', () async {
        await record();

        await expectLater(
          record(user: otherUserId),
          throwsA(isA<ForbiddenException>()),
        );
      });

      test('then an empty external id is rejected', () async {
        await expectLater(
          record(externalId: ''),
          throwsA(isA<ValidationException>()),
        );
      });

      test('then a period that ends before it starts is rejected', () async {
        await expectLater(
          record(start: periodEnd, end: periodStart),
          throwsA(isA<ValidationException>()),
        );
      });
    });

    group('when checking access', () {
      test('then an active period grants access', () async {
        await record();

        expect(await activeAt(midPeriod), isNotNull);
      });

      test('then a past-due period still grants access', () async {
        await record(status: EntitlementStatus.pastDue);

        expect(await activeAt(midPeriod), isNotNull);
      });

      test('then a cancelled period grants access until it ends', () async {
        await record(status: EntitlementStatus.canceled);

        expect(await activeAt(midPeriod), isNotNull);
        expect(await activeAt(periodEnd), isNull);
      });

      test('then an expired subscription grants nothing', () async {
        await record(status: EntitlementStatus.expired);

        expect(await activeAt(midPeriod), isNull);
      });

      test('then the period ending last wins', () async {
        await record();
        await record(
          source: EntitlementSource.appStore,
          externalId: 'rc_1',
          end: DateTime.utc(2027),
        );

        final entitlement = await activeAt(midPeriod);
        expect(entitlement?.source, EntitlementSource.appStore);
      });

      test('then another user gets nothing', () async {
        await record();

        expect(await activeAt(midPeriod, user: otherUserId), isNull);
      });

      test('then requireActive throws without a subscription', () async {
        await expectLater(
          EntitlementService.requireActive(
            sessionBuilder.build(),
            userId,
            now: midPeriod,
          ),
          throwsA(isA<EntitlementRequiredException>()),
        );
      });
    });

    group('when calling the billing endpoint', () {
      test('then a free user has no entitlement', () async {
        final session = createAuthenticatedSession(sessionBuilder);

        expect(await endpoints.billing.getEntitlement(session), isNull);
      });

      test('then a paying user sees their subscription', () async {
        final session = createAuthenticatedSession(
          sessionBuilder,
          userIdentifier: userId.uuid,
        );
        await record(
          start: DateTime.now().toUtc().subtract(const Duration(days: 1)),
          end: DateTime.now().toUtc().add(const Duration(days: 29)),
        );

        final entitlement = await endpoints.billing.getEntitlement(session);
        expect(entitlement?.externalId, 'sub_1');
      });

      test('then an anonymous caller is rejected', () async {
        await expectLater(
          endpoints.billing.getEntitlement(sessionBuilder),
          throwsA(isA<ServerpodUnauthenticatedException>()),
        );
      });
    });
  });
}

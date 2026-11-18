import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/src/features/budget/providers/age_of_money_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/entity_events_provider.dart';
import 'package:openbudget_app/src/features/home/providers/entity_summary_provider.dart';
import 'package:openbudget_app/src/features/reports/providers/category_trends_provider.dart';
import 'package:openbudget_app/src/features/reports/providers/month_figures_provider.dart';
import 'package:openbudget_app/src/features/reports/providers/multi_month_comparison_provider.dart';
import 'package:openbudget_app/src/features/reports/providers/spending_by_payee_provider.dart';
import 'package:openbudget_app/src/features/reports/providers/spending_report_provider.dart';
import 'package:openbudget_app/src/features/reports/providers/spending_trends_provider.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';

import '../../../support/fake_endpoint_client.dart';

const _entityId = '00000000-0000-0000-0000-000000000001';

void main() {
  test(
    'a transaction event refreshes summaries, reports and age of money',
    () async {
      final endMonth = MonthKey.fromDate(DateTime.now());
      final client = _reportClient(endMonth);
      final events = StreamController<EntityChangedEvent>();
      addTearDown(events.close);
      client.handleStream('entityStream', 'watch', events.stream);
      final container = ProviderContainer(
        overrides: [serverpodClientProvider.overrideWithValue(client)],
      );
      addTearDown(container.dispose);

      final subscriptions = _watchReports(container, endMonth);
      addTearDown(() {
        for (final subscription in subscriptions) {
          subscription.close();
        }
      });
      await _settle(container, endMonth);

      expect(client.callsTo('entity', 'listSummaries'), hasLength(1));
      expect(client.callsTo('report', 'ageOfMoney'), hasLength(1));
      expect(client.callsTo('report', 'spending'), hasLength(5));
      expect(client.callsTo('report', 'monthSummaries'), hasLength(3));

      events.add(
        EntityChangedEvent(
          entityId: UuidValue.fromString(_entityId),
          scope: ChangeScope.transactions,
        ),
      );
      await Future<void>.delayed(Duration.zero);
      await _settle(container, endMonth);

      expect(client.callsTo('entity', 'listSummaries'), hasLength(2));
      expect(client.callsTo('report', 'ageOfMoney'), hasLength(2));
      expect(client.callsTo('report', 'spending'), hasLength(10));
      expect(client.callsTo('report', 'monthSummaries'), hasLength(6));
    },
  );

  test(
    'an account event refreshes the summaries but not the reports',
    () async {
      final endMonth = MonthKey.fromDate(DateTime.now());
      final client = _reportClient(endMonth);
      final events = StreamController<EntityChangedEvent>();
      addTearDown(events.close);
      client.handleStream('entityStream', 'watch', events.stream);
      final container = ProviderContainer(
        overrides: [serverpodClientProvider.overrideWithValue(client)],
      );
      addTearDown(container.dispose);

      final subscriptions = _watchReports(container, endMonth);
      addTearDown(() {
        for (final subscription in subscriptions) {
          subscription.close();
        }
      });
      await _settle(container, endMonth);

      events.add(
        EntityChangedEvent(
          entityId: UuidValue.fromString(_entityId),
          scope: ChangeScope.accounts,
        ),
      );
      await Future<void>.delayed(Duration.zero);
      await _settle(container, endMonth);

      expect(client.callsTo('entity', 'listSummaries'), hasLength(2));
      expect(client.callsTo('report', 'ageOfMoney'), hasLength(1));
      expect(client.callsTo('report', 'spending'), hasLength(5));
      expect(client.callsTo('report', 'monthSummaries'), hasLength(3));
    },
  );
}

FakeEndpointClient _reportClient(int endMonth) => FakeEndpointClient()
  ..handle('entity', 'get', (_) => testEntity())
  ..handle('entity', 'listSummaries', (_) => <EntitySummaryView>[])
  ..handle('report', 'ageOfMoney', (_) => 21)
  ..handle(
    'report',
    'monthSummaries',
    (_) => [testMonthSummary(month: endMonth)],
  )
  ..handle('report', 'spending', (_) => <SpendingRow>[])
  ..handle('category', 'list', (_) => <Category>[])
  ..handle('envelope', 'list', (_) => <Envelope>[]);

List<ProviderSubscription<dynamic>> _watchReports(
  ProviderContainer container,
  int endMonth,
) => [
  container.listen(entityEventsProvider(_entityId), (_, _) {}),
  container.listen(entitySummariesProvider, (_, _) {}),
  container.listen(ageOfMoneyProvider(_entityId), (_, _) {}),
  container.listen(monthFiguresProvider(_entityId, endMonth, 3), (_, _) {}),
  container.listen(spendingReportProvider(_entityId, endMonth), (_, _) {}),
  container.listen(
    spendingReportPresetProvider(_entityId, endMonth, 3),
    (_, _) {},
  ),
  container.listen(spendingByPayeeProvider(_entityId, endMonth), (_, _) {}),
  container.listen(categoryTrendsProvider(_entityId), (_, _) {}),
  container.listen(spendingTrendsProvider(_entityId), (_, _) {}),
  container.listen(multiMonthComparisonProvider(_entityId), (_, _) {}),
];

Future<void> _settle(ProviderContainer container, int endMonth) async {
  await Future.wait([
    container.read(entitySummariesProvider.future),
    container.read(ageOfMoneyProvider(_entityId).future),
    container.read(monthFiguresProvider(_entityId, endMonth, 3).future),
    container.read(spendingReportProvider(_entityId, endMonth).future),
    container.read(
      spendingReportPresetProvider(_entityId, endMonth, 3).future,
    ),
    container.read(spendingByPayeeProvider(_entityId, endMonth).future),
    container.read(categoryTrendsProvider(_entityId).future),
    container.read(spendingTrendsProvider(_entityId).future),
    container.read(multiMonthComparisonProvider(_entityId).future),
  ]);
}

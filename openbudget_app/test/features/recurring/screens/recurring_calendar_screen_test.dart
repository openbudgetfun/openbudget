import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/recurring/screens/recurring_calendar_screen.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_test_utils/openbudget_test_utils.dart';

import '../../../fixtures/budget_month.dart';
import '../../../fixtures/transactions.dart';
import '../../../support/fake_endpoint_client.dart';

const String _entityId = fixtureEntityId;
const String _usdAccountId = '00000000-0000-0000-0000-0000000000f0e1';

Future<void> _pumpCalendar(
  WidgetTester tester, {
  List<RecurringTransaction> items = const [],
  List<Account>? accounts,
}) async {
  final client = FakeEndpointClient()
    ..handle('recurringTransaction', 'list', (_) => items)
    ..handle(
      'account',
      'list',
      (_) =>
          accounts ??
          [
            testAccount(),
            testAccount(
              id: _usdAccountId,
              name: 'Dollar account',
              currencyCode: 'USD',
            ),
          ],
    );
  final container = ProviderContainer(
    retry: (_, _) => null,
    overrides: [serverpodClientProvider.overrideWithValue(client)],
  );
  addTearDown(container.dispose);
  await tester.pumpApp(
    const RecurringCalendarScreen(entityId: _entityId),
    container: container,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
  );
  await tester.pumpAndSettle();
}

DateTime _dayInMonth(DateTime month, int day) =>
    DateTime(month.year, month.month, day);

void main() {
  group('RecurringCalendarScreen', () {
    testWidgets('renders the weekday headings and the month name', (
      tester,
    ) async {
      final now = DateTime.now();
      await _pumpCalendar(tester);

      expect(find.text('Schedule Calendar'), findsOneWidget);
      for (final day in ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']) {
        expect(find.text(day), findsOneWidget);
      }
      expect(find.text('${_monthName(now.month)} ${now.year}'), findsOneWidget);
      expect(
        find.text('Tap a day to see scheduled transactions'),
        findsOneWidget,
      );
    });

    testWidgets('moves between months', (tester) async {
      final now = DateTime.now();
      final next = DateTime(now.year, now.month + 1);
      await _pumpCalendar(tester);

      await tester.tap(
        find.byKey(RecurringCalendarScreen.nextMonthKey),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('${_monthName(next.month)} ${next.year}'),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(RecurringCalendarScreen.previousMonthKey),
      );
      await tester.pumpAndSettle();
      expect(find.text('${_monthName(now.month)} ${now.year}'), findsOneWidget);
    });

    testWidgets('marks today as due with its account currency', (tester) async {
      final now = DateTime.now();
      await _pumpCalendar(
        tester,
        items: [
          testRecurring(nextDate: _dayInMonth(now, now.day)),
        ],
      );

      await tester.tap(find.text('${now.day}'));
      await tester.pumpAndSettle();

      expect(find.text('Rent'), findsOneWidget);
      expect(find.text('Due now'), findsWidgets);
      expect(find.text('-£1,200.00'), findsOneWidget);
    });

    testWidgets('shows a future occurrence as scheduled', (tester) async {
      final now = DateTime.now();
      final next = DateTime(now.year, now.month + 1);
      await _pumpCalendar(
        tester,
        items: [
          testRecurring(
            description: 'Insurance',
            nextDate: _dayInMonth(next, 15),
          ),
        ],
      );

      await tester.tap(
        find.byKey(RecurringCalendarScreen.nextMonthKey),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('15'));
      await tester.pumpAndSettle();

      expect(find.text('Insurance'), findsOneWidget);
      expect(find.text('Scheduled'), findsOneWidget);
    });

    testWidgets('shows a past occurrence as posted', (tester) async {
      final now = DateTime.now();
      final previous = DateTime(now.year, now.month - 1);
      await _pumpCalendar(
        tester,
        items: [
          testRecurring(
            description: 'Gym',
            nextDate: _dayInMonth(previous, 15),
          ),
        ],
      );

      await tester.tap(
        find.byKey(RecurringCalendarScreen.previousMonthKey),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('15'));
      await tester.pumpAndSettle();

      expect(find.text('Gym'), findsOneWidget);
      expect(find.text('Posted'), findsOneWidget);
    });

    testWidgets('an empty day says nothing is scheduled', (tester) async {
      final now = DateTime.now();
      await _pumpCalendar(
        tester,
        items: [
          testRecurring(nextDate: _dayInMonth(now, now.day)),
        ],
      );

      final emptyDay = now.day == 1 ? 2 : 1;
      await tester.tap(find.text('$emptyDay'));
      await tester.pumpAndSettle();

      expect(
        find.text('No scheduled transactions on this day'),
        findsOneWidget,
      );
    });

    testWidgets('a USD schedule shows dollars from its account', (
      tester,
    ) async {
      final now = DateTime.now();
      await _pumpCalendar(
        tester,
        items: [
          testRecurring(
            accountId: _usdAccountId,
            description: 'US bill',
            amountMinor: -5000,
            nextDate: _dayInMonth(now, now.day),
          ),
        ],
      );

      await tester.tap(find.text('${now.day}'));
      await tester.pumpAndSettle();

      expect(find.text(r'-$50.00'), findsOneWidget);
    });

    testWidgets('a paused schedule never appears', (tester) async {
      final now = DateTime.now();
      await _pumpCalendar(
        tester,
        items: [
          testRecurring(
            description: 'Paused bill',
            isActive: false,
            nextDate: _dayInMonth(now, now.day),
          ),
        ],
      );

      await tester.tap(find.text('${now.day}'));
      await tester.pumpAndSettle();

      expect(
        find.text('No scheduled transactions on this day'),
        findsOneWidget,
      );
      expect(find.text('Paused bill'), findsNothing);
    });
  });
}

String _monthName(int month) => switch (month) {
  1 => 'January',
  2 => 'February',
  3 => 'March',
  4 => 'April',
  5 => 'May',
  6 => 'June',
  7 => 'July',
  8 => 'August',
  9 => 'September',
  10 => 'October',
  11 => 'November',
  _ => 'December',
};

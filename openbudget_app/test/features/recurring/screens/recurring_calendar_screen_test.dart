// UuidValue is needed for constructing test model data.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/recurring/providers/recurring_calendar_provider.dart';
import 'package:openbudget_app/src/features/recurring/screens/recurring_calendar_screen.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

const _budgetId = 'test-budget-id';
final _budgetUuid = UuidValue.fromString(
  '00000000-0000-0000-0000-000000000101',
);

RecurringTransaction _makeRecurring({
  required String description,
  required DateTime nextOccurrence,
  int amountCents = -1499,
}) => RecurringTransaction(
  id: UuidValue.fromString('00000000-0000-0000-0000-000000000102'),
  description: description,
  amountCents: amountCents,
  currencyCode: 'USD',
  budgetId: _budgetUuid,
  frequency: 'monthly',
  nextOccurrence: nextOccurrence,
  isActive: true,
);

ScheduledOccurrence _occurrence({
  required String description,
  required DateTime date,
  required bool isDue,
  int amountCents = -1499,
}) => ScheduledOccurrence(
  recurring: _makeRecurring(
    description: description,
    nextOccurrence: date,
    amountCents: amountCents,
  ),
  date: date,
  isDue: isDue,
);

Widget _subject(Map<int, List<ScheduledOccurrence>> dayMap) => ProviderScope(
  overrides: [
    recurringCalendarProvider.overrideWith((ref, args) async => dayMap),
  ],
  child: MaterialApp(
    theme: OpenBudgetTheme.light,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const RecurringCalendarScreen(budgetId: _budgetId),
  ),
);

void main() {
  final now = DateTime.now();
  final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
  final dueDate = DateTime(now.year, now.month, now.day);
  final futureDate = DateTime(
    now.year,
    now.month,
    (now.day + 1).clamp(1, daysInMonth),
  );
  final pastDate = DateTime(
    now.year,
    now.month,
    (now.day - 1).clamp(1, daysInMonth),
  );

  group('RecurringCalendarScreen', () {
    testWidgets('renders the month grid with weekday headings', (tester) async {
      await tester.pumpWidget(
        _subject({
          dueDate.day: [
            _occurrence(
              description: 'Rent',
              date: dueDate,
              isDue: true,
              amountCents: -150000,
            ),
          ],
        }),
      );
      await tester.pumpAndSettle();

      expect(find.text('Schedule Calendar'), findsOneWidget);
      expect(find.text('Mon'), findsOneWidget);
      expect(find.text('Sun'), findsOneWidget);
      expect(find.text('${dueDate.day}'), findsOneWidget);
    });

    testWidgets('marks a due occurrence with its tone chip', (tester) async {
      await tester.pumpWidget(
        _subject({
          dueDate.day: [
            _occurrence(
              description: 'Rent',
              date: dueDate,
              isDue: true,
              amountCents: -150000,
            ),
          ],
        }),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('${dueDate.day}'));
      await tester.pumpAndSettle();

      expect(find.text('Rent'), findsOneWidget);
      expect(find.text('Due now'), findsWidgets);
      expect(find.byType(ObToneChip), findsWidgets);
    });

    testWidgets('marks a future occurrence as scheduled', (tester) async {
      if (futureDate.day == dueDate.day) {
        return;
      }
      await tester.pumpWidget(
        _subject({
          futureDate.day: [
            _occurrence(
              description: 'Gym',
              date: futureDate,
              isDue: false,
            ),
          ],
        }),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('${futureDate.day}'));
      await tester.pumpAndSettle();

      expect(find.text('Gym'), findsOneWidget);
      expect(find.text('Scheduled'), findsOneWidget);
    });

    testWidgets('marks a past occurrence as posted', (tester) async {
      if (pastDate.day == dueDate.day) {
        return;
      }
      await tester.pumpWidget(
        _subject({
          pastDate.day: [
            _occurrence(
              description: 'Streaming',
              date: pastDate,
              isDue: true,
            ),
          ],
        }),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('${pastDate.day}'));
      await tester.pumpAndSettle();

      expect(find.text('Streaming'), findsOneWidget);
      expect(find.text('Posted'), findsOneWidget);
    });

    testWidgets('shows an empty panel for a day with nothing scheduled', (
      tester,
    ) async {
      final emptyDay = now.day == 1 ? 2 : 1;
      await tester.pumpWidget(_subject(const {}));
      await tester.pumpAndSettle();

      await tester.tap(find.text('$emptyDay'));
      await tester.pumpAndSettle();

      expect(
        find.text('No scheduled transactions on this day'),
        findsOneWidget,
      );
      expect(find.byType(ObStatePanel), findsOneWidget);
    });

    testWidgets('shows a prompt before a day is chosen', (tester) async {
      await tester.pumpWidget(_subject(const {}));
      await tester.pumpAndSettle();

      expect(
        find.text('Tap a day to see scheduled transactions'),
        findsOneWidget,
      );
    });
  });
}

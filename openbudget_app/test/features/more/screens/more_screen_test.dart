import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/more/screens/more_screen.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

void main() {
  const budgetId = 'test-budget-1';

  Finder skribbleIcon(WiredSvgIconData data) => find.byWidgetPredicate(
    (widget) => widget is SkribbleIcon && widget.data == data,
  );

  Widget buildSubject() => MaterialApp(
    theme: OpenBudgetTheme.light,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const MoreScreen(budgetId: budgetId),
  );

  group('MoreScreen', () {
    testWidgets('renders More title in app bar', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('More'), findsOneWidget);
    });

    testWidgets('shows all navigation items', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Recurring Transactions'), findsOneWidget);
      expect(find.text('Payees'), findsOneWidget);
      expect(find.text('Transaction Rules'), findsOneWidget);
      expect(find.text('Import Transactions'), findsOneWidget);
      expect(find.text('Taxes'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('shows correct icons for each item', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(skribbleIcon(OpenBudgetIcons.recurring), findsOneWidget);
      expect(skribbleIcon(OpenBudgetIcons.people), findsOneWidget);
      expect(skribbleIcon(OpenBudgetIcons.rule), findsOneWidget);
      expect(skribbleIcon(OpenBudgetIcons.upload), findsOneWidget);
      expect(skribbleIcon(OpenBudgetIcons.scale), findsOneWidget);
      expect(skribbleIcon(OpenBudgetIcons.settings), findsOneWidget);
    });

    testWidgets('shows chevron trailing icons', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(skribbleIcon(OpenBudgetIcons.chevronRight), findsNWidgets(6));
    });

    testWidgets('renders items inside a Card', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byType(Card), findsOneWidget);
    });
  });
}

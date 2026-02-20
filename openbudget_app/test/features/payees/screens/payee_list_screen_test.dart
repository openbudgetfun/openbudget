// UuidValue is needed for constructing test model data.
// ignore_for_file: experimental_member_use

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/payees/providers/payee_list_provider.dart';
import 'package:openbudget_app/src/features/payees/screens/payee_list_screen.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

const _budgetId = 'test-budget-id';
final _budgetUuid = UuidValue.fromString(
  '00000000-0000-0000-0000-000000000010',
);

Payee _makePayee({String name = 'Grocery Store', UuidValue? id}) {
  return Payee(id: id, name: name, budgetId: _budgetUuid);
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('PayeeListScreen', () {
    testWidgets('renders loading indicator while payees load', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const PayeeListScreen(budgetId: _budgetId),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders error state with error icon', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            payeeListProvider.overrideWith(
              (ref, budgetId) => throw Exception('Could not load payees'),
            ),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const PayeeListScreen(budgetId: _budgetId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Could not load payees'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
    });

    testWidgets('renders empty state with add payee button', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            payeeListProvider.overrideWith((ref, budgetId) async => <Payee>[]),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const PayeeListScreen(budgetId: _budgetId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No Payees Yet'), findsOneWidget);
      expect(
        find.text('Add payees to track who you transact with'),
        findsOneWidget,
      );
      expect(find.text('Add Payee'), findsOneWidget);
      expect(find.byIcon(Icons.store_rounded), findsOneWidget);
    });

    testWidgets('renders payee list with payee names', (tester) async {
      final payees = [
        _makePayee(
          name: 'Whole Foods',
          id: UuidValue.fromString('00000000-0000-0000-0000-000000000020'),
        ),
        _makePayee(
          name: 'Amazon',
          id: UuidValue.fromString('00000000-0000-0000-0000-000000000021'),
        ),
        _makePayee(
          name: 'Netflix',
          id: UuidValue.fromString('00000000-0000-0000-0000-000000000022'),
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            payeeListProvider.overrideWith((ref, budgetId) async => payees),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const PayeeListScreen(budgetId: _budgetId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Whole Foods'), findsOneWidget);
      expect(find.text('Amazon'), findsOneWidget);
      expect(find.text('Netflix'), findsOneWidget);
    });

    testWidgets('renders search field when payees exist', (tester) async {
      final payees = [
        _makePayee(
          name: 'Target',
          id: UuidValue.fromString('00000000-0000-0000-0000-000000000030'),
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            payeeListProvider.overrideWith((ref, budgetId) async => payees),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const PayeeListScreen(budgetId: _budgetId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
    });

    testWidgets('renders app bar with payees title', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            payeeListProvider.overrideWith((ref, budgetId) async => <Payee>[]),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const PayeeListScreen(budgetId: _budgetId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Payees'), findsOneWidget);
    });

    testWidgets('renders add payee action button in app bar', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            payeeListProvider.overrideWith((ref, budgetId) async => <Payee>[]),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const PayeeListScreen(budgetId: _budgetId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The add icon appears in the app bar action button.
      expect(find.byIcon(Icons.add), findsWidgets);
    });

    testWidgets('renders store icon for each payee', (tester) async {
      final payees = [
        _makePayee(
          name: 'Walmart',
          id: UuidValue.fromString('00000000-0000-0000-0000-000000000040'),
        ),
        _makePayee(
          name: 'Costco',
          id: UuidValue.fromString('00000000-0000-0000-0000-000000000041'),
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            payeeListProvider.overrideWith((ref, budgetId) async => payees),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const PayeeListScreen(budgetId: _budgetId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.store_rounded), findsWidgets);
    });
  });
}

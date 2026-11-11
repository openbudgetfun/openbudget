// UuidValue is needed for constructing test model data.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/payees/providers/payee_list_provider.dart';
import 'package:openbudget_app/src/features/payees/screens/payee_list_screen.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

const _entityId = 'test-budget-id';
final _budgetUuid = UuidValue.fromString(
  '00000000-0000-0000-0000-000000000010',
);

Payee _makePayee({String name = 'Grocery Store', UuidValue? id}) =>
    Payee(id: id, name: name, entityId: _budgetUuid);

void main() {
  group('PayeeListScreen', () {
    testWidgets('renders loading indicator while payees load', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const PayeeListScreen(entityId: _entityId),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(ObLoadingPanel), findsOneWidget);
    });

    testWidgets('renders error state with error icon', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            payeeListProvider.overrideWith(
              (ref, entityId) => throw Exception('Could not load payees'),
            ),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const PayeeListScreen(entityId: _entityId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Could not load payees'), findsOneWidget);
      expect(find.byType(ObStatePanel), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) => w is WiredDoodle && w.kind == WiredDoodleKind.cloud,
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders empty state with add payee button', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            payeeListProvider.overrideWith((ref, entityId) async => <Payee>[]),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const PayeeListScreen(entityId: _entityId),
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
      expect(find.byKey(payeeListEmptyKey), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) => w is WiredDoodle && w.kind == WiredDoodleKind.cupcake,
        ),
        findsOneWidget,
      );
    });

    testWidgets('add payee action opens a hand-drawn name field', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            payeeListProvider.overrideWith((ref, entityId) async => <Payee>[]),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const PayeeListScreen(entityId: _entityId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add Payee'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.byType(ObTextField), findsOneWidget);
      expect(find.byType(ObFilledButton), findsOneWidget);
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
            payeeListProvider.overrideWith((ref, entityId) async => payees),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const PayeeListScreen(entityId: _entityId),
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
            payeeListProvider.overrideWith((ref, entityId) async => payees),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const PayeeListScreen(entityId: _entityId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) => w is SkribbleIcon && w.data == OpenBudgetIcons.search,
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders app bar with payees title', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            payeeListProvider.overrideWith((ref, entityId) async => <Payee>[]),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const PayeeListScreen(entityId: _entityId),
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
            payeeListProvider.overrideWith((ref, entityId) async => <Payee>[]),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const PayeeListScreen(entityId: _entityId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The add icon appears in the app bar action button.
      expect(
        find.byWidgetPredicate(
          (w) => w is SkribbleIcon && w.data == OpenBudgetIcons.add,
        ),
        findsWidgets,
      );
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
            payeeListProvider.overrideWith((ref, entityId) async => payees),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const PayeeListScreen(entityId: _entityId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (w) => w is SkribbleIcon && w.data == OpenBudgetIcons.store,
        ),
        findsWidgets,
      );
    });
  });
}

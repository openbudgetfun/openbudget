import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/features/ledger/providers/ledger_repository.dart';
import 'package:openbudget_app/src/features/ledger/widgets/books_entry_tile.dart';
import 'package:openbudget_app/src/features/tax/providers/tax_providers.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_test_utils/openbudget_test_utils.dart';

import '../ledger_test_data.dart';

Future<void> _pumpTile(
  WidgetTester tester,
  FakeLedgerRepository repository, {
  String entityKind = 'soleTrader',
  String accountingMode = 'envelope',
}) async {
  final container = ProviderContainer(
    overrides: [
      ledgerRepositoryProvider.overrideWithValue(repository),
      taxProfileProvider.overrideWith(
        (ref, id) async => entityKind.isEmpty
            ? null
            : businessTaxProfile(entityKind: entityKind),
      ),
      budgetDetailProvider.overrideWith(
        (ref, id) async => testBudget(accountingMode: accountingMode),
      ),
    ],
  );
  addTearDown(container.dispose);
  final router = GoRouter(
    initialLocation: '/more',
    routes: [
      GoRoute(
        path: '/more',
        builder: (_, _) => const Scaffold(
          body: BooksEntryTile(
            entityId: testBudgetId,
          ),
        ),
      ),
      GoRoute(
        name: booksRoute,
        path: '/budgets/:id/books',
        builder: (_, _) => const Scaffold(body: Text('Books stub')),
      ),
    ],
  );
  await tester.pumpApp(
    const SizedBox.shrink(),
    container: container,
    router: router,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
  );
  await tester.pumpAndSettle();
}

Finder get _tile => find.byKey(const Key('books-entry-tile'));

void main() {
  group('BooksEntryTile', () {
    testWidgets('hides for an individual budget', (tester) async {
      await _pumpTile(
        tester,
        FakeLedgerRepository(),
        entityKind: 'individual',
      );

      expect(_tile, findsNothing);
    });

    testWidgets('hides while the profile has not loaded', (tester) async {
      await _pumpTile(tester, FakeLedgerRepository(), entityKind: '');

      expect(_tile, findsNothing);
    });

    testWidgets('offers the one-way enable action in envelope mode', (
      tester,
    ) async {
      final repository = FakeLedgerRepository();
      await _pumpTile(tester, repository);

      expect(find.text('Enable double-entry books'), findsOneWidget);

      await tester.tap(_tile);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('books-enable-dialog')), findsOneWidget);
      expect(find.textContaining('one-way'), findsOneWidget);
      expect(repository.enabledBudgets, isEmpty);

      await tester.tap(find.byKey(const Key('books-enable-confirm')));
      await tester.pumpAndSettle();

      expect(repository.enabledBudgets, [testBudgetId]);
      expect(find.text('Books stub'), findsOneWidget);
    });

    testWidgets('canceling the enable dialog changes nothing', (tester) async {
      final repository = FakeLedgerRepository();
      await _pumpTile(tester, repository);

      await tester.tap(_tile);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('books-enable-cancel')));
      await tester.pumpAndSettle();

      expect(repository.enabledBudgets, isEmpty);
      expect(find.text('Books stub'), findsNothing);
    });

    testWidgets('opens the books directly in ledger mode', (tester) async {
      final repository = FakeLedgerRepository();
      await _pumpTile(tester, repository, accountingMode: 'ledger');

      expect(find.text('Books'), findsOneWidget);

      await tester.tap(_tile);
      await tester.pumpAndSettle();

      expect(find.text('Books stub'), findsOneWidget);
      expect(repository.enabledBudgets, isEmpty);
    });
  });
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/home/providers/entity_detail_provider.dart';
import 'package:openbudget_app/src/features/ledger/providers/ledger_repository.dart';
import 'package:openbudget_app/src/features/ledger/widgets/books_entry_tile.dart';
import 'package:openbudget_app/src/features/tax/providers/tax_providers.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_test_utils/openbudget_test_utils.dart';

import '../ledger_test_data.dart';

Future<void> _pumpTile(
  WidgetTester tester,
  FakeLedgerRepository repository, {
  EntityKind entityKind = EntityKind.soleTrader,
  AccountingMode accountingMode = AccountingMode.envelope,
}) async {
  final container = ProviderContainer(
    overrides: [
      ledgerRepositoryProvider.overrideWithValue(repository),
      taxProfileProvider.overrideWith(
        // Books are a business feature: the tile shows for a business
        // entity in envelope mode, and for any entity once the ledger is
        // on. An individual envelope entity has no books to enter.
        (ref, id) async =>
            (accountingMode == AccountingMode.envelope &&
                entityKind == EntityKind.individual)
            ? null
            : businessTaxProfile(entityKind: entityKind),
      ),
      entityDetailProvider.overrideWith(
        (ref, id) async =>
            testEntity(accountingMode: accountingMode, kind: entityKind),
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
        path: '/budgets/:entityId/books',
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
        entityKind: EntityKind.individual,
      );

      expect(_tile, findsNothing);
    });

    testWidgets('hides while the entity has not loaded', (tester) async {
      // The tile shows only once the entity's kind is known; the tax
      // profile no longer gates it.
      final container = ProviderContainer(
        overrides: [
          ledgerRepositoryProvider.overrideWithValue(FakeLedgerRepository()),
          entityDetailProvider.overrideWith(
            (ref, id) => Completer<Entity>().future,
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
              body: BooksEntryTile(entityId: testBudgetId),
            ),
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
      await tester.pump();

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
      expect(repository.enabledEntities, isEmpty);

      await tester.tap(find.byKey(const Key('books-enable-confirm')));
      await tester.pumpAndSettle();

      expect(repository.enabledEntities, [testBudgetId]);
      expect(find.text('Books stub'), findsOneWidget);
    });

    testWidgets('canceling the enable dialog changes nothing', (tester) async {
      final repository = FakeLedgerRepository();
      await _pumpTile(tester, repository);

      await tester.tap(_tile);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('books-enable-cancel')));
      await tester.pumpAndSettle();

      expect(repository.enabledEntities, isEmpty);
      expect(find.text('Books stub'), findsNothing);
    });

    testWidgets('opens the books directly in ledger mode', (tester) async {
      final repository = FakeLedgerRepository();
      await _pumpTile(
        tester,
        repository,
        accountingMode: AccountingMode.ledger,
      );

      expect(find.text('Books'), findsOneWidget);

      await tester.tap(_tile);
      await tester.pumpAndSettle();

      expect(find.text('Books stub'), findsOneWidget);
      expect(repository.enabledEntities, isEmpty);
    });
  });
}

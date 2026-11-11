import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/tax/providers/tax_repository.dart';
import 'package:openbudget_app/src/features/tax/widgets/tax_category_sheet.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

import '../tax_test_data.dart';

Widget _buildHost(
  FakeTaxRepository repository, {
  bool transaction = false,
  String? currentCode,
  int? businessUsePercent,
  int? salesTaxMinor,
}) => ProviderScope(
  overrides: [taxRepositoryProvider.overrideWithValue(repository)],
  child: MaterialApp(
    theme: OpenBudgetTheme.light,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: Builder(
        builder: (context) => TextButton(
          onPressed: () {
            if (transaction) {
              unawaited(
                showTransactionTaxCategorySheet(
                  context,
                  entityId: testBudgetId,
                  transactionId: testTransactionId,
                  subject: 'Train ticket',
                  currencyCode: 'GBP',
                  currentCode: currentCode,
                  businessUsePercent: businessUsePercent,
                  salesTaxMinor: salesTaxMinor,
                ),
              );
            } else {
              unawaited(
                showEnvelopeTaxCategorySheet(
                  context,
                  entityId: testBudgetId,
                  envelopeId: testEnvelopeId,
                  subject: 'Rent',
                  currentCode: currentCode,
                ),
              );
            }
          },
          child: const Text('Open'),
        ),
      ),
    ),
  ),
);

Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

void main() {
  group('TaxCategorySheet', () {
    testWidgets('shows a loading panel while categories load', (tester) async {
      final completer = Completer<List<TaxCategoryView>>();
      final loadingRepository = _LoadingCategoriesRepository(completer);
      await tester.pumpWidget(_buildHost(loadingRepository));
      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Loading tax categories'), findsOneWidget);
    });

    testWidgets('shows a problem panel when categories fail', (tester) async {
      await tester.pumpWidget(
        _buildHost(FakeTaxRepository(categoriesError: Exception('offline'))),
      );
      await _open(tester);

      expect(find.text("We couldn't load tax categories."), findsWidgets);
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('invites setup when no tax profile exists', (tester) async {
      await tester.pumpWidget(
        _buildHost(
          FakeTaxRepository(
            categoriesError: Exception('Tax profile not found for this budget'),
          ),
        ),
      );
      await _open(tester);

      expect(find.text('Set up taxes'), findsWidgets);
      expect(
        find.text('Set up a tax profile first to choose a category.'),
        findsOneWidget,
      );
    });

    testWidgets('groups categories and shows report references', (
      tester,
    ) async {
      await tester.pumpWidget(_buildHost(FakeTaxRepository()));
      await _open(tester);

      expect(find.text('Tax category'), findsOneWidget);
      expect(find.text('None'), findsOneWidget);
      expect(find.text('Income'), findsOneWidget);
      expect(find.text('Expenses'), findsOneWidget);
      expect(find.text('Reliefs'), findsOneWidget);
      expect(find.text('Employment income'), findsOneWidget);
      expect(find.text('Office costs'), findsOneWidget);
      expect(find.text('SA103F box 20'), findsOneWidget);
    });

    testWidgets('filters by label and reference', (tester) async {
      await tester.pumpWidget(_buildHost(FakeTaxRepository()));
      await _open(tester);

      await tester.enterText(find.byType(TextField), 'office');
      await tester.pumpAndSettle();

      expect(find.text('Office costs'), findsOneWidget);
      expect(find.text('Employment income'), findsNothing);

      await tester.enterText(find.byType(TextField), 'SA100');
      await tester.pumpAndSettle();

      expect(find.text('Employment income'), findsOneWidget);
      expect(find.text('Office costs'), findsNothing);

      await tester.enterText(find.byType(TextField), 'zzz');
      await tester.pumpAndSettle();

      expect(find.text('No categories match "zzz".'), findsOneWidget);
    });

    testWidgets('saves a chosen envelope category', (tester) async {
      final repository = FakeTaxRepository();
      await tester.pumpWidget(_buildHost(repository));
      await _open(tester);

      await tester.tap(find.text('Office costs'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save category'));
      await tester.pumpAndSettle();

      expect(repository.envelopeUpdates, [
        (envelopeId: testEnvelopeId, code: 'gb.se.office_costs'),
      ]);
      expect(find.text('Save category'), findsNothing);
    });

    testWidgets('clears an envelope category with None', (tester) async {
      final repository = FakeTaxRepository();
      await tester.pumpWidget(
        _buildHost(repository, currentCode: 'gb.ind.employment'),
      );
      await _open(tester);

      await tester.tap(find.text('None'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save category'));
      await tester.pumpAndSettle();

      expect(repository.envelopeUpdates.single.code, isNull);
    });

    testWidgets('carries business use and sales tax for a transaction', (
      tester,
    ) async {
      final repository = FakeTaxRepository();
      await tester.pumpWidget(
        _buildHost(
          repository,
          transaction: true,
          businessUsePercent: 40,
          salesTaxMinor: 250,
        ),
      );
      await _open(tester);

      await tester.tap(find.text('Office costs'));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Business use'),
        300,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();

      final slider = tester.widget<Slider>(find.byType(Slider));
      expect(slider.value, 40);
      expect(find.text('40%'), findsOneWidget);

      await tester.ensureVisible(find.byType(TextField).last);
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField).last).controller?.text,
        '2.50',
      );
      await tester.tap(find.text('Save category'));
      await tester.pumpAndSettle();

      expect(repository.transactionUpdates.single.code, 'gb.se.office_costs');
      expect(repository.transactionUpdates.single.businessUsePercent, 40);
      expect(repository.transactionUpdates.single.salesTaxMinor, 250);
    });

    testWidgets('rejects a malformed sales tax amount', (tester) async {
      final repository = FakeTaxRepository();
      await tester.pumpWidget(_buildHost(repository, transaction: true));
      await _open(tester);

      await tester.scrollUntilVisible(
        find.text('Business use'),
        300,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'abc');
      await tester.tap(find.text('Save category'));
      await tester.pumpAndSettle();

      expect(
        find.text('Enter an amount no larger than the transaction.'),
        findsOneWidget,
      );
      expect(repository.transactionUpdates, isEmpty);
    });

    testWidgets('shows a save failure without closing the sheet', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildHost(FakeTaxRepository(envelopeError: Exception('rejected'))),
      );
      await _open(tester);

      await tester.tap(find.text('Save category'));
      await tester.pumpAndSettle();

      expect(find.text("We couldn't update the tax category."), findsOneWidget);
      expect(find.text('Save category'), findsOneWidget);
    });
  });
}

class _LoadingCategoriesRepository extends FakeTaxRepository {
  _LoadingCategoriesRepository(this.completer);

  final Completer<List<TaxCategoryView>> completer;

  @override
  Future<List<TaxCategoryView>> listCategories(String entityId) =>
      completer.future;
}

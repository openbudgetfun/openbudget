// UuidValue is needed for constructing test model data.
// ignore_for_file: experimental_member_use

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/features/budget/widgets/category_group.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  final budgetId = UuidValue.fromString('00000000-0000-0000-0000-000000000101');
  final categoryId = UuidValue.fromString(
    '00000000-0000-0000-0000-000000000102',
  );
  final envelopeOneId = UuidValue.fromString(
    '00000000-0000-0000-0000-000000000103',
  );
  final envelopeTwoId = UuidValue.fromString(
    '00000000-0000-0000-0000-000000000104',
  );

  CategoryWithEnvelopes makeCategoryWithEnvelopes() {
    final groceries = Envelope(
      id: envelopeOneId,
      name: 'Groceries',
      categoryId: categoryId,
      budgetedAmountCents: 0,
      spentAmountCents: 0,
      currencyCode: 'USD',
      sortOrder: 0,
    );
    final dining = Envelope(
      id: envelopeTwoId,
      name: 'Dining Out',
      categoryId: categoryId,
      budgetedAmountCents: 0,
      spentAmountCents: 0,
      currencyCode: 'USD',
      sortOrder: 1,
    );

    return CategoryWithEnvelopes(
      category: Category(
        id: categoryId,
        name: 'Needs',
        budgetId: budgetId,
        sortOrder: 0,
      ),
      envelopes: [groceries, dining],
      monthlyEnvelopes: [
        MonthlyEnvelopeData(
          envelope: groceries,
          allocatedCents: 0,
          spentCents: 0,
          availableCents: 0,
          carryoverCents: 0,
        ),
        MonthlyEnvelopeData(
          envelope: dining,
          allocatedCents: 0,
          spentCents: 0,
          availableCents: 0,
          carryoverCents: 0,
        ),
      ],
      totalBudgetedCents: 0,
      totalSpentCents: 0,
      totalAvailableCents: 0,
    );
  }

  Widget buildSubject() => ProviderScope(
      child: MaterialApp(
        theme: OpenBudgetTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: CategoryGroup(
            categoryWithEnvelopes: makeCategoryWithEnvelopes(),
            currencyCode: CurrencyCode.usd,
            onAddEnvelope: () {},
            onDeleteCategory: () {},
            onEditCategory: () {},
            onEditEnvelope: (_) {},
            onDeleteEnvelope: (_) {},
            onReorderEnvelopes: (_) {},
          ),
        ),
      ),
    );

  group('CategoryGroup', () {
    testWidgets('enters reorder mode from category long-press menu', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Done'), findsNothing);

      await tester.longPress(find.text('Needs'));
      await tester.pumpAndSettle();

      await tester.tap(
        find.text('Long press an envelope to reorder within category').first,
      );
      await tester.pumpAndSettle();

      expect(find.text('Done'), findsOneWidget);
    });

    testWidgets('enters reorder mode from envelope long-press menu', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Done'), findsNothing);

      await tester.longPress(find.text('Groceries'));
      await tester.pumpAndSettle();

      await tester.tap(
        find.text('Long press an envelope to reorder within category').first,
      );
      await tester.pumpAndSettle();

      expect(find.text('Done'), findsOneWidget);
    });
  });
}

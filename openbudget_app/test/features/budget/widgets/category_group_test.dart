import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_month_provider.dart';
import 'package:openbudget_app/src/features/budget/widgets/category_group.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

import '../../../fixtures/budget_month.dart';

const _envelopeOneId = '00000000-0000-0000-0000-000000000103';
const _envelopeTwoId = '00000000-0000-0000-0000-000000000104';

CategoryMonthGroup _makeGroup() => CategoryMonthGroup(
  category: testCategory(name: 'Needs'),
  envelopes: [
    testEnvelopeRow(envelopeId: _envelopeOneId),
    testEnvelopeRow(envelopeId: _envelopeTwoId, envelopeName: 'Dining Out'),
  ],
);

Widget _buildSubject() => ProviderScope(
  child: MaterialApp(
    theme: OpenBudgetTheme.light,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: CategoryGroup(
        group: _makeGroup(),
        currencyCode: 'USD',
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

void main() {
  group('CategoryGroup', () {
    testWidgets('enters reorder mode from category long-press menu', (
      tester,
    ) async {
      await tester.pumpWidget(_buildSubject());
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
      await tester.pumpWidget(_buildSubject());
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

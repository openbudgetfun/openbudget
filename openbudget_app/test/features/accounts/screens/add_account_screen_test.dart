// Serverpod's UuidValue.fromString is marked experimental.
// ignore_for_file: experimental_member_use

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/accounts/screens/add_account_screen.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  const budgetId = 'test-budget-1';

  Budget makeBudget({String currencyCode = 'USD'}) => Budget(
    id: UuidValue.fromString('00000000-0000-0000-0000-000000000001'),
    name: 'My Budget',
    currencyCode: currencyCode,
    ownerId: UuidValue.fromString('00000000-0000-0000-0000-000000000099'),
    createdAt: DateTime(2026),
  );

  Widget buildSubject({String currencyCode = 'USD'}) {
    return ProviderScope(
      overrides: [
        budgetDetailProvider.overrideWith(
          (ref, id) async => makeBudget(currencyCode: currencyCode),
        ),
      ],
      child: MaterialApp(
        theme: OpenBudgetTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const AddAccountScreen(budgetId: budgetId),
      ),
    );
  }

  testWidgets('renders currency selector', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('Currency'), findsOneWidget);
    expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
  });

  testWidgets('uses budget currency as initial account currency', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject(currencyCode: 'EUR'));
    await tester.pumpAndSettle();

    expect(find.text('EUR (€)'), findsOneWidget);
  });

  testWidgets('currency dropdown includes supported currencies', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await tester.tap(find.text(r'USD ($)'));
    await tester.pumpAndSettle();

    expect(find.text('EUR (€)'), findsOneWidget);
    expect(find.text('GBP (£)'), findsOneWidget);
    expect(find.text('JPY (¥)'), findsOneWidget);
    expect(find.text('BTC (₿)'), findsOneWidget);
  });
}

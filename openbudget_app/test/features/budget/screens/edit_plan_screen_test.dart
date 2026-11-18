import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_month_provider.dart';
import 'package:openbudget_app/src/features/budget/screens/edit_plan_screen.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

import '../../../fixtures/budget_month.dart';

const _entityId = '00000000-0000-0000-0000-000000000B01';
const _categoryId = '00000000-0000-0000-0000-000000000B02';
const _envelopeId = '00000000-0000-0000-0000-000000000B03';

BudgetMonthView _makeMonthView() => testMonthView(
  entityId: _entityId,
  summary: testMonthSummary(
    month: 202602,
    incomeMinor: 800000,
    allocatedMinor: 0,
    readyToAssignMinor: 800000,
    availableMinor: 800000,
  ),
  categories: [testCategory(id: _categoryId, name: 'Needs')],
  envelopes: [
    testEnvelopeRow(
      envelopeId: _envelopeId,
      categoryId: _categoryId,
    ),
  ],
);

void main() {
  testWidgets('renders edit plan layout and category target entry points', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/budgets/$_entityId/plan/edit',
      routes: [
        GoRoute(
          name: planRoute,
          path: '/budgets/:entityId/plan',
          builder: (_, _) =>
              const Scaffold(body: Center(child: Text('Plan route'))),
        ),
        GoRoute(
          name: editPlanRoute,
          path: '/budgets/:entityId/plan/edit',
          builder: (context, state) =>
              EditPlanScreen(entityId: state.pathParameters['entityId']!),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          budgetMonthProvider(_entityId).overrideWith(
            (ref) async => _makeMonthView(),
          ),
        ],
        child: MaterialApp.router(
          theme: OpenBudgetTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Edit Plan'), findsOneWidget);
    expect(find.text('Cost to Be Me'), findsOneWidget);
    expect(find.text('Monthly Targets'), findsOneWidget);
    expect(find.text('Monthly Income'), findsOneWidget);
    expect(find.text('New Group'), findsOneWidget);
    expect(find.text('Reorder'), findsOneWidget);
    expect(find.text('Needs'), findsOneWidget);
    expect(find.text('Add Target'), findsOneWidget);
  });
}

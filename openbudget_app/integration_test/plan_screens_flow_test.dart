import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/age_of_money_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_goals_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_month_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/category_actions_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/credit_card_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/envelope_activity_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/recent_moves_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/review_queue_provider.dart';
import 'package:openbudget_app/src/features/budget/screens/budget_detail_screen.dart';
import 'package:openbudget_app/src/features/budget/screens/category_detail_screen.dart';
import 'package:openbudget_app/src/features/budget/screens/recent_moves_screen.dart';
import 'package:openbudget_app/src/features/budget/widgets/budget_amount_keypad.dart';
import 'package:openbudget_app/src/features/home/providers/entity_detail_provider.dart';
import 'package:openbudget_app/src/features/recurring/providers/recurring_actions_provider.dart';
import 'package:openbudget_app/src/features/transactions/providers/transaction_actions_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';
import 'package:patrol/patrol.dart';

import 'common/patrol_helpers.dart';
import 'common/test_data.dart';
import 'helpers/screenshot_capture.dart';

const String _entityId = TestData.gbpEntityId;
const String _categoryId = '00000000-0000-0000-0000-000000000902';
const String _categoryTwoId = '00000000-0000-0000-0000-000000000908';
const String _utilitiesEnvelopeId = '00000000-0000-0000-0000-000000000903';
const String _storageEnvelopeId = '00000000-0000-0000-0000-000000000905';
const String _groceriesEnvelopeId = '00000000-0000-0000-0000-000000000909';
const String _accountId = '00000000-0000-0000-0000-000000000906';

const int _utilitiesAllocatedMinor = 6000;

final UuidValue _entityUuid = UuidValue.fromString(_entityId);
final UuidValue _categoryUuid = UuidValue.fromString(_categoryId);
final UuidValue _utilitiesEnvelopeUuid = UuidValue.fromString(
  _utilitiesEnvelopeId,
);
final UuidValue _storageEnvelopeUuid = UuidValue.fromString(
  _storageEnvelopeId,
);

Category _billsCategory(String name) => Category(
  id: _categoryUuid,
  name: name,
  entityId: _entityUuid,
  sortOrder: 0,
);

Envelope _utilitiesEnvelope({int sortOrder = 0}) => Envelope(
  id: _utilitiesEnvelopeUuid,
  name: 'Utilities',
  entityId: _entityUuid,
  categoryId: _categoryUuid,
  sortOrder: sortOrder,
  note: 'Auto-pay every month',
);

Envelope _storageEnvelope() => Envelope(
  id: _storageEnvelopeUuid,
  name: 'Self storage',
  entityId: _entityUuid,
  categoryId: _categoryUuid,
  sortOrder: 1,
);

EnvelopeMonthView _view(
  Envelope envelope, {
  int allocatedMinor = 0,
  int activityMinor = 0,
  int availableMinor = 0,
}) => EnvelopeMonthView(
  envelope: envelope,
  carryoverMinor: 0,
  allocatedMinor: allocatedMinor,
  activityMinor: activityMinor,
  availableMinor: availableMinor,
  goalUnderfundedMinor: 0,
);

BudgetMonthSummary _summary({
  required int incomeMinor,
  required int allocatedMinor,
  required int activityMinor,
  required int readyToAssignMinor,
  required int availableMinor,
}) => BudgetMonthSummary(
  month: 202602,
  incomeMinor: incomeMinor,
  uncategorizedMinor: 0,
  fxDifferenceMinor: 0,
  allocatedMinor: allocatedMinor,
  activityMinor: activityMinor,
  overspentLastMonthMinor: 0,
  assignedInFutureMinor: 0,
  readyToAssignMinor: readyToAssignMinor,
  availableMinor: availableMinor,
);

BudgetMonthView _makeMonthView() {
  final utilities = _utilitiesEnvelope();
  final storage = _storageEnvelope();
  return BudgetMonthView(
    entityId: _entityUuid,
    month: 202602,
    currencyCode: 'USD',
    summary: _summary(
      incomeMinor: 20000,
      allocatedMinor: _utilitiesAllocatedMinor,
      activityMinor: 0,
      readyToAssignMinor: 14000,
      availableMinor: _utilitiesAllocatedMinor,
    ),
    categories: [_billsCategory('Bills')],
    envelopes: [
      _view(
        utilities,
        allocatedMinor: _utilitiesAllocatedMinor,
        availableMinor: _utilitiesAllocatedMinor,
      ),
      _view(storage),
    ],
  );
}

BudgetMonthView _makeOverspentMonthView() {
  final utilities = _utilitiesEnvelope();
  final storage = _storageEnvelope();
  return BudgetMonthView(
    entityId: _entityUuid,
    month: 202602,
    currencyCode: 'USD',
    summary: _summary(
      incomeMinor: 20000,
      allocatedMinor: 0,
      activityMinor: _utilitiesAllocatedMinor,
      readyToAssignMinor: 20000,
      availableMinor: -_utilitiesAllocatedMinor,
    ),
    categories: [_billsCategory('Bills')],
    envelopes: [
      _view(
        utilities,
        activityMinor: _utilitiesAllocatedMinor,
        availableMinor: -_utilitiesAllocatedMinor,
      ),
      _view(storage),
    ],
  );
}

/// Two top-level groups, for the reorder flow.
BudgetMonthView _makeReorderMonthView() {
  final bills = _billsCategory('Housing');
  final utilities = _utilitiesEnvelope();
  final groceriesCategory = Category(
    id: UuidValue.fromString(_categoryTwoId),
    name: 'Groceries Group',
    entityId: _entityUuid,
    sortOrder: 1,
  );
  final food = Envelope(
    id: UuidValue.fromString(_groceriesEnvelopeId),
    name: 'Food',
    entityId: _entityUuid,
    categoryId: groceriesCategory.id!,
    sortOrder: 0,
  );

  return BudgetMonthView(
    entityId: _entityUuid,
    month: 202602,
    currencyCode: 'USD',
    summary: _summary(
      incomeMinor: 20000,
      allocatedMinor: 9000,
      activityMinor: 0,
      readyToAssignMinor: 11000,
      availableMinor: 9000,
    ),
    categories: [bills, groceriesCategory],
    envelopes: [
      _view(
        utilities,
        allocatedMinor: _utilitiesAllocatedMinor,
        availableMinor: _utilitiesAllocatedMinor,
      ),
      _view(food, allocatedMinor: 3000, availableMinor: 3000),
    ],
  );
}

List<CategoryMonthGroup> _groupsOf(BudgetMonthView view) {
  final byCategory = <UuidValue, CategoryMonthGroup>{};
  for (final envelope in view.envelopes) {
    final category = view.categories.firstWhere(
      (category) => category.id == envelope.envelope.categoryId,
    );
    final group = byCategory.putIfAbsent(
      category.id!,
      () => CategoryMonthGroup(category: category, envelopes: []),
    );
    group.envelopes.add(envelope);
  }
  return byCategory.values.toList();
}

TransactionView _makeMonthlyTransaction() {
  const transactionId = '00000000-0000-0000-0000-000000000907';
  return TransactionView(
    transaction: Transaction(
      id: UuidValue.fromString(transactionId),
      entityId: _entityUuid,
      accountId: UuidValue.fromString(_accountId),
      date: DateTime(2026, 2, 22),
      amountMinor: -10000,
      baseAmountMinor: -10000,
      fxRateDate: DateTime(2026, 2, 22),
      description: 'Landlord',
    ),
    lines: [
      TransactionLine(
        id: UuidValue.fromString('00000000-0000-0000-0000-000000000910'),
        transactionId: UuidValue.fromString(transactionId),
        amountMinor: -10000,
        baseAmountMinor: -10000,
      ),
    ],
    accountCurrencyCode: 'USD',
    accountName: 'Daily USD',
  );
}

class _FakeCategoryActions extends CategoryActions {
  List<String> reorderedCategoryIds = [];
  String? reorderedEntityId;

  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  @override
  Future<void> reorderCategories({
    required String entityId,
    required List<String> categoryIds,
  }) async {
    reorderedCategoryIds = List.of(categoryIds);
    reorderedEntityId = entityId;
  }
}

class _FakeTransactionActions extends TransactionActions {
  List<String> clearedTransactionIds = [];
  String? clearedEntityId;

  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  @override
  Future<int> setStatus({
    required List<String> transactionIds,
    required TransactionStatus status,
    required String entityId,
  }) async {
    clearedTransactionIds = List.of(transactionIds);
    clearedEntityId = entityId;
    return transactionIds.length;
  }
}

ProviderContainer _planContainer({
  required BudgetMonthView monthView,
  List<TransactionView> reviewQueue = const [],
  CategoryActions? categoryActions,
  TransactionActions? transactionActions,
}) {
  final groups = _groupsOf(monthView);
  final container = ProviderContainer(
    overrides: [
      entityDetailProvider.overrideWith(
        (ref, id) async => TestData.usdEntity(),
      ),
      if (categoryActions != null)
        categoryActionsProvider.overrideWith(() => categoryActions),
      if (transactionActions != null)
        transactionActionsProvider.overrideWith(() => transactionActions),
      budgetMonthProvider.overrideWith((ref, entityId) async {
        ref.watch(selectedYyyymmProvider(entityId));
        return monthView;
      }),
      budgetMonthGroupsProvider.overrideWith((ref, entityId) async {
        ref.watch(selectedYyyymmProvider(entityId));
        return groups;
      }),
      budgetGoalsProvider.overrideWith((ref, entityId) async => {}),
      creditCardPaymentsProvider.overrideWith(
        (ref, entityId) async => const [],
      ),
      recurringDueCountProvider.overrideWith((ref, entityId) async => 0),
      reviewQueueProvider.overrideWith((ref, entityId) async => reviewQueue),
      // The envelope activity sheet and the header's age-of-money stat read
      // the server otherwise, which would leave a pending connection at
      // teardown.
      envelopeActivityProvider.overrideWith2(
        (_) => _FakeEnvelopeActivity(),
      ),
      ageOfMoneyProvider.overrideWith((ref, entityId) async => null),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

/// An empty envelope activity page, so the sheets never touch the network.
class _FakeEnvelopeActivity extends EnvelopeActivity {
  @override
  Future<EnvelopeActivityState> build(
    String entityId,
    String envelopeId,
  ) async => const EnvelopeActivityState(items: []);
}

Widget _buildApp(
  ProviderContainer container, {
  List<GoRoute> extraRoutes = const [],
}) {
  final router = GoRouter(
    initialLocation: '/budgets/$_entityId/plan',
    routes: [
      GoRoute(
        name: homeRoute,
        path: homePath,
        builder: (_, _) => const Scaffold(body: Text('Home')),
      ),
      GoRoute(
        name: planRoute,
        path: '/budgets/:entityId/plan',
        builder: (context, state) =>
            BudgetDetailScreen(entityId: state.pathParameters['entityId']!),
        routes: extraRoutes,
      ),
    ],
  );

  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp.router(
      theme: ThemeData.light(useMaterial3: true),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  );
}

GoRoute _recentMovesRoutes() => GoRoute(
  name: recentMovesRoute,
  path: 'recent-moves',
  builder: (context, state) =>
      RecentMovesScreen(entityId: state.pathParameters['entityId']!),
  routes: [
    GoRoute(
      name: envelopeMovesRoute,
      path: ':envelopeId',
      builder: (context, state) => EnvelopeMovesScreen(
        entityId: state.pathParameters['entityId']!,
        envelopeId: state.pathParameters['envelopeId']!,
      ),
    ),
  ],
);

GoRoute _categoryDetailRoute() => GoRoute(
  name: categoryDetailRoute,
  path: 'category/:categoryId/envelope/:envelopeId',
  builder: (context, state) => CategoryDetailScreen(
    entityId: state.pathParameters['entityId']!,
    categoryId: state.pathParameters['categoryId']!,
    envelopeId: state.pathParameters['envelopeId']!,
  ),
);

void main() {
  patrolWidgetTest('opens recent moves and category detail from plan', (
    $,
  ) async {
    final tester = $.tester;
    final transactionActions = _FakeTransactionActions();
    final container = _planContainer(
      monthView: _makeMonthView(),
      reviewQueue: [_makeMonthlyTransaction()],
      transactionActions: transactionActions,
    );

    await tester.pumpWidget(
      _buildApp(
        container,
        extraRoutes: [
          _recentMovesRoutes(),
          _categoryDetailRoute(),
        ],
      ),
    );
    await tester.pumpAndSettle();
    final planPage = PlanTabPage(tester);
    expect(planPage.finishOnboardingButton, findsOneWidget);
    container
        .read(recentMovesProvider.notifier)
        .recordAssigned(
          entityId: _entityId,
          envelopeId: _utilitiesEnvelopeId,
          amountMinor: _utilitiesAllocatedMinor,
        );
    container
        .read(recentMovesProvider.notifier)
        .recordMove(
          entityId: _entityId,
          fromEnvelopeId: _storageEnvelopeId,
          toEnvelopeId: _utilitiesEnvelopeId,
          amountMinor: 3000,
        );
    await tester.pumpAndSettle();
    await captureIntegrationScreenshot(tester, 'plan-screen');
    await tester.pump(const Duration(seconds: 1));
    await planPage.finishOnboarding();
    expect(planPage.finishOnboardingButton, findsNothing);
    expect(planPage.reviewTransactionsBanner, findsOneWidget);
    await planPage.openReviewTransactions();
    await tester.pumpAndSettle();
    expect(find.text('1 New Transaction'), findsOneWidget);
    await captureIntegrationScreenshot(tester, 'review-transactions-screen');
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text('Landlord'));
    await tester.pumpAndSettle();
    expect(find.text('1 Selected'), findsOneWidget);
    await tester.tap(find.text('Approve'));
    await tester.pumpAndSettle();
    expect(transactionActions.clearedEntityId, _entityId);
    expect(transactionActions.clearedTransactionIds, [
      _makeMonthlyTransaction().transaction.id.toString(),
    ]);
    expect(find.text('No Transactions'), findsOneWidget);
    expect(find.text("You're All Done!"), findsOneWidget);
    await captureIntegrationScreenshot(
      tester,
      'review-transactions-empty-screen',
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    await captureIntegrationScreenshot(
      tester,
      'plan-screen-onboarding-dismissed',
    );
    await tester.pump(const Duration(seconds: 1));
    await planPage.showSpotlight();
    await captureIntegrationScreenshot(tester, 'spotlight-screen');
    await tester.pump(const Duration(seconds: 1));
    await planPage.showCategories();
    await tester.pumpAndSettle();
    expect(find.byType(ObEnvelopeGauge), findsWidgets);

    await tester.tap(find.byKey(const Key('budget-plan-menu')));
    await tester.pumpAndSettle();
    expect(find.text('Hide Amounts'), findsOneWidget);
    await captureIntegrationScreenshot(tester, 'plan-menu');
    await tester.pump(const Duration(seconds: 1));

    await _tapPopupMenuItem(tester, 'Undo');
    await tester.tap(find.byKey(const Key('budget-plan-menu')));
    await tester.pumpAndSettle();
    await _tapPopupMenuItem(tester, 'Recent Moves');
    expect(find.text('Hide Progress Bars', skipOffstage: false), findsNothing);
    await _dismissCoachmarkIfVisible(tester);
    expect(find.text('Ready to Assign'), findsOneWidget);
    expect(find.text('Self storage'), findsNothing);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    container
        .read(recentMovesProvider.notifier)
        .recordMove(
          entityId: _entityId,
          fromEnvelopeId: _storageEnvelopeId,
          toEnvelopeId: _utilitiesEnvelopeId,
          amountMinor: 3000,
        );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('budget-plan-menu')));
    await tester.pumpAndSettle();
    await _tapPopupMenuItem(tester, 'Hide Progress Bars');
    expect(find.byType(ObEnvelopeGauge), findsNothing);

    await tester.tap(find.byKey(const Key('budget-plan-menu')));
    await tester.pumpAndSettle();
    await _tapPopupMenuItem(tester, 'Hide Progress Bars');
    expect(find.byType(ObEnvelopeGauge), findsWidgets);

    await tester.tap(find.byKey(const Key('budget-plan-menu')));
    await tester.pumpAndSettle();
    await _tapPopupMenuItem(tester, 'Hide Amounts');
    expect(find.text('••••'), findsWidgets);

    await tester.tap(find.byKey(const Key('budget-plan-menu')));
    await tester.pumpAndSettle();
    await _tapPopupMenuItem(tester, 'Hide Amounts');
    expect(find.text('••••'), findsNothing);

    await tester.tap(find.byKey(const Key('budget-plan-menu')));
    await tester.pumpAndSettle();
    await _tapPopupMenuItem(tester, 'Collapse/Expand');
    expect(find.textContaining('Auto-pay every month'), findsNothing);

    await tester.tap(find.byKey(const Key('budget-plan-menu')));
    await tester.pumpAndSettle();
    await _tapPopupMenuItem(tester, 'Collapse/Expand');
    expect(find.textContaining('Auto-pay every month'), findsOneWidget);

    await tester.tap(find.byKey(const Key('budget-plan-menu')));
    await tester.pumpAndSettle();
    await _tapPopupMenuItem(tester, 'Recent Moves');
    await _dismissCoachmarkIfVisible(tester);
    await captureIntegrationScreenshot(tester, 'recent-moves-screen');
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Moved'));
    await tester.pumpAndSettle();
    await captureIntegrationScreenshot(tester, 'recent-moves-moved-screen');
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Self storage').first);
    await tester.pumpAndSettle();
    expect(find.text('Moves'), findsOneWidget);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Recent Moves'), findsOneWidget);

    await tester.tap(find.text('Utilities').first);
    await tester.pumpAndSettle();
    await captureIntegrationScreenshot(tester, 'envelope-moves-screen');
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Recent Moves'), findsOneWidget);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Utilities'));
    await tester.pumpAndSettle();
    await captureIntegrationScreenshot(tester, 'plan-inline-editor-screen');
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Details'));
    await tester.pumpAndSettle();
    await captureIntegrationScreenshot(tester, 'category-detail-screen');
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Balance'), findsOneWidget);
    expect(find.text('Set Goal'), findsOneWidget);
    await tester.tap(find.text('Set Goal'));
    await tester.pumpAndSettle();

    expect(find.text('Save Target'), findsOneWidget);
    var saveTargetButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Save Target'),
    );
    expect(saveTargetButton.onPressed, isNull);

    // The amount field opens the keypad sheet; enter 2800 and confirm.
    await tester.tap(find.widgetWithText(BudgetAmountField, 'Amount'));
    await tester.pumpAndSettle();
    for (final digit in ['2', '8', '0', '0']) {
      await tester.tap(find.byKey(Key('budget-keypad-digit-$digit')));
      await tester.pump();
    }
    await tester.tap(find.byKey(const Key('budget-keypad-done')));
    await tester.pumpAndSettle();

    saveTargetButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Save Target'),
    );
    expect(saveTargetButton.onPressed, isNotNull);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    final categoryDetailPage = CategoryDetailPage(tester);
    await categoryDetailPage.scrollToRenameCategory();
    expect(categoryDetailPage.renameCategoryButton, findsOneWidget);
  });

  patrolWidgetTest('opens overspending coverage sheet from plan banner', (
    $,
  ) async {
    final tester = $.tester;
    final container = _planContainer(monthView: _makeOverspentMonthView());

    await tester.pumpWidget(_buildApp(container));
    await tester.pumpAndSettle();

    expect(find.text('Cover 1 overspent category'), findsOneWidget);
    await tester.tap(find.text('Cover 1 overspent category'));
    await tester.pumpAndSettle();

    expect(find.text('Cover Overspending'), findsOneWidget);
    expect(find.textContaining(r'Needs $60.00'), findsOneWidget);
    expect(find.text('Cover'), findsOneWidget);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Cover 1 overspent category'), findsOneWidget);
  });

  patrolWidgetTest('desktop recent moves flow opens and switches tabs', (
    $,
  ) async {
    final tester = $.tester;
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(1024, 768));

    final container = _planContainer(
      monthView: _makeMonthView(),
      reviewQueue: [_makeMonthlyTransaction()],
    );

    await tester.pumpWidget(
      _buildApp(container, extraRoutes: [_recentMovesRoutes()]),
    );
    await tester.pumpAndSettle();

    container
        .read(recentMovesProvider.notifier)
        .recordAssigned(
          entityId: _entityId,
          envelopeId: _utilitiesEnvelopeId,
          amountMinor: _utilitiesAllocatedMinor,
        );
    container
        .read(recentMovesProvider.notifier)
        .recordMove(
          entityId: _entityId,
          fromEnvelopeId: _storageEnvelopeId,
          toEnvelopeId: _utilitiesEnvelopeId,
          amountMinor: 3000,
        );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('budget-plan-menu')));
    await tester.pumpAndSettle();
    await _tapPopupMenuItem(tester, 'Recent Moves');
    await _dismissCoachmarkIfVisible(tester);
    await tester.pumpAndSettle();

    expect(find.text('Recent Moves'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Moved'), findsOneWidget);
    await captureIntegrationScreenshot(tester, 'recent-moves-desktop-screen');

    await tester.tap(find.text('Moved'));
    await tester.pumpAndSettle();

    expect(find.text('Self storage'), findsOneWidget);
    await captureIntegrationScreenshot(
      tester,
      'recent-moves-desktop-moved-screen',
    );

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Categories'), findsOneWidget);
  });

  patrolWidgetTest('reorder mode moves categories and exits cleanly', (
    $,
  ) async {
    final tester = $.tester;
    final categoryActions = _FakeCategoryActions();
    final container = _planContainer(
      monthView: _makeReorderMonthView(),
      categoryActions: categoryActions,
    );

    await tester.pumpWidget(_buildApp(container));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('budget-plan-menu')));
    await tester.pumpAndSettle();
    await _tapPopupMenuItem(tester, 'Reorder Categories');
    expect(find.widgetWithText(TextButton, 'Done'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Groceries Group'),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    final housingBefore = tester.getTopLeft(find.text('Housing')).dy;
    final groceriesBefore = tester.getTopLeft(find.text('Groceries Group')).dy;
    expect(housingBefore, lessThan(groceriesBefore));

    await tester.tap(
      find
          .byWidgetPredicate(
            (widget) =>
                widget is SkribbleIcon &&
                widget.data == OpenBudgetIcons.chevronUp,
          )
          .last,
    );
    await tester.pumpAndSettle();

    final housingAfter = tester.getTopLeft(find.text('Housing')).dy;
    final groceriesAfter = tester.getTopLeft(find.text('Groceries Group')).dy;
    expect(groceriesAfter, lessThan(housingAfter));

    await tester.tap(find.widgetWithText(TextButton, 'Done'));
    await tester.pumpAndSettle();

    expect(categoryActions.reorderedEntityId, _entityId);
    expect(
      categoryActions.reorderedCategoryIds,
      _groupsOf(_makeReorderMonthView()).reversed
          .map((group) => group.category.id.toString())
          .toList(),
    );
    expect(find.byKey(const Key('budget-plan-menu')), findsOneWidget);
  });
}

Future<void> _tapPopupMenuItem(WidgetTester tester, String label) async {
  final textFinder = find.text(label, skipOffstage: false);
  if (textFinder.evaluate().isEmpty) {
    throw TestFailure('Expected popup menu item "$label" to be visible.');
  }

  final menuItemFinder = find.ancestor(
    of: textFinder.first,
    matching: find.byType(PopupMenuItem),
  );
  if (menuItemFinder.evaluate().isNotEmpty) {
    await tester.tap(menuItemFinder.first, warnIfMissed: false);
  } else {
    await tester.tap(textFinder.first, warnIfMissed: false);
  }
  await tester.pumpAndSettle();
}

Future<void> _dismissCoachmarkIfVisible(WidgetTester tester) async {
  final gotIt = find.text('Got It!');
  if (gotIt.evaluate().isEmpty) return;
  await tester.tap(gotIt.first);
  await tester.pumpAndSettle();
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_actions_provider.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_list_provider.dart';
import 'package:openbudget_app/src/features/accounts/providers/institution_catalog_provider.dart';
import 'package:openbudget_app/src/features/accounts/screens/add_account_screen.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class _RecordingCreateAccountActions extends AccountActions {
  int? createdBalanceCents;

  @override
  Future<void> build() async {}

  @override
  Future<Account> createAccount({
    required String name,
    required String accountType,
    required int balanceCents,
    required String currencyCode,
    required String budgetId,
    required bool onBudget,
    required int sortOrder,
    String? walletAddress,
    String? institutionId,
  }) async {
    createdBalanceCents = balanceCents;
    return Account(
      id: UuidValue.fromString('00000000-0000-0000-0000-000000000777'),
      name: name,
      accountType: accountType,
      balanceCents: balanceCents,
      currencyCode: currencyCode,
      budgetId: UuidValue.fromString(budgetId),
      onBudget: onBudget,
      sortOrder: sortOrder,
      isClosed: false,
    );
  }
}

class _ThrowingCreateAccountActions extends AccountActions {
  @override
  Future<void> build() async {}

  @override
  Future<Account> createAccount({
    required String name,
    required String accountType,
    required int balanceCents,
    required String currencyCode,
    required String budgetId,
    required bool onBudget,
    required int sortOrder,
    String? walletAddress,
    String? institutionId,
  }) async {
    throw StateError('createAccount decode error');
  }
}

void main() {
  const budgetId = 'test-budget-1';
  const unlinkedTypeTileKey = Key('add-account-unlinked-type-tile');
  const checkingTypeOptionKey = ValueKey('add-account-type-option-checking');
  final testInstitutions = <Institution>[
    Institution(slug: 'citi', name: 'Citi', plaidInstitutionId: 'ins_citi'),
    Institution(slug: 'chase', name: 'Chase', plaidInstitutionId: 'ins_chase'),
    Institution(slug: 'wise', name: 'Wise', plaidInstitutionId: 'ins_wise'),
  ];

  Budget makeBudget({String currencyCode = 'USD'}) => Budget(
    id: UuidValue.fromString('00000000-0000-0000-0000-000000000001'),
    name: 'My Budget',
    currencyCode: currencyCode,
    ownerId: UuidValue.fromString('00000000-0000-0000-0000-000000000099'),
    createdAt: DateTime(2026),
  );

  Widget buildSubject({String currencyCode = 'USD'}) {
    final router = GoRouter(
      initialLocation: '/budgets/$budgetId/accounts/add',
      routes: [
        GoRoute(
          name: addAccountRoute,
          path: '/budgets/:id/accounts/add',
          builder: (context, state) =>
              AddAccountScreen(budgetId: state.pathParameters['id']!),
        ),
        GoRoute(
          name: accountListRoute,
          path: '/budgets/:id/accounts',
          builder: (_, _) => const Scaffold(body: Text('Account List')),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        budgetDetailProvider.overrideWith(
          (ref, id) async => makeBudget(currencyCode: currencyCode),
        ),
        institutionCatalogProvider.overrideWith(
          (ref, locationCode) async => testInstitutions,
        ),
      ],
      child: MaterialApp.router(
        theme: OpenBudgetTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
  }

  testWidgets('renders bank search entry step', (tester) async {
    await tester.pumpWidget(buildSubject());
    await _pumpToBankSearch(tester);

    expect(find.text('Add Accounts'), findsOneWidget);
    expect(find.text('Search for your bank'), findsOneWidget);
    expect(find.text('Search by institution name'), findsOneWidget);
    expect(
      find.text('Search by institution name or web address (URL)'),
      findsOneWidget,
    );
    expect(find.text('Popular Options'), findsOneWidget);

    await _scrollToAddUnlinked(tester);
    expect(find.text('Add an Unlinked Account'), findsOneWidget);
  });

  testWidgets('shows staged loading states before bank search', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(find.text('Loading...'), findsOneWidget);
    expect(find.text('Search for your bank'), findsNothing);

    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();

    expect(find.text('Add Accounts'), findsOneWidget);
    expect(find.text('Loading institutions...'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pumpAndSettle();

    expect(find.text('Search for your bank'), findsOneWidget);
  });

  testWidgets('does not render currency selector in unlinked account step', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject(currencyCode: 'EUR'));
    await _pumpToBankSearch(tester);

    await _tapAddUnlinked(tester);
    await tester.pumpAndSettle();

    expect(find.text('Add Unlinked Account'), findsOneWidget);
    expect(find.text('Currency'), findsNothing);
    expect(find.text('EUR (€)'), findsNothing);
    expect(find.byType(DropdownButtonFormField<String>), findsNothing);
  });

  testWidgets('filters institutions by search query', (tester) async {
    await tester.pumpWidget(buildSubject());
    await _pumpToBankSearch(tester);

    final searchField = find.byType(TextField).first;
    await tester.enterText(searchField, 'citi');
    await tester.pumpAndSettle();

    expect(find.text('Search Results'), findsOneWidget);
    expect(find.text('Citi'), findsOneWidget);
    expect(find.text('Chase'), findsNothing);

    await tester.enterText(searchField, 'zzz');
    await tester.pumpAndSettle();

    expect(find.textContaining('No institutions found'), findsOneWidget);

    await tester.enterText(searchField, '');
    await tester.pumpAndSettle();

    expect(find.text('Popular Options'), findsOneWidget);
    expect(find.text('Chase'), findsOneWidget);
  });

  testWidgets('search submit keeps user on the bank search step', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());
    await _pumpToBankSearch(tester);

    await tester.enterText(find.byType(TextField).first, 'citi');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(find.text('Search for your bank'), findsOneWidget);
    expect(find.text('Search Results'), findsOneWidget);
    expect(find.text('Add Unlinked Account'), findsNothing);
    expect(find.textContaining('Linked connections for "citi"'), findsNothing);
  });

  testWidgets('bank selection shows unavailable notice and falls back', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());
    await _pumpToBankSearch(tester);

    await tester.enterText(find.byType(TextField).first, 'citi');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Citi'));
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();

    expect(find.text('Add Unlinked Account'), findsOneWidget);
    expect(
      find.textContaining(
        'Linked connections for "Citi" are currently unavailable',
      ),
      findsOneWidget,
    );
  });

  testWidgets('account type picker can be opened from unlinked form', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());
    await _pumpToBankSearch(tester);

    await _tapAddUnlinked(tester);
    await tester.pumpAndSettle();

    await _openAccountTypePicker(
      tester,
      typeTileFinder: find.byKey(unlinkedTypeTileKey),
    );

    expect(find.byKey(checkingTypeOptionKey), findsOneWidget);
    expect(find.text('Cash Accounts'), findsOneWidget);
    expect(
      find.text(
        'Cash accounts hold funds you already own and can spend immediately.',
      ),
      findsOneWidget,
    );
    expect(find.text('Credit Accounts'), findsOneWidget);
    expect(
      find.text(
        "A credit account lets you spend borrowed money that you'll need to repay later, often with interest.",
      ),
      findsOneWidget,
    );
    expect(find.text('Mortgages and Loans'), findsOneWidget);
    expect(
      find.text(
        "Accounts that have an outstanding balance you're currently paying off, and aren't spending from.",
      ),
      findsOneWidget,
    );
    expect(_skribbleIcon(OpenBudgetIcons.bank), findsOneWidget);
    expect(_skribbleIcon(OpenBudgetIcons.savings), findsOneWidget);
  });

  testWidgets('next stays disabled until type and balance are provided', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());
    await _pumpToBankSearch(tester);

    await _tapAddUnlinked(tester);
    await tester.pumpAndSettle();

    var nextButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Next'),
    );
    expect(nextButton.onPressed, isNull);

    await tester.enterText(find.byType(TextField).at(0), 'Daily');
    await tester.enterText(find.byType(TextField).at(1), '50000');
    await tester.pumpAndSettle();

    nextButton = tester.widget(find.widgetWithText(FilledButton, 'Next'));
    expect(nextButton.onPressed, isNull);

    await _openAccountTypePicker(
      tester,
      typeTileFinder: find.byKey(unlinkedTypeTileKey),
    );
    await _tapAccountTypeOption(
      tester,
      optionFinder: find.byKey(checkingTypeOptionKey),
    );

    nextButton = tester.widget(find.widgetWithText(FilledButton, 'Next'));
    expect(nextButton.onPressed, isNotNull);
  });

  testWidgets('create account fallback succeeds when row exists after error', (
    tester,
  ) async {
    var accountListReads = 0;
    final before = Account(
      id: UuidValue.fromString('00000000-0000-0000-0000-000000000201'),
      name: 'Existing',
      accountType: 'checking',
      balanceCents: 1000,
      currencyCode: 'USD',
      budgetId: UuidValue.fromString('00000000-0000-0000-0000-000000000001'),
      onBudget: true,
      sortOrder: 0,
      isClosed: false,
    );
    final after = Account(
      id: UuidValue.fromString('00000000-0000-0000-0000-000000000202'),
      name: 'New',
      accountType: 'checking',
      balanceCents: 5000,
      currencyCode: 'USD',
      budgetId: UuidValue.fromString('00000000-0000-0000-0000-000000000001'),
      onBudget: true,
      sortOrder: 1,
      isClosed: false,
    );

    final router = GoRouter(
      initialLocation: '/budgets/$budgetId/accounts/add',
      routes: [
        GoRoute(
          name: addAccountRoute,
          path: '/budgets/:id/accounts/add',
          builder: (context, state) =>
              AddAccountScreen(budgetId: state.pathParameters['id']!),
        ),
        GoRoute(
          name: accountListRoute,
          path: '/budgets/:id/accounts',
          builder: (_, _) => const Scaffold(body: Text('Account List')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          budgetDetailProvider.overrideWith((ref, id) async => makeBudget()),
          institutionCatalogProvider.overrideWith(
            (ref, locationCode) async => testInstitutions,
          ),
          accountActionsProvider.overrideWith(
            _ThrowingCreateAccountActions.new,
          ),
          accountListProvider(budgetId).overrideWith((ref) async {
            accountListReads++;
            return accountListReads == 1 ? [before] : [before, after];
          }),
        ],
        child: MaterialApp.router(
          theme: OpenBudgetTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );

    await _pumpToBankSearch(tester);
    await _tapAddUnlinked(tester);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'Daily');
    await tester.enterText(find.byType(TextField).at(1), '50');
    await _openAccountTypePicker(
      tester,
      typeTileFinder: find.byKey(unlinkedTypeTileKey),
    );
    await _tapAccountTypeOption(
      tester,
      optionFinder: find.byKey(checkingTypeOptionKey),
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await tester.pumpAndSettle();

    expect(find.text('Account Added'), findsOneWidget);
    expect(find.text('Success!'), findsOneWidget);
    expect(
      find.text('Could not create account. Please try again.'),
      findsNothing,
    );
    expect(accountListReads, greaterThanOrEqualTo(2));
  });

  group('unlinked account balance entry', () {
    Widget buildSubjectWith(AccountActions actions) {
      final router = GoRouter(
        initialLocation: '/budgets/$budgetId/accounts/add',
        routes: [
          GoRoute(
            name: addAccountRoute,
            path: '/budgets/:id/accounts/add',
            builder: (context, state) =>
                AddAccountScreen(budgetId: state.pathParameters['id']!),
          ),
          GoRoute(
            name: accountListRoute,
            path: '/budgets/:id/accounts',
            builder: (_, _) => const Scaffold(body: Text('Account List')),
          ),
        ],
      );

      return ProviderScope(
        overrides: [
          budgetDetailProvider.overrideWith((ref, id) async => makeBudget()),
          institutionCatalogProvider.overrideWith(
            (ref, locationCode) async => testInstitutions,
          ),
          accountActionsProvider.overrideWith(() => actions),
          accountListProvider(budgetId).overrideWith((ref) async => const []),
        ],
        child: MaterialApp.router(
          theme: OpenBudgetTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      );
    }

    Future<void> fillForm(WidgetTester tester, String balance) async {
      await _pumpToBankSearch(tester);
      await _tapAddUnlinked(tester);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(0), 'Daily');
      await tester.enterText(find.byType(TextField).at(1), balance);
      await tester.pumpAndSettle();

      await _openAccountTypePicker(
        tester,
        typeTileFinder: find.byKey(unlinkedTypeTileKey),
      );
      await _tapAccountTypeOption(
        tester,
        optionFinder: find.byKey(checkingTypeOptionKey),
      );
    }

    testWidgets('saves 12.34 as 1234 minor units', (tester) async {
      final actions = _RecordingCreateAccountActions();
      await tester.pumpWidget(buildSubjectWith(actions));
      await fillForm(tester, '12.34');

      await tester.tap(find.widgetWithText(FilledButton, 'Next'));
      await tester.pumpAndSettle();

      expect(actions.createdBalanceCents, 1234);
    });

    testWidgets('refuses an over-precise balance instead of rounding it', (
      tester,
    ) async {
      final actions = _RecordingCreateAccountActions();
      await tester.pumpWidget(buildSubjectWith(actions));
      await fillForm(tester, '12.345');

      expect(
        find.text('Enter a valid amount with at most 2 decimal places'),
        findsOneWidget,
      );

      final nextButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Next'),
      );
      expect(nextButton.onPressed, isNull);
      expect(actions.createdBalanceCents, isNull);
    });

    testWidgets('accepts a negative balance', (tester) async {
      final actions = _RecordingCreateAccountActions();
      await tester.pumpWidget(buildSubjectWith(actions));
      await fillForm(tester, '-12.34');

      expect(
        find.text('Enter a valid amount with at most 2 decimal places'),
        findsNothing,
      );

      await tester.tap(find.widgetWithText(FilledButton, 'Next'));
      await tester.pumpAndSettle();

      expect(actions.createdBalanceCents, -1234);
    });
  });
}

Future<void> _pumpToBankSearch(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 1500));
  await tester.pumpAndSettle();
}

Future<void> _tapAddUnlinked(WidgetTester tester) async {
  await _scrollToAddUnlinked(tester);
  await tester.tap(find.text('Add an Unlinked Account'));
}

Future<void> _scrollToAddUnlinked(WidgetTester tester) async {
  final finder = find.text('Add an Unlinked Account');
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      finder,
      200,
      scrollable: find.byType(Scrollable).first,
    );
  }
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
}

Future<void> _openAccountTypePicker(
  WidgetTester tester, {
  required Finder typeTileFinder,
}) async {
  final tile = tester.widget<ListTile>(typeTileFinder);
  final onTap = tile.onTap;
  if (onTap == null) {
    fail('Expected account type tile to be tappable.');
  }
  onTap();
  await tester.pumpAndSettle();
}

Future<void> _tapAccountTypeOption(
  WidgetTester tester, {
  required Finder optionFinder,
}) async {
  final tile = tester.widget<ListTile>(optionFinder);
  final onTap = tile.onTap;
  if (onTap == null) {
    fail('Expected account type option to be tappable.');
  }
  onTap();
  await tester.pumpAndSettle();
}

Finder _skribbleIcon(WiredSvgIconData data) => find.byWidgetPredicate(
  (widget) => widget is SkribbleIcon && widget.data == data,
);

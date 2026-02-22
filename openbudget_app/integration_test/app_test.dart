import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:integration_test/integration_test.dart';
import 'package:openbudget_app/main.dart';
import 'package:openbudget_app/src/features/auth/providers/auth_provider.dart';
import 'package:openbudget_app/src/features/auth/providers/auth_state.dart';
import 'package:openbudget_app/src/features/home/providers/budget_list_provider.dart';

Future<void> _pumpApp(
  WidgetTester tester, {
  required AuthState authState,
}) async {
  final container = ProviderContainer(
    overrides: [
      authProvider.overrideWithValue(authState),
      budgetListProvider.overrideWith((ref) async => const []),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const OpenBudgetApp(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('unauthenticated app launch shows login screen', (tester) async {
    await _pumpApp(tester, authState: const Unauthenticated());
    expect(find.byKey(const Key('login-openbudget-mark')), findsOneWidget);
    expect(find.text('Log In'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
  });

  testWidgets('authenticated app launch shows home empty state', (
    tester,
  ) async {
    await _pumpApp(tester, authState: const Authenticated(userId: 'user-1'));
    expect(find.text('No Budgets Yet'), findsOneWidget);
  });
}

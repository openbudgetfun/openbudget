import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/auth/providers/auth_provider.dart';
import 'package:openbudget_app/src/features/auth/providers/auth_state.dart';
import 'package:openbudget_app/src/features/settings/screens/delete_account_screen.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

import '../../../support/fake_endpoint_client.dart';
import '../providers/account_deletion_provider_test.dart' show FakeAuthNotifier;

void main() {
  Future<ProviderContainer> pumpScreen(
    WidgetTester tester,
    FakeEndpointClient client,
  ) async {
    final container = ProviderContainer(
      overrides: [
        serverpodClientProvider.overrideWithValue(client),
        authProvider.overrideWith(FakeAuthNotifier.new),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: OpenBudgetTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const DeleteAccountScreen(entityId: 'test-budget-id'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  Future<void> tapDelete(WidgetTester tester) async {
    await tester.ensureVisible(find.byKey(DeleteAccountScreen.deleteButtonKey));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(DeleteAccountScreen.deleteButtonKey));
    await tester.pumpAndSettle();
  }

  group('DeleteAccountScreen', () {
    testWidgets('explains what is deleted and offers the action', (
      tester,
    ) async {
      await pumpScreen(tester, FakeEndpointClient());

      expect(
        find.textContaining('Deleting your account is permanent'),
        findsOneWidget,
      );
      expect(find.text('What gets deleted'), findsOneWidget);
      expect(find.textContaining('cancel it first'), findsOneWidget);
      expect(find.text('Delete My Account'), findsOneWidget);
    });

    testWidgets('cancelling the confirmation deletes nothing', (tester) async {
      final client = FakeEndpointClient();
      final container = await pumpScreen(tester, client);

      await tapDelete(tester);
      expect(find.text('Delete your account?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(client.calls, isEmpty);
      expect(container.read(authProvider), isA<Authenticated>());
    });

    testWidgets('confirming deletes the account and signs out', (
      tester,
    ) async {
      final client = FakeEndpointClient()
        ..handle('settings', 'deleteAccount', (_) => null);
      final container = await pumpScreen(tester, client);

      await tapDelete(tester);
      await tester.tap(find.byKey(DeleteAccountScreen.confirmButtonKey));
      await tester.pumpAndSettle();

      expect(client.callsTo('settings', 'deleteAccount'), hasLength(1));
      expect(container.read(authProvider), isA<Unauthenticated>());
    });

    testWidgets('a renewing subscription shows how to proceed', (
      tester,
    ) async {
      final client = FakeEndpointClient()
        ..handle(
          'settings',
          'deleteAccount',
          (_) => throw ValidationException(message: 'Cancel first'),
        );
      final container = await pumpScreen(tester, client);

      await tapDelete(tester);
      await tester.tap(find.byKey(DeleteAccountScreen.confirmButtonKey));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Cancel your OpenBudget Plus subscription before deleting your '
          'account.',
        ),
        findsOneWidget,
      );
      expect(container.read(authProvider), isA<Authenticated>());
    });

    testWidgets('any other failure asks to try again', (tester) async {
      final client = FakeEndpointClient()
        ..handle(
          'settings',
          'deleteAccount',
          (_) => throw Exception('offline'),
        );
      await pumpScreen(tester, client);

      await tapDelete(tester);
      await tester.tap(find.byKey(DeleteAccountScreen.confirmButtonKey));
      await tester.pumpAndSettle();

      expect(
        find.text('Could not delete your account. Please try again.'),
        findsOneWidget,
      );
    });
  });
}

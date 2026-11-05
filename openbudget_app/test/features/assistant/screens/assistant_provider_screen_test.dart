import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/assistant/models/assistant_failure.dart';
import 'package:openbudget_app/src/features/assistant/providers/assistant_api_provider.dart';
import 'package:openbudget_app/src/features/assistant/screens/assistant_provider_screen.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_test_utils/openbudget_test_utils.dart';

import '../support/fake_assistant_api.dart';

Future<ProviderContainer> _pumpProvider(
  WidgetTester tester,
  FakeAssistantApi api,
) async {
  final container = ProviderContainer(
    overrides: [assistantApiProvider.overrideWith((ref) => api)],
  );
  addTearDown(container.dispose);

  await tester.pumpApp(
    const AssistantProviderScreen(),
    container: container,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
  );
  await tester.pumpAndSettle();
  return container;
}

Future<void> _fillForm(
  WidgetTester tester, {
  String baseUrl = 'https://api.example.com/v1',
  String model = 'model-a',
  String apiKey = 'sk-test-abcd',
}) async {
  await tester.enterText(
    find.byKey(AssistantProviderScreen.baseUrlFieldKey),
    baseUrl,
  );
  await tester.enterText(
    find.byKey(AssistantProviderScreen.modelFieldKey),
    model,
  );
  await tester.enterText(
    find.byKey(AssistantProviderScreen.apiKeyFieldKey),
    apiKey,
  );
}

void main() {
  testWidgets('shows an obscured key field when there is no provider', (
    tester,
  ) async {
    await _pumpProvider(tester, FakeAssistantApi());

    expect(find.text('Base URL'), findsOneWidget);
    expect(find.text('Model'), findsOneWidget);
    expect(find.text('API key'), findsOneWidget);
    expect(find.byKey(AssistantProviderScreen.baseUrlFieldKey), findsOneWidget);
    expect(find.byKey(AssistantProviderScreen.modelFieldKey), findsOneWidget);
    expect(find.byKey(AssistantProviderScreen.apiKeyFieldKey), findsOneWidget);

    final keyField = tester.widget<TextField>(
      find.descendant(
        of: find.byKey(AssistantProviderScreen.apiKeyFieldKey),
        matching: find.byType(TextField),
      ),
    );
    expect(keyField.obscureText, isTrue);
  });

  testWidgets('rejects a non-HTTPS base URL before calling the server', (
    tester,
  ) async {
    final api = FakeAssistantApi();
    await _pumpProvider(tester, api);

    await _fillForm(tester, baseUrl: 'http://api.example.com/v1');
    await tester.tap(find.byKey(AssistantProviderScreen.saveButtonKey));
    await tester.pumpAndSettle();

    expect(
      find.text('Use a full HTTPS URL that points at the provider.'),
      findsOneWidget,
    );
    expect(api.saveRequests, isEmpty);
  });

  testWidgets('saves a provider and shows the base URL, model and key hint', (
    tester,
  ) async {
    final api = FakeAssistantApi();
    await _pumpProvider(tester, api);

    await _fillForm(tester);
    await tester.tap(find.byKey(AssistantProviderScreen.saveButtonKey));
    await tester.pumpAndSettle();

    expect(api.saveRequests.single.baseUrl, 'https://api.example.com/v1');
    expect(api.saveRequests.single.model, 'model-a');
    expect(find.text('Your provider is connected'), findsOneWidget);
    expect(find.text('https://api.example.com/v1'), findsOneWidget);
    expect(find.text('model-a'), findsOneWidget);
    expect(find.text('••••abcd'), findsOneWidget);
    expect(
      find.byKey(AssistantProviderScreen.removeButtonKey),
      findsOneWidget,
    );
  });

  testWidgets('shows a saved provider with the stored key hint', (
    tester,
  ) async {
    final api = FakeAssistantApi(
      providerSettings: AgentProviderSettingsView(
        baseUrl: 'https://provider.example.com/v1',
        model: 'gpt-test',
        keyHint: 'wxyz',
      ),
    );
    await _pumpProvider(tester, api);

    expect(find.text('Your provider is connected'), findsOneWidget);
    expect(find.text('https://provider.example.com/v1'), findsOneWidget);
    expect(find.text('gpt-test'), findsOneWidget);
    expect(find.text('••••wxyz'), findsOneWidget);
    expect(find.byKey(AssistantProviderScreen.apiKeyFieldKey), findsNothing);
  });

  testWidgets('removes the provider and returns to the form', (tester) async {
    final api = FakeAssistantApi(
      providerSettings: AgentProviderSettingsView(
        baseUrl: 'https://provider.example.com/v1',
        model: 'gpt-test',
        keyHint: 'wxyz',
      ),
    );
    await _pumpProvider(tester, api);

    await tester.tap(find.byKey(AssistantProviderScreen.removeButtonKey));
    await tester.pumpAndSettle();
    expect(find.text('Remove this provider?'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Remove provider'));
    await tester.pumpAndSettle();

    expect(api.clearCalls, 1);
    expect(find.byKey(AssistantProviderScreen.baseUrlFieldKey), findsOneWidget);
    expect(find.text('Your provider is connected'), findsNothing);
  });

  testWidgets('shows the server validation message when saving fails', (
    tester,
  ) async {
    final api = FakeAssistantApi(
      saveError: const AssistantFailure.validation(
        message: 'baseUrl must point at a public host.',
      ),
    );
    await _pumpProvider(tester, api);

    await _fillForm(tester);
    await tester.tap(find.byKey(AssistantProviderScreen.saveButtonKey));
    await tester.pumpAndSettle();

    expect(find.text('baseUrl must point at a public host.'), findsOneWidget);
  });

  testWidgets('shows an error state when the provider cannot be loaded', (
    tester,
  ) async {
    final api = FakeAssistantApi(
      providerSettingsError: Exception('offline'),
    );
    await _pumpProvider(tester, api);

    expect(find.text('Could not load your provider settings.'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });
}

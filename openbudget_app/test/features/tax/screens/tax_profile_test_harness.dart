import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/home/providers/entity_detail_provider.dart';
import 'package:openbudget_app/src/features/tax/providers/tax_providers.dart';
import 'package:openbudget_app/src/features/tax/providers/tax_repository.dart';
import 'package:openbudget_app/src/features/tax/screens/tax_profile_screen.dart';
import 'package:openbudget_app/src/features/tax/tax_question_labels.g.dart';
import 'package:openbudget_app/src/features/tax/widgets/tax_question_field.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

import '../tax_test_data.dart';

/// The profile screen for an entity of [countryCode] and [kind], backed by
/// [repository].
Widget buildTaxProfileApp(
  FakeTaxRepository repository, {
  String countryCode = 'GB',
  EntityKind kind = EntityKind.individual,
  Future<TaxProfileRecord?> Function(Ref ref, String entityId)? profileBuilder,
}) {
  final router = GoRouter(
    initialLocation: '/budgets/$testEntityId/tax/profile',
    routes: [
      GoRoute(
        name: taxProfileRoute,
        path: '/budgets/:entityId/tax/profile',
        builder: (context, state) =>
            TaxProfileScreen(entityId: state.pathParameters['entityId']!),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      taxRepositoryProvider.overrideWithValue(repository),
      entityDetailProvider.overrideWith(
        (ref, entityId) async =>
            testEntity(countryCode: countryCode, kind: kind),
      ),
      if (profileBuilder != null)
        taxProfileProvider.overrideWith(profileBuilder),
    ],
    child: MaterialApp.router(
      theme: OpenBudgetTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  );
}

/// The English text the form shows for [key].
String taxText(String key) =>
    taxQuestionLabel(lookupAppLocalizations(const Locale('en')), key);

/// The field of the question stored under [questionKey].
Finder taxField(String questionKey) =>
    find.byKey(taxQuestionFieldKey(questionKey));

/// Scrolls the form so [finder] is on screen, from the top, because the
/// list builds only the rows near the window.
Future<void> revealTaxField(WidgetTester tester, Finder finder) async {
  final scrollable = find.byType(Scrollable).first;
  tester.state<ScrollableState>(scrollable).position.jumpTo(0);
  await tester.pump();
  await tester.scrollUntilVisible(finder, 200, scrollable: scrollable);
  await tester.pumpAndSettle();
}

/// Taps the switch of [questionKey] when it does not already show [value].
Future<void> setTaxSwitch(
  WidgetTester tester,
  String questionKey, {
  required bool value,
}) async {
  await revealTaxField(tester, taxField(questionKey));
  final tile = tester.widget<SwitchListTile>(taxField(questionKey));
  if (tile.value == value) return;
  await tester.tap(taxField(questionKey));
  await tester.pumpAndSettle();
}

/// Opens the dropdown of [questionKey] and picks the item with [label].
Future<void> pickTaxOption(
  WidgetTester tester,
  String questionKey,
  String label,
) async {
  await revealTaxField(tester, taxField(questionKey));
  await tester.tap(taxField(questionKey));
  await tester.pumpAndSettle();
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}

/// Types [text] into the text field of [questionKey].
Future<void> enterTaxText(
  WidgetTester tester,
  String questionKey,
  String text,
) async {
  await revealTaxField(tester, taxField(questionKey));
  await tester.enterText(
    find.descendant(
      of: taxField(questionKey),
      matching: find.byType(TextField),
    ),
    text,
  );
  await tester.pumpAndSettle();
}

/// Presses Save profile.
Future<void> saveTaxProfile(WidgetTester tester) async {
  await tester.scrollUntilVisible(
    find.text('Save profile'),
    300,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Save profile'));
  await tester.pumpAndSettle();
}

/// The profile JSON the repository stored last.
Map<String, Object?> lastSavedTaxProfile(FakeTaxRepository repository) =>
    jsonDecode(repository.savedProfiles.last.profileJson)
        as Map<String, Object?>;

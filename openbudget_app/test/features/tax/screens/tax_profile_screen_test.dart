import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/home/providers/budget_list_provider.dart';
import 'package:openbudget_app/src/features/tax/providers/tax_providers.dart';
import 'package:openbudget_app/src/features/tax/providers/tax_repository.dart';
import 'package:openbudget_app/src/features/tax/screens/tax_profile_screen.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

import '../tax_test_data.dart';

const _otherBudgetId = '00000000-0000-0000-0000-0000000000a411';

Widget _buildApp(
  FakeTaxRepository repository, {
  Future<TaxProfileRecord?> Function(Ref ref, String budgetId)? profileBuilder,
}) {
  final router = GoRouter(
    initialLocation: '/budgets/$testBudgetId/tax/profile',
    routes: [
      GoRoute(
        name: taxProfileRoute,
        path: '/budgets/:id/tax/profile',
        builder: (context, state) =>
            TaxProfileScreen(budgetId: state.pathParameters['id']!),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      taxRepositoryProvider.overrideWithValue(repository),
      budgetListProvider.overrideWith(
        (ref) async => [
          testBudget(),
          testBudget(id: _otherBudgetId, name: 'Personal'),
        ],
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

Future<void> _selectCountry(WidgetTester tester, String label) async {
  await tester.tap(find.byType(DropdownButtonFormField<TaxJurisdiction>));
  await tester.pumpAndSettle();
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}

Future<void> _selectEntity(WidgetTester tester, String label) async {
  await tester.tap(find.byType(DropdownButtonFormField<TaxEntityKind>));
  await tester.pumpAndSettle();
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}

Future<void> _save(WidgetTester tester) async {
  await tester.scrollUntilVisible(
    find.text('Save profile'),
    300,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Save profile'));
  await tester.pumpAndSettle();
}

Map<String, Object?> _lastProfileJson(FakeTaxRepository repository) =>
    jsonDecode(repository.savedProfiles.last.profileJson)
        as Map<String, Object?>;

void main() {
  group('TaxProfileScreen', () {
    testWidgets('shows a loading panel while the profile loads', (
      tester,
    ) async {
      final completer = Completer<TaxProfileRecord?>();
      await tester.pumpWidget(
        _buildApp(
          FakeTaxRepository(),
          profileBuilder: (ref, budgetId) => completer.future,
        ),
      );
      await tester.pump();

      expect(find.text('Loading your tax profile'), findsOneWidget);
    });

    testWidgets('shows a problem panel when the profile fails to load', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildApp(FakeTaxRepository(profileError: Exception('offline'))),
      );
      await tester.pumpAndSettle();

      expect(find.text("We couldn't load your tax profile."), findsWidgets);
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('starts a new UK profile and saves individual defaults', (
      tester,
    ) async {
      final fake = FakeTaxRepository();
      await tester.pumpWidget(_buildApp(fake));
      await tester.pumpAndSettle();

      expect(find.text('United Kingdom'), findsWidgets);
      expect(find.text('Individual'), findsOneWidget);
      expect(find.text('Scottish taxpayer'), findsOneWidget);
      expect(find.text('Student loan plan'), findsOneWidget);
      expect(find.text('Linked personal budget'), findsNothing);

      await _save(tester);

      expect(fake.savedProfiles, hasLength(1));
      final saved = fake.savedProfiles.single;
      expect(saved.jurisdiction, 'GB');
      expect(saved.entityKind, 'individual');
      expect(saved.linkedBudgetId, isNull);
      expect(_lastProfileJson(fake), {
        'jurisdiction': 'GB',
        'entityKind': 'individual',
        'salesTaxRegistered': false,
        'scottishTaxpayer': false,
      });
    });

    testWidgets('saves a US profile with the chosen filing status', (
      tester,
    ) async {
      final fake = FakeTaxRepository();
      await tester.pumpWidget(_buildApp(fake));
      await tester.pumpAndSettle();

      await _selectCountry(tester, 'United States');
      expect(find.text('Filing status'), findsOneWidget);
      expect(find.text('Scottish taxpayer'), findsNothing);

      await tester.tap(find.byType(DropdownButtonFormField<UsFilingStatus>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Married filing jointly').last);
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Registered for sales tax or VAT'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Registered for sales tax or VAT'));
      await tester.pumpAndSettle();

      await _save(tester);

      final saved = _lastProfileJson(fake);
      expect(saved['jurisdiction'], 'US');
      expect(saved['filingStatus'], 'marriedFilingJointly');
      expect(saved['salesTaxRegistered'], isTrue);
    });

    testWidgets('validates a Nigerian annual rent before saving', (
      tester,
    ) async {
      final fake = FakeTaxRepository();
      await tester.pumpWidget(_buildApp(fake));
      await tester.pumpAndSettle();

      await _selectCountry(tester, 'Nigeria');
      expect(find.text('Annual rent paid'), findsOneWidget);

      await tester.ensureVisible(find.byType(TextField));
      await tester.enterText(find.byType(TextField), 'not a number');
      await _save(tester);

      await tester.scrollUntilVisible(
        find.text('Annual rent paid'),
        -300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Enter the annual rent as a number, such as 1200000.'),
        findsOneWidget,
      );
      expect(fake.savedProfiles, isEmpty);
    });

    testWidgets('saves a Nigerian annual rent in minor units', (tester) async {
      final fake = FakeTaxRepository();
      await tester.pumpWidget(_buildApp(fake));
      await tester.pumpAndSettle();

      await _selectCountry(tester, 'Nigeria');
      await tester.ensureVisible(find.byType(TextField));
      await tester.enterText(find.byType(TextField), '1200000');
      await _save(tester);

      expect(fake.savedProfiles, hasLength(1));
      expect(_lastProfileJson(fake)['annualRentMinor'], 120000000);
      expect(_lastProfileJson(fake)['jurisdiction'], 'NG');
    });

    testWidgets('saves Nigerian ceiling and multinational defaults', (
      tester,
    ) async {
      final fake = FakeTaxRepository();
      await tester.pumpWidget(_buildApp(fake));
      await tester.pumpAndSettle();

      await _selectCountry(tester, 'Nigeria');
      expect(find.text('Small company turnover ceiling'), findsOneWidget);
      expect(find.text('Member of a multinational group'), findsOneWidget);

      await _save(tester);

      final saved = _lastProfileJson(fake);
      expect(saved['smallCompanyCeiling'], 'ntaGazette');
      expect(saved['mneGroupMember'], isFalse);
    });

    testWidgets('saves the chosen Nigerian ceiling and multinational flag', (
      tester,
    ) async {
      final fake = FakeTaxRepository();
      await tester.pumpWidget(_buildApp(fake));
      await tester.pumpAndSettle();

      await _selectCountry(tester, 'Nigeria');

      await tester.tap(
        find.byType(DropdownButtonFormField<NgSmallCompanyCeiling>),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('N100,000,000 (Administration Act)').last);
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Member of a multinational group'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Member of a multinational group'));
      await tester.pumpAndSettle();

      await _save(tester);

      final saved = _lastProfileJson(fake);
      expect(saved['smallCompanyCeiling'], 'ntaaIntended');
      expect(saved['mneGroupMember'], isTrue);
    });

    testWidgets('shows German options and saves their defaults', (
      tester,
    ) async {
      final fake = FakeTaxRepository();
      await tester.pumpWidget(_buildApp(fake));
      await tester.pumpAndSettle();

      await _selectCountry(tester, 'Germany');

      expect(find.text('Joint assessment'), findsOneWidget);
      expect(find.text('Church tax'), findsOneWidget);
      expect(find.text('Small business VAT exemption'), findsOneWidget);

      await _save(tester);

      final saved = _lastProfileJson(fake);
      expect(saved['jointAssessment'], isFalse);
      expect(saved['churchTax'], isFalse);
      expect(saved['smallBusinessExemption'], isTrue);
    });

    testWidgets('prefills an existing profile and its linked budget', (
      tester,
    ) async {
      const profile = UsTaxProfile(
        entityKind: TaxEntityKind.soleTrader,
        salesTaxRegistered: true,
        filingStatus: UsFilingStatus.headOfHousehold,
      );
      await tester.pumpWidget(
        _buildApp(
          FakeTaxRepository(profile: taxProfileRecord(profile: profile)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('United States'), findsWidgets);
      expect(find.text('Sole trader'), findsOneWidget);
      expect(find.text('Head of household'), findsOneWidget);
      expect(find.text('Linked personal budget'), findsOneWidget);

      final salesTile = tester.widget<SwitchListTile>(
        find.ancestor(
          of: find.text('Registered for sales tax or VAT'),
          matching: find.byType(SwitchListTile),
        ),
      );
      expect(salesTile.value, isTrue);
    });

    testWidgets('saves the linked personal budget for a company', (
      tester,
    ) async {
      final fake = FakeTaxRepository();
      await tester.pumpWidget(_buildApp(fake));
      await tester.pumpAndSettle();

      await _selectEntity(tester, 'Company');
      expect(find.text('Linked personal budget'), findsOneWidget);

      await tester.tap(find.byType(DropdownButtonFormField<String>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Personal').last);
      await tester.pumpAndSettle();

      await _save(tester);

      final saved = fake.savedProfiles.single;
      expect(saved.entityKind, 'company');
      expect(saved.linkedBudgetId, _otherBudgetId);
    });

    testWidgets('shows a save failure inline without losing the form', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildApp(FakeTaxRepository(saveError: Exception('connection closed'))),
      );
      await tester.pumpAndSettle();

      await _save(tester);

      expect(find.text("We couldn't save your tax profile."), findsOneWidget);
      expect(find.text('United Kingdom'), findsOneWidget);
    });
  });
}

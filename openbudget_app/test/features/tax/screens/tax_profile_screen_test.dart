import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';

import '../tax_test_data.dart';
import 'tax_profile_test_harness.dart';

Future<void> _selectEntity(WidgetTester tester, String label) =>
    pickTaxOption(tester, 'entityKind', label);

void main() {
  group('TaxProfileScreen', () {
    testWidgets('shows a loading panel while the profile loads', (
      tester,
    ) async {
      final completer = Completer<TaxProfileRecord?>();
      await tester.pumpWidget(
        buildTaxProfileApp(
          FakeTaxRepository(),
          profileBuilder: (ref, entityId) => completer.future,
        ),
      );
      await tester.pump();

      expect(find.text('Loading your tax profile'), findsOneWidget);
    });

    testWidgets('shows a problem panel when the profile fails to load', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTaxProfileApp(
          FakeTaxRepository(profileError: Exception('offline')),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("We couldn't load your tax profile."), findsWidgets);
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('starts a new UK profile and saves individual defaults', (
      tester,
    ) async {
      final fake = FakeTaxRepository();
      await tester.pumpWidget(buildTaxProfileApp(fake));
      await tester.pumpAndSettle();

      expect(find.text('United Kingdom'), findsWidgets);
      expect(find.text('Individual'), findsOneWidget);
      expect(find.text('Scottish taxpayer'), findsOneWidget);
      expect(find.text('Student loan plan'), findsOneWidget);
      expect(find.text('Postgraduate loan'), findsOneWidget);
      expect(find.text('Accounting period end'), findsNothing);
      expect(find.text('Associated companies'), findsNothing);
      // The personal-business link lives on the entity now, not here.
      expect(find.text('Linked personal budget'), findsNothing);

      await saveTaxProfile(tester);

      expect(fake.savedProfiles, hasLength(1));
      final saved = fake.savedProfiles.single;
      expect(saved.entityId, testEntityId);
      expect(saved.jurisdiction, 'GB');
      expect(saved.entityKind, 'individual');
      expect(lastSavedTaxProfile(fake), {
        'jurisdiction': 'GB',
        'entityKind': 'individual',
        'salesTaxRegistered': false,
        'scottishTaxpayer': false,
      });
    });

    testWidgets('saves an undergraduate plan with a postgraduate loan', (
      tester,
    ) async {
      final fake = FakeTaxRepository();
      await tester.pumpWidget(buildTaxProfileApp(fake));
      await tester.pumpAndSettle();

      await pickTaxOption(tester, 'studentLoanPlan', 'Plan 2');
      await setTaxSwitch(tester, 'postgraduateLoan', value: true);
      await saveTaxProfile(tester);

      final saved = lastSavedTaxProfile(fake);
      expect(saved['studentLoanPlan'], 'plan2');
      expect(saved['postgraduateLoan'], isTrue);
    });

    testWidgets('clears a student loan plan with "No student loan"', (
      tester,
    ) async {
      final fake = FakeTaxRepository(
        profile: taxProfileRecord(
          profile: const GbTaxProfile(
            entityKind: EntityKind.individual,
            studentLoanPlan: GbStudentLoanPlan.plan1,
          ),
        ),
      );
      await tester.pumpWidget(buildTaxProfileApp(fake));
      await tester.pumpAndSettle();

      await pickTaxOption(tester, 'studentLoanPlan', 'No student loan');
      await saveTaxProfile(tester);

      expect(lastSavedTaxProfile(fake), isNot(contains('studentLoanPlan')));
    });

    testWidgets('saves a UK company accounting period and associates', (
      tester,
    ) async {
      final fake = FakeTaxRepository();
      await tester.pumpWidget(buildTaxProfileApp(fake));
      await tester.pumpAndSettle();

      await _selectEntity(tester, 'Company');
      expect(find.text('Accounting period end'), findsOneWidget);
      expect(find.text('Associated companies'), findsOneWidget);

      await enterTaxText(tester, 'associatedCompanies', '2');
      await saveTaxProfile(tester);

      final saved = lastSavedTaxProfile(fake);
      // The default 31 March end is not stored; the count is.
      expect(saved['accountingPeriodEndMonth'], isNull);
      expect(saved['accountingPeriodEndDay'], isNull);
      expect(saved['associatedCompanies'], 2);
    });

    testWidgets('a UK company keeps a non-default accounting period', (
      tester,
    ) async {
      final fake = FakeTaxRepository();
      await tester.pumpWidget(buildTaxProfileApp(fake));
      await tester.pumpAndSettle();

      await _selectEntity(tester, 'Company');
      await revealTaxField(tester, taxField('accountingPeriodEnd'));

      // Month dropdown first, then the day dropdown. The menu builds its
      // items lazily, so pick months near the default that are visible.
      final dropdowns = find.descendant(
        of: taxField('accountingPeriodEnd'),
        matching: find.byType(DropdownButtonFormField<int>),
      );
      await tester.tap(dropdowns.first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('May').last);
      await tester.pumpAndSettle();
      await tester.tap(dropdowns.last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('31').last);
      await tester.pumpAndSettle();

      await saveTaxProfile(tester);

      final saved = lastSavedTaxProfile(fake);
      expect(saved['accountingPeriodEndMonth'], 5);
      // 31 is the default day, so it is not stored.
      expect(saved['accountingPeriodEndDay'], isNull);
    });

    testWidgets('moving the month keeps the day inside it', (tester) async {
      final fake = FakeTaxRepository();
      await tester.pumpWidget(
        buildTaxProfileApp(fake, kind: EntityKind.company),
      );
      await tester.pumpAndSettle();

      // The day starts at 31; April has 30 days.
      await revealTaxField(tester, taxField('accountingPeriodEnd'));
      await tester.tap(
        find
            .descendant(
              of: taxField('accountingPeriodEnd'),
              matching: find.byType(DropdownButtonFormField<int>),
            )
            .first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('April').last);
      await tester.pumpAndSettle();
      await saveTaxProfile(tester);

      final saved = lastSavedTaxProfile(fake);
      expect(saved['accountingPeriodEndMonth'], 4);
      expect(saved['accountingPeriodEndDay'], 30);
    });

    testWidgets('rejects a non-numeric associated companies count', (
      tester,
    ) async {
      final fake = FakeTaxRepository();
      await tester.pumpWidget(buildTaxProfileApp(fake));
      await tester.pumpAndSettle();

      await _selectEntity(tester, 'Company');
      await enterTaxText(tester, 'associatedCompanies', 'two');
      await saveTaxProfile(tester);

      await revealTaxField(tester, taxField('associatedCompanies'));
      expect(find.text('Enter a whole number of 0 or more.'), findsOneWidget);
      expect(fake.savedProfiles, isEmpty);
    });

    testWidgets('saves a US profile with the chosen filing status', (
      tester,
    ) async {
      final fake = FakeTaxRepository();
      await tester.pumpWidget(buildTaxProfileApp(fake, countryCode: 'US'));
      await tester.pumpAndSettle();

      expect(find.text('United States'), findsWidgets);
      expect(find.text('Filing status'), findsOneWidget);
      expect(find.text('Scottish taxpayer'), findsNothing);

      await pickTaxOption(tester, 'filingStatus', 'Married filing jointly');
      await setTaxSwitch(tester, 'salesTaxRegistered', value: true);
      await saveTaxProfile(tester);

      final saved = lastSavedTaxProfile(fake);
      expect(saved['jurisdiction'], 'US');
      expect(saved['filingStatus'], 'marriedFilingJointly');
      expect(saved['salesTaxRegistered'], isTrue);
    });

    testWidgets('the spouse questions appear only for joint filers', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTaxProfileApp(FakeTaxRepository(), countryCode: 'US'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Your spouse has an SSN'), findsNothing);
      expect(find.text('Your spouse is 65 or older'), findsNothing);

      await pickTaxOption(tester, 'filingStatus', 'Married filing jointly');

      await revealTaxField(tester, taxField('spouseHasSsn'));
      expect(find.text('Your spouse has an SSN'), findsOneWidget);
      await revealTaxField(tester, taxField('spouse65OrOlder'));
      expect(find.text('Your spouse is 65 or older'), findsOneWidget);
    });

    testWidgets('offers qualifying surviving spouse as a filing status', (
      tester,
    ) async {
      final fake = FakeTaxRepository();
      await tester.pumpWidget(buildTaxProfileApp(fake, countryCode: 'US'));
      await tester.pumpAndSettle();

      await pickTaxOption(
        tester,
        'filingStatus',
        'Qualifying surviving spouse',
      );
      await saveTaxProfile(tester);

      expect(
        lastSavedTaxProfile(fake)['filingStatus'],
        'qualifyingSurvivingSpouse',
      );
    });

    testWidgets('saves US dependents, age, SSN, and exclusion', (tester) async {
      final fake = FakeTaxRepository();
      await tester.pumpWidget(buildTaxProfileApp(fake, countryCode: 'US'));
      await tester.pumpAndSettle();

      await enterTaxText(tester, 'dependentsUnder17', '2');
      await enterTaxText(tester, 'dependents17OrOlder', '1');
      await enterTaxText(tester, 'foreignEarnedIncomeExclusionMinor', '5000');
      await setTaxSwitch(tester, 'taxpayer65OrOlder', value: true);
      await saveTaxProfile(tester);

      final saved = lastSavedTaxProfile(fake);
      expect(saved['jurisdiction'], 'US');
      expect(saved['taxpayer65OrOlder'], isTrue);
      expect(saved['spouse65OrOlder'], isFalse);
      expect(saved['taxpayerHasSsn'], isTrue);
      expect(saved['foreignEarnedIncomeExclusionMinor'], 500000);
      // The SSN switch starts off, so no dependent carries an SSN yet.
      expect(saved['dependents'], [
        {'underSeventeen': true, 'hasValidSsn': false},
        {'underSeventeen': true, 'hasValidSsn': false},
        {'underSeventeen': false, 'hasValidSsn': false},
      ]);
    });

    testWidgets('saves the US home office method for a sole trader', (
      tester,
    ) async {
      final fake = FakeTaxRepository();
      await tester.pumpWidget(buildTaxProfileApp(fake, countryCode: 'US'));
      await tester.pumpAndSettle();

      await _selectEntity(tester, 'Sole trader');
      expect(find.text('Home office method'), findsOneWidget);
      expect(find.text('Specified service business'), findsOneWidget);

      await pickTaxOption(tester, 'homeOfficeMethod', 'Regular (Form 8829)');
      await saveTaxProfile(tester);

      final saved = lastSavedTaxProfile(fake);
      expect(saved['homeOfficeMethod'], 'regular');
      expect(saved['specifiedServiceTrade'], isFalse);
    });

    testWidgets('validates a Nigerian annual rent before saving', (
      tester,
    ) async {
      final fake = FakeTaxRepository();
      await tester.pumpWidget(buildTaxProfileApp(fake, countryCode: 'NG'));
      await tester.pumpAndSettle();

      expect(find.text('Annual rent paid'), findsOneWidget);

      await enterTaxText(tester, 'annualRentMinor', 'not a number');
      await saveTaxProfile(tester);

      await revealTaxField(tester, taxField('annualRentMinor'));
      expect(
        find.text('Enter the amount as a number, such as 4800.'),
        findsOneWidget,
      );
      expect(fake.savedProfiles, isEmpty);
    });

    testWidgets('typing again clears the amount error', (tester) async {
      final fake = FakeTaxRepository();
      await tester.pumpWidget(buildTaxProfileApp(fake, countryCode: 'NG'));
      await tester.pumpAndSettle();

      await enterTaxText(tester, 'annualRentMinor', 'x');
      await saveTaxProfile(tester);
      await enterTaxText(tester, 'annualRentMinor', '12');

      expect(
        find.text('Enter the amount as a number, such as 4800.'),
        findsNothing,
      );
    });

    testWidgets('saves a Nigerian annual rent in minor units', (tester) async {
      final fake = FakeTaxRepository();
      await tester.pumpWidget(buildTaxProfileApp(fake, countryCode: 'NG'));
      await tester.pumpAndSettle();

      await enterTaxText(tester, 'annualRentMinor', '1200000');
      await saveTaxProfile(tester);

      expect(fake.savedProfiles, hasLength(1));
      expect(lastSavedTaxProfile(fake)['annualRentMinor'], 120000000);
      expect(lastSavedTaxProfile(fake)['jurisdiction'], 'NG');
    });

    testWidgets('saves Nigerian ceiling and multinational defaults', (
      tester,
    ) async {
      final fake = FakeTaxRepository();
      await tester.pumpWidget(buildTaxProfileApp(fake, countryCode: 'NG'));
      await tester.pumpAndSettle();

      expect(find.text('Small company turnover ceiling'), findsOneWidget);
      expect(find.text('Member of a multinational group'), findsOneWidget);

      await saveTaxProfile(tester);

      final saved = lastSavedTaxProfile(fake);
      expect(saved['smallCompanyCeiling'], 'ntaGazette');
      expect(saved['mneGroupMember'], isFalse);
    });

    testWidgets('shows German options and saves their defaults', (
      tester,
    ) async {
      final fake = FakeTaxRepository();
      await tester.pumpWidget(buildTaxProfileApp(fake, countryCode: 'DE'));
      await tester.pumpAndSettle();

      expect(find.text('Germany'), findsWidgets);
      expect(find.text('Joint assessment'), findsOneWidget);
      expect(find.text('Church tax'), findsOneWidget);
      expect(find.text('Spouse also earns wages'), findsNothing);
      expect(find.text('State (Land) of the church tax'), findsNothing);

      await saveTaxProfile(tester);

      final saved = lastSavedTaxProfile(fake);
      expect(saved['jointAssessment'], isFalse);
      expect(saved['churchTax'], isFalse);
      expect(saved['churchTaxState'], isNull);
      expect(saved['smallBusinessExemption'], isTrue);
      expect(saved['children'], 0);
      expect(saved['einkunftsArt'], 'gewerblich');
    });

    testWidgets('rejects a non-numeric German child count', (tester) async {
      final fake = FakeTaxRepository();
      await tester.pumpWidget(buildTaxProfileApp(fake, countryCode: 'DE'));
      await tester.pumpAndSettle();

      await enterTaxText(tester, 'children', 'two');
      await saveTaxProfile(tester);

      await revealTaxField(tester, taxField('children'));
      expect(find.text('Enter a whole number of 0 or more.'), findsOneWidget);
      expect(fake.savedProfiles, isEmpty);
    });

    testWidgets('a German sole trader chooses the Einkunftsart', (
      tester,
    ) async {
      final fake = FakeTaxRepository();
      await tester.pumpWidget(buildTaxProfileApp(fake, countryCode: 'DE'));
      await tester.pumpAndSettle();

      await _selectEntity(tester, 'Sole trader');

      expect(find.text('Type of self-employment'), findsOneWidget);
      await pickTaxOption(
        tester,
        'einkunftsArt',
        'Freiberufler (liberal profession)',
      );
      await saveTaxProfile(tester);

      expect(lastSavedTaxProfile(fake)['einkunftsArt'], 'freiberuflich');
    });

    testWidgets('prefills an existing profile from the entity', (tester) async {
      const profile = UsTaxProfile(
        entityKind: EntityKind.soleTrader,
        salesTaxRegistered: true,
        filingStatus: UsFilingStatus.headOfHousehold,
      );
      await tester.pumpWidget(
        buildTaxProfileApp(
          FakeTaxRepository(profile: taxProfileRecord(profile: profile)),
          countryCode: 'US',
          kind: EntityKind.soleTrader,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('United States'), findsWidgets);
      expect(find.text('Sole trader'), findsOneWidget);
      await revealTaxField(tester, taxField('filingStatus'));
      expect(find.text('Head of household'), findsOneWidget);

      final salesTile = tester.widget<SwitchListTile>(
        taxField('salesTaxRegistered'),
      );
      expect(salesTile.value, isTrue);
    });

    testWidgets('keeps the residence and US-person answers it is given', (
      tester,
    ) async {
      final fake = FakeTaxRepository(
        profile: taxProfileRecord(
          profile: const GbTaxProfile(
            entityKind: EntityKind.individual,
            taxResident: true,
            usPerson: true,
          ),
        ),
      );
      await tester.pumpWidget(buildTaxProfileApp(fake));
      await tester.pumpAndSettle();

      await setTaxSwitch(tester, 'scottishTaxpayer', value: true);
      await saveTaxProfile(tester);

      final saved = lastSavedTaxProfile(fake);
      expect(saved['taxResident'], isTrue);
      expect(saved['usPerson'], isTrue);
      expect(saved['scottishTaxpayer'], isTrue);
    });

    testWidgets('asks the residence and US-person questions in every country', (
      tester,
    ) async {
      for (final country in ['GB', 'US', 'NG', 'DE']) {
        await tester.pumpWidget(
          buildTaxProfileApp(FakeTaxRepository(), countryCode: country),
        );
        await tester.pumpAndSettle();

        expect(find.text('Tax resident of this country'), findsOneWidget);
        expect(find.text('US person'), findsOneWidget);
      }
    });

    testWidgets('shows a save failure inline without losing the form', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTaxProfileApp(
          FakeTaxRepository(saveError: Exception('connection closed')),
        ),
      );
      await tester.pumpAndSettle();

      await setTaxSwitch(tester, 'scottishTaxpayer', value: true);
      await saveTaxProfile(tester);

      expect(find.text("We couldn't save your tax profile."), findsOneWidget);
      await revealTaxField(tester, taxField('scottishTaxpayer'));
      expect(
        tester.widget<SwitchListTile>(taxField('scottishTaxpayer')).value,
        isTrue,
      );
    });
  });

  group('layout', () {
    for (final country in ['GB', 'US', 'NG', 'DE']) {
      for (final kind in EntityKind.values) {
        testWidgets('$country ${kind.name} survives large text', (
          tester,
        ) async {
          tester.view
            ..physicalSize = const Size(390, 844)
            ..devicePixelRatio = 1;
          tester.platformDispatcher.textScaleFactorTestValue = 2;
          addTearDown(tester.view.reset);
          addTearDown(tester.platformDispatcher.clearAllTestValues);
          await tester.pumpWidget(
            buildTaxProfileApp(
              FakeTaxRepository(),
              countryCode: country,
              kind: kind,
            ),
          );
          await tester.pumpAndSettle();

          // Walk the whole form: any overflow throws.
          final scrollable = find.byType(Scrollable).first;
          for (var i = 0; i < 40; i++) {
            await tester.drag(scrollable, const Offset(0, -300));
            await tester.pump();
          }

          expect(tester.takeException(), isNull);
        });
      }
    }

    testWidgets('stacks the month and day under large text', (tester) async {
      tester.view
        ..physicalSize = const Size(390, 844)
        ..devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearAllTestValues);
      await tester.pumpWidget(
        buildTaxProfileApp(FakeTaxRepository(), kind: EntityKind.company),
      );
      await tester.pumpAndSettle();
      await revealTaxField(tester, taxField('accountingPeriodEnd'));

      final dropdowns = find.descendant(
        of: taxField('accountingPeriodEnd'),
        matching: find.byType(DropdownButtonFormField<int>),
      );
      expect(
        tester.getTopLeft(dropdowns.last).dy,
        greaterThan(tester.getBottomLeft(dropdowns.first).dy),
      );
    });

    testWidgets('keeps the form in a readable column on a desktop window', (
      tester,
    ) async {
      tester.view
        ..physicalSize = const Size(1440, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        buildTaxProfileApp(FakeTaxRepository(), countryCode: 'DE'),
      );
      await tester.pumpAndSettle();

      final width = tester.getSize(taxField('jointAssessment')).width;
      expect(width, lessThanOrEqualTo(760));
    });
  });
}

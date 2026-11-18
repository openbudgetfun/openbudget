import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/src/features/tax/providers/tax_actions_provider.dart';
import 'package:openbudget_app/src/features/tax/providers/tax_providers.dart';
import 'package:openbudget_app/src/features/tax/providers/tax_repository.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';

import '../tax_test_data.dart';

ProviderContainer _containerWith(TaxRepository repository) {
  final container = ProviderContainer(
    overrides: [taxRepositoryProvider.overrideWithValue(repository)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('taxProfileProvider', () {
    test('returns null when the entity has no profile', () async {
      final container = _containerWith(FakeTaxRepository());

      final profile = await container.read(
        taxProfileProvider(testEntityId).future,
      );

      expect(profile, isNull);
    });

    test('returns the stored profile record', () async {
      final record = taxProfileRecord();
      final container = _containerWith(FakeTaxRepository(profile: record));

      final profile = await container.read(
        taxProfileProvider(testEntityId).future,
      );

      expect(profile, same(record));
      final json = jsonDecode(profile!.profileJson) as Map<String, Object?>;
      expect(json['jurisdiction'], 'GB');
      expect(json['entityKind'], EntityKind.individual.name);
    });

    test('surfaces repository errors', () async {
      final container = _containerWith(
        FakeTaxRepository(profileError: Exception('offline')),
      );
      final provider = taxProfileProvider(testEntityId);
      final subscription = container.listen(provider, (_, _) {});
      addTearDown(subscription.close);

      await Future<void>.delayed(Duration.zero);

      final state = container.read(provider);
      expect(state.hasError, isTrue);
      expect(state.error, isA<Exception>());
    });
  });

  group('taxReportProvider', () {
    test('asks for the requested tax year', () async {
      final fake = FakeTaxRepository(
        reports: {2026: taxReportView(), 2025: taxReportView(startYear: 2025)},
      );
      final container = _containerWith(fake);

      final report = await container.read(
        taxReportProvider(testEntityId, 2026).future,
      );

      expect(report.yearLabel, '2026/27');
      expect(fake.reportCalls, [(entityId: testEntityId, startYear: 2026)]);
    });

    test('keeps separate reports for separate years', () async {
      final fake = FakeTaxRepository(
        reports: {2026: taxReportView(), 2025: refundTaxReport()},
      );
      final container = _containerWith(fake);

      final owed = await container.read(
        taxReportProvider(testEntityId, 2026).future,
      );
      final refund = await container.read(
        taxReportProvider(testEntityId, 2025).future,
      );

      expect(owed.balanceDueMinor, 748000);
      expect(refund.balanceDueMinor, -150000);
    });

    test('passes on unsupported-year errors', () async {
      final container = _containerWith(
        FakeTaxRepository(
          reportError: TaxRulesUnavailableException(
            message: 'No GB tax rates for 2030.',
          ),
        ),
      );
      final provider = taxReportProvider(testEntityId, 2030);
      final subscription = container.listen(provider, (_, _) {});
      addTearDown(subscription.close);

      await Future<void>.delayed(Duration.zero);

      final state = container.read(provider);
      expect(state.hasError, isTrue);
      expect(state.error, isA<TaxRulesUnavailableException>());
    });
  });

  group('taxCategoriesProvider', () {
    test('returns the catalog for the entity', () async {
      final container = _containerWith(FakeTaxRepository());

      final categories = await container.read(
        taxCategoriesProvider(testEntityId).future,
      );

      expect(categories, hasLength(3));
      expect(categories.first.code, 'gb.ind.employment');
      expect(categories[1].reportReference, 'SA103F box 20');
    });

    test('surfaces a missing profile as an error', () async {
      final container = _containerWith(
        FakeTaxRepository(
          categoriesError: Exception('Tax profile not found for this entity'),
        ),
      );
      final provider = taxCategoriesProvider(testEntityId);
      final subscription = container.listen(provider, (_, _) {});
      addTearDown(subscription.close);

      await Future<void>.delayed(Duration.zero);

      final state = container.read(provider);
      expect(state.hasError, isTrue);
      expect(state.error.toString(), contains('Tax profile not found'));
    });
  });

  group('taxActionsProvider', () {
    test('forwards a profile save and updates the fake store', () async {
      final fake = FakeTaxRepository();
      final container = _containerWith(fake);
      const profile = GbTaxProfile(
        entityKind: EntityKind.soleTrader,
        salesTaxRegistered: true,
        scottishTaxpayer: true,
      );

      final saved = await container
          .read(taxActionsProvider.notifier)
          .saveProfile(
            entityId: testEntityId,
            jurisdiction: profile.jurisdiction.countryCode,
            entityKind: profile.entityKind.name,
            profileJson: testProfileJson(profile),
          );

      final savedJson = jsonDecode(saved.profileJson) as Map<String, Object?>;
      expect(savedJson['jurisdiction'], 'GB');
      expect(fake.savedProfiles, hasLength(1));
      expect(fake.savedProfiles.single.entityKind, 'soleTrader');
      expect(
        fake.savedProfiles.single.profileJson,
        contains('"scottishTaxpayer":true'),
      );
      expect(
        container.read(taxActionsProvider),
        const AsyncValue<void>.data(null),
      );
    });

    test('forwards envelope and line categorisation', () async {
      final fake = FakeTaxRepository();
      final container = _containerWith(fake);
      final actions = container.read(taxActionsProvider.notifier);

      await actions.setEnvelopeTaxCategory(
        entityId: testEntityId,
        envelopeId: testEnvelopeId,
        code: 'gb.se.office_costs',
      );
      await actions.setLineTax(
        entityId: testEntityId,
        transactionLineId: testTransactionLineId,
        code: 'gb.se.office_costs',
        businessUsePercent: 60,
        salesTaxMinor: 250,
      );

      expect(fake.envelopeUpdates, [
        (envelopeId: testEnvelopeId, code: 'gb.se.office_costs'),
      ]);
      expect(fake.lineUpdates.single.businessUsePercent, 60);
      expect(fake.lineUpdates.single.salesTaxMinor, 250);
    });

    test('records a failed save as an error state and rethrows', () async {
      final container = _containerWith(
        FakeTaxRepository(saveError: Exception('server said no')),
      );

      await expectLater(
        container
            .read(taxActionsProvider.notifier)
            .saveProfile(
              entityId: testEntityId,
              jurisdiction: 'GB',
              entityKind: 'individual',
              profileJson: testProfileJson(
                const GbTaxProfile(entityKind: EntityKind.individual),
              ),
            ),
        throwsA(isA<Exception>()),
      );
      expect(container.read(taxActionsProvider).hasError, isTrue);
    });
  });
}

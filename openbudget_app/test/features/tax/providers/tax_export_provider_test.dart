import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/src/features/tax/providers/tax_export_provider.dart';
import 'package:openbudget_app/src/features/tax/providers/tax_repository.dart';
import 'package:openbudget_app/src/features/tax/providers/tax_url_launcher_provider.dart';

import '../tax_test_data.dart';

ProviderContainer _containerWith(
  TaxRepository repository,
  FakeTaxUrlLauncher launcher,
) {
  final container = ProviderContainer(
    overrides: [
      taxRepositoryProvider.overrideWithValue(repository),
      taxUrlLauncherProvider.overrideWithValue(launcher),
    ],
  );
  addTearDown(container.dispose);
  // Keeps the auto-disposed notifier alive for the length of the test.
  container.listen(taxExportProvider, (_, _) {});
  return container;
}

/// A repository whose export link arrives when the test says so.
class _PendingExportRepository extends FakeTaxRepository {
  final Completer<String> link = Completer<String>();

  @override
  Future<String> createExportLink(String entityId, {int? startYear}) {
    exportCalls.add((entityId: entityId, startYear: startYear));
    return link.future;
  }
}

void main() {
  group('TaxExport', () {
    test('asks for the link and opens it as a download', () async {
      final repository = FakeTaxRepository();
      final launcher = FakeTaxUrlLauncher();
      final container = _containerWith(repository, launcher);

      final opened = await container
          .read(taxExportProvider.notifier)
          .exportSummary(entityId: testEntityId, startYear: 2026);

      expect(opened, isTrue);
      expect(repository.exportCalls, [
        (entityId: testEntityId, startYear: 2026),
      ]);
      expect(launcher.openedDownloads, [Uri.parse(testExportLink)]);
      expect(container.read(taxExportProvider).hasError, isFalse);
    });

    test('lets the server choose the year when none is given', () async {
      final repository = FakeTaxRepository();
      final container = _containerWith(repository, FakeTaxUrlLauncher());

      await container
          .read(taxExportProvider.notifier)
          .exportSummary(entityId: testEntityId);

      expect(repository.exportCalls.single.startYear, isNull);
    });

    test(
      'is loading while the link is made, and ignores a second tap',
      () async {
        final repository = _PendingExportRepository();
        final launcher = FakeTaxUrlLauncher();
        final container = _containerWith(repository, launcher);
        final notifier = container.read(taxExportProvider.notifier);

        final first = notifier.exportSummary(entityId: testEntityId);
        expect(container.read(taxExportProvider).isLoading, isTrue);

        final second = await notifier.exportSummary(entityId: testEntityId);
        expect(second, isFalse);
        expect(repository.exportCalls, hasLength(1));

        repository.link.complete(testExportLink);
        expect(await first, isTrue);
        expect(container.read(taxExportProvider).isLoading, isFalse);
        expect(launcher.openedDownloads, hasLength(1));
      },
    );

    test(
      "keeps the server's failure as the state and opens nothing",
      () async {
        final launcher = FakeTaxUrlLauncher();
        final container = _containerWith(
          FakeTaxRepository(exportError: Exception('server down')),
          launcher,
        );

        final opened = await container
            .read(taxExportProvider.notifier)
            .exportSummary(entityId: testEntityId);

        expect(opened, isFalse);
        expect(container.read(taxExportProvider).hasError, isTrue);
        expect(launcher.openedDownloads, isEmpty);
      },
    );

    test('fails when the device would not open the link', () async {
      final container = _containerWith(
        FakeTaxRepository(),
        FakeTaxUrlLauncher(opens: false),
      );

      final opened = await container
          .read(taxExportProvider.notifier)
          .exportSummary(entityId: testEntityId);

      expect(opened, isFalse);
      expect(
        container.read(taxExportProvider).error,
        isA<TaxExportOpenException>(),
      );
    });

    test('never opens a link that is not a web address', () async {
      for (final link in [
        'javascript:alert(1)',
        'file:///etc/passwd',
        '',
        'zip',
      ]) {
        final launcher = FakeTaxUrlLauncher();
        final container = _containerWith(
          FakeTaxRepository(exportLink: link),
          launcher,
        );

        final opened = await container
            .read(taxExportProvider.notifier)
            .exportSummary(entityId: testEntityId);

        expect(opened, isFalse, reason: link);
        expect(launcher.openedDownloads, isEmpty, reason: link);
        expect(
          container.read(taxExportProvider).error,
          isA<TaxExportOpenException>(),
          reason: link,
        );
      }
    });

    test('can try again after a failure', () async {
      final repository = FakeTaxRepository(exportError: Exception('offline'));
      final launcher = FakeTaxUrlLauncher();
      final container = _containerWith(repository, launcher);
      final notifier = container.read(taxExportProvider.notifier);

      expect(await notifier.exportSummary(entityId: testEntityId), isFalse);

      repository.exportError = null;
      expect(await notifier.exportSummary(entityId: testEntityId), isTrue);
      expect(container.read(taxExportProvider).hasError, isFalse);
      expect(launcher.openedDownloads, hasLength(1));
    });
  });
}

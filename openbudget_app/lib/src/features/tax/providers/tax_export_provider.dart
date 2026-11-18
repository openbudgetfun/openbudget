import 'package:openbudget_app/src/features/tax/providers/tax_repository.dart';
import 'package:openbudget_app/src/features/tax/providers/tax_url_launcher_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tax_export_provider.g.dart';

/// The server answered with a link, but the device would not open it.
class TaxExportOpenException implements Exception {
  const TaxExportOpenException();

  @override
  String toString() => 'TaxExportOpenException: the download link did not open';
}

/// Asks the server for a signed summary link and opens it.
///
/// The state is the progress of the latest attempt: loading while the link
/// is made and opened, an error when either step failed, data once the
/// download has started.
@riverpod
class TaxExport extends _$TaxExport {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  /// Makes a link for the tax year starting in [startYear] (the entity's
  /// current year when null) and opens it. Returns whether it opened.
  Future<bool> exportSummary({
    required String entityId,
    int? startYear,
  }) async {
    if (state.isLoading) {
      return false;
    }
    state = const AsyncValue.loading();
    try {
      final link = await ref
          .read(taxRepositoryProvider)
          .createExportLink(entityId, startYear: startYear);
      final url = Uri.tryParse(link);
      if (url == null || !_isWebLink(url)) {
        throw const TaxExportOpenException();
      }
      final opened = await ref.read(taxUrlLauncherProvider).openDownload(url);
      if (!opened) {
        throw const TaxExportOpenException();
      }
      if (ref.mounted) {
        state = const AsyncValue.data(null);
      }
      return true;
    } on Exception catch (error, stackTrace) {
      if (ref.mounted) {
        state = AsyncValue.error(error, stackTrace);
      }
      return false;
    }
  }
}

bool _isWebLink(Uri url) =>
    (url.scheme == 'https' || url.scheme == 'http') && url.host.isNotEmpty;

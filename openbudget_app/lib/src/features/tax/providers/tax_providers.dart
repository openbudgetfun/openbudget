import 'package:openbudget_app/src/features/tax/providers/tax_repository.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tax_providers.g.dart';

/// The budget's tax profile, or null when none has been set.
@riverpod
Future<TaxProfileRecord?> taxProfile(Ref ref, String entityId) =>
    ref.watch(taxRepositoryProvider).getProfile(entityId);

/// The tax report for the tax year starting in [startYear].
@riverpod
Future<TaxReportView> taxReport(Ref ref, String entityId, int startYear) =>
    ref.watch(taxRepositoryProvider).getReport(entityId, startYear);

/// The categories available to the budget's entity kind.
@riverpod
Future<List<TaxCategoryView>> taxCategories(Ref ref, String entityId) =>
    ref.watch(taxRepositoryProvider).listCategories(entityId);

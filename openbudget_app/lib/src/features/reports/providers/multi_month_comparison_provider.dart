import 'package:equatable/equatable.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_month_provider.dart';
import 'package:openbudget_app/src/features/home/providers/entity_detail_provider.dart';
import 'package:openbudget_app/src/features/reports/providers/month_figures_provider.dart';
import 'package:openbudget_app/src/features/reports/utils/month_range.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'multi_month_comparison_provider.g.dart';

class MonthColumn extends Equatable {
  const MonthColumn({required this.month, required this.totalActivityMinor});

  /// The yyyymm month.
  final int month;

  /// Sum of envelope activity this month; negative is spending.
  final int totalActivityMinor;

  @override
  List<Object?> get props => [month, totalActivityMinor];
}

class EnvelopeComparison extends Equatable {
  const EnvelopeComparison({
    required this.envelope,
    required this.monthlyActivityMinor,
  });

  final Envelope envelope;

  /// Activity in base minor units keyed by yyyymm; missing months are zero.
  final Map<int, int> monthlyActivityMinor;

  @override
  List<Object?> get props => [envelope, monthlyActivityMinor];
}

class CategoryComparison extends Equatable {
  const CategoryComparison({
    required this.category,
    required this.envelopes,
    required this.monthlyActivityMinor,
  });

  final Category category;
  final List<EnvelopeComparison> envelopes;

  /// The category's envelopes summed, keyed by yyyymm; missing months are
  /// zero.
  final Map<int, int> monthlyActivityMinor;

  @override
  List<Object?> get props => [category, envelopes, monthlyActivityMinor];
}

class MultiMonthComparison extends Equatable {
  const MultiMonthComparison({
    required this.currencyCode,
    required this.months,
    required this.categories,
  });

  final String currencyCode;
  final List<MonthColumn> months;
  final List<CategoryComparison> categories;

  @override
  List<Object?> get props => [currencyCode, months, categories];
}

/// Compares the last [monthCount] months for each envelope that moved.
///
/// One `report.spending` call with [ReportGrouping.envelope] and `byMonth`
/// supplies every month of activity; `report.monthSummaries` supplies the
/// month headers and totals. Envelope and category metadata comes from the
/// entity's whole lists, never from a month view.
@riverpod
Future<MultiMonthComparison> multiMonthComparison(
  Ref ref,
  String entityId, {
  int monthCount = 3,
}) async {
  final client = ref.read(serverpodClientProvider);
  final endMonth = MonthKey.fromDate(DateTime.now());
  final summaries = await ref.watch(
    monthFiguresProvider(entityId, endMonth, monthCount).future,
  );
  final categories = await ref.watch(categoryListProvider(entityId).future);
  final envelopes = await ref.watch(envelopeListProvider(entityId).future);
  final entity = await ref.watch(entityDetailProvider(entityId).future);

  final rows = await client.report.spending(
    UuidValue.fromString(entityId),
    monthRangeStart(endMonth, monthCount),
    endMonth,
    ReportGrouping.envelope,
    true,
  );

  final activityByEnvelope = <String, Map<int, int>>{};
  for (final row in rows) {
    final groupId = row.groupId;
    final month = row.month;
    if (groupId == null || month == null) continue;
    activityByEnvelope
        .putIfAbsent(groupId.toString(), () => {})
        .update(
          month,
          (activity) => activity + row.outflowMinor + row.inflowMinor,
          ifAbsent: () => row.outflowMinor + row.inflowMinor,
        );
  }

  final envelopesByCategory = <String, List<Envelope>>{};
  for (final envelope in envelopes) {
    envelopesByCategory
        .putIfAbsent(envelope.categoryId.toString(), () => [])
        .add(envelope);
  }

  final comparisons = <CategoryComparison>[];
  for (final category in categories) {
    final categoryEnvelopes = <EnvelopeComparison>[];
    final categoryActivity = <int, int>{};

    for (final envelope
        in envelopesByCategory[category.id?.toString() ?? ''] ??
            const <Envelope>[]) {
      final activity = activityByEnvelope[envelope.id?.toString() ?? ''];
      if (activity == null || activity.values.every((value) => value == 0)) {
        continue;
      }
      categoryEnvelopes.add(
        EnvelopeComparison(
          envelope: envelope,
          monthlyActivityMinor: activity,
        ),
      );
      for (final entry in activity.entries) {
        categoryActivity.update(
          entry.key,
          (total) => total + entry.value,
          ifAbsent: () => entry.value,
        );
      }
    }

    if (categoryEnvelopes.isEmpty) continue;
    comparisons.add(
      CategoryComparison(
        category: category,
        envelopes: categoryEnvelopes,
        monthlyActivityMinor: categoryActivity,
      ),
    );
  }

  return MultiMonthComparison(
    currencyCode: entity.baseCurrencyCode,
    months: [
      for (final summary in summaries)
        MonthColumn(
          month: summary.month,
          totalActivityMinor: summary.activityMinor,
        ),
    ],
    categories: comparisons,
  );
}

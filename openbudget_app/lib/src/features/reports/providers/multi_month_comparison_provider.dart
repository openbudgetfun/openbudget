import 'package:equatable/equatable.dart';
import 'package:openbudget_app/src/features/reports/providers/month_figures_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'multi_month_comparison_provider.g.dart';

class MonthColumn extends Equatable {
  const MonthColumn({
    required this.month,
    required this.totalAllocatedMinor,
    required this.totalActivityMinor,
    required this.totalAvailableMinor,
    required this.totalIncomeMinor,
  });

  /// The yyyymm month.
  final int month;
  final int totalAllocatedMinor;
  final int totalActivityMinor;
  final int totalAvailableMinor;
  final int totalIncomeMinor;

  @override
  List<Object?> get props => [
    month,
    totalAllocatedMinor,
    totalActivityMinor,
    totalAvailableMinor,
    totalIncomeMinor,
  ];
}

class EnvelopeComparison extends Equatable {
  const EnvelopeComparison({required this.envelope, required this.monthData});

  final Envelope envelope;

  /// Keyed by yyyymm int, each entry holds
  /// [allocatedMinor, activityMinor, availableMinor].
  final Map<int, List<int>> monthData;

  @override
  List<Object?> get props => [envelope, monthData];
}

class CategoryComparison extends Equatable {
  const CategoryComparison({
    required this.category,
    required this.envelopes,
    required this.monthTotals,
  });

  final Category category;
  final List<EnvelopeComparison> envelopes;

  /// Keyed by yyyymm int, each entry holds
  /// [allocatedMinor, activityMinor, availableMinor].
  final Map<int, List<int>> monthTotals;

  @override
  List<Object?> get props => [category, envelopes, monthTotals];
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

/// Compares the last [monthCount] months from the server's month views,
/// fetched once for the whole screen.
@riverpod
Future<MultiMonthComparison> multiMonthComparison(
  Ref ref,
  String entityId, {
  int monthCount = 3,
}) async {
  final views = await ref.watch(
    monthFiguresProvider(entityId, MonthKey.fromDate(DateTime.now()), monthCount)
        .future,
  );

  final monthKeys = views.map((view) => view.month).toList();
  final categoryComparisons = <CategoryComparison>[];

  for (final category in views.first.categories) {
    final envelopeComparisons = <EnvelopeComparison>[];
    final catMonthTotals = <int, List<int>>{
      for (final key in monthKeys) key: [0, 0, 0],
    };

    for (final view in views) {
      final monthEnvelopes = view.envelopes
          .where(
            (e) => e.envelope.categoryId == category.id,
          )
          .toList();

      for (final envelopeMonth in monthEnvelopes) {
        final allocated = envelopeMonth.allocatedMinor;
        final activity = envelopeMonth.activityMinor;
        final available = envelopeMonth.availableMinor;

        envelopeComparisons.add(
          EnvelopeComparison(
            envelope: envelopeMonth.envelope,
            monthData: {
              view.month: [allocated, activity, available],
            },
          ),
        );
        final totals = catMonthTotals[view.month]!;
        catMonthTotals[view.month] = [
          totals[0] + allocated,
          totals[1] + activity,
          totals[2] + available,
        ];
      }
    }

    categoryComparisons.add(
      CategoryComparison(
        category: category,
        envelopes: envelopeComparisons,
        monthTotals: catMonthTotals,
      ),
    );
  }

  final monthColumns = views
      .map(
        (view) => MonthColumn(
          month: view.month,
          totalAllocatedMinor: view.summary.allocatedMinor,
          totalActivityMinor: view.summary.activityMinor,
          totalAvailableMinor: view.summary.availableMinor,
          totalIncomeMinor: view.summary.incomeMinor,
        ),
      )
      .toList();

  return MultiMonthComparison(
    currencyCode: views.first.currencyCode,
    months: monthColumns,
    categories: categoryComparisons,
  );
}

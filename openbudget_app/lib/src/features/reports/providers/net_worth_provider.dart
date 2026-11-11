import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'net_worth_provider.g.dart';

/// Combined net worth in the user's reporting currency, straight from
/// `report.netWorth`. No conversion happens in the app: incomplete
/// currencies are listed, never guessed.
@riverpod
Future<NetWorthView> netWorth(Ref ref) async {
  final client = ref.read(serverpodClientProvider);
  return client.report.netWorth();
}

/// Net worth scoped to the included entities only, for the chip filter on
/// the breakdown tab. A changed id set re-queries.
@riverpod
Future<NetWorthView> netWorthForEntities(
  Ref ref,
  Set<String> entityIds,
) async {
  final client = ref.read(serverpodClientProvider);
  return client.report.netWorth(
    entityIds: entityIds.map(UuidValue.fromString).toList(),
  );
}

/// Which granularity backs each history range toggle.
enum NetWorthRange {
  /// Three months of daily points.
  threeMonths(NetWorthGranularity.day),

  /// One year of weekly points.
  oneYear(NetWorthGranularity.week),

  /// Everything, monthly.
  all(NetWorthGranularity.month);

  const NetWorthRange(this.granularity);

  final NetWorthGranularity granularity;
}

/// The history range for the chart, in calendar days per range.
extension NetWorthRangeDates on NetWorthRange {
  ({DateTime from, DateTime to}) dates({DateTime? now}) {
    final today = now ?? DateTime.now();
    final todayDate = DateTime.utc(today.year, today.month, today.day);
    return switch (this) {
      NetWorthRange.threeMonths => (
        from: todayDate.subtract(const Duration(days: 92)),
        to: todayDate,
      ),
      NetWorthRange.oneYear => (
        from: todayDate.subtract(const Duration(days: 366)),
        to: todayDate,
      ),
      NetWorthRange.all => (
        from: DateTime.utc(1900, 1, 1),
        to: todayDate,
      ),
    };
  }
}

/// Net worth history for one range toggle, from `report.netWorthHistory`.
///
/// `all` asks for a bounded window starting at the earliest possible point
/// the server accepts; the server limits and clamps ranges itself.
@riverpod
Future<NetWorthHistoryView> netWorthHistory(
  Ref ref,
  NetWorthRange range,
) async {
  final client = ref.read(serverpodClientProvider);
  final (:from, :to) = range.dates();
  return client.report.netWorthHistory(from, to, range.granularity);
}

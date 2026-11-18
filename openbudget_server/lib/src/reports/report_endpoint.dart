import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:openbudget_server/src/reports/net_worth_service.dart';
import 'package:openbudget_server/src/reports/report_service.dart';
import 'package:serverpod/serverpod.dart';

/// Read-only reporting surface for net worth, the crypto breakdown, spending,
/// month summaries and age of money. Every method requires a signed-in caller and delegates the
/// ownership boundary to its service.
class ReportEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Combined net worth for the caller's entities on one date.
  Future<NetWorthView> netWorth(
    Session session, {
    List<UuidValue>? entityIds,
    String? currencyCode,
    DateTime? asOf,
  }) => NetWorthService.current(
    session,
    entityIds: entityIds,
    currencyCode: currencyCode,
    asOf: asOf,
  );

  /// Net worth at the last day of each period in a range.
  Future<NetWorthHistoryView> netWorthHistory(
    Session session,
    DateTime fromDate,
    DateTime toDate,
    NetWorthGranularity granularity, {
    List<UuidValue>? entityIds,
    String? currencyCode,
  }) => NetWorthService.history(
    session,
    fromDate: fromDate,
    toDate: toDate,
    granularity: granularity,
    entityIds: entityIds,
    currencyCode: currencyCode,
  );

  /// What one owned entity's wallets are worth today, split by chain or by
  /// asset, in the reporting currency. Only counted holdings are summed.
  Future<CryptoBreakdownView> cryptoBreakdown(
    Session session,
    UuidValue entityId,
    CryptoBreakdownGrouping grouping, {
    String? currencyCode,
  }) => NetWorthService.cryptoBreakdown(
    session,
    entityId: entityId,
    grouping: grouping,
    currencyCode: currencyCode,
  );

  /// One group's spending and income over a month range.
  Future<List<SpendingRow>> spending(
    Session session,
    UuidValue entityId,
    int fromMonth,
    int toMonth,
    ReportGrouping grouping,
    // The public contract keeps `byMonth` positional.
    // ignore: avoid_positional_boolean_parameters
    bool byMonth,
  ) => ReportService.spending(
    session,
    entityId,
    fromMonth,
    toMonth,
    grouping,
    byMonth,
  );

  /// The section 6.4 summary for every month from [fromMonth] to [toMonth].
  Future<List<BudgetMonthSummary>> monthSummaries(
    Session session,
    UuidValue entityId,
    int fromMonth,
    int toMonth,
  ) => ReportService.monthSummaries(session, entityId, fromMonth, toMonth);

  /// The mean age in days of the last ten outflows' money, or null.
  Future<int?> ageOfMoney(Session session, UuidValue entityId) =>
      ReportService.ageOfMoney(session, entityId);
}

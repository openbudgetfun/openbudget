import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:openbudget_server/src/reports/net_worth_service.dart';
import 'package:serverpod/serverpod.dart';

/// Read-only reporting surface. This unit exposes net worth only; spending,
/// month summaries and age of money arrive with their own service.
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
}

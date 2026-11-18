import 'dart:async';

import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';

/// One endpoint call the fake client received.
typedef EndpointCall = ({
  String endpoint,
  String method,
  Map<String, dynamic> args,
});

/// A [Client] whose endpoint calls are answered by registered handlers.
///
/// Generated endpoint objects call `callServerEndpoint`, so a handler sees
/// exactly the arguments the app sent and any unregistered call fails the
/// test. No network request is ever made.
class FakeEndpointClient extends Client {
  FakeEndpointClient() : super('http://localhost/');

  final List<EndpointCall> calls = [];
  final Map<String, FutureOr<Object?> Function(Map<String, dynamic> args)>
  _handlers = {};
  final Map<String, Stream<Object?>> _streams = {};

  /// Registers the answer for one endpoint method.
  void handle(
    String endpoint,
    String method,
    FutureOr<Object?> Function(Map<String, dynamic> args) handler,
  ) {
    _handlers['$endpoint.$method'] = handler;
  }

  /// Registers the stream returned by a streaming endpoint method.
  void handleStream(String endpoint, String method, Stream<Object?> stream) {
    _streams['$endpoint.$method'] = stream;
    calls.add((endpoint: endpoint, method: method, args: const {}));
  }

  /// The calls made to one endpoint method.
  List<EndpointCall> callsTo(String endpoint, String method) => [
    for (final call in calls)
      if (call.endpoint == endpoint && call.method == method) call,
  ];

  @override
  Future<T> callServerEndpoint<T>(
    String endpoint,
    String method,
    Map<String, dynamic> args, {
    bool authenticated = true,
  }) async {
    calls.add((endpoint: endpoint, method: method, args: args));
    final handler = _handlers['$endpoint.$method'];
    if (handler == null) {
      throw StateError('Unexpected endpoint call $endpoint.$method');
    }
    return await handler(args) as T;
  }

  @override
  dynamic callStreamingServerEndpoint<T, G>(
    String endpoint,
    String method,
    Map<String, dynamic> args,
    // Matches the superclass signature.
    // ignore: strict_raw_type
    Map<String, Stream> streams, {
    bool authenticated = true,
  }) {
    final stream = _streams['$endpoint.$method'];
    if (stream == null) {
      throw StateError('Unexpected streaming call $endpoint.$method');
    }
    return stream;
  }
}

/// A consistent entity for provider tests.
Entity testEntity({
  String id = '00000000-0000-0000-0000-000000000001',
  String name = 'Household',
  String baseCurrencyCode = 'GBP',
}) => Entity(
  id: UuidValue.fromString(id),
  ownerId: UuidValue.fromString('00000000-0000-0000-0000-0000000000ff'),
  name: name,
  kind: EntityKind.individual,
  countryCode: 'GB',
  baseCurrencyCode: baseCurrencyCode,
  timeZone: 'Europe/London',
  fiscalYearEndMonth: 4,
  fiscalYearEndDay: 6,
);

/// One month summary with only the fields a test cares about set.
BudgetMonthSummary testMonthSummary({
  required int month,
  int incomeMinor = 0,
  int uncategorizedMinor = 0,
  int fxDifferenceMinor = 0,
  int allocatedMinor = 0,
  int activityMinor = 0,
  int overspentLastMonthMinor = 0,
  int assignedInFutureMinor = 0,
  int readyToAssignMinor = 0,
  int availableMinor = 0,
}) => BudgetMonthSummary(
  month: month,
  incomeMinor: incomeMinor,
  uncategorizedMinor: uncategorizedMinor,
  fxDifferenceMinor: fxDifferenceMinor,
  allocatedMinor: allocatedMinor,
  activityMinor: activityMinor,
  overspentLastMonthMinor: overspentLastMonthMinor,
  assignedInFutureMinor: assignedInFutureMinor,
  readyToAssignMinor: readyToAssignMinor,
  availableMinor: availableMinor,
);

/// One spending row with the given group and amounts.
SpendingRow testSpendingRow({
  required String name,
  String? groupId,
  int? month,
  int outflowMinor = 0,
  int inflowMinor = 0,
  int transactionCount = 0,
}) => SpendingRow(
  groupId: groupId == null ? null : UuidValue.fromString(groupId),
  name: name,
  month: month,
  outflowMinor: outflowMinor,
  inflowMinor: inflowMinor,
  transactionCount: transactionCount,
);

/// One envelope in [categoryId].
Envelope testEnvelope({
  required String id,
  required String categoryId,
  required String name,
  int sortOrder = 0,
}) => Envelope(
  id: UuidValue.fromString(id),
  entityId: UuidValue.fromString('00000000-0000-0000-0000-000000000001'),
  categoryId: UuidValue.fromString(categoryId),
  name: name,
  sortOrder: sortOrder,
);

/// One category.
Category testCategory({
  required String id,
  required String name,
  int sortOrder = 0,
}) => Category(
  id: UuidValue.fromString(id),
  entityId: UuidValue.fromString('00000000-0000-0000-0000-000000000001'),
  name: name,
  sortOrder: sortOrder,
);

import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:openbudget_server/src/payees/payee_service.dart';
import 'package:serverpod/serverpod.dart';

/// API surface for payee operations.
///
/// All methods require authentication and delegate to [PayeeService], which
/// owns the entity boundary and publishes committed change events.
class PayeeEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Creates a payee, or reuses the entity's payee with the same name.
  Future<Payee> create(
    Session session,
    String name,
    UuidValue entityId,
  ) => PayeeService.create(session, name: name, entityId: entityId);

  /// Lists every payee of an entity, ordered by name and id.
  Future<List<Payee>> list(Session session, UuidValue entityId) =>
      PayeeService.list(session, entityId: entityId);

  /// Gets a single payee by ID.
  Future<Payee> get(Session session, UuidValue payeeId) =>
      PayeeService.getById(session, payeeId: payeeId);

  /// Renames a payee by ID.
  Future<Payee> update(
    Session session,
    UuidValue payeeId, {
    String? name,
  }) => PayeeService.update(session, payeeId: payeeId, name: name);

  /// Returns the envelope used by the payee's most recent coded transaction.
  Future<UuidValue?> lastUsedEnvelopeId(
    Session session,
    UuidValue payeeId,
    UuidValue entityId,
  ) => PayeeService.lastUsedEnvelopeId(
    session,
    payeeId: payeeId,
    entityId: entityId,
  );

  /// Merges the source payee into the target payee.
  ///
  /// Returns the number of transactions reassigned. The source payee is
  /// deleted after its transactions, recurring schedules and rules move.
  Future<int> merge(
    Session session,
    UuidValue sourcePayeeId,
    UuidValue targetPayeeId,
  ) => PayeeService.merge(
    session,
    sourcePayeeId: sourcePayeeId,
    targetPayeeId: targetPayeeId,
  );

  /// Deletes a payee and clears every reference to it.
  Future<Payee> delete(Session session, UuidValue payeeId) =>
      PayeeService.delete(session, payeeId: payeeId);
}

import 'package:openbudget_server/src/envelopes/envelope_service.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

/// API surface for envelope operations.
///
/// All methods require authentication and delegate to [EnvelopeService],
/// which owns the entity boundary and the reassignment transaction.
class EnvelopeEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Creates an envelope at the end of its category's list.
  Future<Envelope> create(
    Session session,
    UuidValue categoryId,
    String name, {
    String? note,
    String? taxCategoryCode,
  }) => EnvelopeService.create(
    session,
    categoryId: categoryId,
    name: name,
    note: note,
    taxCategoryCode: taxCategoryCode,
  );

  /// Lists every envelope of an entity.
  Future<List<Envelope>> list(Session session, UuidValue entityId) =>
      EnvelopeService.list(session, entityId: entityId);

  /// Loads one envelope by id.
  Future<Envelope> get(Session session, UuidValue envelopeId) =>
      EnvelopeService.getById(session, envelopeId: envelopeId);

  /// Updates one envelope, including nullable clear flags.
  Future<Envelope> update(
    Session session,
    UuidValue envelopeId, {
    String? name,
    UuidValue? categoryId,
    String? note,
    bool? isHidden,
    String? taxCategoryCode,
    bool? clearTaxCategoryCode,
    UuidValue? defaultLedgerAccountId,
    bool? clearDefaultLedgerAccount,
  }) => EnvelopeService.update(
    session,
    envelopeId: envelopeId,
    name: name,
    categoryId: categoryId,
    note: note,
    isHidden: isHidden,
    taxCategoryCode: taxCategoryCode,
    clearTaxCategoryCode: clearTaxCategoryCode,
    defaultLedgerAccountId: defaultLedgerAccountId,
    clearDefaultLedgerAccount: clearDefaultLedgerAccount,
  );

  /// Rewrites one category's envelope order from an exact id list.
  Future<List<Envelope>> reorder(
    Session session,
    UuidValue categoryId,
    List<UuidValue> envelopeIds,
  ) => EnvelopeService.reorder(
    session,
    categoryId: categoryId,
    envelopeIds: envelopeIds,
  );

  /// Deletes an envelope, optionally moving every reference first.
  Future<void> delete(
    Session session,
    UuidValue envelopeId, {
    UuidValue? reassignToEnvelopeId,
  }) => EnvelopeService.delete(
    session,
    envelopeId: envelopeId,
    reassignToEnvelopeId: reassignToEnvelopeId,
  );
}

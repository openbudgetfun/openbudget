import 'package:openbudget_server/src/envelopes/envelope_service.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

/// API surface for envelope operations.
///
/// All methods require authentication.
class EnvelopeEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Creates a new envelope within a category.
  Future<Envelope> create(
    Session session,
    String name,
    UuidValue categoryId,
    int budgetedAmountCents,
    String currencyCode,
  ) async {
    return EnvelopeService.create(
      session,
      name: name,
      categoryId: categoryId,
      budgetedAmountCents: budgetedAmountCents,
      currencyCode: currencyCode,
    );
  }

  /// Lists all envelopes for a category.
  Future<List<Envelope>> list(Session session, UuidValue categoryId) async {
    return EnvelopeService.listForCategory(session, categoryId: categoryId);
  }

  /// Gets a single envelope by ID.
  Future<Envelope> get(Session session, UuidValue envelopeId) async {
    return EnvelopeService.getById(session, envelopeId: envelopeId);
  }

  /// Updates an envelope by ID.
  Future<Envelope> update(
    Session session,
    UuidValue envelopeId, {
    String? name,
    int? budgetedAmountCents,
    int? spentAmountCents,
    String? note,
  }) async {
    return EnvelopeService.update(
      session,
      envelopeId: envelopeId,
      name: name,
      budgetedAmountCents: budgetedAmountCents,
      spentAmountCents: spentAmountCents,
      note: note,
    );
  }

  /// Reorders envelopes within a category.
  Future<List<Envelope>> reorder(
    Session session,
    UuidValue categoryId,
    List<String> envelopeIds,
  ) async {
    return EnvelopeService.reorder(
      session,
      categoryId: categoryId,
      envelopeIds: envelopeIds.map(UuidValue.fromString).toList(),
    );
  }

  /// Deletes an envelope by ID.
  Future<Envelope> delete(Session session, UuidValue envelopeId) async {
    return EnvelopeService.delete(session, envelopeId: envelopeId);
  }
}

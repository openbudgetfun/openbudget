import 'package:openbudget_server/src/budgets/budget_realtime_notifier.dart';
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
    final envelope = await EnvelopeService.create(
      session,
      name: name,
      categoryId: categoryId,
      budgetedAmountCents: budgetedAmountCents,
      currencyCode: currencyCode,
    );
    await BudgetRealtimeNotifier.notifyCategoryChanged(
      session,
      envelope.categoryId,
    );
    return envelope;
  }

  /// Lists all envelopes for a category.
  Future<List<Envelope>> list(Session session, UuidValue categoryId) async =>
      EnvelopeService.listForCategory(session, categoryId: categoryId);

  /// Gets a single envelope by ID.
  Future<Envelope> get(Session session, UuidValue envelopeId) async =>
      EnvelopeService.getById(session, envelopeId: envelopeId);

  /// Updates an envelope by ID.
  Future<Envelope> update(
    Session session,
    UuidValue envelopeId, {
    String? name,
    int? budgetedAmountCents,
    int? spentAmountCents,
    String? note,
    bool? isHidden,
  }) async {
    final envelope = await EnvelopeService.update(
      session,
      envelopeId: envelopeId,
      name: name,
      budgetedAmountCents: budgetedAmountCents,
      spentAmountCents: spentAmountCents,
      note: note,
      isHidden: isHidden,
    );
    await BudgetRealtimeNotifier.notifyCategoryChanged(
      session,
      envelope.categoryId,
    );
    return envelope;
  }

  /// Reorders envelopes within a category.
  Future<List<Envelope>> reorder(
    Session session,
    UuidValue categoryId,
    List<String> envelopeIds,
  ) async {
    final envelopes = await EnvelopeService.reorder(
      session,
      categoryId: categoryId,
      envelopeIds: envelopeIds.map(UuidValue.fromString).toList(),
    );
    await BudgetRealtimeNotifier.notifyCategoryChanged(session, categoryId);
    return envelopes;
  }

  /// Deletes an envelope by ID.
  Future<Envelope> delete(Session session, UuidValue envelopeId) async {
    final envelope = await EnvelopeService.delete(
      session,
      envelopeId: envelopeId,
    );
    await BudgetRealtimeNotifier.notifyCategoryChanged(
      session,
      envelope.categoryId,
    );
    return envelope;
  }
}

import 'package:openbudget_server/src/categories/category_service.dart';
import 'package:openbudget_server/src/exceptions/exceptions.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

/// Business logic for managing envelopes within a category.
///
/// All methods verify category (and thus budget) ownership before operating.
class EnvelopeService {
  /// Creates an envelope within a category, verifying ownership.
  static Future<Envelope> create(
    Session session, {
    required String name,
    required UuidValue categoryId,
    required int budgetedAmountCents,
    required String currencyCode,
  }) async {
    // Verify the user owns the parent category's budget.
    await CategoryService.getById(session, categoryId: categoryId);

    final envelope = Envelope(
      name: name,
      categoryId: categoryId,
      budgetedAmountCents: budgetedAmountCents,
      spentAmountCents: 0,
      currencyCode: currencyCode,
      createdAt: DateTime.now(),
    );
    return Envelope.db.insertRow(session, envelope);
  }

  /// Lists all envelopes for a category, verifying ownership.
  static Future<List<Envelope>> listForCategory(
    Session session, {
    required UuidValue categoryId,
  }) async {
    await CategoryService.getById(session, categoryId: categoryId);

    return Envelope.db.find(
      session,
      where: (t) => t.categoryId.equals(categoryId),
    );
  }

  /// Fetches a single envelope, verifying ownership.
  static Future<Envelope> getById(
    Session session, {
    required UuidValue envelopeId,
  }) async {
    final envelope = await Envelope.db.findById(session, envelopeId);
    if (envelope == null) {
      throw NotFoundException('Envelope not found');
    }

    // Verify the user owns the parent category's budget.
    await CategoryService.getById(session, categoryId: envelope.categoryId);
    return envelope;
  }

  /// Updates an envelope, verifying ownership.
  static Future<Envelope> update(
    Session session, {
    required UuidValue envelopeId,
    String? name,
    int? budgetedAmountCents,
    int? spentAmountCents,
  }) async {
    final envelope = await getById(session, envelopeId: envelopeId);

    final updated = envelope.copyWith(
      name: name ?? envelope.name,
      budgetedAmountCents: budgetedAmountCents ?? envelope.budgetedAmountCents,
      spentAmountCents: spentAmountCents ?? envelope.spentAmountCents,
    );
    return Envelope.db.updateRow(session, updated);
  }

  /// Deletes an envelope, verifying ownership.
  static Future<Envelope> delete(
    Session session, {
    required UuidValue envelopeId,
  }) async {
    final envelope = await getById(session, envelopeId: envelopeId);
    return Envelope.db.deleteRow(session, envelope);
  }
}

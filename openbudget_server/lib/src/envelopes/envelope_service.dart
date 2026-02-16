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
    int? sortOrder,
  }) async {
    // Verify the user owns the parent category's budget.
    await CategoryService.getById(session, categoryId: categoryId);

    // Auto-assign sort order if not provided.
    final order =
        sortOrder ?? await _nextSortOrder(session, categoryId: categoryId);

    final envelope = Envelope(
      name: name,
      categoryId: categoryId,
      budgetedAmountCents: budgetedAmountCents,
      spentAmountCents: 0,
      currencyCode: currencyCode,
      sortOrder: order,
      createdAt: DateTime.now(),
    );
    return Envelope.db.insertRow(session, envelope);
  }

  /// Lists all envelopes for a category, ordered by sortOrder.
  static Future<List<Envelope>> listForCategory(
    Session session, {
    required UuidValue categoryId,
  }) async {
    await CategoryService.getById(session, categoryId: categoryId);

    return Envelope.db.find(
      session,
      where: (t) => t.categoryId.equals(categoryId),
      orderBy: (t) => t.sortOrder,
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
    String? note,
  }) async {
    final envelope = await getById(session, envelopeId: envelopeId);

    final updated = envelope.copyWith(
      name: name ?? envelope.name,
      budgetedAmountCents: budgetedAmountCents ?? envelope.budgetedAmountCents,
      spentAmountCents: spentAmountCents ?? envelope.spentAmountCents,
      note: note ?? envelope.note,
    );
    return Envelope.db.updateRow(session, updated);
  }

  /// Batch-updates sort order for envelopes within a category.
  static Future<List<Envelope>> reorder(
    Session session, {
    required UuidValue categoryId,
    required List<UuidValue> envelopeIds,
  }) async {
    await CategoryService.getById(session, categoryId: categoryId);

    final results = <Envelope>[];
    for (var i = 0; i < envelopeIds.length; i++) {
      final envelope = await Envelope.db.findById(session, envelopeIds[i]);
      if (envelope == null) continue;
      final updated = envelope.copyWith(sortOrder: i);
      results.add(await Envelope.db.updateRow(session, updated));
    }
    return results;
  }

  /// Deletes an envelope, verifying ownership.
  static Future<Envelope> delete(
    Session session, {
    required UuidValue envelopeId,
  }) async {
    final envelope = await getById(session, envelopeId: envelopeId);
    return Envelope.db.deleteRow(session, envelope);
  }

  /// Returns the next available sort order for a category.
  static Future<int> _nextSortOrder(
    Session session, {
    required UuidValue categoryId,
  }) async {
    final existing = await Envelope.db.find(
      session,
      where: (t) => t.categoryId.equals(categoryId),
      orderBy: (t) => t.sortOrder,
      orderDescending: true,
      limit: 1,
    );
    return existing.isEmpty ? 0 : existing.first.sortOrder + 1;
  }
}

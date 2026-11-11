import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/entities/entity_access.dart';
import 'package:openbudget_server/src/entities/entity_realtime_notifier.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/tax/tax_catalogue_validation.dart';
import 'package:openbudget_server/src/transactions/transaction_writer.dart';
import 'package:serverpod/serverpod.dart';

/// Owns envelope lifecycle within one entity's envelope plan.
///
/// Every read and write crosses [EntityAccess]. Lines move only through
/// [TransactionWriter], so reconciliation, period locks, stored FX amounts,
/// balances, revisions and audits keep their rules. Plan references move in
/// the same database transaction as the envelope row.
abstract final class EnvelopeService {
  static final _log = ObLogger('EnvelopeService');

  /// Creates an envelope at the end of its category's list.
  static Future<Envelope> create(
    Session session, {
    required UuidValue categoryId,
    required String name,
    String? note,
    String? taxCategoryCode,
  }) async {
    final envelopeName = _requireName(name);
    final envelopeNote = _normaliseNote(note);
    final taxCode = TaxCatalogueValidation.normalise(taxCategoryCode);

    _log.info('Creating envelope name=$envelopeName category=$categoryId');

    final envelope = await session.db.transaction((tx) async {
      final discovered = await Category.db.findById(
        session,
        categoryId,
        transaction: tx,
      );
      if (discovered == null) {
        throw NotFoundException(message: 'Category not found');
      }

      final entity = _requireWritable(
        await EntityAccess.requireOwned(
          session,
          discovered.entityId,
          transaction: tx,
          lock: true,
        ),
      );
      final category = await _lockCategories(session, {categoryId}, tx);
      if (category[categoryId]!.entityId != entity.id) {
        throw ValidationException(
          message: 'The category changed concurrently; retry the create',
        );
      }

      TaxCatalogueValidation.requireCode(entity, taxCode);
      final sortOrder = await _nextSortOrder(session, categoryId, tx);

      return Envelope.db.insertRow(
        session,
        Envelope(
          entityId: entity.id!,
          categoryId: categoryId,
          name: envelopeName,
          note: envelopeNote,
          taxCategoryCode: taxCode,
          sortOrder: sortOrder,
        ),
        transaction: tx,
      );
    });

    await _notify(session, envelope.entityId);
    return envelope;
  }

  /// Lists every envelope of an entity, category order first, then position.
  static Future<List<Envelope>> list(
    Session session, {
    required UuidValue entityId,
  }) async {
    await EntityAccess.requireOwned(session, entityId);

    final categories = await Category.db.find(
      session,
      where: (t) => t.entityId.equals(entityId),
      orderByList: (t) => [t.sortOrder, t.id],
    );
    final envelopes = await Envelope.db.find(
      session,
      where: (t) => t.entityId.equals(entityId),
      orderByList: (t) => [t.sortOrder, t.id],
    );

    final byCategory = <UuidValue, List<Envelope>>{};
    for (final envelope in envelopes) {
      byCategory.putIfAbsent(envelope.categoryId, () => []).add(envelope);
    }

    final ordered = <Envelope>[];
    for (final category in categories) {
      ordered.addAll(byCategory.remove(category.id) ?? const []);
    }
    byCategory.values.forEach(ordered.addAll);

    return ordered;
  }

  /// Loads one envelope after checking that the caller owns its entity.
  static Future<Envelope> getById(
    Session session, {
    required UuidValue envelopeId,
  }) async {
    final envelope = await Envelope.db.findById(session, envelopeId);
    if (envelope == null) {
      throw NotFoundException(message: 'Envelope not found');
    }

    await EntityAccess.requireOwned(session, envelope.entityId);
    return envelope;
  }

  /// Renames, recategorises, hides or recodes one envelope.
  ///
  /// A null [note] leaves the stored note unchanged; an empty or whitespace
  /// note clears it. The explicit clear flags clear their nullable reference
  /// and cannot be combined with a value in the same call.
  static Future<Envelope> update(
    Session session, {
    required UuidValue envelopeId,
    String? name,
    UuidValue? categoryId,
    String? note,
    bool? isHidden,
    String? taxCategoryCode,
    bool? clearTaxCategoryCode,
    UuidValue? defaultLedgerAccountId,
    bool? clearDefaultLedgerAccount,
  }) async {
    final clearTaxCode = clearTaxCategoryCode ?? false;
    final clearLedgerDefault = clearDefaultLedgerAccount ?? false;
    final taxCode = TaxCatalogueValidation.normalise(taxCategoryCode);

    if (clearTaxCode && taxCode != null) {
      throw ValidationException(
        message: 'clearTaxCategoryCode cannot be combined with taxCategoryCode',
      );
    }
    if (clearLedgerDefault && defaultLedgerAccountId != null) {
      throw ValidationException(
        message:
            'clearDefaultLedgerAccount cannot be combined with '
            'defaultLedgerAccountId',
      );
    }

    _log.info('Updating envelope id=$envelopeId');

    final updated = await session.db.transaction((tx) async {
      final discovered = await Envelope.db.findById(
        session,
        envelopeId,
        transaction: tx,
      );
      if (discovered == null) {
        throw NotFoundException(message: 'Envelope not found');
      }

      final entity = _requireWritable(
        await EntityAccess.requireOwned(
          session,
          discovered.entityId,
          transaction: tx,
          lock: true,
        ),
      );

      // Read the current row after the entity lock, so an update that won the
      // race cannot make us move the envelope back to a stale category.
      final current = await Envelope.db.findById(
        session,
        envelopeId,
        transaction: tx,
      );
      if (current == null) {
        throw NotFoundException(message: 'Envelope not found');
      }
      if (current.entityId != entity.id) {
        throw ValidationException(
          message: 'The envelope changed concurrently; retry the update',
        );
      }

      final currentCategoryId = current.categoryId;
      final targetCategoryId = categoryId ?? currentCategoryId;
      final categories = await _lockCategories(session, {
        currentCategoryId,
        targetCategoryId,
      }, tx);
      if (categories.values.any((category) => category.entityId != entity.id)) {
        throw ForbiddenException(
          message: 'Envelope category belongs to another entity',
        );
      }

      final envelope = await Envelope.db.findById(
        session,
        envelopeId,
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );
      if (envelope == null) {
        throw NotFoundException(message: 'Envelope not found');
      }
      if (envelope.entityId != discovered.entityId ||
          envelope.categoryId != currentCategoryId) {
        throw ValidationException(
          message: 'The envelope changed concurrently; retry the update',
        );
      }

      if (!clearTaxCode && taxCode != null) {
        TaxCatalogueValidation.requireCode(entity, taxCode);
      }
      if (!clearLedgerDefault && defaultLedgerAccountId != null) {
        await _requireLedgerDefault(
          session,
          entity,
          defaultLedgerAccountId,
          tx,
        );
      }

      final categoryChanged = targetCategoryId != envelope.categoryId;
      final sortOrder = categoryChanged
          ? await _nextSortOrder(session, targetCategoryId, tx)
          : envelope.sortOrder;

      var row = envelope.copyWith(
        name: name == null ? null : _requireName(name),
        categoryId: targetCategoryId,
        sortOrder: sortOrder,
        isHidden: isHidden,
        updatedAt: _now(),
      );

      if (note != null) {
        row = row.copyWith(note: _normaliseNote(note));
      }
      if (taxCode != null || clearTaxCode) {
        row = row.copyWith(taxCategoryCode: taxCode);
      }
      if (defaultLedgerAccountId != null || clearLedgerDefault) {
        row = row.copyWith(defaultLedgerAccountId: defaultLedgerAccountId);
      }

      return Envelope.db.updateRow(session, row, transaction: tx);
    });

    await _notify(session, updated.entityId);
    return updated;
  }

  /// Rewrites one category's envelope order from an exact list of its ids.
  static Future<List<Envelope>> reorder(
    Session session, {
    required UuidValue categoryId,
    required List<UuidValue> envelopeIds,
  }) async {
    _requireNoDuplicates(envelopeIds);

    final result = await session.db.transaction((tx) async {
      final discovered = await Category.db.findById(
        session,
        categoryId,
        transaction: tx,
      );
      if (discovered == null) {
        throw NotFoundException(message: 'Category not found');
      }

      _requireWritable(
        await EntityAccess.requireOwned(
          session,
          discovered.entityId,
          transaction: tx,
          lock: true,
        ),
      );
      final category = await _lockCategories(session, {categoryId}, tx);

      final owned = await Envelope.db.find(
        session,
        where: (t) => t.categoryId.equals(categoryId),
        orderByList: (t) => [t.id],
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );
      _requireExactSet(envelopeIds, owned);
      if (owned.any((row) => row.entityId != category[categoryId]!.entityId)) {
        throw ValidationException(
          message: 'An envelope in this category belongs to another entity',
        );
      }

      final byId = {
        for (final envelope in owned) _requireId(envelope): envelope,
      };
      final now = _now();
      final updated = <Envelope>[];

      for (var index = 0; index < envelopeIds.length; index++) {
        updated.add(
          await Envelope.db.updateRow(
            session,
            byId[envelopeIds[index]]!.copyWith(
              sortOrder: index,
              updatedAt: now,
            ),
            transaction: tx,
          ),
        );
      }

      return (entityId: discovered.entityId, envelopes: updated);
    });

    await _notify(session, result.entityId);
    return result.envelopes;
  }

  /// Deletes an envelope, optionally moving every reference first.
  ///
  /// Reassigning moves transaction lines through [TransactionWriter], merges
  /// monthly allocations by exact sum, keeps one identical goal, resolves
  /// payee rules, updates recurring schedules and merges template lines. A
  /// reconciled or period-locked line, or a conflicting goal or rule, rejects
  /// the whole delete with a validation error and no partial move.
  static Future<void> delete(
    Session session, {
    required UuidValue envelopeId,
    UuidValue? reassignToEnvelopeId,
  }) async {
    _log.info(
      'Deleting envelope id=$envelopeId reassign=$reassignToEnvelopeId',
    );

    final outcome = await TransactionWriter.inTransaction(session, (tx) async {
      final discovered = await Envelope.db.findById(
        session,
        envelopeId,
        transaction: tx,
      );
      if (discovered == null) {
        throw NotFoundException(message: 'Envelope not found');
      }

      final entity = _requireWritable(
        await EntityAccess.requireOwned(
          session,
          discovered.entityId,
          transaction: tx,
          lock: true,
        ),
      );
      final destination = await _resolveDestination(
        session,
        entity,
        envelopeId,
        reassignToEnvelopeId,
        tx,
      );

      // Accounts first, before catalogue or transaction rows. Transaction
      // writers take their account lock before touching an envelope, so this
      // order keeps both paths from waiting on each other.
      final lockedAccountIds = destination == null
          ? null
          : await TransactionWriter.lockEnvelopeLineAccounts(
              session,
              entityId: entity.id!,
              envelopeId: envelopeId,
              transaction: tx,
            );

      final categories = await _lockCategories(session, {
        discovered.categoryId,
        if (destination != null) destination.categoryId,
      }, tx);
      if (categories.values.any((category) => category.entityId != entity.id)) {
        throw ForbiddenException(
          message: 'Envelope category belongs to another entity',
        );
      }

      final locked = await _lockEnvelopes(session, {
        envelopeId,
        if (destination != null) _requireId(destination),
      }, tx);
      final source = locked[envelopeId]!;
      final destinationEnvelope = destination == null
          ? null
          : locked[destination.id]!;

      final lineCount = await TransactionLine.db.count(
        session,
        where: (t) => t.envelopeId.equals(envelopeId),
        transaction: tx,
      );
      if (lineCount > 0 && destinationEnvelope == null) {
        throw ValidationException(
          message:
              'An envelope used by transaction lines needs '
              'reassignToEnvelopeId',
        );
      }

      final affectedMonths = <int>{};

      if (destinationEnvelope != null) {
        await TransactionWriter.reassignEnvelopeLines(
          session,
          fromEnvelopeId: envelopeId,
          toEnvelopeId: _requireId(destinationEnvelope),
          transaction: tx,
          lockedAccountIds: lockedAccountIds,
        );
        affectedMonths.addAll(
          await _moveAllocations(
            session,
            source: source,
            destination: destinationEnvelope,
            transaction: tx,
          ),
        );
        await _moveGoal(
          session,
          source: source,
          destination: destinationEnvelope,
          transaction: tx,
        );
        await _moveRules(
          session,
          source: source,
          destination: destinationEnvelope,
          transaction: tx,
        );
        await _moveRecurringTransactions(
          session,
          source: source,
          destination: destinationEnvelope,
          transaction: tx,
        );
        await _moveTemplateLines(
          session,
          source: source,
          destination: destinationEnvelope,
          transaction: tx,
        );
      }

      await Envelope.db.deleteRow(session, source, transaction: tx);

      return (entityId: entity.id!, months: affectedMonths);
    });

    await _notify(session, outcome.entityId);

    final months = outcome.months.toList()..sort();
    for (final month in months) {
      await _notify(session, outcome.entityId, month: month);
    }
  }

  static Future<Envelope?> _resolveDestination(
    Session session,
    Entity entity,
    UuidValue envelopeId,
    UuidValue? reassignToEnvelopeId,
    Transaction transaction,
  ) async {
    if (reassignToEnvelopeId == null) return null;
    if (reassignToEnvelopeId == envelopeId) {
      throw ValidationException(
        message: 'An envelope cannot be reassigned to itself',
      );
    }

    final destination = await Envelope.db.findById(
      session,
      reassignToEnvelopeId,
      transaction: transaction,
    );
    if (destination == null) {
      throw NotFoundException(message: 'Destination envelope not found');
    }
    if (destination.entityId != entity.id) {
      throw ForbiddenException(
        message: 'Destination envelope belongs to another entity',
      );
    }

    return destination;
  }

  /// Merges the source envelope's monthly allocations into the destination.
  ///
  /// A month on both envelopes is added by exact checked sum; a zero total
  /// deletes the destination row because the table never stores zero. A month
  /// only on the source moves its row. Returns the affected months so the
  /// caller can publish their events after commit.
  static Future<Set<int>> _moveAllocations(
    Session session, {
    required Envelope source,
    required Envelope destination,
    required Transaction transaction,
  }) async {
    final rows = await MonthlyAllocation.db.find(
      session,
      where: (t) =>
          t.envelopeId.inSet({_requireId(source), _requireId(destination)}),
      orderByList: (t) => [t.envelopeId, t.month],
      transaction: transaction,
      lockMode: LockMode.forUpdate,
    );
    for (final row in rows) {
      if (row.entityId != source.entityId) {
        throw ValidationException(
          message: 'A monthly allocation belongs to another entity',
        );
      }
    }

    final sourceRows = rows
        .where((row) => row.envelopeId == source.id)
        .toList();
    final destinationByMonth = {
      for (final row in rows)
        if (row.envelopeId == destination.id) row.month: row,
    };

    final now = _now();
    final affected = <int>{};

    for (final sourceRow in sourceRows) {
      final destinationRow = destinationByMonth[sourceRow.month];

      if (destinationRow == null) {
        if (sourceRow.allocatedMinor == 0) {
          await MonthlyAllocation.db.deleteRow(
            session,
            sourceRow,
            transaction: transaction,
          );
          continue;
        }

        await MonthlyAllocation.db.updateRow(
          session,
          sourceRow.copyWith(
            envelopeId: _requireId(destination),
            updatedAt: now,
          ),
          transaction: transaction,
        );
        affected.add(sourceRow.month);
        continue;
      }

      final sum = _checkedAdd(
        sourceRow.allocatedMinor,
        destinationRow.allocatedMinor,
        context: 'Monthly allocation for month ${sourceRow.month}',
      );

      if (sum == 0) {
        await MonthlyAllocation.db.deleteRow(
          session,
          destinationRow,
          transaction: transaction,
        );
      } else {
        await MonthlyAllocation.db.updateRow(
          session,
          destinationRow.copyWith(allocatedMinor: sum, updatedAt: now),
          transaction: transaction,
        );
      }
      await MonthlyAllocation.db.deleteRow(
        session,
        sourceRow,
        transaction: transaction,
      );
      affected.add(sourceRow.month);
    }

    return affected;
  }

  /// Keeps the destination goal, or rejects two different goals.
  static Future<void> _moveGoal(
    Session session, {
    required Envelope source,
    required Envelope destination,
    required Transaction transaction,
  }) async {
    final goals = await EnvelopeGoal.db.find(
      session,
      where: (t) =>
          t.envelopeId.inSet({_requireId(source), _requireId(destination)}),
      orderByList: (t) => [t.envelopeId, t.id],
      transaction: transaction,
      lockMode: LockMode.forUpdate,
    );
    for (final goal in goals) {
      if (goal.entityId != source.entityId) {
        throw ValidationException(
          message: 'An envelope goal belongs to another entity',
        );
      }
    }

    final sourceGoals = goals
        .where((goal) => goal.envelopeId == source.id)
        .toList();
    if (sourceGoals.isEmpty) return;
    final sourceGoal = sourceGoals.first;

    final destinationGoals = goals
        .where((goal) => goal.envelopeId == destination.id)
        .toList();
    final destinationGoal = destinationGoals.isEmpty
        ? null
        : destinationGoals.first;

    if (destinationGoal == null) {
      await EnvelopeGoal.db.updateRow(
        session,
        sourceGoal.copyWith(
          envelopeId: _requireId(destination),
          updatedAt: _now(),
        ),
        transaction: transaction,
      );
      return;
    }

    final identical =
        destinationGoal.kind == sourceGoal.kind &&
        destinationGoal.amountMinor == sourceGoal.amountMinor &&
        destinationGoal.targetDate == sourceGoal.targetDate;
    if (!identical) {
      throw ValidationException(
        message:
            'The destination envelope already has a different goal; remove '
            'one goal before reassigning',
      );
    }

    await EnvelopeGoal.db.deleteRow(
      session,
      sourceGoal,
      transaction: transaction,
    );
  }

  /// Moves payee rules, dropping an exact duplicate on the destination.
  ///
  /// A rule that differs only by `enabled` is rejected rather than silently
  /// changing when a payee starts filling an envelope.
  static Future<void> _moveRules(
    Session session, {
    required Envelope source,
    required Envelope destination,
    required Transaction transaction,
  }) async {
    final sourceRules = await TransactionRule.db.find(
      session,
      where: (t) => t.envelopeId.equals(_requireId(source)),
      orderByList: (t) => [t.payeeId, t.id],
      transaction: transaction,
      lockMode: LockMode.forUpdate,
    );
    if (sourceRules.isEmpty) return;

    for (final rule in sourceRules) {
      if (rule.entityId != source.entityId) {
        throw ValidationException(
          message: 'A transaction rule belongs to another entity',
        );
      }
    }

    final destinationRules = await TransactionRule.db.find(
      session,
      where: (t) =>
          t.envelopeId.equals(_requireId(destination)) &
          t.payeeId.inSet({for (final rule in sourceRules) rule.payeeId}),
      orderByList: (t) => [t.payeeId, t.id],
      transaction: transaction,
      lockMode: LockMode.forUpdate,
    );
    for (final rule in destinationRules) {
      if (rule.entityId != source.entityId) {
        throw ValidationException(
          message: 'A transaction rule belongs to another entity',
        );
      }
    }

    final destinationByPayee = {
      for (final rule in destinationRules) rule.payeeId: rule,
    };

    for (final rule in sourceRules) {
      final existing = destinationByPayee[rule.payeeId];
      if (existing == null) {
        await TransactionRule.db.updateRow(
          session,
          rule.copyWith(envelopeId: _requireId(destination)),
          transaction: transaction,
        );
        continue;
      }

      if (existing.enabled != rule.enabled) {
        throw ValidationException(
          message:
              'The destination envelope already has a rule for this payee '
              'with a different enabled state',
        );
      }

      await TransactionRule.db.deleteRow(
        session,
        rule,
        transaction: transaction,
      );
    }
  }

  static Future<void> _moveRecurringTransactions(
    Session session, {
    required Envelope source,
    required Envelope destination,
    required Transaction transaction,
  }) async {
    final rows = await RecurringTransaction.db.find(
      session,
      where: (t) => t.envelopeId.equals(_requireId(source)),
      orderByList: (t) => [t.id],
      transaction: transaction,
      lockMode: LockMode.forUpdate,
    );
    final now = _now();

    for (final row in rows) {
      if (row.entityId != source.entityId) {
        throw ValidationException(
          message: 'A recurring transaction belongs to another entity',
        );
      }

      await RecurringTransaction.db.updateRow(
        session,
        row.copyWith(envelopeId: _requireId(destination), updatedAt: now),
        transaction: transaction,
      );
    }
  }

  /// Merges template lines by exact sum so deleting an envelope never drops a
  /// saved plan amount through the line's cascade.
  static Future<void> _moveTemplateLines(
    Session session, {
    required Envelope source,
    required Envelope destination,
    required Transaction transaction,
  }) async {
    final sourceLines = await BudgetTemplateLine.db.find(
      session,
      where: (t) => t.envelopeId.equals(_requireId(source)),
      orderByList: (t) => [t.templateId, t.id],
      transaction: transaction,
      lockMode: LockMode.forUpdate,
    );
    if (sourceLines.isEmpty) return;

    final templateIds = {for (final line in sourceLines) line.templateId};
    final templates = await BudgetTemplate.db.find(
      session,
      where: (t) => t.id.inSet(templateIds),
      orderByList: (t) => [t.id],
      transaction: transaction,
    );
    if (templates.length != templateIds.length ||
        templates.any((template) => template.entityId != source.entityId)) {
      throw ValidationException(
        message: 'A budget template belongs to another entity',
      );
    }

    final destinationLines = await BudgetTemplateLine.db.find(
      session,
      where: (t) =>
          t.envelopeId.equals(_requireId(destination)) &
          t.templateId.inSet(templateIds),
      orderByList: (t) => [t.templateId, t.id],
      transaction: transaction,
      lockMode: LockMode.forUpdate,
    );
    final destinationByTemplate = {
      for (final line in destinationLines) line.templateId: line,
    };

    for (final sourceLine in sourceLines) {
      final destinationLine = destinationByTemplate[sourceLine.templateId];
      if (destinationLine == null) {
        await BudgetTemplateLine.db.updateRow(
          session,
          sourceLine.copyWith(envelopeId: _requireId(destination)),
          transaction: transaction,
        );
        continue;
      }

      final sum = _checkedAdd(
        sourceLine.allocatedMinor,
        destinationLine.allocatedMinor,
        context: 'Budget template line',
      );
      await BudgetTemplateLine.db.updateRow(
        session,
        destinationLine.copyWith(allocatedMinor: sum),
        transaction: transaction,
      );
      await BudgetTemplateLine.db.deleteRow(
        session,
        sourceLine,
        transaction: transaction,
      );
    }
  }

  static Future<Map<UuidValue, Category>> _lockCategories(
    Session session,
    Set<UuidValue> ids,
    Transaction transaction,
  ) async {
    final ordered = ids.toList()..sort((a, b) => a.uuid.compareTo(b.uuid));
    final categories = <UuidValue, Category>{};

    for (final id in ordered) {
      final category = await Category.db.findById(
        session,
        id,
        transaction: transaction,
        lockMode: LockMode.forUpdate,
      );
      if (category == null) {
        throw NotFoundException(message: 'Category not found');
      }
      categories[id] = category;
    }

    return categories;
  }

  static Future<Map<UuidValue, Envelope>> _lockEnvelopes(
    Session session,
    Set<UuidValue> ids,
    Transaction transaction,
  ) async {
    final ordered = ids.toList()..sort((a, b) => a.uuid.compareTo(b.uuid));
    final envelopes = <UuidValue, Envelope>{};

    for (final id in ordered) {
      final envelope = await Envelope.db.findById(
        session,
        id,
        transaction: transaction,
        lockMode: LockMode.forUpdate,
      );
      if (envelope == null) {
        throw NotFoundException(message: 'Envelope not found');
      }
      envelopes[id] = envelope;
    }

    return envelopes;
  }

  static Future<void> _requireLedgerDefault(
    Session session,
    Entity entity,
    UuidValue ledgerAccountId,
    Transaction transaction,
  ) async {
    final account = await LedgerAccount.db.findById(
      session,
      ledgerAccountId,
      transaction: transaction,
    );
    if (account == null) {
      throw NotFoundException(message: 'Ledger account not found');
    }
    if (account.entityId != entity.id) {
      throw ForbiddenException(
        message: 'Ledger account belongs to another entity',
      );
    }
    if (account.archivedAt != null) {
      throw ValidationException(
        message: 'An archived ledger account cannot be an envelope default',
      );
    }
    if (account.systemRole == LedgerSystemRole.bank ||
        account.systemRole == LedgerSystemRole.bankClearing) {
      throw ValidationException(
        message: 'A bank account cannot be an envelope default',
      );
    }
  }

  static Future<int> _nextSortOrder(
    Session session,
    UuidValue categoryId,
    Transaction transaction,
  ) async {
    final last = await Envelope.db.findFirstRow(
      session,
      where: (t) => t.categoryId.equals(categoryId),
      orderBy: (t) => t.sortOrder.desc(),
      transaction: transaction,
    );

    return (last?.sortOrder ?? -1) + 1;
  }

  static String _requireName(String raw) {
    final name = raw.trim();
    if (name.isEmpty) {
      throw ValidationException(message: 'Name is required');
    }

    return name;
  }

  static UuidValue _requireId(Envelope envelope) {
    final id = envelope.id;
    if (id == null) {
      throw StateError('A persisted envelope has no id');
    }

    return id;
  }

  static String? _normaliseNote(String? raw) {
    final note = raw?.trim();
    return note == null || note.isEmpty ? null : note;
  }

  static int _checkedAdd(
    int first,
    int second, {
    required String context,
  }) {
    final sum = BigInt.from(first) + BigInt.from(second);
    if (sum.abs() > BigInt.from(maxSafeMinor)) {
      throw ValidationException(
        message: '$context exceeds the safe minor-unit range',
      );
    }

    return sum.toInt();
  }

  static void _requireNoDuplicates(List<UuidValue> envelopeIds) {
    if (envelopeIds.toSet().length != envelopeIds.length) {
      throw ValidationException(
        message: 'reorder rejects duplicate envelope ids',
      );
    }
  }

  static void _requireExactSet(
    List<UuidValue> requested,
    List<Envelope> owned,
  ) {
    final requestedSet = requested.toSet();
    final ownedSet = {for (final envelope in owned) _requireId(envelope)};

    if (requestedSet.length != ownedSet.length ||
        !requestedSet.containsAll(ownedSet)) {
      throw ValidationException(
        message: 'reorder needs every envelope of the category exactly once',
      );
    }
  }

  static Entity _requireWritable(Entity entity) {
    if (entity.archivedAt != null) {
      throw ValidationException(
        message: 'An archived entity rejects envelope changes',
      );
    }

    return entity;
  }

  static DateTime _now() => DateTime.now().toUtc();

  static Future<void> _notify(
    Session session,
    UuidValue entityId, {
    int? month,
  }) => EntityRealtimeNotifier.notify(
    session,
    entityId,
    ChangeScope.plan,
    month: month,
  );
}

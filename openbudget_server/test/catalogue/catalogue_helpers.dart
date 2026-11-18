import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/entities/entity_realtime_notifier.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/transactions/transaction_writer.dart';
import 'package:serverpod/serverpod.dart';

import '../support/budget_test_book.dart';

/// One recorded committed event.
class EventLog {
  final List<EntityChangedEvent> events = [];

  /// Records one event without opening a message-bus connection.
  Future<void> record(
    Session session,
    UuidValue entityId,
    ChangeScope scope, {
    int? month,
    UuidValue? accountId,
  }) async {
    events.add(
      EntityChangedEvent(
        entityId: entityId,
        scope: scope,
        month: month,
        accountId: accountId,
      ),
    );
  }

  /// Months carried by plan events, in publication order.
  List<int?> get planMonths => [
    for (final event in events)
      if (event.scope == ChangeScope.plan) event.month,
  ];

  /// Installs this log as both the catalogue and writer publisher.
  void install() {
    EntityRealtimeNotifier.debugPublisher = record;
    TransactionWriter.debugPublisher = record;
  }

  /// Restores the production publishers.
  void reset() {
    EntityRealtimeNotifier.resetForTests();
    TransactionWriter.resetForTests();
  }
}

/// Catalogue rows that [BudgetTestBook] does not create by default.
extension CatalogueBook on BudgetTestBook {
  /// Inserts a category in this book's entity.
  Future<Category> addCategory({
    String name = 'Everyday',
    int sortOrder = 0,
    bool isHidden = false,
    Entity? entity,
  }) {
    final owner = entity ?? this.entity;
    return Category.db.insertRow(
      session,
      Category(
        entityId: owner.id!,
        name: name,
        sortOrder: sortOrder,
        isHidden: isHidden,
      ),
    );
  }

  /// Inserts an envelope in [category].
  Future<Envelope> addEnvelopeIn(
    Category category, {
    String name = 'Groceries',
    int sortOrder = 0,
    bool isHidden = false,
    String? note,
    String? taxCategoryCode,
    UuidValue? defaultLedgerAccountId,
  }) => Envelope.db.insertRow(
    session,
    Envelope(
      entityId: category.entityId,
      categoryId: category.id!,
      name: name,
      sortOrder: sortOrder,
      isHidden: isHidden,
      note: note,
      taxCategoryCode: taxCategoryCode,
      defaultLedgerAccountId: defaultLedgerAccountId,
    ),
  );

  /// Inserts a monthly allocation for [envelope].
  Future<MonthlyAllocation> addAllocation(
    Envelope envelope, {
    required int month,
    required int allocatedMinor,
  }) => MonthlyAllocation.db.insertRow(
    session,
    MonthlyAllocation(
      entityId: envelope.entityId,
      envelopeId: envelope.id!,
      month: month,
      allocatedMinor: allocatedMinor,
    ),
  );

  /// Inserts a goal for [envelope].
  Future<EnvelopeGoal> addGoal(
    Envelope envelope, {
    EnvelopeGoalKind kind = EnvelopeGoalKind.monthlyFunding,
    int amountMinor = 1000,
    DateTime? targetDate,
  }) => EnvelopeGoal.db.insertRow(
    session,
    EnvelopeGoal(
      entityId: envelope.entityId,
      envelopeId: envelope.id!,
      kind: kind,
      amountMinor: amountMinor,
      targetDate: targetDate,
    ),
  );

  /// Inserts a recurring transaction that codes to [envelope].
  Future<RecurringTransaction> addRecurring(
    Envelope envelope, {
    required Account account,
    String description = 'Rent',
    int amountMinor = -1000,
    DateTime? nextDate,
  }) => RecurringTransaction.db.insertRow(
    session,
    RecurringTransaction(
      entityId: envelope.entityId,
      accountId: account.id!,
      envelopeId: envelope.id,
      description: description,
      amountMinor: amountMinor,
      frequency: RecurrenceFrequency.monthly,
      nextDate: nextDate ?? DateTime.utc(2026, 12),
    ),
  );

  /// Inserts an empty budget template in this book's entity.
  Future<BudgetTemplate> addTemplate({String name = 'Standard month'}) =>
      BudgetTemplate.db.insertRow(
        session,
        BudgetTemplate(entityId: entity.id!, name: name),
      );

  /// Inserts one line in [template].
  Future<BudgetTemplateLine> addTemplateLine(
    BudgetTemplate template,
    Envelope envelope, {
    required int allocatedMinor,
  }) => BudgetTemplateLine.db.insertRow(
    session,
    BudgetTemplateLine(
      templateId: template.id!,
      envelopeId: envelope.id!,
      allocatedMinor: allocatedMinor,
    ),
  );
}

import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'entity_summary_provider.g.dart';

/// One entity's headline figures for the home screen.
///
/// This mirrors the server's `EntitySummaryView`. It is composed client-side
/// from `entity.list`, `budget.getMonth`, `recurring.countDue` and one
/// `report.netWorth` call while `entity.listSummaries` is not yet on the
/// generated client; the provider is the only place to change when the
/// server method arrives.
class EntitySummary {
  const EntitySummary({
    required this.entity,
    required this.month,
    required this.readyToAssignMinor,
    required this.overspentEnvelopeCount,
    required this.netWorthMinor,
    required this.netWorthComplete,
    required this.uncategorizedCount,
    required this.pendingProposalCount,
    required this.dueRecurringCount,
  });

  final Entity entity;
  final int month;

  /// Ready to Assign this month in base minor units; null when the entity
  /// has no on-budget account.
  final int? readyToAssignMinor;
  final int overspentEnvelopeCount;
  final int netWorthMinor;
  final bool netWorthComplete;
  final int uncategorizedCount;
  final int pendingProposalCount;
  final int dueRecurringCount;

  String get entityId => entity.id?.toString() ?? '';
  String get name => entity.name;
  String get baseCurrencyCode => entity.baseCurrencyCode;
}

@riverpod
Future<List<EntitySummary>> entitySummaries(Ref ref) async {
  final client = ref.read(serverpodClientProvider);
  final entities = await client.entity.list();
  if (entities.isEmpty) return const [];

  final month = MonthKey.fromDate(DateTime.now());
  final netWorth = await client.report.netWorth();
  final worthByEntity = <String, NetWorthEntityRow>{
    for (final row in netWorth.entities) row.entityId.toString(): row,
  };

  final summaries = <EntitySummary>[];
  for (final entity in entities) {
    final entityId = entity.id?.toString() ?? '';
    final monthView = await client.budget.getMonth(
      UuidValue.fromString(entityId),
      month,
    );
    final dueRecurring = await client.recurringTransaction.countDue(
      UuidValue.fromString(entityId),
    );
    final pendingProposals = await client.agent.listProposals(
      UuidValue.fromString(entityId),
      pendingOnly: true,
    );

    summaries.add(
      EntitySummary(
        entity: entity,
        month: month,
        readyToAssignMinor: monthView.summary.readyToAssignMinor,
        overspentEnvelopeCount: monthView.envelopes
            .where((e) => e.availableMinor < 0)
            .length,
        netWorthMinor: worthByEntity[entityId]?.netWorthMinor ?? 0,
        netWorthComplete: worthByEntity[entityId]?.isComplete ?? true,
        uncategorizedCount: monthView.summary.uncategorizedMinor == 0 ? 0 : 1,
        pendingProposalCount: pendingProposals.length,
        dueRecurringCount: dueRecurring,
      ),
    );
  }
  return summaries;
}

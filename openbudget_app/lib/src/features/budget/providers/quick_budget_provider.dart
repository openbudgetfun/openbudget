import 'package:equatable/equatable.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'quick_budget_provider.g.dart';

class QuickBudgetSuggestion extends Equatable {
  const QuickBudgetSuggestion({
    required this.allocatedLastMonthMinor,
    required this.spentLastMonthMinor,
    required this.averageAllocatedMinor,
    required this.averageSpentMinor,
  });

  final int allocatedLastMonthMinor;
  final int spentLastMonthMinor;
  final int averageAllocatedMinor;
  final int averageSpentMinor;

  @override
  List<Object?> get props => [
    allocatedLastMonthMinor,
    spentLastMonthMinor,
    averageAllocatedMinor,
    averageSpentMinor,
  ];
}

/// Suggestions for one envelope from the previous three months' views.
@riverpod
Future<QuickBudgetSuggestion> quickBudgetSuggestion(
  Ref ref,
  String entityId,
  String envelopeId,
  int month,
) async {
  final client = ref.read(serverpodClientProvider);
  final entityUuid = UuidValue.fromString(entityId);
  final envelopeUuid = UuidValue.fromString(envelopeId);

  var allocatedTotal = 0;
  var spentTotal = 0;
  var allocatedLastMonth = 0;
  var spentLastMonth = 0;

  var m = MonthKey.previous(month);
  for (var i = 0; i < 3; i++) {
    final view = await client.budget.getMonth(entityUuid, m);
    final row = view.envelopes
        .where((e) => e.envelope.id == envelopeUuid)
        .firstOrNull;
    if (row != null) {
      if (i == 0) {
        allocatedLastMonth = row.allocatedMinor;
        spentLastMonth = row.activityMinor.abs();
      }
      allocatedTotal += row.allocatedMinor;
      spentTotal += row.activityMinor.abs();
    }
    m = MonthKey.previous(m);
  }

  return QuickBudgetSuggestion(
    allocatedLastMonthMinor: allocatedLastMonth,
    spentLastMonthMinor: spentLastMonth,
    averageAllocatedMinor: allocatedTotal ~/ 3,
    averageSpentMinor: spentTotal ~/ 3,
  );
}

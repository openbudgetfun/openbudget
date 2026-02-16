import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'age_of_money_provider.g.dart';

/// Fetches the "Age of Money" metric for a budget.
///
/// Returns the average number of days between income receipt and spending,
/// or null if there is insufficient data.
@riverpod
Future<int?> ageOfMoney(Ref ref, String budgetId) async {
  final client = ref.read(serverpodClientProvider);
  // Serverpod API requires UuidValue which is experimental in uuid package.
  // ignore: experimental_member_use
  return client.transaction.ageOfMoney(UuidValue.fromString(budgetId));
}

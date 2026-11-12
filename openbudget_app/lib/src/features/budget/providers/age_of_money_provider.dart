import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'age_of_money_provider.g.dart';

/// The mean age in days of the entity's last ten outflows' money, straight
/// from `report.ageOfMoney`. Null means the entity has too little history
/// for a meaningful figure.
@riverpod
Future<int?> ageOfMoney(Ref ref, String entityId) async {
  final client = ref.read(serverpodClientProvider);
  return client.report.ageOfMoney(UuidValue.fromString(entityId));
}

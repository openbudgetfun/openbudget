import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'entity_summary_provider.g.dart';

/// One headline summary per entity for the home screen, straight from
/// `entity.listSummaries`. The server composes Ready to Assign, overspent
/// envelopes, net worth, uncategorised transactions, due recurring
/// transactions and pending proposals in that one call.
@riverpod
Future<List<EntitySummaryView>> entitySummaries(Ref ref) async {
  final client = ref.read(serverpodClientProvider);
  return client.entity.listSummaries();
}

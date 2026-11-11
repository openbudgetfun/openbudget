import 'package:openbudget_app/src/features/accounts/providers/account_list_provider.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'plaid_account_link_provider.g.dart';

/// The entity's Plaid connections: sync status, last error and Remove.
@riverpod
Future<List<PlaidConnection>> plaidConnections(Ref ref, String entityId) async {
  final client = ref.read(serverpodClientProvider);
  return client.plaid.listConnections(UuidValue.fromString(entityId));
}

@riverpod
class PlaidAccountLink extends _$PlaidAccountLink {
  @override
  FutureOr<void> build() {}

  Future<String> createLinkToken({required String entityId}) async {
    final client = ref.read(serverpodClientProvider);
    return client.plaid.createLinkToken(UuidValue.fromString(entityId));
  }

  Future<PlaidConnection> exchangePublicToken({
    required String entityId,
    required String publicToken,
  }) async {
    final client = ref.read(serverpodClientProvider);
    final connection = await client.plaid.exchangePublicToken(
      UuidValue.fromString(entityId),
      publicToken,
    );
    ref.invalidate(plaidConnectionsProvider(entityId));
    ref.invalidate(accountListProvider(entityId));
    return connection;
  }

  Future<PlaidConnection> syncConnection({
    required String connectionId,
    required String entityId,
  }) async {
    final client = ref.read(serverpodClientProvider);
    final connection = await client.plaid.syncConnection(
      UuidValue.fromString(connectionId),
    );
    ref.invalidate(plaidConnectionsProvider(entityId));
    ref.invalidate(accountListProvider(entityId));
    return connection;
  }

  Future<void> removeConnection({
    required String connectionId,
    required String entityId,
  }) async {
    final client = ref.read(serverpodClientProvider);
    await client.plaid.removeConnection(UuidValue.fromString(connectionId));
    ref.invalidate(plaidConnectionsProvider(entityId));
    ref.invalidate(accountListProvider(entityId));
  }

  Future<PlaidConnection> importSandboxAccounts({
    required String entityId,
    String? plaidInstitutionId,
  }) async {
    final client = ref.read(serverpodClientProvider);
    final connection = await client.plaid.importSandboxAccounts(
      UuidValue.fromString(entityId),
      plaidInstitutionId: plaidInstitutionId,
    );
    ref.invalidate(plaidConnectionsProvider(entityId));
    ref.invalidate(accountListProvider(entityId));
    return connection;
  }
}

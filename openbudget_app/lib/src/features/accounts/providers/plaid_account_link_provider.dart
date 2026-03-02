import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'plaid_account_link_provider.g.dart';

@riverpod
class PlaidAccountLink extends _$PlaidAccountLink {
  @override
  FutureOr<void> build() {}

  Future<String> createLinkToken({required String budgetId}) async {
    final client = ref.read(serverpodClientProvider);
    return client.plaid.createLinkToken(
      // Serverpod API requires UuidValue which is experimental in uuid package.
      // ignore: experimental_member_use
      UuidValue.fromString(budgetId),
    );
  }

  Future<List<Account>> exchangePublicToken({
    required String budgetId,
    required String publicToken,
  }) async {
    final client = ref.read(serverpodClientProvider);
    return client.plaid.exchangePublicToken(
      // Serverpod API requires UuidValue which is experimental in uuid package.
      // ignore: experimental_member_use
      UuidValue.fromString(budgetId),
      publicToken,
    );
  }

  Future<List<Account>> importSandboxAccounts({
    required String budgetId,
    String? plaidInstitutionId,
  }) async {
    final client = ref.read(serverpodClientProvider);
    return client.plaid.importSandboxAccounts(
      // Serverpod API requires UuidValue which is experimental in uuid package.
      // ignore: experimental_member_use
      UuidValue.fromString(budgetId),
      plaidInstitutionId: plaidInstitutionId,
    );
  }
}

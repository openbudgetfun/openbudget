import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'crypto_breakdown_provider.g.dart';

/// What one entity's wallets are worth in the reporting currency, split by
/// chain or by asset, straight from `report.cryptoBreakdown`.
///
/// The server converts and sums; the app never does. A `walletCount` of zero
/// means the entity has no wallets and the net worth screen hides the
/// section.
@riverpod
Future<CryptoBreakdownView> cryptoBreakdown(
  Ref ref,
  String entityId,
  CryptoBreakdownGrouping grouping,
) async {
  final client = ref.read(serverpodClientProvider);
  return client.report.cryptoBreakdown(
    UuidValue.fromString(entityId),
    grouping,
  );
}

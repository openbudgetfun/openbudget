import 'package:openbudget_app/src/features/plus/providers/plus_billing_api.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'plus_entitlement_provider.g.dart';

/// The subscription that currently grants OpenBudget Plus, or null on the
/// free plan.
///
/// Other features watch this provider to unlock paid surfaces. Refresh it
/// after any purchase or portal visit with `ref.invalidate`.
@riverpod
Future<Entitlement?> plusEntitlement(Ref ref) =>
    ref.watch(plusBillingApiProvider).getEntitlement();

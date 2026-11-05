import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/generated/protocol.dart';

/// Normalizes [raw] and returns it when OpenBudget supports the currency.
///
/// Money is stored with its code so an amount is never silently interpreted
/// as a different currency. Rejecting unsupported codes at the write boundary
/// keeps every stored budget, account, and transaction displayable.
String requireSupportedCurrency(String raw) {
  final currency = CurrencyCode.tryParse(raw);
  if (currency == null) {
    throw ValidationException(message: 'Unsupported currency: ${raw.trim()}');
  }
  return currency.code;
}

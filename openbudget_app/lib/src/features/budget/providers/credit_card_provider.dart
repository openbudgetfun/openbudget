import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_list_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/monthly_allocation_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/selected_month_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'credit_card_provider.freezed.dart';
part 'credit_card_provider.g.dart';

@freezed
sealed class CreditCardPaymentInfo with _$CreditCardPaymentInfo {
  const factory CreditCardPaymentInfo({
    required Account account,
    required int spentCents,
    required int paymentCents,
  }) = _CreditCardPaymentInfo;
}

/// Computes credit card payment information for all credit card accounts
/// in a budget, based on the selected month's transactions.
@riverpod
Future<List<CreditCardPaymentInfo>> creditCardPayments(
  Ref ref,
  String budgetId,
) async {
  final selectedMonth = ref.watch(selectedMonthProvider(budgetId));
  final accounts = await ref.watch(accountListProvider(budgetId).future);
  final transactions = await ref.watch(
    monthlyTransactionsProvider(
      budgetId,
      selectedMonth.year,
      selectedMonth.month,
    ).future,
  );

  final creditCards = accounts.where(
    (a) => a.accountType == 'creditCard' && !a.isClosed,
  );

  if (creditCards.isEmpty) return [];

  final result = <CreditCardPaymentInfo>[];

  for (final card in creditCards) {
    final cardId = card.id?.toString() ?? '';

    // Sum spending on this card for the month (negative amounts = spending).
    final cardTransactions = transactions.where(
      (t) => t.accountId?.toString() == cardId,
    );

    final spentCents = cardTransactions
        .where((t) => t.amountCents < 0)
        .fold<int>(0, (sum, t) => sum + t.amountCents.abs());

    // Payment amount is the positive balance on the card (what you owe).
    // Card balance is negative (liability), so payment = abs(balance).
    final paymentCents = card.balanceCents.abs();

    result.add(
      CreditCardPaymentInfo(
        account: card,
        spentCents: spentCents,
        paymentCents: paymentCents,
      ),
    );
  }

  return result;
}

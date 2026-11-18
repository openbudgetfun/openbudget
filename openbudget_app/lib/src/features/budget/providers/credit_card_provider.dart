import 'package:equatable/equatable.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_list_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/selected_month_provider.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'credit_card_provider.g.dart';

class CreditCardPaymentInfo extends Equatable {
  const CreditCardPaymentInfo({
    required this.account,
    required this.spentMinor,
    required this.balanceMinor,
  });

  final Account account;

  /// The month's spending on the card, in the card's currency, positive.
  final int spentMinor;

  /// What the card owes (the liability balance, positive).
  final int balanceMinor;

  @override
  List<Object?> get props => [account, spentMinor, balanceMinor];
}

/// Each card's month spending and balance.
///
/// Spending comes from `transaction.list` filtered by account and the
/// selected month's dates; payment envelopes are deferred (Q3).
@riverpod
Future<List<CreditCardPaymentInfo>> creditCardPayments(
  Ref ref,
  String entityId,
) async {
  final month = ref.watch(selectedMonthProvider(entityId));
  final accounts = await ref.watch(accountListProvider(entityId).future);

  final cards = accounts
      .where((a) => a.kind == AccountKind.creditCard && a.closedAt == null)
      .toList();
  if (cards.isEmpty) return const [];

  final client = ref.read(serverpodClientProvider);
  final firstDay = MonthKey.toFirstDate(month);
  final lastDay = MonthKey.toLastDate(month);
  final entityUuid = UuidValue.fromString(entityId);

  final result = <CreditCardPaymentInfo>[];
  for (final card in cards) {
    final cardId = card.id?.toString() ?? '';
    final query = TransactionQuery(
      entityId: entityUuid,
      accountId: UuidValue.fromString(cardId),
      fromDate: firstDay,
      toDate: lastDay,
      limit: 200,
    );
    final page = await client.transaction.list(query);
    final spentMinor = page.items
        .where((view) => view.transaction.amountMinor < 0)
        .fold<int>(
          0,
          (sum, view) => sum + view.transaction.amountMinor.abs(),
        );

    result.add(
      CreditCardPaymentInfo(
        account: card,
        spentMinor: spentMinor,
        balanceMinor: card.balanceMinor.abs(),
      ),
    );
  }
  return result;
}

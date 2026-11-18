import 'package:openbudget_core/src/generated/account_balance_source.dart';
import 'package:openbudget_core/src/generated/account_kind.dart';

/// Account classification independent of balance sign.
extension AccountKindRules on AccountKind {
  /// Whether this kind represents money owed.
  bool get isLiability => switch (this) {
    AccountKind.creditCard ||
    AccountKind.loan ||
    AccountKind.mortgage ||
    AccountKind.otherLiability => true,
    AccountKind.cash ||
    AccountKind.checking ||
    AccountKind.savings ||
    AccountKind.investment ||
    AccountKind.crypto ||
    AccountKind.property ||
    AccountKind.vehicle ||
    AccountKind.otherAsset => false,
  };

  /// Whether the account can participate in the envelope plan.
  bool get canBeOnBudget => switch (this) {
    AccountKind.cash ||
    AccountKind.checking ||
    AccountKind.savings ||
    AccountKind.creditCard => true,
    AccountKind.loan ||
    AccountKind.mortgage ||
    AccountKind.otherLiability ||
    AccountKind.investment ||
    AccountKind.crypto ||
    AccountKind.property ||
    AccountKind.vehicle ||
    AccountKind.otherAsset => false,
  };

  /// Default source for the cached account balance.
  AccountBalanceSource get defaultBalanceSource => switch (this) {
    AccountKind.cash ||
    AccountKind.checking ||
    AccountKind.savings ||
    AccountKind.creditCard ||
    AccountKind.loan ||
    AccountKind.mortgage ||
    AccountKind.otherLiability => AccountBalanceSource.transactions,
    AccountKind.investment ||
    AccountKind.crypto ||
    AccountKind.property ||
    AccountKind.vehicle ||
    AccountKind.otherAsset => AccountBalanceSource.valuations,
  };

  /// Permitted balance sources for this kind.
  Set<AccountBalanceSource> get allowedBalanceSources => switch (this) {
    AccountKind.cash ||
    AccountKind.checking ||
    AccountKind.savings ||
    AccountKind.creditCard => const {AccountBalanceSource.transactions},
    AccountKind.crypto ||
    AccountKind.property ||
    AccountKind.vehicle => const {AccountBalanceSource.valuations},
    AccountKind.loan ||
    AccountKind.mortgage ||
    AccountKind.otherLiability ||
    AccountKind.investment ||
    AccountKind.otherAsset => const {
      AccountBalanceSource.transactions,
      AccountBalanceSource.valuations,
    },
  };
}

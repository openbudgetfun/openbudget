import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_core/openbudget_core.dart';

/// The human label for an account kind, shared by the account list and the
/// net worth breakdown.
String accountKindLabel(AccountKind kind, AppLocalizations l10n) =>
    switch (kind) {
      AccountKind.checking => l10n.accountTypeChecking,
      AccountKind.savings => l10n.accountTypeSavings,
      AccountKind.creditCard => l10n.accountTypeCreditCard,
      AccountKind.cash => l10n.accountTypeCash,
      AccountKind.investment => l10n.accountTypeInvestment,
      AccountKind.crypto => l10n.accountTypeCryptoWallet,
      AccountKind.loan => l10n.addAccountTypePersonalLoan,
      AccountKind.mortgage => l10n.addAccountTypeMortgage,
      AccountKind.property => l10n.addAccountTypeProperty,
      AccountKind.vehicle => l10n.addAccountTypeVehicle,
      AccountKind.otherAsset => l10n.addAccountTypeOtherAsset,
      AccountKind.otherLiability => l10n.addAccountTypeOtherDebt,
    };

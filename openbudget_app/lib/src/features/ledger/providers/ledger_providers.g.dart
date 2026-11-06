// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ledger_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The budget's chart of accounts, archived accounts included so the
/// Accounts tab can mark them.

@ProviderFor(ledgerAccounts)
final ledgerAccountsProvider = LedgerAccountsFamily._();

/// The budget's chart of accounts, archived accounts included so the
/// Accounts tab can mark them.

final class LedgerAccountsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<LedgerAccount>>,
          List<LedgerAccount>,
          FutureOr<List<LedgerAccount>>
        >
    with
        $FutureModifier<List<LedgerAccount>>,
        $FutureProvider<List<LedgerAccount>> {
  /// The budget's chart of accounts, archived accounts included so the
  /// Accounts tab can mark them.
  LedgerAccountsProvider._({
    required LedgerAccountsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'ledgerAccountsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$ledgerAccountsHash();

  @override
  String toString() {
    return r'ledgerAccountsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<LedgerAccount>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<LedgerAccount>> create(Ref ref) {
    final argument = this.argument as String;
    return ledgerAccounts(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LedgerAccountsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$ledgerAccountsHash() => r'd4016bbf6dc27ea1439d923c0bef4a78d302def2';

/// The budget's chart of accounts, archived accounts included so the
/// Accounts tab can mark them.

final class LedgerAccountsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<LedgerAccount>>, String> {
  LedgerAccountsFamily._()
    : super(
        retry: null,
        name: r'ledgerAccountsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The budget's chart of accounts, archived accounts included so the
  /// Accounts tab can mark them.

  LedgerAccountsProvider call(String budgetId) =>
      LedgerAccountsProvider._(argument: budgetId, from: this);

  @override
  String toString() => r'ledgerAccountsProvider';
}

/// The budget's journals, newest first.

@ProviderFor(ledgerJournals)
final ledgerJournalsProvider = LedgerJournalsFamily._();

/// The budget's journals, newest first.

final class LedgerJournalsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Journal>>,
          List<Journal>,
          FutureOr<List<Journal>>
        >
    with $FutureModifier<List<Journal>>, $FutureProvider<List<Journal>> {
  /// The budget's journals, newest first.
  LedgerJournalsProvider._({
    required LedgerJournalsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'ledgerJournalsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$ledgerJournalsHash();

  @override
  String toString() {
    return r'ledgerJournalsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Journal>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Journal>> create(Ref ref) {
    final argument = this.argument as String;
    return ledgerJournals(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LedgerJournalsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$ledgerJournalsHash() => r'c7900a6f97413b825b723bacda18a39ccbd391c8';

/// The budget's journals, newest first.

final class LedgerJournalsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Journal>>, String> {
  LedgerJournalsFamily._()
    : super(
        retry: null,
        name: r'ledgerJournalsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The budget's journals, newest first.

  LedgerJournalsProvider call(String budgetId) =>
      LedgerJournalsProvider._(argument: budgetId, from: this);

  @override
  String toString() => r'ledgerJournalsProvider';
}

/// The trial balance through the inclusive calendar date [asOf].

@ProviderFor(ledgerTrialBalance)
final ledgerTrialBalanceProvider = LedgerTrialBalanceFamily._();

/// The trial balance through the inclusive calendar date [asOf].

final class LedgerTrialBalanceProvider
    extends
        $FunctionalProvider<
          AsyncValue<TrialBalanceView>,
          TrialBalanceView,
          FutureOr<TrialBalanceView>
        >
    with $FutureModifier<TrialBalanceView>, $FutureProvider<TrialBalanceView> {
  /// The trial balance through the inclusive calendar date [asOf].
  LedgerTrialBalanceProvider._({
    required LedgerTrialBalanceFamily super.from,
    required (String, DateTime) super.argument,
  }) : super(
         retry: null,
         name: r'ledgerTrialBalanceProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$ledgerTrialBalanceHash();

  @override
  String toString() {
    return r'ledgerTrialBalanceProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<TrialBalanceView> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<TrialBalanceView> create(Ref ref) {
    final argument = this.argument as (String, DateTime);
    return ledgerTrialBalance(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is LedgerTrialBalanceProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$ledgerTrialBalanceHash() =>
    r'a636436799c60a1c5ab1d41d72233b6a8fb0ce82';

/// The trial balance through the inclusive calendar date [asOf].

final class LedgerTrialBalanceFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<TrialBalanceView>,
          (String, DateTime)
        > {
  LedgerTrialBalanceFamily._()
    : super(
        retry: null,
        name: r'ledgerTrialBalanceProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The trial balance through the inclusive calendar date [asOf].

  LedgerTrialBalanceProvider call(String budgetId, DateTime asOf) =>
      LedgerTrialBalanceProvider._(argument: (budgetId, asOf), from: this);

  @override
  String toString() => r'ledgerTrialBalanceProvider';
}

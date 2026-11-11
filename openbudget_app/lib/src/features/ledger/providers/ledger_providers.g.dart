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

String _$ledgerAccountsHash() => r'0e6ff4ba5811c995eafc55c9b74be15aa8c2f0ca';

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

  LedgerAccountsProvider call(String entityId) =>
      LedgerAccountsProvider._(argument: entityId, from: this);

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

String _$ledgerJournalsHash() => r'bb5f19178a59a3100f653548682bd2524bec5f28';

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

  LedgerJournalsProvider call(String entityId) =>
      LedgerJournalsProvider._(argument: entityId, from: this);

  @override
  String toString() => r'ledgerJournalsProvider';
}

/// One journal's lines, oldest first.

@ProviderFor(ledgerJournalLines)
final ledgerJournalLinesProvider = LedgerJournalLinesFamily._();

/// One journal's lines, oldest first.

final class LedgerJournalLinesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<JournalLine>>,
          List<JournalLine>,
          FutureOr<List<JournalLine>>
        >
    with
        $FutureModifier<List<JournalLine>>,
        $FutureProvider<List<JournalLine>> {
  /// One journal's lines, oldest first.
  LedgerJournalLinesProvider._({
    required LedgerJournalLinesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'ledgerJournalLinesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$ledgerJournalLinesHash();

  @override
  String toString() {
    return r'ledgerJournalLinesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<JournalLine>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<JournalLine>> create(Ref ref) {
    final argument = this.argument as String;
    return ledgerJournalLines(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LedgerJournalLinesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$ledgerJournalLinesHash() =>
    r'9264e5b35027c5f94d16f870819938e52aa75c98';

/// One journal's lines, oldest first.

final class LedgerJournalLinesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<JournalLine>>, String> {
  LedgerJournalLinesFamily._()
    : super(
        retry: null,
        name: r'ledgerJournalLinesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One journal's lines, oldest first.

  LedgerJournalLinesProvider call(String journalId) =>
      LedgerJournalLinesProvider._(argument: journalId, from: this);

  @override
  String toString() => r'ledgerJournalLinesProvider';
}

/// The budget's stored period lock date, or null when none is set.

@ProviderFor(ledgerLockDate)
final ledgerLockDateProvider = LedgerLockDateFamily._();

/// The budget's stored period lock date, or null when none is set.

final class LedgerLockDateProvider
    extends
        $FunctionalProvider<
          AsyncValue<LedgerPeriodLock?>,
          LedgerPeriodLock?,
          FutureOr<LedgerPeriodLock?>
        >
    with
        $FutureModifier<LedgerPeriodLock?>,
        $FutureProvider<LedgerPeriodLock?> {
  /// The budget's stored period lock date, or null when none is set.
  LedgerLockDateProvider._({
    required LedgerLockDateFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'ledgerLockDateProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$ledgerLockDateHash();

  @override
  String toString() {
    return r'ledgerLockDateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<LedgerPeriodLock?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<LedgerPeriodLock?> create(Ref ref) {
    final argument = this.argument as String;
    return ledgerLockDate(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LedgerLockDateProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$ledgerLockDateHash() => r'0bd78be081e737f4bc1b74644ee7df40c04d40b8';

/// The budget's stored period lock date, or null when none is set.

final class LedgerLockDateFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<LedgerPeriodLock?>, String> {
  LedgerLockDateFamily._()
    : super(
        retry: null,
        name: r'ledgerLockDateProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The budget's stored period lock date, or null when none is set.

  LedgerLockDateProvider call(String entityId) =>
      LedgerLockDateProvider._(argument: entityId, from: this);

  @override
  String toString() => r'ledgerLockDateProvider';
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
    r'cc452235e3bb2abae47fa2614533350a95b618aa';

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

  LedgerTrialBalanceProvider call(String entityId, DateTime asOf) =>
      LedgerTrialBalanceProvider._(argument: (entityId, asOf), from: this);

  @override
  String toString() => r'ledgerTrialBalanceProvider';
}

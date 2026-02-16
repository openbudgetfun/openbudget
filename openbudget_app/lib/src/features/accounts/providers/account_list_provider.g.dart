// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(accountList)
final accountListProvider = AccountListFamily._();

final class AccountListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Account>>,
          List<Account>,
          FutureOr<List<Account>>
        >
    with $FutureModifier<List<Account>>, $FutureProvider<List<Account>> {
  AccountListProvider._({
    required AccountListFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'accountListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$accountListHash();

  @override
  String toString() {
    return r'accountListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Account>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Account>> create(Ref ref) {
    final argument = this.argument as String;
    return accountList(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AccountListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$accountListHash() => r'441872a31d0fc55157a891065adb3a5b00924431';

final class AccountListFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Account>>, String> {
  AccountListFamily._()
    : super(
        retry: null,
        name: r'accountListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AccountListProvider call(String budgetId) =>
      AccountListProvider._(argument: budgetId, from: this);

  @override
  String toString() => r'accountListProvider';
}

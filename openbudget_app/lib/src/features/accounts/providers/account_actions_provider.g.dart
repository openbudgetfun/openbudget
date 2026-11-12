// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_actions_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Create, edit, close and delete actions for accounts, plus valuations for
/// track-by-value accounts. Opening balances and dates become an opening
/// transaction or a first valuation on the server.

@ProviderFor(AccountActions)
final accountActionsProvider = AccountActionsProvider._();

/// Create, edit, close and delete actions for accounts, plus valuations for
/// track-by-value accounts. Opening balances and dates become an opening
/// transaction or a first valuation on the server.
final class AccountActionsProvider
    extends $AsyncNotifierProvider<AccountActions, void> {
  /// Create, edit, close and delete actions for accounts, plus valuations for
  /// track-by-value accounts. Opening balances and dates become an opening
  /// transaction or a first valuation on the server.
  AccountActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountActionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountActionsHash();

  @$internal
  @override
  AccountActions create() => AccountActions();
}

String _$accountActionsHash() => r'68c2fd282ad921862189755ca08b058399820244';

/// Create, edit, close and delete actions for accounts, plus valuations for
/// track-by-value accounts. Opening balances and dates become an opening
/// transaction or a first valuation on the server.

abstract class _$AccountActions extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

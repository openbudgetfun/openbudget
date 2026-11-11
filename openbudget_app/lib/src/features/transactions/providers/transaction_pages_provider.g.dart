// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_pages_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The paged transaction list for one entity, filtered by
/// [TransactionFilter] and paged by the server's keyset cursor.

@ProviderFor(TransactionPages)
final transactionPagesProvider = TransactionPagesFamily._();

/// The paged transaction list for one entity, filtered by
/// [TransactionFilter] and paged by the server's keyset cursor.
final class TransactionPagesProvider
    extends $AsyncNotifierProvider<TransactionPages, TransactionPageState> {
  /// The paged transaction list for one entity, filtered by
  /// [TransactionFilter] and paged by the server's keyset cursor.
  TransactionPagesProvider._({
    required TransactionPagesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'transactionPagesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$transactionPagesHash();

  @override
  String toString() {
    return r'transactionPagesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TransactionPages create() => TransactionPages();

  @override
  bool operator ==(Object other) {
    return other is TransactionPagesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$transactionPagesHash() => r'b0e5863afd30bcd48311e0ee0515ebd929b474fe';

/// The paged transaction list for one entity, filtered by
/// [TransactionFilter] and paged by the server's keyset cursor.

final class TransactionPagesFamily extends $Family
    with
        $ClassFamilyOverride<
          TransactionPages,
          AsyncValue<TransactionPageState>,
          TransactionPageState,
          FutureOr<TransactionPageState>,
          String
        > {
  TransactionPagesFamily._()
    : super(
        retry: null,
        name: r'transactionPagesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The paged transaction list for one entity, filtered by
  /// [TransactionFilter] and paged by the server's keyset cursor.

  TransactionPagesProvider call(String entityId) =>
      TransactionPagesProvider._(argument: entityId, from: this);

  @override
  String toString() => r'transactionPagesProvider';
}

/// The paged transaction list for one entity, filtered by
/// [TransactionFilter] and paged by the server's keyset cursor.

abstract class _$TransactionPages extends $AsyncNotifier<TransactionPageState> {
  late final _$args = ref.$arg as String;
  String get entityId => _$args;

  FutureOr<TransactionPageState> build(String entityId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<TransactionPageState>, TransactionPageState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<TransactionPageState>,
                TransactionPageState
              >,
              AsyncValue<TransactionPageState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

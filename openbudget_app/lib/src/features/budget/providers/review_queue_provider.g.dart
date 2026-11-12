// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_queue_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The month's uncategorised transactions, newest first: the review
/// sheet's queue, from `transaction.list` with `uncategorizedOnly`.

@ProviderFor(reviewQueue)
final reviewQueueProvider = ReviewQueueFamily._();

/// The month's uncategorised transactions, newest first: the review
/// sheet's queue, from `transaction.list` with `uncategorizedOnly`.

final class ReviewQueueProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TransactionView>>,
          List<TransactionView>,
          FutureOr<List<TransactionView>>
        >
    with
        $FutureModifier<List<TransactionView>>,
        $FutureProvider<List<TransactionView>> {
  /// The month's uncategorised transactions, newest first: the review
  /// sheet's queue, from `transaction.list` with `uncategorizedOnly`.
  ReviewQueueProvider._({
    required ReviewQueueFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'reviewQueueProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$reviewQueueHash();

  @override
  String toString() {
    return r'reviewQueueProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<TransactionView>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<TransactionView>> create(Ref ref) {
    final argument = this.argument as String;
    return reviewQueue(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ReviewQueueProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$reviewQueueHash() => r'92b9a5668a959d73fe1e1e909b9d9a24d164c0fb';

/// The month's uncategorised transactions, newest first: the review
/// sheet's queue, from `transaction.list` with `uncategorizedOnly`.

final class ReviewQueueFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<TransactionView>>, String> {
  ReviewQueueFamily._()
    : super(
        retry: null,
        name: r'reviewQueueProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The month's uncategorised transactions, newest first: the review
  /// sheet's queue, from `transaction.list` with `uncategorizedOnly`.

  ReviewQueueProvider call(String entityId) =>
      ReviewQueueProvider._(argument: entityId, from: this);

  @override
  String toString() => r'reviewQueueProvider';
}

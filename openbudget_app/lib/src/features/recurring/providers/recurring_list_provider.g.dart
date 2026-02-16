// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(recurringList)
final recurringListProvider = RecurringListFamily._();

final class RecurringListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RecurringTransaction>>,
          List<RecurringTransaction>,
          FutureOr<List<RecurringTransaction>>
        >
    with
        $FutureModifier<List<RecurringTransaction>>,
        $FutureProvider<List<RecurringTransaction>> {
  RecurringListProvider._({
    required RecurringListFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'recurringListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$recurringListHash();

  @override
  String toString() {
    return r'recurringListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<RecurringTransaction>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<RecurringTransaction>> create(Ref ref) {
    final argument = this.argument as String;
    return recurringList(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RecurringListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$recurringListHash() => r'72158de0fca2dad2be3436eb007b354fa05bfa22';

final class RecurringListFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<RecurringTransaction>>,
          String
        > {
  RecurringListFamily._()
    : super(
        retry: null,
        name: r'recurringListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RecurringListProvider call(String budgetId) =>
      RecurringListProvider._(argument: budgetId, from: this);

  @override
  String toString() => r'recurringListProvider';
}

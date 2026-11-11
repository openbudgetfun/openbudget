// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tax_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The budget's tax profile, or null when none has been set.

@ProviderFor(taxProfile)
final taxProfileProvider = TaxProfileFamily._();

/// The budget's tax profile, or null when none has been set.

final class TaxProfileProvider
    extends
        $FunctionalProvider<
          AsyncValue<TaxProfileRecord?>,
          TaxProfileRecord?,
          FutureOr<TaxProfileRecord?>
        >
    with
        $FutureModifier<TaxProfileRecord?>,
        $FutureProvider<TaxProfileRecord?> {
  /// The budget's tax profile, or null when none has been set.
  TaxProfileProvider._({
    required TaxProfileFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'taxProfileProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$taxProfileHash();

  @override
  String toString() {
    return r'taxProfileProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<TaxProfileRecord?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<TaxProfileRecord?> create(Ref ref) {
    final argument = this.argument as String;
    return taxProfile(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TaxProfileProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$taxProfileHash() => r'9359b8ead6e1656c0d08bba93758be94d7c80b80';

/// The budget's tax profile, or null when none has been set.

final class TaxProfileFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<TaxProfileRecord?>, String> {
  TaxProfileFamily._()
    : super(
        retry: null,
        name: r'taxProfileProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The budget's tax profile, or null when none has been set.

  TaxProfileProvider call(String entityId) =>
      TaxProfileProvider._(argument: entityId, from: this);

  @override
  String toString() => r'taxProfileProvider';
}

/// The tax report for the tax year starting in [startYear].

@ProviderFor(taxReport)
final taxReportProvider = TaxReportFamily._();

/// The tax report for the tax year starting in [startYear].

final class TaxReportProvider
    extends
        $FunctionalProvider<
          AsyncValue<TaxReportView>,
          TaxReportView,
          FutureOr<TaxReportView>
        >
    with $FutureModifier<TaxReportView>, $FutureProvider<TaxReportView> {
  /// The tax report for the tax year starting in [startYear].
  TaxReportProvider._({
    required TaxReportFamily super.from,
    required (String, int) super.argument,
  }) : super(
         retry: null,
         name: r'taxReportProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$taxReportHash();

  @override
  String toString() {
    return r'taxReportProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<TaxReportView> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<TaxReportView> create(Ref ref) {
    final argument = this.argument as (String, int);
    return taxReport(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is TaxReportProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$taxReportHash() => r'c3856b10d662aaf504489247c44cb25a8607d69e';

/// The tax report for the tax year starting in [startYear].

final class TaxReportFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<TaxReportView>, (String, int)> {
  TaxReportFamily._()
    : super(
        retry: null,
        name: r'taxReportProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The tax report for the tax year starting in [startYear].

  TaxReportProvider call(String entityId, int startYear) =>
      TaxReportProvider._(argument: (entityId, startYear), from: this);

  @override
  String toString() => r'taxReportProvider';
}

/// The categories available to the budget's entity kind.

@ProviderFor(taxCategories)
final taxCategoriesProvider = TaxCategoriesFamily._();

/// The categories available to the budget's entity kind.

final class TaxCategoriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TaxCategoryView>>,
          List<TaxCategoryView>,
          FutureOr<List<TaxCategoryView>>
        >
    with
        $FutureModifier<List<TaxCategoryView>>,
        $FutureProvider<List<TaxCategoryView>> {
  /// The categories available to the budget's entity kind.
  TaxCategoriesProvider._({
    required TaxCategoriesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'taxCategoriesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$taxCategoriesHash();

  @override
  String toString() {
    return r'taxCategoriesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<TaxCategoryView>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<TaxCategoryView>> create(Ref ref) {
    final argument = this.argument as String;
    return taxCategories(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TaxCategoriesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$taxCategoriesHash() => r'323e560b73f97067940be6e291b8abc42095fd16';

/// The categories available to the budget's entity kind.

final class TaxCategoriesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<TaxCategoryView>>, String> {
  TaxCategoriesFamily._()
    : super(
        retry: null,
        name: r'taxCategoriesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The categories available to the budget's entity kind.

  TaxCategoriesProvider call(String entityId) =>
      TaxCategoriesProvider._(argument: entityId, from: this);

  @override
  String toString() => r'taxCategoriesProvider';
}

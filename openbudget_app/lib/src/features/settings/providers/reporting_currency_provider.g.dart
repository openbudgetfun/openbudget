// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reporting_currency_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The user's reporting currency: every converted figure in the app — net
/// worth, entity summaries — is expressed in it by the server.

@ProviderFor(userSettings)
final userSettingsProvider = UserSettingsProvider._();

/// The user's reporting currency: every converted figure in the app — net
/// worth, entity summaries — is expressed in it by the server.

final class UserSettingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<UserSettings>,
          UserSettings,
          FutureOr<UserSettings>
        >
    with $FutureModifier<UserSettings>, $FutureProvider<UserSettings> {
  /// The user's reporting currency: every converted figure in the app — net
  /// worth, entity summaries — is expressed in it by the server.
  UserSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userSettingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userSettingsHash();

  @$internal
  @override
  $FutureProviderElement<UserSettings> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<UserSettings> create(Ref ref) {
    return userSettings(ref);
  }
}

String _$userSettingsHash() => r'4dc947b3f963d3e611dbc9d655006daac046595c';

/// The reporting currency code itself, for call sites that only format.

@ProviderFor(reportingCurrency)
final reportingCurrencyProvider = ReportingCurrencyProvider._();

/// The reporting currency code itself, for call sites that only format.

final class ReportingCurrencyProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// The reporting currency code itself, for call sites that only format.
  ReportingCurrencyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reportingCurrencyProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reportingCurrencyHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return reportingCurrency(ref);
  }
}

String _$reportingCurrencyHash() => r'60ce6c9dfbf1ace953d1d97d066797e46030915f';

@ProviderFor(ReportingCurrencyActions)
final reportingCurrencyActionsProvider = ReportingCurrencyActionsProvider._();

final class ReportingCurrencyActionsProvider
    extends $NotifierProvider<ReportingCurrencyActions, AsyncValue<void>> {
  ReportingCurrencyActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reportingCurrencyActionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reportingCurrencyActionsHash();

  @$internal
  @override
  ReportingCurrencyActions create() => ReportingCurrencyActions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$reportingCurrencyActionsHash() =>
    r'cbcc4b0c45f01846b89ef51792880f8b528c7997';

abstract class _$ReportingCurrencyActions extends $Notifier<AsyncValue<void>> {
  AsyncValue<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

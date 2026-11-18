import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/home/providers/entity_actions_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_app/src/widgets/app_toast.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// The base currency a new entity starts with in [country]: its first
/// current currency that OpenBudget can book in, or US dollars for a
/// territory with none (such as Antarctica).
CurrencyCode _defaultCurrencyFor(CountryInfo country) {
  for (final code in country.currencies) {
    if (CurrencyCode.tryParse(code) case final currency?) return currency;
  }
  return CurrencyCode.usd;
}

/// The countries the picker offers: every servable one, those with a tax
/// pack first.
List<CountryInfo> _pickableCountries() {
  final servable = [
    for (final country in Countries.all)
      if (country.servable) country,
  ];
  bool hasPack(CountryInfo country) =>
      TaxJurisdiction.fromCountryCode(country.code) != null;
  servable.sort((a, b) => a.displayName.compareTo(b.displayName));
  return [
    ...servable.where(hasPack),
    ...servable.where((country) => !hasPack(country)),
  ];
}

/// Creates an entity: name, kind, country, base currency, time zone and —
/// for businesses — the financial year end, all defaulted from the country.
class CreateEntityScreen extends HookConsumerWidget {
  const CreateEntityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final nameController = useTextEditingController(
      text: l10n.createBudgetDefaultName,
    );
    final selectedKind = useState(EntityKind.individual);
    final selectedCountry = useState(Countries.byCode('GB')!);
    final selectedCurrency = useState(CurrencyCode.gbp);
    final selectedTimeZone = useState(defaultTimeZone('GB'));
    final fiscalYearEnd = useState(
      defaultFiscalYearEnd('GB', EntityKind.individual),
    );
    final isSubmitting = useState(false);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final statusBarStyle =
        (theme.brightness == Brightness.light
                ? SystemUiOverlayStyle.dark
                : SystemUiOverlayStyle.light)
            .copyWith(statusBarColor: palette.canvas);

    void pickCountry(CountryInfo country) {
      selectedCountry.value = country;
      selectedCurrency.value = _defaultCurrencyFor(country);
      selectedTimeZone.value = defaultTimeZone(country.code);
      fiscalYearEnd.value = defaultFiscalYearEnd(
        country.code,
        selectedKind.value,
      );
    }

    void pickKind(EntityKind kind) {
      selectedKind.value = kind;
      fiscalYearEnd.value = defaultFiscalYearEnd(
        selectedCountry.value.code,
        kind,
      );
    }

    final isCompany = selectedKind.value == EntityKind.company;
    final taxYear = _taxYearRange(
      selectedCountry.value,
      Localizations.localeOf(context).toString(),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: statusBarStyle,
      child: Scaffold(
        backgroundColor: palette.canvas,
        appBar: AppBar(
          backgroundColor: palette.canvas,
          surfaceTintColor: palette.canvas,
          scrolledUnderElevation: 0,
          leading: IconButton(
            tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
            icon: SkribbleIcon(data: OpenBudgetIcons.close, color: palette.ink),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
                return;
              }
              context.goNamed(homeRoute);
            },
          ),
        ),
        body: SafeArea(
          top: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(SpacingTokens.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.createEntityTitle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: palette.ink,
                        height: 1.08,
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.lg),
                    TextField(
                      key: const Key('create-entity-name-field'),
                      controller: nameController,
                      enabled: !isSubmitting.value,
                      textInputAction: TextInputAction.next,
                      onTapOutside: (_) => FocusScope.of(context).unfocus(),
                      decoration: InputDecoration(
                        labelText: l10n.createBudgetNameLabel,
                        prefixIcon: ObFieldIcon(
                          data: OpenBudgetIcons.label,
                          color: palette.mutedInk,
                        ),
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.md),
                    Text(
                      l10n.createEntityKindLabel,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: palette.mutedInk,
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.xs),
                    // The highlighter fill marks the choice, so the check
                    // glyph goes: at 360pt it pushed "Personal" and "Sole
                    // trader" onto two lines. Labels shrink rather than wrap.
                    SegmentedButton<EntityKind>(
                      showSelectedIcon: false,
                      segments: [
                        for (final (kind, label) in [
                          (EntityKind.individual, l10n.entityKindPersonal),
                          (EntityKind.soleTrader, l10n.entityKindSoleTrader),
                          (EntityKind.company, l10n.entityKindCompany),
                        ])
                          ButtonSegment(
                            value: kind,
                            label: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(label, maxLines: 1, softWrap: false),
                            ),
                          ),
                      ],
                      selected: {selectedKind.value},
                      onSelectionChanged: (kinds) => pickKind(kinds.first),
                    ),
                    const SizedBox(height: SpacingTokens.md),
                    _EntityPickerRow(
                      key: const Key('create-entity-country-row'),
                      label: l10n.createEntityCountry,
                      value: selectedCountry.value.displayName,
                      onTap: isSubmitting.value
                          ? null
                          : () async {
                              final picked = await _selectCountry(
                                context,
                                selectedCountry.value,
                              );
                              if (picked != null) pickCountry(picked);
                            },
                    ),
                    const SizedBox(height: SpacingTokens.sm),
                    _EntityPickerRow(
                      key: const Key('create-entity-currency-row'),
                      label: l10n.createBudgetPlanCurrency,
                      value:
                          '${selectedCurrency.value.displayName} (${selectedCurrency.value.code})',
                      onTap: isSubmitting.value
                          ? null
                          : () async {
                              final selected = await _selectCurrency(
                                context,
                                selectedCountry.value,
                                selectedCurrency.value,
                              );
                              if (selected != null) {
                                selectedCurrency.value = selected;
                              }
                            },
                    ),
                    const SizedBox(height: SpacingTokens.sm),
                    _EntityPickerRow(
                      key: const Key('create-entity-time-zone-row'),
                      label: l10n.createEntityTimeZone,
                      value: selectedTimeZone.value,
                      onTap: isSubmitting.value
                          ? null
                          : () async {
                              final picked = await _selectTimeZone(
                                context,
                                selectedCountry.value.code,
                                selectedTimeZone.value,
                              );
                              if (picked != null) {
                                selectedTimeZone.value = picked;
                              }
                            },
                    ),
                    if (isCompany) ...[
                      const SizedBox(height: SpacingTokens.sm),
                      _EntityPickerRow(
                        key: const Key('create-entity-fiscal-year-row'),
                        label: l10n.createEntityFiscalYearEnd,
                        value: l10n.createEntityFiscalYearValue(
                          fiscalYearEnd.value.day,
                          fiscalYearEnd.value.month,
                        ),
                        onTap: isSubmitting.value
                            ? null
                            : () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.utc(
                                    DateTime.now().year,
                                    fiscalYearEnd.value.month,
                                    fiscalYearEnd.value.day,
                                  ),
                                  firstDate: DateTime.utc(2000),
                                  lastDate: DateTime.utc(2100),
                                );
                                if (picked != null) {
                                  fiscalYearEnd.value = (
                                    month: picked.month,
                                    day: picked.day,
                                  );
                                }
                              },
                      ),
                    ] else if (taxYear != null) ...[
                      // A person's tax year is set by the country, so it is
                      // shown, not offered for editing.
                      const SizedBox(height: SpacingTokens.sm),
                      _EntityPickerRow(
                        key: const Key('create-entity-tax-year-row'),
                        label: l10n.createEntityTaxYear,
                        value: l10n.createEntityTaxYearValue(
                          taxYear.start,
                          taxYear.end,
                        ),
                        readOnly: true,
                      ),
                    ],
                    const SizedBox(height: SpacingTokens.lg),
                    FilledButton(
                      key: const Key('create-entity-create-button'),
                      onPressed: isSubmitting.value
                          ? null
                          : () async {
                              isSubmitting.value = true;
                              try {
                                final entityName = nameController.text.trim();
                                final entityId = await ref
                                    .read(entityActionsProvider.notifier)
                                    .create(
                                      name: entityName.isEmpty
                                          ? l10n.createBudgetDefaultName
                                          : entityName,
                                      kind: selectedKind.value,
                                      countryCode: selectedCountry.value.code,
                                      baseCurrencyCode:
                                          selectedCurrency.value.code,
                                      timeZone: selectedTimeZone.value,
                                      fiscalYearEndMonth:
                                          fiscalYearEnd.value.month,
                                      fiscalYearEndDay: fiscalYearEnd.value.day,
                                    );
                                if (context.mounted && entityId.isNotEmpty) {
                                  context.goNamed(
                                    addAccountRoute,
                                    pathParameters: {'entityId': entityId},
                                  );
                                } else if (context.mounted) {
                                  isSubmitting.value = false;
                                }
                              } on Exception catch (_) {
                                isSubmitting.value = false;
                                if (context.mounted) {
                                  showAppToast(
                                    context,
                                    message: l10n.createBudgetError,
                                    variant: AppToastVariant.error,
                                  );
                                }
                              }
                            },
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                      ),
                      child: isSubmitting.value
                          ? WiredLoadingIndicator(
                              size: 20,
                              color: palette.onAction,
                            )
                          : Text(l10n.createBudgetPersonalize),
                    ),
                    const SizedBox(height: SpacingTokens.sm),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<CountryInfo?> _selectCountry(
    BuildContext context,
    CountryInfo current,
  ) {
    final l10n = AppLocalizations.of(context);
    return showObPickerSheet<CountryInfo>(
      context,
      title: l10n.createEntityPickCountry,
      options: [
        for (final country in _pickableCountries())
          ObPickerOption(
            value: country,
            label: country.displayName,
            code: country.code,
            keywords: [
              if (country.name != country.displayName) country.name,
              ...country.searchAliases,
            ],
            section: TaxJurisdiction.fromCountryCode(country.code) != null
                ? l10n.createEntitySectionTaxRules
                : l10n.createEntitySectionAllCountries,
          ),
      ],
      selected: current,
      searchHint: l10n.createEntitySearchCountries,
      clearSearchLabel: l10n.createEntityClearSearch,
      selectedLabel: l10n.createEntityPickerSelected,
      resultCountLabel: l10n.createEntityResultCount,
      noMatchLabel: l10n.createEntityNoMatch,
    );
  }

  Future<CurrencyCode?> _selectCurrency(
    BuildContext context,
    CountryInfo country,
    CurrencyCode current,
  ) {
    final l10n = AppLocalizations.of(context);
    final local = [
      for (final code in country.currencies) ?CurrencyCode.tryParse(code),
    ];
    final rest = [
      for (final currency in CurrencyCode.values)
        if (!local.contains(currency)) currency,
    ]..sort((a, b) => a.displayName.compareTo(b.displayName));
    return showObPickerSheet<CurrencyCode>(
      context,
      title: l10n.createEntityPickCurrency,
      options: [
        for (final currency in [...local, ...rest])
          ObPickerOption(
            value: currency,
            label: currency.displayName,
            code: currency.code,
            keywords: [currency.symbol.trim()],
            section: local.contains(currency)
                ? l10n.createEntitySectionCountryCurrencies(country.displayName)
                : l10n.createEntitySectionAllCurrencies,
          ),
      ],
      selected: current,
      searchHint: l10n.createEntitySearchCurrencies,
      clearSearchLabel: l10n.createEntityClearSearch,
      selectedLabel: l10n.createEntityPickerSelected,
      resultCountLabel: l10n.createEntityResultCount,
      noMatchLabel: l10n.createEntityNoMatch,
    );
  }

  Future<String?> _selectTimeZone(
    BuildContext context,
    String countryCode,
    String current,
  ) {
    final l10n = AppLocalizations.of(context);
    return showObPickerSheet<String>(
      context,
      title: l10n.createEntityPickTimeZone,
      options: [
        for (final zone in timeZoneChoices(countryCode))
          ObPickerOption(value: zone, label: zone),
      ],
      selected: current,
      searchHint: l10n.createEntitySearchTimeZones,
      clearSearchLabel: l10n.createEntityClearSearch,
      selectedLabel: l10n.createEntityPickerSelected,
      resultCountLabel: l10n.createEntityResultCount,
      noMatchLabel: l10n.createEntityNoMatch,
    );
  }
}

/// The start and end of [country]'s individual tax year as short dates in
/// [locale], or null when the dataset has none or follows a calendar other
/// than the Gregorian one.
({String start, String end})? _taxYearRange(
  CountryInfo country,
  String locale,
) {
  final taxYear = country.individualTaxYear;
  if (taxYear == null || taxYear.calendar != TaxYearCalendar.gregorian) {
    return null;
  }
  final end = defaultFiscalYearEnd(country.code, EntityKind.individual);
  // 2001 is not a leap year, so no date rolls over.
  final format = DateFormat.MMMd(locale);
  return (
    start: format.format(DateTime(2001, taxYear.startMonth, taxYear.startDay)),
    end: format.format(DateTime(2001, end.month, end.day)),
  );
}

class _EntityPickerRow extends HookWidget {
  const _EntityPickerRow({
    required this.label,
    required this.value,
    this.onTap,
    this.readOnly = false,
    super.key,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;

  /// Shows the row as a fact: no pencil, no tap target.
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.md,
            vertical: SpacingTokens.sm + 2,
          ),
          decoration: ObRoughDecoration(
            // A fact on the quiet wash reads as settled; a choice sits on
            // paper.
            color: readOnly ? palette.wash(ObTone.neutral) : palette.surface,
            outline: palette.quietPen,
            radius: 10,
            seed: 53,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: palette.mutedInk,
                      ),
                    ),
                    Text(
                      value,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: palette.ink,
                      ),
                    ),
                  ],
                ),
              ),
              if (!readOnly)
                SkribbleIcon(data: OpenBudgetIcons.edit, color: palette.ink),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/home/providers/entity_actions_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_app/src/widgets/app_toast.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// Countries offered first, each with its default base currency.
const _leadCountries = <({String code, String name, CurrencyCode currency})>[
  (code: 'GB', name: 'United Kingdom', currency: CurrencyCode.gbp),
  (code: 'US', name: 'United States', currency: CurrencyCode.usd),
  (code: 'NG', name: 'Nigeria', currency: CurrencyCode.ngn),
  (code: 'DE', name: 'Germany', currency: CurrencyCode.eur),
];

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
    final selectedCountry = useState(_leadCountries.first);
    final selectedCurrency = useState(_leadCountries.first.currency);
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

    void pickCountry(
      ({String code, String name, CurrencyCode currency}) country,
    ) {
      selectedCountry.value = country;
      selectedCurrency.value = country.currency;
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

    final showFiscalYear = selectedKind.value != EntityKind.individual;

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
                    SegmentedButton<EntityKind>(
                      segments: [
                        ButtonSegment(
                          value: EntityKind.individual,
                          label: Text(l10n.entityKindPersonal),
                        ),
                        ButtonSegment(
                          value: EntityKind.soleTrader,
                          label: Text(l10n.entityKindSoleTrader),
                        ),
                        ButtonSegment(
                          value: EntityKind.company,
                          label: Text(l10n.entityKindCompany),
                        ),
                      ],
                      selected: {selectedKind.value},
                      onSelectionChanged: (kinds) => pickKind(kinds.first),
                    ),
                    const SizedBox(height: SpacingTokens.md),
                    _EntityPickerRow(
                      label: l10n.createEntityCountry,
                      value: selectedCountry.value.name,
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
                      label: l10n.createBudgetPlanCurrency,
                      value:
                          '${selectedCurrency.value.displayName} (${selectedCurrency.value.code})',
                      onTap: isSubmitting.value
                          ? null
                          : () async {
                              final selected = await _selectCurrency(
                                context,
                                selectedCurrency.value,
                              );
                              if (selected != null) {
                                selectedCurrency.value = selected;
                              }
                            },
                    ),
                    const SizedBox(height: SpacingTokens.sm),
                    _EntityPickerRow(
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
                    if (showFiscalYear) ...[
                      const SizedBox(height: SpacingTokens.sm),
                      _EntityPickerRow(
                        label: l10n.createEntityFiscalYearEnd,
                        value: l10n.createEntityFiscalYearValue(
                          fiscalYearEnd.value.month,
                          fiscalYearEnd.value.day,
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
                    ],
                    const SizedBox(height: SpacingTokens.lg),
                    FilledButton(
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

  Future<({String code, String name, CurrencyCode currency})?> _selectCountry(
    BuildContext context,
    ({String code, String name, CurrencyCode currency}) current,
  ) => showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: _leadCountries.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final country = _leadCountries[index];
          return ListTile(
            title: Text(country.name),
            subtitle: Text(country.code),
            trailing: country.code == current.code
                ? SkribbleIcon(
                    data: OpenBudgetIcons.check,
                    color: Theme.of(context).ob.funded,
                  )
                : null,
            onTap: () => Navigator.of(context).pop(country),
          );
        },
      ),
    ),
  );

  Future<CurrencyCode?> _selectCurrency(
    BuildContext context,
    CurrencyCode current,
  ) => showModalBottomSheet<CurrencyCode>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: CurrencyCode.values.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final currency = CurrencyCode.values[index];
          return ListTile(
            title: Text('${currency.displayName} (${currency.code})'),
            trailing: currency == current
                ? SkribbleIcon(
                    data: OpenBudgetIcons.check,
                    color: Theme.of(context).ob.funded,
                  )
                : null,
            onTap: () => Navigator.of(context).pop(currency),
          );
        },
      ),
    ),
  );

  Future<String?> _selectTimeZone(
    BuildContext context,
    String countryCode,
    String current,
  ) {
    final choices = timeZoneChoices(countryCode);
    return showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: choices.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final zone = choices[index];
            return ListTile(
              title: Text(zone),
              trailing: zone == current
                  ? SkribbleIcon(
                      data: OpenBudgetIcons.check,
                      color: Theme.of(context).ob.funded,
                    )
                  : null,
              onTap: () => Navigator.of(context).pop(zone),
            );
          },
        ),
      ),
    );
  }
}

class _EntityPickerRow extends HookWidget {
  const _EntityPickerRow({
    required this.label,
    required this.value,
    this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;

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
            color: palette.surface,
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
              SkribbleIcon(data: OpenBudgetIcons.edit, color: palette.ink),
            ],
          ),
        ),
      ),
    );
  }
}

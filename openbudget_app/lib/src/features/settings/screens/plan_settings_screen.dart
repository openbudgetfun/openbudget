import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/home/providers/entity_detail_provider.dart';
import 'package:openbudget_app/src/features/home/providers/entity_actions_provider.dart';
import 'package:openbudget_app/src/features/settings/providers/display_options_provider.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_app/src/utils/currency_code_utils.dart';
import 'package:openbudget_app/src/widgets/app_toast.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// Edits the entity itself: name, time zone, financial year end and
/// "Count in my net worth", plus the local display options.
class PlanSettingsScreen extends HookConsumerWidget {
  const PlanSettingsScreen({required this.entityId, super.key});

  final String entityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final entityAsync = ref.watch(entityDetailProvider(entityId));
    final numberFormat = ref.watch(numberFormatStyleProvider);
    final currencyPlacement = ref.watch(currencyPlacementStyleProvider);
    final dateFormat = ref.watch(dateFormatStyleProvider);
    final theme = Theme.of(context);
    final palette = theme.ob;

    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: () =>
              context.goNamed(settingsRoute, pathParameters: {'entityId': entityId}),
          child: Text(l10n.dialogCancel),
        ),
        leadingWidth: 92,
        title: Text(l10n.settingsPlanSettings),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => context.goNamed(
              settingsRoute,
              pathParameters: {'entityId': entityId},
            ),
            child: Text(l10n.dialogDone),
          ),
        ],
      ),
      body: entityAsync.when(
        loading: () => ObLoadingPanel(label: l10n.settingsLoading),
        error: (_, _) => Padding(
          padding: const EdgeInsets.all(SpacingTokens.md),
          child: ObStatePanel.problem(title: l10n.settingsLoadError),
        ),
        data: (entity) {
          final currency = CurrencyCode.tryParse(entity.baseCurrencyCode);
          final showFiscalYear = entity.kind != EntityKind.individual;

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              SpacingTokens.md,
              SpacingTokens.md,
              SpacingTokens.md,
              SpacingTokens.xl,
            ),
            children: [
              ObCard(
                child: ListTile(
                  title: Text(
                    entity.name,
                    style: theme.textTheme.titleMedium,
                  ),
                  trailing: SkribbleIcon(
                    data: OpenBudgetIcons.edit,
                    size: 20,
                    color: palette.mutedInk,
                  ),
                  onTap: () => _showRenameEntityDialog(context, ref, entity),
                ),
              ),
              const SizedBox(height: SpacingTokens.md),
              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    _SettingChoiceTile(
                      title: l10n.settingsCurrency,
                      value: currency == null
                          ? normalizeCurrencyCode(entity.baseCurrencyCode)
                          : '${currency.displayName} - ${currency.code}',
                      isNavigation: true,
                      onTap: () => context.goNamed(
                        currencySettingsRoute,
                        pathParameters: {'entityId': entityId},
                      ),
                    ),
                    const Divider(height: 1),
                    _SettingChoiceTile(
                      title: l10n.createEntityTimeZone,
                      value: entity.timeZone,
                      onTap: () => _selectTimeZone(context, ref, entity),
                    ),
                    if (showFiscalYear) ...[
                      const Divider(height: 1),
                      _SettingChoiceTile(
                        title: l10n.createEntityFiscalYearEnd,
                        value: l10n.createEntityFiscalYearValue(
                          entity.fiscalYearEndDay,
                          entity.fiscalYearEndMonth,
                        ),
                        onTap: () =>
                            _selectFiscalYearEnd(context, ref, entity),
                      ),
                    ],
                    const Divider(height: 1),
                    SwitchListTile(
                      title: Text(l10n.entityCountInNetWorth),
                      subtitle: Text(l10n.entityCountInNetWorthHint),
                      value: entity.includeInNetWorth,
                      onChanged: (value) => _updateEntity(
                        context,
                        ref,
                        entity,
                        includeInNetWorth: value,
                        successMessage: l10n.settingsRenameSuccess,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: SpacingTokens.md),
              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    _SettingChoiceTile(
                      title: l10n.settingsNumberFormat,
                      value: _numberFormatLabel(l10n, numberFormat),
                      onTap: () => _selectNumberFormat(context, ref),
                    ),
                    const Divider(height: 1),
                    _SettingChoiceTile(
                      title: l10n.settingsCurrencyPlacement,
                      value: _currencyPlacementLabel(l10n, currencyPlacement),
                      onTap: () => _selectCurrencyPlacement(context, ref),
                    ),
                    const Divider(height: 1),
                    _SettingChoiceTile(
                      title: l10n.settingsDateFormat,
                      value: _dateFormatLabel(l10n, dateFormat),
                      onTap: () => _selectDateFormat(context, ref),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: SpacingTokens.lg),
              FilledButton(
                onPressed: () =>
                    _confirmDeleteEntity(context, ref, entity.name),
                style: FilledButton.styleFrom(
                  backgroundColor: palette.overspentWash,
                  foregroundColor: palette.overspent,
                ),
                child: Text(l10n.settingsDeletePlan),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _updateEntity(
    BuildContext context,
    WidgetRef ref,
    Entity entity, {
    Object? name = _unset,
    Object? timeZone = _unset,
    Object? fiscalYearEndMonth = _unset,
    Object? fiscalYearEndDay = _unset,
    bool? includeInNetWorth,
    required String successMessage,
  }) async {
    final client = ref.read(serverpodClientProvider);
    try {
      await client.entity.update(
        UuidValue.fromString(entityId),
        name: name == _unset ? null : name as String?,
        timeZone: timeZone == _unset ? null : timeZone as String?,
        fiscalYearEndMonth: fiscalYearEndMonth == _unset
            ? null
            : fiscalYearEndMonth as int?,
        fiscalYearEndDay: fiscalYearEndDay == _unset
            ? null
            : fiscalYearEndDay as int?,
        includeInNetWorth: includeInNetWorth,
      );
      ref.invalidate(entityDetailProvider(entityId));
      if (!context.mounted) return;
      showAppToast(
        context,
        message: successMessage,
        variant: AppToastVariant.success,
      );
    } on Exception catch (_) {
      if (!context.mounted) return;
      showAppToast(
        context,
        message: AppLocalizations.of(context).settingsRenameError,
        variant: AppToastVariant.error,
      );
    }
  }

  Future<void> _showRenameEntityDialog(
    BuildContext context,
    WidgetRef ref,
    Entity entity,
  ) async {
    final l10n = AppLocalizations.of(context);
    final palette = Theme.of(context).ob;
    final controller = TextEditingController(text: entity.name);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settingsRenameBudget),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: l10n.createBudgetNameLabel,
            prefixIcon: ObFieldIcon(
              data: OpenBudgetIcons.label,
              size: 20,
              color: palette.mutedInk,
            ),
          ),
          autofocus: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => Navigator.of(ctx).pop(true),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.dialogCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.dialogSave),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final name = controller.text.trim();
    controller.dispose();
    if (name.isEmpty || name == entity.name) return;

    await _updateEntity(
      context,
      ref,
      entity,
      name: name,
      successMessage: l10n.settingsRenameSuccess,
    );
  }

  Future<void> _selectTimeZone(
    BuildContext context,
    WidgetRef ref,
    Entity entity,
  ) async {
    final choices = timeZoneChoices(entity.countryCode);
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: choices.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (sheetContext, index) {
            final zone = choices[index];
            final selectedZone = zone == entity.timeZone;
            return ListTile(
              title: Text(zone),
              trailing: selectedZone
                  ? const SkribbleIcon(data: OpenBudgetIcons.check)
                  : null,
              onTap: () => Navigator.of(sheetContext).pop(zone),
            );
          },
        ),
      ),
    );
    if (selected == null || selected == entity.timeZone) return;
    if (!context.mounted) return;
    await _updateEntity(
      context,
      ref,
      entity,
      timeZone: selected,
      successMessage: AppLocalizations.of(context).settingsRenameSuccess,
    );
  }

  Future<void> _selectFiscalYearEnd(
    BuildContext context,
    WidgetRef ref,
    Entity entity,
  ) async {
    final l10n = AppLocalizations.of(context);
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.utc(
        DateTime.now().year,
        entity.fiscalYearEndMonth,
        entity.fiscalYearEndDay,
      ),
      firstDate: DateTime.utc(2000),
      lastDate: DateTime.utc(2100),
    );
    if (picked == null) return;
    if (picked.month == entity.fiscalYearEndMonth &&
        picked.day == entity.fiscalYearEndDay) {
      return;
    }
    if (!context.mounted) return;
    await _updateEntity(
      context,
      ref,
      entity,
      fiscalYearEndMonth: picked.month,
      fiscalYearEndDay: picked.day,
      successMessage: l10n.settingsRenameSuccess,
    );
  }

  /// Deleting an entity asks the user to type its exact name.
  Future<void> _confirmDeleteEntity(
    BuildContext context,
    WidgetRef ref,
    String entityName,
  ) async {
    final l10n = AppLocalizations.of(context);
    final palette = Theme.of(context).ob;
    final controller = TextEditingController();
    var canDelete = false;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(l10n.budgetDeleteTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.budgetDeleteConfirm(entityName)),
              const SizedBox(height: SpacingTokens.md),
              TextField(
                controller: controller,
                autofocus: true,
                onChanged: (value) => setDialogState(
                  () => canDelete = value.trim() == entityName,
                ),
                decoration: InputDecoration(
                  labelText: l10n.entityDeleteNameField,
                  hintText: entityName,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l10n.dialogCancel),
            ),
            FilledButton(
              onPressed: canDelete ? () => Navigator.of(ctx).pop(true) : null,
              style: FilledButton.styleFrom(
                backgroundColor: palette.overspentWash,
                foregroundColor: palette.overspent,
              ),
              child: Text(l10n.budgetDeleteButton),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await ref
          .read(entityActionsProvider.notifier)
          .deleteEntity(entityId: entityId, confirmName: entityName);
      if (context.mounted) {
        showAppToast(
          context,
          message: l10n.budgetDeleteSuccess,
          variant: AppToastVariant.success,
        );
        context.go(homePath);
      }
    } on Exception catch (_) {
      if (context.mounted) {
        showAppToast(
          context,
          message: l10n.budgetDeleteError,
          variant: AppToastVariant.error,
        );
      }
    }
  }

  Future<void> _selectNumberFormat(BuildContext context, WidgetRef ref) async {
    final selected = await _showChoiceBottomSheet<NumberFormatStyle>(
      context,
      options: NumberFormatStyle.values,
      current: ref.read(numberFormatStyleProvider),
      labelBuilder: (option) =>
          _numberFormatLabel(AppLocalizations.of(context), option),
    );
    if (selected == null) return;
    ref.read(numberFormatStyleProvider.notifier).setNumberFormat(selected);
  }

  Future<void> _selectCurrencyPlacement(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final selected = await _showChoiceBottomSheet<CurrencyPlacementStyle>(
      context,
      options: CurrencyPlacementStyle.values,
      current: ref.read(currencyPlacementStyleProvider),
      labelBuilder: (option) =>
          _currencyPlacementLabel(AppLocalizations.of(context), option),
    );
    if (selected == null) return;
    ref
        .read(currencyPlacementStyleProvider.notifier)
        .setCurrencyPlacement(selected);
  }

  Future<void> _selectDateFormat(BuildContext context, WidgetRef ref) async {
    final selected = await _showChoiceBottomSheet<DateFormatStyle>(
      context,
      options: DateFormatStyle.values,
      current: ref.read(dateFormatStyleProvider),
      labelBuilder: (option) =>
          _dateFormatLabel(AppLocalizations.of(context), option),
    );
    if (selected == null) return;
    ref.read(dateFormatStyleProvider.notifier).setDateFormat(selected);
  }

  Future<T?> _showChoiceBottomSheet<T>(
    BuildContext context, {
    required List<T> options,
    required T current,
    required String Function(T option) labelBuilder,
  }) => showModalBottomSheet<T>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: options.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final option = options[index];
          final selected = option == current;
          return ListTile(
            title: Text(labelBuilder(option)),
            selected: selected,
            trailing: selected
                ? const SkribbleIcon(data: OpenBudgetIcons.check)
                : null,
            onTap: () => Navigator.of(context).pop(option),
          );
        },
      ),
    ),
  );
}

const _unset = Object();

/// One settings row: title, current value, and where a tap goes.
class _SettingChoiceTile extends HookWidget {
  const _SettingChoiceTile({
    required this.title,
    required this.value,
    this.isNavigation = false,
    this.onTap,
  });

  final String title;
  final String value;
  final bool isNavigation;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;
    return ListTile(
      title: Text(title, style: theme.textTheme.bodyLarge),
      subtitle: value.isEmpty ? null : Text(value),
      trailing: isNavigation
          ? SkribbleIcon(
              data: OpenBudgetIcons.chevronRight,
              size: 20,
              color: palette.mutedInk,
            )
          : null,
      onTap: onTap,
    );
  }
}

String _numberFormatLabel(AppLocalizations l10n, NumberFormatStyle style) =>
    switch (style) {
      NumberFormatStyle.standard => l10n.settingsNumberFormatStandard,
      NumberFormatStyle.european => l10n.settingsNumberFormatEuropean,
    };

String _currencyPlacementLabel(
  AppLocalizations l10n,
  CurrencyPlacementStyle style,
) => switch (style) {
  CurrencyPlacementStyle.beforeAmount => l10n.settingsCurrencyPlacementBefore,
  CurrencyPlacementStyle.afterAmount => l10n.settingsCurrencyPlacementAfter,
};

String _dateFormatLabel(AppLocalizations l10n, DateFormatStyle style) =>
    switch (style) {
      DateFormatStyle.dayMonthYear => l10n.settingsDateFormatDayMonthYear,
      DateFormatStyle.monthDayYear => l10n.settingsDateFormatMonthDayYear,
      DateFormatStyle.yearMonthDay => l10n.settingsDateFormatYearMonthDay,
    };

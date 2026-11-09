import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_app/src/widgets/app_toast.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class CreateBudgetScreen extends HookConsumerWidget {
  const CreateBudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final nameController = useTextEditingController(
      text: l10n.createBudgetDefaultName,
    );
    final selectedCurrency = useState(CurrencyCode.usd);
    final isSubmitting = useState(false);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final statusBarStyle =
        (theme.brightness == Brightness.light
                ? SystemUiOverlayStyle.dark
                : SystemUiOverlayStyle.light)
            .copyWith(statusBarColor: palette.canvas);

    ref.watch(createBudgetProvider);

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
                    const SizedBox(height: SpacingTokens.sm),
                    const _WelcomeHeroCard(),
                    const SizedBox(height: SpacingTokens.xl + SpacingTokens.sm),
                    Text(
                      l10n.createBudgetWelcomeTitle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: palette.ink,
                        height: 1.08,
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.lg),
                    Text(
                      l10n.createBudgetWelcomeSubtitle,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        height: 1.35,
                        color: palette.mutedInk,
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.md),
                    Text(
                      l10n.createBudgetWelcomeBody,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        height: 1.35,
                        color: palette.mutedInk,
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.xxl),
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
                    _PlanCurrencyRow(
                      label: l10n.createBudgetPlanCurrency,
                      value: selectedCurrency.value.displayName,
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
                    const SizedBox(height: SpacingTokens.lg),
                    FilledButton(
                      onPressed: isSubmitting.value
                          ? null
                          : () async {
                              isSubmitting.value = true;
                              try {
                                final budgetName = nameController.text.trim();
                                final budgetId = await ref
                                    .read(createBudgetProvider.notifier)
                                    .create(
                                      name: budgetName.isEmpty
                                          ? l10n.createBudgetDefaultName
                                          : budgetName,
                                      currency: selectedCurrency.value,
                                    );
                                if (context.mounted) {
                                  context.goNamed(
                                    addAccountRoute,
                                    pathParameters: {'id': budgetId},
                                  );
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
}

class _WelcomeHeroCard extends HookWidget {
  const _WelcomeHeroCard();

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).ob;

    return ObCard(
      tone: ObTone.brand,
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.md,
        vertical: SpacingTokens.lg,
      ),
      child: Column(
        children: [
          ExcludeSemantics(
            child: WiredDoodle(
              kind: WiredDoodleKind.flower,
              size: 96,
              seed: 5,
              color: palette.brand,
            ),
          ),
          const SizedBox(height: SpacingTokens.sm),
          const ExcludeSemantics(
            child: ObEnvelopeGauge(
              fraction: 1,
              semanticLabel: '',
              width: 120,
              seed: 2,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanCurrencyRow extends HookWidget {
  const _PlanCurrencyRow({
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

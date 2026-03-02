import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_app/src/theme/openbudget_palette.dart';
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
    final colorScheme = theme.colorScheme;
    final bodyTextColor = OpenBudgetPalette.fgSecondaryFor(theme);
    final statusBarStyle =
        (theme.brightness == Brightness.light
                ? SystemUiOverlayStyle.dark
                : SystemUiOverlayStyle.light)
            .copyWith(statusBarColor: OpenBudgetPalette.transparentFor(theme));

    ref.watch(createBudgetProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: statusBarStyle,
      child: Scaffold(
        backgroundColor: OpenBudgetPalette.bgAuthFor(theme),
        appBar: AppBar(
          backgroundColor: OpenBudgetPalette.bgAuthFor(theme),
          surfaceTintColor: OpenBudgetPalette.transparentFor(theme),
          scrolledUnderElevation: 0,
          leading: IconButton(
            tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
            icon: const Icon(Icons.close_rounded),
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
                        color: OpenBudgetPalette.fgHeroTitleFor(theme),
                        height: 1.08,
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.lg),
                    Text(
                      l10n.createBudgetWelcomeSubtitle,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        height: 1.35,
                        color: bodyTextColor,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: SpacingTokens.md),
                    Text(
                      l10n.createBudgetWelcomeBody,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        height: 1.35,
                        color: bodyTextColor,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: SpacingTokens.xxl),
                    TextField(
                      controller: nameController,
                      enabled: !isSubmitting.value,
                      textInputAction: TextInputAction.next,
                      onTapOutside: (_) => FocusScope.of(context).unfocus(),
                      decoration: InputDecoration(
                        labelText: l10n.createBudgetNameLabel,
                        prefixIcon: const Icon(Icons.label_outlined),
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
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(l10n.createBudgetError),
                                      backgroundColor: colorScheme.error,
                                    ),
                                  );
                                }
                              }
                            },
                      style: FilledButton.styleFrom(
                        elevation: 0,
                        minimumSize: const Size.fromHeight(52),
                        backgroundColor: OpenBudgetPalette.bgBrandFor(theme),
                        foregroundColor: OpenBudgetPalette.fgOnBrandFor(theme),
                        disabledBackgroundColor:
                            OpenBudgetPalette.borderSubtleFor(theme),
                        disabledForegroundColor:
                            OpenBudgetPalette.fgSecondaryFor(theme),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(RadiusTokens.sm),
                        ),
                        textStyle: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: isSubmitting.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
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
  ) {
    return showModalBottomSheet<CurrencyCode>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: CurrencyCode.values.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final currency = CurrencyCode.values[index];
            return ListTile(
              title: Text('${currency.displayName} (${currency.code})'),
              trailing: currency == current
                  ? const Icon(Icons.check_rounded)
                  : null,
              onTap: () => Navigator.of(context).pop(currency),
            );
          },
        ),
      ),
    );
  }
}

class _WelcomeHeroCard extends HookWidget {
  const _WelcomeHeroCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 172,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            OpenBudgetPalette.bgHeroGradientStartFor(theme),
            OpenBudgetPalette.bgHeroGradientEndFor(theme),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(RadiusTokens.md),
      ),
      child: Stack(
        children: [
          Positioned(
            left: -26,
            top: -10,
            child: Container(
              width: 190,
              height: 150,
              decoration: BoxDecoration(
                color: OpenBudgetPalette.bgHeroBlobPrimaryFor(
                  theme,
                ).withAlpha(130),
                borderRadius: BorderRadius.circular(44),
              ),
            ),
          ),
          Positioned(
            right: -34,
            bottom: -40,
            child: Container(
              width: 190,
              height: 120,
              decoration: BoxDecoration(
                color: OpenBudgetPalette.bgHeroBlobSecondaryFor(
                  theme,
                ).withAlpha(115),
                borderRadius: BorderRadius.circular(90),
              ),
            ),
          ),
          Center(
            child: Icon(
              Icons.favorite_rounded,
              color: OpenBudgetPalette.bgHeroBlobAccentFor(theme),
              size: 84,
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(RadiusTokens.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.md,
          vertical: SpacingTokens.sm + 2,
        ),
        decoration: BoxDecoration(
          color: OpenBudgetPalette.borderSubtleFor(theme).withAlpha(55),
          borderRadius: BorderRadius.circular(RadiusTokens.sm),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: OpenBudgetPalette.fgSecondaryFor(theme),
                    ),
                  ),
                  Text(
                    value,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: OpenBudgetPalette.fgHeroBodyFor(theme),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.edit_rounded,
              color: OpenBudgetPalette.fgSecondaryFor(theme),
            ),
          ],
        ),
      ),
    );
  }
}

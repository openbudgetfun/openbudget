import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// The tax year with arrows to step to the one before or after.
///
/// An arrow whose callback is null is disabled, for the moment the year is
/// still being found.
class TaxYearSwitcher extends HookWidget {
  const TaxYearSwitcher({
    required this.label,
    required this.onPrevious,
    required this.onNext,
    this.subtitle,
    super.key,
  });

  final String label;

  /// A quieter line under [label], such as the first and last day.
  final String? subtitle;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.md),
      child: Row(
        children: [
          IconButton(
            key: const Key('tax-year-previous'),
            tooltip: l10n.taxPreviousYear,
            onPressed: onPrevious,
            icon: const SkribbleIcon(data: OpenBudgetIcons.chevronLeft),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  label,
                  key: const Key('tax-year-label'),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
                if (subtitle case final line?)
                  Text(
                    line,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.ob.mutedInk,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            key: const Key('tax-year-next'),
            tooltip: l10n.taxNextYear,
            onPressed: onNext,
            icon: const SkribbleIcon(data: OpenBudgetIcons.chevronRight),
          ),
        ],
      ),
    );
  }
}

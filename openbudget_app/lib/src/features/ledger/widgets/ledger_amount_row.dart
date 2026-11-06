import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// One row of a two-column ledger table: the account code and name on the
/// left, the debit and credit amounts on the right.
///
/// [isHeader] renders the muted column header, [isTotals] the bold totals
/// row. An empty amount prints nothing so each side shows only when the
/// figure exists, matching the trial balance.
class LedgerAmountRow extends HookWidget {
  const LedgerAmountRow({
    required this.code,
    required this.name,
    required this.debit,
    required this.credit,
    this.isHeader = false,
    this.isTotals = false,
    super.key,
  });

  final String code;
  final String name;
  final String debit;
  final String credit;
  final bool isHeader;
  final bool isTotals;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;
    final style = isHeader || isTotals
        ? theme.textTheme.labelMedium
        : theme.textTheme.bodyMedium;
    final headerStyle = isHeader
        ? style?.copyWith(color: palette.mutedInk)
        : isTotals
        ? style?.copyWith(fontWeight: FontWeight.w700)
        : style;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SpacingTokens.sm),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: Text(
              code,
              style: theme.textTheme.bodySmall?.copyWith(
                color: palette.mutedInk,
              ),
            ),
          ),
          Expanded(child: Text(name, style: headerStyle)),
          const SizedBox(width: SpacingTokens.sm),
          SizedBox(
            width: 96,
            child: Text(
              debit,
              textAlign: TextAlign.right,
              style: headerStyle?.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          SizedBox(
            width: 96,
            child: Text(
              credit,
              textAlign: TextAlign.right,
              style: headerStyle?.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/tax/widgets/tax_category_sheet.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// The tax category control on an envelope's detail screen.
///
/// The catalog is fetched by the sheet, not here, so opening an envelope never
/// asks the server for tax data it does not show.
class EnvelopeTaxCategoryRow extends HookWidget {
  const EnvelopeTaxCategoryRow({
    required this.entityId,
    required this.envelope,
    this.onChanged,
    super.key,
  });

  final String entityId;
  final Envelope envelope;
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final selectedCode = useState<String?>(envelope.taxCategoryCode);
    final subtitle = selectedCode.value == null
        ? l10n.taxCategoryNotSet
        : l10n.taxCategoryTagged;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.md,
      ),
      leading: SkribbleIcon(data: OpenBudgetIcons.label, color: palette.ink),
      title: Text(
        l10n.taxCategoryRowLabel,
        style: theme.textTheme.bodyLarge,
      ),
      subtitle: Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall?.copyWith(color: palette.mutedInk),
      ),
      trailing: SkribbleIcon(
        data: OpenBudgetIcons.chevronRight,
        size: 20,
        color: palette.mutedInk,
      ),
      onTap: () async {
        final selection = await showEnvelopeTaxCategorySheet(
          context,
          entityId: entityId,
          envelopeId: envelope.id?.toString() ?? '',
          subject: envelope.name,
          currentCode: selectedCode.value,
        );
        if (selection == null) return;
        selectedCode.value = selection.code;
        onChanged?.call();
      },
    );
  }
}

/// The tax treatment control on a transaction's edit screen.
class TransactionTaxCategoryRow extends HookWidget {
  const TransactionTaxCategoryRow({
    required this.entityId,
    required this.transaction,
    required this.currencyCode,
    this.onChanged,
    super.key,
  });

  final String entityId;
  final Transaction transaction;
  final String currencyCode;
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final selectedCode = useState<String?>(transaction.taxCategoryCode);
    final subtitle = selectedCode.value == null
        ? l10n.taxCategoryNotSet
        : l10n.taxCategoryTagged;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: SkribbleIcon(data: OpenBudgetIcons.label, color: palette.ink),
      title: Text(
        l10n.taxCategoryRowLabel,
        style: theme.textTheme.bodyLarge,
      ),
      subtitle: Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall?.copyWith(color: palette.mutedInk),
      ),
      trailing: SkribbleIcon(
        data: OpenBudgetIcons.chevronRight,
        size: 20,
        color: palette.mutedInk,
      ),
      onTap: () async {
        final selection = await showTransactionTaxCategorySheet(
          context,
          entityId: entityId,
          transactionId: transaction.id?.toString() ?? '',
          subject: transaction.description,
          currencyCode: currencyCode,
          currentCode: selectedCode.value,
          businessUsePercent: transaction.businessUsePercent,
          salesTaxMinor: transaction.salesTaxMinor,
        );
        if (selection == null) return;
        selectedCode.value = selection.code;
        onChanged?.call();
      },
    );
  }
}

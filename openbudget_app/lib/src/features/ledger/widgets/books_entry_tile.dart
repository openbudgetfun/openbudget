import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/features/ledger/ledger_formatting.dart';
import 'package:openbudget_app/src/features/ledger/providers/ledger_actions_provider.dart';
import 'package:openbudget_app/src/features/tax/providers/tax_providers.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_app/src/widgets/app_toast.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// Entity kinds whose budgets may keep books: everything a business runs.
final _bookkeepingEntityKinds = <String>{
  TaxEntityKind.soleTrader.name,
  TaxEntityKind.company.name,
};

/// The More-screen entry into a budget's double-entry books.
///
/// Only budgets whose tax profile is a sole trader or company show the
/// tile. In envelope mode the tile offers to enable books behind a
/// one-way-switch confirmation; once enabled it opens the Books screen.
class BooksEntryTile extends HookConsumerWidget {
  const BooksEntryTile({required this.budgetId, super.key});

  final String budgetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final profileAsync = ref.watch(taxProfileProvider(budgetId));
    final budgetAsync = ref.watch(budgetDetailProvider(budgetId));
    final isEnabling = useState(false);

    final entityKind = profileAsync.value?.entityKind;
    final budget = budgetAsync.value;
    if (entityKind == null ||
        budget == null ||
        !_bookkeepingEntityKinds.contains(entityKind)) {
      return const SizedBox.shrink();
    }

    final isLedger =
        AccountingMode.tryParse(budget.accountingMode) == AccountingMode.ledger;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(height: 1),
        ListTile(
          key: const Key('books-entry-tile'),
          leading: SkribbleIcon(
            data: OpenBudgetIcons.document,
            color: palette.ink,
          ),
          title: Text(
            isLedger ? l10n.booksEntryTitle : l10n.booksEntryEnableTitle,
            style: theme.textTheme.bodyLarge,
          ),
          trailing: SkribbleIcon(
            data: OpenBudgetIcons.chevronRight,
            size: 20,
            color: palette.mutedInk,
          ),
          onTap: isEnabling.value
              ? null
              : () async {
                  if (isLedger) {
                    await _openBooks(context);
                    return;
                  }
                  final confirmed = await _confirmEnable(context, budget.name);
                  if (!confirmed) return;
                  if (!context.mounted) return;
                  await _enable(context, ref, isEnabling);
                },
        ),
      ],
    );
  }

  Future<void> _openBooks(BuildContext context) => context.pushNamed(
    booksRoute,
    pathParameters: {'id': budgetId},
  );

  Future<bool> _confirmEnable(BuildContext context, String budgetName) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        key: const Key('books-enable-dialog'),
        title: Text(l10n.booksEnableDialogTitle),
        content: Text(l10n.booksEnableDialogBody(budgetName)),
        actions: [
          TextButton(
            key: const Key('books-enable-cancel'),
            onPressed: () => dialogContext.pop(false),
            child: Text(l10n.dialogCancel),
          ),
          FilledButton(
            key: const Key('books-enable-confirm'),
            onPressed: () => dialogContext.pop(true),
            child: Text(l10n.booksEnableDialogConfirm),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  Future<void> _enable(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<bool> isEnabling,
  ) async {
    final l10n = AppLocalizations.of(context);
    isEnabling.value = true;
    try {
      await ref
          .read(ledgerActionsProvider.notifier)
          .enableLedger(
            budgetId: budgetId,
          );
      if (!context.mounted) return;
      showAppToast(
        context,
        message: l10n.booksEnabledToast,
        variant: AppToastVariant.success,
      );
      await _openBooks(context);
    } on Exception catch (error) {
      if (!context.mounted) return;
      showAppToast(
        context,
        message: ledgerErrorMessage(error, l10n.booksEnableError),
        variant: AppToastVariant.error,
      );
    } finally {
      isEnabling.value = false;
    }
  }
}

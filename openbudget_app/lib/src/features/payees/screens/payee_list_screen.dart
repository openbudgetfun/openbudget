import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/payees/providers/payee_actions_provider.dart';
import 'package:openbudget_app/src/features/payees/providers/payee_list_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_app/src/widgets/app_toast.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// The key on the empty state shown when there are no payees yet.
const payeeListEmptyKey = Key('payee-list-empty');

class PayeeListScreen extends HookConsumerWidget {
  const PayeeListScreen({required this.entityId, super.key});

  final String entityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final payeesAsync = ref.watch(payeeListProvider(entityId));
    final theme = Theme.of(context);
    final palette = theme.ob;
    final searchController = useTextEditingController();
    final searchQuery = useState('');

    useEffect(() {
      void listener() => searchQuery.value = searchController.text;
      searchController.addListener(listener);
      return () => searchController.removeListener(listener);
    }, [searchController]);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const SkribbleIcon(data: OpenBudgetIcons.back),
          tooltip: l10n.transactionsBack,
          onPressed: () => context.goNamed(
            moreRoute,
            pathParameters: {'entityId': entityId},
          ),
        ),
        title: Text(l10n.payeeListTitle),
        actions: [
          IconButton(
            icon: const SkribbleIcon(data: OpenBudgetIcons.add),
            tooltip: l10n.payeeAddButton,
            onPressed: () => _showAddPayeeDialog(context, ref),
          ),
        ],
      ),
      body: payeesAsync.when(
        loading: () => Center(
          child: ObLoadingPanel(label: l10n.payeesLoading),
        ),
        error: (error, _) => Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(SpacingTokens.md),
            child: ObStatePanel.problem(
              title: l10n.payeeLoadError,
              message: error.toString(),
              action: ObStateAction(
                label: l10n.homeRetry,
                onPressed: () => ref.invalidate(payeeListProvider(entityId)),
              ),
            ),
          ),
        ),
        data: (payees) {
          if (payees.isEmpty) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(SpacingTokens.md),
                child: ObStatePanel.empty(
                  key: payeeListEmptyKey,
                  title: l10n.payeeEmptyTitle,
                  message: l10n.payeeEmptySubtitle,
                  doodle: WiredDoodleKind.cupcake,
                  action: ObStateAction(
                    label: l10n.payeeAddButton,
                    onPressed: () => _showAddPayeeDialog(context, ref),
                  ),
                ),
              ),
            );
          }

          final query = searchQuery.value.toLowerCase();
          final filtered = query.isEmpty
              ? payees
              : payees
                    .where((p) => p.name.toLowerCase().contains(query))
                    .toList();

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(payeeListProvider(entityId)),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    SpacingTokens.md,
                    SpacingTokens.md,
                    SpacingTokens.md,
                    SpacingTokens.sm,
                  ),
                  child: ObTextField(
                    controller: searchController,
                    hintText: l10n.payeeSearchHint,
                    prefixIcon: const ObFieldIcon(
                      data: OpenBudgetIcons.search,
                    ),
                    suffixIcon: searchQuery.value.isNotEmpty
                        ? IconButton(
                            key: const Key('payee-search-clear'),
                            icon: const SkribbleIcon(
                              data: OpenBudgetIcons.close,
                            ),
                            tooltip: l10n.transactionsSearchClear,
                            onPressed: searchController.clear,
                          )
                        : null,
                  ),
                ),
                if (query.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SpacingTokens.md,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        l10n.payeeSearchResultCount(filtered.length),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: palette.mutedInk,
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(SpacingTokens.md),
                            child: ObStatePanel.empty(
                              title: l10n.payeeSearchNoResults,
                              doodle: WiredDoodleKind.cloud,
                              tone: ObTone.review,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(SpacingTokens.md),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final payee = filtered[index];
                            return _PayeeTile(payee: payee, entityId: entityId);
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddPayeeDialog(BuildContext context, WidgetRef ref) {
    unawaited(
      showDialog<void>(
        context: context,
        builder: (_) => _AddPayeeDialog(entityId: entityId),
      ),
    );
  }
}

class _PayeeTile extends HookConsumerWidget {
  const _PayeeTile({required this.payee, required this.entityId});

  final Payee payee;
  final String entityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;

    return Dismissible(
      key: ValueKey(payee.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: SpacingTokens.lg),
        margin: const EdgeInsets.only(bottom: SpacingTokens.sm),
        decoration: ObRoughDecoration(
          color: palette.overspent,
          outline: palette.overspent,
          seed: 23,
        ),
        child: SkribbleIcon(
          data: OpenBudgetIcons.delete,
          color: palette.onAction,
        ),
      ),
      confirmDismiss: (_) => _confirmDelete(context, l10n),
      onDismissed: (_) => _deletePayee(context, ref, l10n),
      child: ObCard(
        margin: const EdgeInsets.only(bottom: SpacingTokens.sm),
        child: ListTile(
          onTap: () => _showEditDialog(context),
          onLongPress: () => _showPayeeMenu(context, ref),
          leading: Container(
            width: 40,
            height: 40,
            decoration: ObRoughDecoration(
              color: palette.wash(ObTone.brand),
              outline: palette.quietPen,
              radius: 20,
              strokeWidth: 1.6,
              seed: 13,
            ),
            child: Center(
              child: SkribbleIcon(
                data: OpenBudgetIcons.store,
                size: 20,
                color: palette.brand,
              ),
            ),
          ),
          title: Text(payee.name, style: theme.textTheme.titleSmall),
          trailing: const SkribbleIcon(
            data: OpenBudgetIcons.chevronRight,
            size: 20,
          ),
        ),
      ),
    );
  }

  void _showPayeeMenu(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        builder: (ctx) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const SkribbleIcon(data: OpenBudgetIcons.edit),
                title: Text(l10n.payeeEditTitle),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _showEditDialog(context);
                },
              ),
              ListTile(
                leading: const SkribbleIcon(data: OpenBudgetIcons.merge),
                title: Text(l10n.payeeMergeTitle),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _showMergeDialog(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMergeDialog(BuildContext context) {
    unawaited(
      showDialog<void>(
        context: context,
        builder: (_) =>
            _MergePayeeDialog(sourcePayee: payee, entityId: entityId),
      ),
    );
  }

  Future<bool?> _confirmDelete(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final palette = Theme.of(context).ob;
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteConfirmTitle),
        content: Text('${l10n.deleteConfirmMessage}\n\n"${payee.name}"'),
        actions: [
          ObTextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.dialogCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: palette.overspent,
              foregroundColor: palette.onAction,
            ),
            child: Text(l10n.deleteConfirmButton),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePayee(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    try {
      final deleted = await ref
          .read(payeeActionsProvider.notifier)
          .deletePayee(payeeId: payee.id?.toString() ?? '', entityId: entityId);
      if (context.mounted) {
        showAppToast(
          context,
          message: l10n.deleteSuccess,
          variant: AppToastVariant.success,
          actionLabel: l10n.undoAction,
          onAction: () => _undoDelete(context, ref, deleted, l10n),
        );
      }
    } on Exception catch (_) {
      if (context.mounted) {
        showAppToast(
          context,
          message: l10n.deleteError,
          variant: AppToastVariant.error,
        );
      }
    }
  }

  Future<void> _undoDelete(
    BuildContext context,
    WidgetRef ref,
    Payee deleted,
    AppLocalizations l10n,
  ) async {
    try {
      await ref
          .read(payeeActionsProvider.notifier)
          .undoDeletePayee(deletedPayee: deleted, entityId: entityId);
      if (context.mounted) {
        showAppToast(
          context,
          message: l10n.undoDeleteSuccess,
          variant: AppToastVariant.success,
        );
      }
    } on Exception catch (_) {
      if (context.mounted) {
        showAppToast(
          context,
          message: l10n.undoDeleteError,
          variant: AppToastVariant.error,
        );
      }
    }
  }

  void _showEditDialog(BuildContext context) {
    unawaited(
      showDialog<void>(
        context: context,
        builder: (_) => _EditPayeeDialog(payee: payee, entityId: entityId),
      ),
    );
  }
}

class _AddPayeeDialog extends HookConsumerWidget {
  const _AddPayeeDialog({required this.entityId});

  final String entityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final nameController = useTextEditingController();
    final isSubmitting = useState(false);

    return AlertDialog(
      title: Text(l10n.payeeAddButton),
      content: ObTextField(
        controller: nameController,
        labelText: l10n.payeeNameLabel,
        prefixIcon: const ObFieldIcon(data: OpenBudgetIcons.store),
        autofocus: true,
        onSubmitted: isSubmitting.value
            ? null
            : (_) => _submit(context, ref, nameController, isSubmitting),
      ),
      actions: [
        ObTextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.dialogCancel),
        ),
        ObFilledButton(
          isLoading: isSubmitting.value,
          loadingLabel: l10n.dialogSave,
          onPressed: () => _submit(context, ref, nameController, isSubmitting),
          child: Text(l10n.dialogSave),
        ),
      ],
    );
  }

  Future<void> _submit(
    BuildContext context,
    WidgetRef ref,
    TextEditingController nameController,
    ValueNotifier<bool> isSubmitting,
  ) async {
    final l10n = AppLocalizations.of(context);
    final name = nameController.text.trim();
    if (name.isEmpty) return;

    isSubmitting.value = true;
    final navigator = Navigator.of(context);
    try {
      await ref
          .read(payeeActionsProvider.notifier)
          .createPayee(name: name, entityId: entityId);
      if (!context.mounted) return;
      showAppToast(
        context,
        message: l10n.payeeCreateSuccess,
        variant: AppToastVariant.success,
      );
      navigator.pop();
    } on Exception catch (_) {
      isSubmitting.value = false;
      if (!context.mounted) return;
      showAppToast(
        context,
        message: l10n.payeeCreateError,
        variant: AppToastVariant.error,
      );
    }
  }
}

class _EditPayeeDialog extends HookConsumerWidget {
  const _EditPayeeDialog({required this.payee, required this.entityId});

  final Payee payee;
  final String entityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final nameController = useTextEditingController(text: payee.name);
    final isSubmitting = useState(false);

    return AlertDialog(
      title: Text(l10n.payeeEditTitle),
      content: ObTextField(
        controller: nameController,
        labelText: l10n.payeeNameLabel,
        prefixIcon: const ObFieldIcon(data: OpenBudgetIcons.store),
        autofocus: true,
        onSubmitted: isSubmitting.value
            ? null
            : (_) => _submit(context, ref, nameController, isSubmitting),
      ),
      actions: [
        ObTextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.dialogCancel),
        ),
        ObFilledButton(
          isLoading: isSubmitting.value,
          loadingLabel: l10n.dialogSave,
          onPressed: () => _submit(context, ref, nameController, isSubmitting),
          child: Text(l10n.dialogSave),
        ),
      ],
    );
  }

  Future<void> _submit(
    BuildContext context,
    WidgetRef ref,
    TextEditingController nameController,
    ValueNotifier<bool> isSubmitting,
  ) async {
    final l10n = AppLocalizations.of(context);
    final name = nameController.text.trim();
    if (name.isEmpty) return;

    isSubmitting.value = true;
    final navigator = Navigator.of(context);
    try {
      await ref
          .read(payeeActionsProvider.notifier)
          .updatePayee(
            payeeId: payee.id?.toString() ?? '',
            entityId: entityId,
            name: name,
          );
      if (!context.mounted) return;
      showAppToast(
        context,
        message: l10n.payeeEditSuccess,
        variant: AppToastVariant.success,
      );
      navigator.pop();
    } on Exception catch (_) {
      isSubmitting.value = false;
      if (!context.mounted) return;
      showAppToast(
        context,
        message: l10n.payeeEditError,
        variant: AppToastVariant.error,
      );
    }
  }
}

class _MergePayeeDialog extends HookConsumerWidget {
  const _MergePayeeDialog({required this.sourcePayee, required this.entityId});

  final Payee sourcePayee;
  final String entityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final payeesAsync = ref.watch(payeeListProvider(entityId));
    final selectedTargetId = useState<String?>(null);
    final isSubmitting = useState(false);

    final targetPayees =
        payeesAsync.whenOrNull(
          data: (payees) => payees
              .where((p) => p.id?.toString() != sourcePayee.id?.toString())
              .toList(),
        ) ??
        <Payee>[];

    return AlertDialog(
      title: Text(l10n.payeeMergeTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '"${sourcePayee.name}"',
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: SpacingTokens.sm),
          Text(l10n.payeeMergeInto),
          const SizedBox(height: SpacingTokens.sm),
          Row(
            children: [
              const SkribbleIcon(data: OpenBudgetIcons.store),
              const SizedBox(width: SpacingTokens.sm),
              Expanded(
                child: ObDropdown<String>(
                  value: selectedTargetId.value,
                  labelText: l10n.payeeLabel,
                  items: targetPayees
                      .map(
                        (p) => DropdownMenuItem(
                          value: p.id?.toString() ?? '',
                          child: Text(p.name),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => selectedTargetId.value = v,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        ObTextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.dialogCancel),
        ),
        ObFilledButton(
          isLoading: isSubmitting.value,
          loadingLabel: l10n.payeeMergeButton,
          onPressed: selectedTargetId.value == null
              ? null
              : () => _submit(
                  context,
                  ref,
                  selectedTargetId.value!,
                  isSubmitting,
                ),
          child: Text(l10n.payeeMergeButton),
        ),
      ],
    );
  }

  Future<void> _submit(
    BuildContext context,
    WidgetRef ref,
    String targetPayeeId,
    ValueNotifier<bool> isSubmitting,
  ) async {
    final l10n = AppLocalizations.of(context);
    isSubmitting.value = true;
    final navigator = Navigator.of(context);

    try {
      await ref
          .read(payeeActionsProvider.notifier)
          .mergePayees(
            sourcePayeeId: sourcePayee.id?.toString() ?? '',
            targetPayeeId: targetPayeeId,
            entityId: entityId,
          );
      if (!context.mounted) return;
      showAppToast(
        context,
        message: l10n.payeeMergeSuccess,
        variant: AppToastVariant.success,
      );
      navigator.pop();
    } on Exception catch (_) {
      isSubmitting.value = false;
      if (!context.mounted) return;
      showAppToast(
        context,
        message: l10n.payeeMergeError,
        variant: AppToastVariant.error,
      );
    }
  }
}

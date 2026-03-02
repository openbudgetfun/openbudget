import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_actions_provider.dart';
import 'package:openbudget_app/src/features/accounts/providers/plaid_account_link_provider.dart';
import 'package:openbudget_app/src/features/accounts/providers/wallet_actions_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_app/src/theme/openbudget_palette.dart';
import 'package:openbudget_app/src/utils/currency_code_utils.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';
import 'package:plaid_flutter/plaid_flutter.dart';

enum _AddAccountStep {
  loading,
  loadingInstitutions,
  searchBank,
  walletConnection,
  unlinkedAccount,
  accountType,
  success,
}

const _addAccountSearchScrollKey = Key('add-account-search-scroll');
const _addAccountUnlinkedScrollKey = Key('add-account-unlinked-scroll');
const addAccountScreenCaptureBoundaryKey = Key(
  'add-account-screen-capture-boundary',
);
const _addAccountAddUnlinkedButtonKey = Key('add-account-add-unlinked-button');
const _addAccountUnlinkedNicknameFieldKey = Key(
  'add-account-unlinked-nickname-field',
);
const _addAccountUnlinkedTypeTileKey = Key('add-account-unlinked-type-tile');
const _addAccountUnlinkedBalanceFieldKey = Key(
  'add-account-unlinked-balance-field',
);
const _addAccountWalletAddressFieldKey = Key(
  'add-account-wallet-address-field',
);
const _addAccountWalletLabelFieldKey = Key('add-account-wallet-label-field');
const _addAccountUnlinkedWalletAddressFieldKey = Key(
  'add-account-unlinked-wallet-address-field',
);

class AddAccountScreen extends HookConsumerWidget {
  const AddAccountScreen({required this.budgetId, super.key});

  final String budgetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final step = useState(_AddAccountStep.loading);
    final nameController = useTextEditingController();
    final balanceController = useTextEditingController();
    final walletAddressController = useTextEditingController();
    final searchController = useTextEditingController();
    final walletLabelController = useTextEditingController();
    final isSubmitting = useState(false);
    final selectedTypeKey = useState<String?>(null);
    final selectedCurrency = useState(CurrencyCode.usd);
    final walletOnBudget = useState(false);
    final successAccountLabel = useState<String>('Account');
    final didHydrateBudgetCurrency = useState(false);
    final showSearchingOverlay = useState(false);
    // Keep step scroll state ephemeral so returning between wizard steps always
    // starts from the top instead of restoring page-storage offsets.
    final searchScrollController = useScrollController(keepScrollOffset: false);
    final unlinkedScrollController = useScrollController(
      keepScrollOffset: false,
    );
    final accountTypeScrollController = useScrollController(
      keepScrollOffset: false,
    );
    final budgetAsync = ref.watch(budgetDetailProvider(budgetId));
    final budgetCurrencyCode = budgetAsync.whenOrNull(
      data: (budget) => budget.currencyCode,
    );

    final typeSections = _accountTypeSections(l10n);
    final accountTypes = [
      for (final section in typeSections) ...section.options,
    ];
    final selectedType = selectedTypeKey.value == null
        ? null
        : accountTypes.firstWhere(
            (type) => type.key == selectedTypeKey.value,
            orElse: () => accountTypes.first,
          );

    useEffect(() {
      if (didHydrateBudgetCurrency.value || budgetCurrencyCode == null) {
        return null;
      }
      selectedCurrency.value = parseCurrencyCode(budgetCurrencyCode);
      didHydrateBudgetCurrency.value = true;
      return null;
    }, [budgetCurrencyCode]);

    useListenable(nameController);
    useListenable(balanceController);
    useListenable(walletAddressController);
    useListenable(searchController);
    useListenable(walletLabelController);

    useEffect(() {
      if (step.value != _AddAccountStep.loading) return null;
      final timer = Timer(const Duration(milliseconds: 450), () {
        if (context.mounted) {
          step.value = _AddAccountStep.loadingInstitutions;
        }
      });
      return timer.cancel;
    }, [step.value]);

    useEffect(() {
      if (step.value != _AddAccountStep.loadingInstitutions) return null;
      final timer = Timer(const Duration(milliseconds: 900), () {
        if (context.mounted) {
          step.value = _AddAccountStep.searchBank;
        }
      });
      return timer.cancel;
    }, [step.value]);

    useEffect(
      () {
        void resetScroll(ScrollController controller) {
          if (controller.hasClients) {
            controller.jumpTo(0);
            return;
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (controller.hasClients) {
              controller.jumpTo(0);
            }
          });
        }

        if (step.value == _AddAccountStep.searchBank) {
          resetScroll(searchScrollController);
        } else if (step.value == _AddAccountStep.unlinkedAccount) {
          resetScroll(unlinkedScrollController);
        } else if (step.value == _AddAccountStep.accountType) {
          resetScroll(accountTypeScrollController);
        }

        return null;
      },
      [
        step.value,
        searchScrollController,
        unlinkedScrollController,
        accountTypeScrollController,
      ],
    );

    final balanceValue = double.tryParse(balanceController.text.trim());
    final isWalletType = selectedType?.key == 'cryptoWallet';
    final canSubmit =
        selectedType != null &&
        nameController.text.trim().isNotEmpty &&
        (isWalletType
            ? walletAddressController.text.trim().isNotEmpty
            : balanceValue != null);
    final canSubmitWallet = walletAddressController.text.trim().isNotEmpty;

    Future<void> startLinkedBankFlow(String institutionName) async {
      if (showSearchingOverlay.value || institutionName.trim().isEmpty) return;
      final messenger = ScaffoldMessenger.of(context);

      final isMobilePlaidPlatform =
          !kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.android);
      if (!isMobilePlaidPlatform) {
        step.value = _AddAccountStep.unlinkedAccount;
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              'Linked connections are only available on iOS/Android right now. '
              'Add an unlinked account instead.',
            ),
          ),
        );
        return;
      }

      showSearchingOverlay.value = true;
      try {
        final linkToken = await ref
            .read(plaidAccountLinkProvider.notifier)
            .createLinkToken(budgetId: budgetId);
        final publicToken = await _runPlaidLink(linkToken: linkToken);
        if (!context.mounted) return;

        if (publicToken == null || publicToken.isEmpty) {
          step.value = _AddAccountStep.unlinkedAccount;
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                'Linked connections for "$institutionName" were not completed. '
                'Add an unlinked account instead.',
              ),
            ),
          );
          return;
        }

        final imported = await ref
            .read(plaidAccountLinkProvider.notifier)
            .exchangePublicToken(budgetId: budgetId, publicToken: publicToken);
        if (!context.mounted) return;

        if (imported.isEmpty) {
          step.value = _AddAccountStep.unlinkedAccount;
          messenger.showSnackBar(
            const SnackBar(
              content: Text(
                'No accounts were imported from this connection. '
                'Add an unlinked account instead.',
              ),
            ),
          );
          return;
        }

        context.goNamed(accountListRoute, pathParameters: {'id': budgetId});
      } on Exception catch (_) {
        if (!context.mounted) return;
        step.value = _AddAccountStep.unlinkedAccount;
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'Linked connections for "$institutionName" are currently unavailable. '
              'Add an unlinked account instead.',
            ),
          ),
        );
      } finally {
        showSearchingOverlay.value = false;
      }
    }

    Future<void> submitSolanaWallet() async {
      if (!canSubmitWallet || isSubmitting.value) return;
      isSubmitting.value = true;
      final messenger = ScaffoldMessenger.of(context);
      try {
        await ref
            .read(walletActionsProvider.notifier)
            .connectSolanaWallet(
              budgetId: budgetId,
              address: walletAddressController.text.trim(),
              label: walletLabelController.text.trim().isEmpty
                  ? null
                  : walletLabelController.text.trim(),
              onBudget: walletOnBudget.value,
            );
        if (!context.mounted) return;
        successAccountLabel.value = 'Solana Wallet';
        step.value = _AddAccountStep.success;
      } on Exception catch (_) {
        if (!context.mounted) return;
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.accountCreateError),
            backgroundColor: colorScheme.error,
          ),
        );
      } finally {
        isSubmitting.value = false;
      }
    }

    Future<void> submitUnlinkedAccount() async {
      if (!canSubmit || isSubmitting.value) return;
      final chosenType = selectedType;
      final budget = budgetAsync.value;
      if (budget == null) return;

      isSubmitting.value = true;

      final parsedBalance = isWalletType ? 0.0 : balanceValue;
      if (parsedBalance == null) {
        isSubmitting.value = false;
        return;
      }

      var balanceCents =
          (parsedBalance * _pow10(selectedCurrency.value.decimals)).round();
      if (chosenType.isDebt && balanceCents > 0) {
        balanceCents = -balanceCents;
      }

      final messenger = ScaffoldMessenger.of(context);
      try {
        await ref
            .read(accountActionsProvider.notifier)
            .createAccount(
              name: nameController.text.trim(),
              accountType: chosenType.serverType,
              balanceCents: balanceCents,
              currencyCode: selectedCurrency.value.code,
              budgetId: budgetId,
              onBudget: chosenType.onBudgetDefault,
              sortOrder: 0,
              walletAddress: isWalletType
                  ? walletAddressController.text.trim()
                  : null,
            );
        if (!context.mounted) return;
        isSubmitting.value = false;
        successAccountLabel.value = chosenType.label;
        step.value = _AddAccountStep.success;
      } on Exception catch (_) {
        if (!context.mounted) return;
        isSubmitting.value = false;
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.accountCreateError),
            backgroundColor: colorScheme.error,
          ),
        );
      }
    }

    return RepaintBoundary(
      key: addAccountScreenCaptureBoundaryKey,
      child: Scaffold(
        backgroundColor: OpenBudgetPalette.bgPrimaryFor(Theme.of(context)),
        appBar: AppBar(
          backgroundColor: OpenBudgetPalette.bgPrimaryFor(Theme.of(context)),
          surfaceTintColor: OpenBudgetPalette.transparentFor(Theme.of(context)),
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          leading:
              step.value == _AddAccountStep.loading ||
                  step.value == _AddAccountStep.loadingInstitutions ||
                  step.value == _AddAccountStep.searchBank
              ? null
              : IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: () {
                    if (step.value == _AddAccountStep.unlinkedAccount) {
                      step.value = _AddAccountStep.searchBank;
                    } else if (step.value == _AddAccountStep.walletConnection) {
                      step.value = _AddAccountStep.searchBank;
                    } else if (step.value == _AddAccountStep.accountType ||
                        step.value == _AddAccountStep.success) {
                      step.value = _AddAccountStep.unlinkedAccount;
                    }
                  },
                ),
          title: Text(
            switch (step.value) {
              _AddAccountStep.loading => '',
              _AddAccountStep.loadingInstitutions => 'Add Accounts',
              _AddAccountStep.searchBank => 'Add Accounts',
              _AddAccountStep.walletConnection => 'Connect Solana Wallet',
              _AddAccountStep.unlinkedAccount => 'Add Unlinked Account',
              _AddAccountStep.accountType => 'Select Account Type',
              _AddAccountStep.success => 'Account Added',
            },
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () => context.goNamed(
                accountListRoute,
                pathParameters: {'id': budgetId},
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            switch (step.value) {
              _AddAccountStep.loading => const _StepFrame(
                child: _LoadingStep(title: 'Loading...', includeSpinner: false),
              ),
              _AddAccountStep.loadingInstitutions => const _StepFrame(
                child: _LoadingStep(
                  title: 'Loading institutions...',
                  includeSpinner: true,
                ),
              ),
              _AddAccountStep.searchBank => _StepFrame(
                child: _BankSearchStep(
                  scrollController: searchScrollController,
                  searchController: searchController,
                  searchQuery: searchController.text,
                  onInstitutionTap: startLinkedBankFlow,
                  onConnectSolana: () =>
                      step.value = _AddAccountStep.walletConnection,
                  onAddUnlinked: () =>
                      step.value = _AddAccountStep.unlinkedAccount,
                ),
              ),
              _AddAccountStep.walletConnection => _StepFrame(
                maxWidth: 720,
                child: _WalletConnectStep(
                  walletAddressController: walletAddressController,
                  walletLabelController: walletLabelController,
                  onBudget: walletOnBudget.value,
                  onBudgetChanged: (value) => walletOnBudget.value = value,
                ),
              ),
              _AddAccountStep.unlinkedAccount => _StepFrame(
                maxWidth: 720,
                child: _UnlinkedAccountStep(
                  scrollController: unlinkedScrollController,
                  nameController: nameController,
                  balanceController: balanceController,
                  walletAddressController: walletAddressController,
                  showWalletAddress: isWalletType,
                  selectedTypeLabel:
                      selectedType?.label ?? 'Select account type...',
                  hasSelectedType: selectedType != null,
                  onChooseType: () => step.value = _AddAccountStep.accountType,
                ),
              ),
              _AddAccountStep.accountType => _StepFrame(
                maxWidth: 720,
                child: _AccountTypeStep(
                  scrollController: accountTypeScrollController,
                  sections: typeSections,
                  selectedTypeKey: selectedTypeKey.value,
                  onSelected: (option) {
                    selectedTypeKey.value = option.key;
                    step.value = _AddAccountStep.unlinkedAccount;
                  },
                ),
              ),
              _AddAccountStep.success => _SuccessStep(
                accountTypeLabel: successAccountLabel.value,
                onAddAnother: () {
                  nameController.clear();
                  balanceController.clear();
                  walletAddressController.clear();
                  walletLabelController.clear();
                  walletOnBudget.value = false;
                  step.value = _AddAccountStep.unlinkedAccount;
                },
                onDone: () => context.goNamed(
                  accountListRoute,
                  pathParameters: {'id': budgetId},
                ),
              ),
            },
            if (showSearchingOverlay.value)
              ColoredBox(
                color: OpenBudgetPalette.fgPrimaryFor(
                  Theme.of(context),
                ).withAlpha(120),
                child: const Center(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: SpacingTokens.lg,
                        vertical: SpacingTokens.md,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: SpacingTokens.md),
                          Text('Loading institutions...'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        bottomNavigationBar: switch (step.value) {
          _AddAccountStep.loading => null,
          _AddAccountStep.loadingInstitutions => null,
          _AddAccountStep.walletConnection => SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                SpacingTokens.md,
                SpacingTokens.sm,
                SpacingTokens.md,
                SpacingTokens.md,
              ),
              child: _StepFrame(
                maxWidth: 720,
                child: FilledButton(
                  onPressed: canSubmitWallet && !isSubmitting.value
                      ? submitSolanaWallet
                      : null,
                  child: isSubmitting.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Connect Wallet'),
                ),
              ),
            ),
          ),
          _AddAccountStep.unlinkedAccount => SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                SpacingTokens.md,
                SpacingTokens.sm,
                SpacingTokens.md,
                SpacingTokens.md,
              ),
              child: _StepFrame(
                maxWidth: 720,
                child: FilledButton(
                  onPressed: canSubmit && !isSubmitting.value
                      ? submitUnlinkedAccount
                      : null,
                  child: isSubmitting.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Next'),
                ),
              ),
            ),
          ),
          _AddAccountStep.success => null,
          _AddAccountStep.searchBank || _AddAccountStep.accountType => null,
        },
      ),
    );
  }

  Future<String?> _runPlaidLink({required String linkToken}) async {
    final completer = Completer<String?>();
    late final StreamSubscription<LinkSuccess> successSub;
    late final StreamSubscription<LinkExit> exitSub;

    successSub = PlaidLink.onSuccess.listen((event) {
      if (!completer.isCompleted) {
        completer.complete(event.publicToken);
      }
    });

    exitSub = PlaidLink.onExit.listen((_) {
      if (!completer.isCompleted) {
        completer.complete(null);
      }
    });

    try {
      await PlaidLink.create(
        configuration: LinkTokenConfiguration(token: linkToken),
      );
      await PlaidLink.open();
      return await completer.future.timeout(
        const Duration(minutes: 5),
        onTimeout: () => null,
      );
    } finally {
      await successSub.cancel();
      await exitSub.cancel();
    }
  }
}

class _StepFrame extends StatelessWidget {
  const _StepFrame({required this.child, this.maxWidth = 980});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth >= 900
            ? constraints.maxWidth.clamp(0, maxWidth).toDouble()
            : constraints.maxWidth;
        final horizontalPadding = (constraints.maxWidth - width) / 2;
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding > 0 ? horizontalPadding : 0,
          ),
          child: child,
        );
      },
    );
  }
}

class _LoadingStep extends StatelessWidget {
  const _LoadingStep({required this.title, required this.includeSpinner});

  final String title;
  final bool includeSpinner;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final logoAsset = theme.brightness == Brightness.dark
        ? 'assets/branding/logos/ob_primary_dark_512.png'
        : 'assets/branding/logos/ob_primary_light_512.png';

    final content = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.xl,
        vertical: SpacingTokens.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(RadiusTokens.lg),
            child: Image.asset(
              logoAsset,
              width: 84,
              height: 84,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.account_balance_rounded,
                size: 84,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: SpacingTokens.md),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            'This might take a few seconds.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: OpenBudgetPalette.fgSecondaryFor(Theme.of(context)),
            ),
          ),
          if (includeSpinner) ...[
            const SizedBox(height: SpacingTokens.lg),
            const SizedBox(
              height: 28,
              width: 28,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
          ],
        ],
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(child: content),
        ),
      ),
    );
  }
}

class _BankSearchStep extends StatelessWidget {
  const _BankSearchStep({
    required this.scrollController,
    required this.searchController,
    required this.searchQuery,
    required this.onInstitutionTap,
    required this.onConnectSolana,
    required this.onAddUnlinked,
  });

  final ScrollController scrollController;
  final TextEditingController searchController;
  final String searchQuery;
  final Future<void> Function(String institution) onInstitutionTap;
  final VoidCallback onConnectSolana;
  final VoidCallback onAddUnlinked;

  @override
  Widget build(BuildContext context) {
    const institutions = [
      _InstitutionOption(name: 'Chase'),
      _InstitutionOption(name: 'Capital One'),
      _InstitutionOption(name: 'American Express'),
      _InstitutionOption(name: 'Bank of America'),
      _InstitutionOption(name: 'Citi'),
      _InstitutionOption(name: 'Discover'),
      _InstitutionOption(name: 'Wells Fargo'),
      _InstitutionOption(name: 'Apple Card'),
    ];
    final normalizedQuery = searchQuery.trim().toLowerCase();
    final filteredInstitutions = normalizedQuery.isEmpty
        ? institutions
        : institutions
              .where(
                (institution) =>
                    institution.name.toLowerCase().contains(normalizedQuery),
              )
              .toList(growable: false);
    final sectionTitle = normalizedQuery.isEmpty
        ? 'Popular Options'
        : 'Search Results';

    return ListView(
      key: _addAccountSearchScrollKey,
      controller: scrollController,
      primary: false,
      padding: const EdgeInsets.fromLTRB(
        SpacingTokens.md,
        SpacingTokens.md,
        SpacingTokens.md,
        SpacingTokens.xl,
      ),
      children: [
        Text(
          'Search for your bank',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: SpacingTokens.sm),
        Text(
          'Search by institution name',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: SpacingTokens.xs),
        TextField(
          controller: searchController,
          onSubmitted: (_) => FocusScope.of(context).unfocus(),
          textInputAction: TextInputAction.search,
        ),
        const SizedBox(height: SpacingTokens.xs),
        Text(
          'Search by institution name or web address (URL)',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: OpenBudgetPalette.fgSecondaryFor(Theme.of(context)),
          ),
        ),
        const SizedBox(height: SpacingTokens.md),
        Text(
          sectionTitle,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: SpacingTokens.sm),
        if (filteredInstitutions.isEmpty)
          Container(
            padding: const EdgeInsets.all(SpacingTokens.md),
            decoration: BoxDecoration(
              color: OpenBudgetPalette.bgSecondaryFor(Theme.of(context)),
              border: Border.all(
                color: OpenBudgetPalette.borderSubtleFor(Theme.of(context)),
              ),
              borderRadius: BorderRadius.circular(RadiusTokens.md),
            ),
            child: Text(
              'No institutions found. Try another name or add an unlinked account.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: OpenBudgetPalette.fgSecondaryFor(Theme.of(context)),
              ),
            ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final tileWidth = (constraints.maxWidth - SpacingTokens.sm) / 2;
              return Wrap(
                spacing: SpacingTokens.sm,
                runSpacing: SpacingTokens.sm,
                children: [
                  for (final institution in filteredInstitutions)
                    SizedBox(
                      width: tileWidth,
                      child: _InstitutionTile(
                        option: institution,
                        onTap: () => onInstitutionTap(institution.name),
                      ),
                    ),
                ],
              );
            },
          ),
        const SizedBox(height: SpacingTokens.md),
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.sm),
              child: Text(
                'or',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: OpenBudgetPalette.fgSecondaryFor(Theme.of(context)),
                ),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: SpacingTokens.md),
        OutlinedButton(
          key: _addAccountAddUnlinkedButtonKey,
          onPressed: onAddUnlinked,
          child: const Text('Add an Unlinked Account'),
        ),
        const SizedBox(height: SpacingTokens.sm),
        FilledButton.icon(
          onPressed: onConnectSolana,
          icon: const Icon(Icons.currency_bitcoin_rounded),
          label: const Text('Connect Solana Wallet'),
        ),
      ],
    );
  }
}

class _InstitutionTile extends StatelessWidget {
  const _InstitutionTile({required this.option, required this.onTap});

  final _InstitutionOption option;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(RadiusTokens.md),
      child: Container(
        height: 84,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: OpenBudgetPalette.bgSecondaryFor(Theme.of(context)),
          border: Border.all(
            color: OpenBudgetPalette.borderSubtleFor(Theme.of(context)),
          ),
          borderRadius: BorderRadius.circular(RadiusTokens.md),
        ),
        child: Text(
          option.name,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

@immutable
class _InstitutionOption {
  const _InstitutionOption({required this.name});

  final String name;
}

class _WalletConnectStep extends StatelessWidget {
  const _WalletConnectStep({
    required this.walletAddressController,
    required this.walletLabelController,
    required this.onBudget,
    required this.onBudgetChanged,
  });

  final TextEditingController walletAddressController;
  final TextEditingController walletLabelController;
  final bool onBudget;
  final ValueChanged<bool> onBudgetChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        SpacingTokens.md,
        SpacingTokens.md,
        SpacingTokens.md,
        SpacingTokens.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Connect a Solana wallet in read-only mode. '
            'OpenBudget imports native SPL balances and keeps fiat valuation synced.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: OpenBudgetPalette.fgSecondaryFor(theme),
            ),
          ),
          const SizedBox(height: SpacingTokens.md),
          Text(
            'Wallet Address',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: SpacingTokens.xs),
          TextField(
            key: _addAccountWalletAddressFieldKey,
            controller: walletAddressController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              hintText: 'Paste Solana wallet address',
            ),
          ),
          const SizedBox(height: SpacingTokens.md),
          Text(
            'Wallet Label (optional)',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: SpacingTokens.xs),
          TextField(
            key: _addAccountWalletLabelFieldKey,
            controller: walletLabelController,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(hintText: 'My Solana Wallet'),
          ),
          const SizedBox(height: SpacingTokens.md),
          SwitchListTile(
            title: const Text('Include in budget totals'),
            value: onBudget,
            onChanged: onBudgetChanged,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}

class _UnlinkedAccountStep extends StatelessWidget {
  const _UnlinkedAccountStep({
    required this.scrollController,
    required this.nameController,
    required this.balanceController,
    required this.walletAddressController,
    required this.showWalletAddress,
    required this.selectedTypeLabel,
    required this.hasSelectedType,
    required this.onChooseType,
  });

  final ScrollController scrollController;
  final TextEditingController nameController;
  final TextEditingController balanceController;
  final TextEditingController walletAddressController;
  final bool showWalletAddress;
  final String selectedTypeLabel;
  final bool hasSelectedType;
  final VoidCallback onChooseType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primaryTextColor = theme.brightness == Brightness.dark
        ? theme.colorScheme.onSurface
        : OpenBudgetPalette.fgIconStrongFor(Theme.of(context));
    final secondaryTextColor = theme.brightness == Brightness.dark
        ? theme.colorScheme.onSurfaceVariant
        : OpenBudgetPalette.fgSecondaryFor(Theme.of(context));
    final headingStyle =
        (theme.textTheme.titleSmall ??
                const TextStyle(fontSize: 21, fontWeight: FontWeight.w600))
            .copyWith(fontWeight: FontWeight.w700, color: primaryTextColor);
    final introStyle =
        (theme.textTheme.bodyMedium ??
                const TextStyle(fontSize: 17, fontWeight: FontWeight.w400))
            .copyWith(color: secondaryTextColor);
    final formValueStyle =
        (theme.textTheme.bodyLarge ??
                const TextStyle(fontSize: 20, fontWeight: FontWeight.w500))
            .copyWith(color: primaryTextColor);
    final formHintStyle =
        (theme.textTheme.bodyLarge ??
                const TextStyle(fontSize: 20, fontWeight: FontWeight.w500))
            .copyWith(color: secondaryTextColor.withAlpha(220));
    final introText = showWalletAddress
        ? 'Add your Solana wallet to track transfers, swaps, and holdings in one place.'
        : "Bank connections are currently unavailable in this build, so let's set up an unlinked account.";

    return SingleChildScrollView(
      key: _addAccountUnlinkedScrollKey,
      controller: scrollController,
      primary: false,
      padding: const EdgeInsets.fromLTRB(
        SpacingTokens.md,
        SpacingTokens.md,
        SpacingTokens.md,
        SpacingTokens.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(introText, style: introStyle),
          const SizedBox(height: SpacingTokens.md),
          Text('Give it a nickname', style: headingStyle),
          const SizedBox(height: SpacingTokens.xs),
          TextField(
            key: _addAccountUnlinkedNicknameFieldKey,
            controller: nameController,
            textInputAction: TextInputAction.next,
            style: formValueStyle,
            decoration: InputDecoration(
              hintText: 'Enter nickname',
              hintStyle: formHintStyle,
            ),
          ),
          const SizedBox(height: SpacingTokens.md),
          Text('What type of account are you adding?', style: headingStyle),
          const SizedBox(height: SpacingTokens.xs),
          ListTile(
            key: _addAccountUnlinkedTypeTileKey,
            onTap: onChooseType,
            title: Text(
              selectedTypeLabel,
              style: formValueStyle.copyWith(
                color: hasSelectedType ? primaryTextColor : secondaryTextColor,
                fontWeight: hasSelectedType ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: SpacingTokens.sm,
            ),
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: OpenBudgetPalette.borderSubtleFor(Theme.of(context)),
              ),
              borderRadius: BorderRadius.circular(RadiusTokens.md),
            ),
          ),
          const SizedBox(height: SpacingTokens.md),
          if (showWalletAddress) ...[
            Container(
              padding: const EdgeInsets.all(SpacingTokens.md),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withAlpha(120),
                borderRadius: BorderRadius.circular(RadiusTokens.md),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.wallet_outlined, color: colorScheme.primary),
                  const SizedBox(width: SpacingTokens.sm),
                  Expanded(
                    child: Text(
                      'OpenBudget will auto-sync transactions and holdings after wallet setup. '
                      'You can tag and categorize activity in account details.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: SpacingTokens.md),
            Text('What is your Solana wallet address?', style: headingStyle),
            const SizedBox(height: SpacingTokens.xs),
            TextField(
              key: _addAccountUnlinkedWalletAddressFieldKey,
              controller: walletAddressController,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.done,
              style: formValueStyle.copyWith(fontFamily: 'monospace'),
              decoration: InputDecoration(
                hintText: 'e.g. 5xQf...w8bP',
                hintStyle: formHintStyle,
              ),
            ),
            const SizedBox(height: SpacingTokens.xs),
            Text(
              'Only public wallet addresses are supported.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: secondaryTextColor,
              ),
            ),
          ] else ...[
            Text('What is your current account balance?', style: headingStyle),
            const SizedBox(height: SpacingTokens.xs),
            TextField(
              key: _addAccountUnlinkedBalanceFieldKey,
              controller: balanceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              textInputAction: TextInputAction.done,
              style: formValueStyle,
              decoration: InputDecoration(
                hintText: '5000',
                hintStyle: formHintStyle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AccountTypeStep extends StatelessWidget {
  const _AccountTypeStep({
    required this.scrollController,
    required this.sections,
    required this.selectedTypeKey,
    required this.onSelected,
  });

  final ScrollController scrollController;
  final List<_AccountTypeSection> sections;
  final String? selectedTypeKey;
  final ValueChanged<_AccountTypeOption> onSelected;

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController,
      primary: false,
      padding: const EdgeInsets.fromLTRB(
        SpacingTokens.md,
        SpacingTokens.sm,
        SpacingTokens.md,
        SpacingTokens.xl,
      ),
      children: [
        for (final section in sections) ...[
          Text(
            section.title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            section.subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: OpenBudgetPalette.fgSecondaryFor(Theme.of(context)),
            ),
          ),
          const SizedBox(height: SpacingTokens.sm),
          for (final option in section.options) ...[
            ListTile(
              key: ValueKey('add-account-type-option-${option.key}'),
              onTap: () => onSelected(option),
              title: Text(option.label),
              trailing: option.key == selectedTypeKey
                  ? Icon(
                      Icons.check_rounded,
                      color: OpenBudgetPalette.bgBrandFor(Theme.of(context)),
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.sm,
              ),
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: OpenBudgetPalette.borderSubtleFor(Theme.of(context)),
                ),
                borderRadius: BorderRadius.circular(RadiusTokens.md),
              ),
            ),
            const SizedBox(height: SpacingTokens.xs),
          ],
          const SizedBox(height: SpacingTokens.md),
        ],
      ],
    );
  }
}

class _SuccessStep extends StatelessWidget {
  const _SuccessStep({
    required this.accountTypeLabel,
    required this.onAddAnother,
    required this.onDone,
  });

  final String accountTypeLabel;
  final VoidCallback onAddAnother;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: _StepFrame(
        maxWidth: 720,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            SpacingTokens.md,
            SpacingTokens.md,
            SpacingTokens.md,
            SpacingTokens.md,
          ),
          child: Column(
            children: [
              Icon(
                Icons.check_circle_rounded,
                size: 72,
                color: OpenBudgetPalette.fgSuccessFor(Theme.of(context)),
              ),
              const SizedBox(height: SpacingTokens.md),
              Text(
                'Success!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: SpacingTokens.xs),
              Text(
                '$accountTypeLabel account added to OpenBudget.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: OpenBudgetPalette.fgSecondaryFor(Theme.of(context)),
                ),
              ),
              const SizedBox(height: SpacingTokens.xl),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onAddAnother,
                      child: const Text('Add Another'),
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.sm),
                  Expanded(
                    child: FilledButton(
                      onPressed: onDone,
                      child: const Text('Done'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

@immutable
class _AccountTypeOption {
  const _AccountTypeOption({
    required this.key,
    required this.label,
    required this.serverType,
    required this.onBudgetDefault,
    required this.isDebt,
  });

  final String key;
  final String label;
  final String serverType;
  final bool onBudgetDefault;
  final bool isDebt;
}

@immutable
class _AccountTypeSection {
  const _AccountTypeSection({
    required this.title,
    required this.subtitle,
    required this.options,
  });

  final String title;
  final String subtitle;
  final List<_AccountTypeOption> options;
}

List<_AccountTypeSection> _accountTypeSections(AppLocalizations l10n) {
  return [
    _AccountTypeSection(
      title: 'Cash Accounts',
      subtitle:
          'Cash accounts hold funds you already own and can spend immediately.',
      options: [
        _AccountTypeOption(
          key: 'checking',
          label: l10n.accountTypeChecking,
          serverType: 'checking',
          onBudgetDefault: true,
          isDebt: false,
        ),
        _AccountTypeOption(
          key: 'savings',
          label: l10n.accountTypeSavings,
          serverType: 'savings',
          onBudgetDefault: true,
          isDebt: false,
        ),
        _AccountTypeOption(
          key: 'cash',
          label: l10n.accountTypeCash,
          serverType: 'cash',
          onBudgetDefault: true,
          isDebt: false,
        ),
      ],
    ),
    _AccountTypeSection(
      title: 'Credit Accounts',
      subtitle:
          "A credit account lets you spend borrowed money that you'll need to repay later, often with interest.",
      options: [
        _AccountTypeOption(
          key: 'creditCard',
          label: l10n.accountTypeCreditCard,
          serverType: 'creditCard',
          onBudgetDefault: true,
          isDebt: true,
        ),
        const _AccountTypeOption(
          key: 'lineOfCredit',
          label: 'Line of Credit',
          serverType: 'other',
          onBudgetDefault: true,
          isDebt: true,
        ),
      ],
    ),
    const _AccountTypeSection(
      title: 'Mortgages and Loans',
      subtitle:
          "Accounts that have an outstanding balance you're currently paying off, and aren't spending from.",
      options: [
        _AccountTypeOption(
          key: 'mortgage',
          label: 'Mortgage',
          serverType: 'other',
          onBudgetDefault: false,
          isDebt: true,
        ),
        _AccountTypeOption(
          key: 'autoLoan',
          label: 'Auto Loan',
          serverType: 'other',
          onBudgetDefault: false,
          isDebt: true,
        ),
        _AccountTypeOption(
          key: 'studentLoan',
          label: 'Student Loan',
          serverType: 'other',
          onBudgetDefault: false,
          isDebt: true,
        ),
        _AccountTypeOption(
          key: 'personalLoan',
          label: 'Personal Loan',
          serverType: 'other',
          onBudgetDefault: false,
          isDebt: true,
        ),
        _AccountTypeOption(
          key: 'medicalDebt',
          label: 'Medical Debt',
          serverType: 'other',
          onBudgetDefault: false,
          isDebt: true,
        ),
        _AccountTypeOption(
          key: 'otherDebt',
          label: 'Other Debt',
          serverType: 'other',
          onBudgetDefault: false,
          isDebt: true,
        ),
      ],
    ),
    const _AccountTypeSection(
      title: 'Tracking Accounts',
      subtitle:
          "Accounts that hold money you don't plan to spend soon, such as investments or loans.",
      options: [
        _AccountTypeOption(
          key: 'asset',
          label: 'Asset (e.g. Investment)',
          serverType: 'investment',
          onBudgetDefault: false,
          isDebt: false,
        ),
        _AccountTypeOption(
          key: 'liability',
          label: 'Liability',
          serverType: 'other',
          onBudgetDefault: false,
          isDebt: true,
        ),
      ],
    ),
    const _AccountTypeSection(
      title: 'Digital Assets',
      subtitle:
          'Track a Solana wallet with automatic transaction history and asset valuations.',
      options: [
        _AccountTypeOption(
          key: 'cryptoWallet',
          label: 'Solana Wallet',
          serverType: 'cryptoWallet',
          onBudgetDefault: false,
          isDebt: false,
        ),
      ],
    ),
  ];
}

double _pow10(int exponent) {
  var result = 1.0;
  for (var i = 0; i < exponent; i++) {
    result *= 10;
  }
  return result;
}

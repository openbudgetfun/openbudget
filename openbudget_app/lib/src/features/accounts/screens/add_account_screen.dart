import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_actions_provider.dart';
import 'package:openbudget_app/src/features/accounts/providers/institution_catalog_provider.dart';
import 'package:openbudget_app/src/features/accounts/providers/plaid_account_link_provider.dart';
import 'package:openbudget_app/src/features/accounts/widgets/add_wallet_step.dart';
import 'package:openbudget_app/src/features/home/providers/entity_detail_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_app/src/utils/money_input.dart';
import 'package:openbudget_app/src/widgets/app_toast.dart';
import 'package:openbudget_client/openbudget_client.dart';
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
const _addAccountUnlinkedWalletAddressFieldKey = Key(
  'add-account-unlinked-wallet-address-field',
);

String _resolveLocationCode() {
  final locale = PlatformDispatcher.instance.locale;
  final countryCode = locale.countryCode?.trim().toUpperCase();
  if (countryCode != null && countryCode.isNotEmpty) {
    return countryCode;
  }
  return 'US';
}

class AddAccountScreen extends HookConsumerWidget {
  const AddAccountScreen({required this.entityId, super.key});

  final String entityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final step = useState(_AddAccountStep.loading);
    final nameController = useTextEditingController();
    final balanceController = useTextEditingController();
    final walletAddressController = useTextEditingController();
    final searchController = useTextEditingController();
    final isSubmitting = useState(false);
    final selectedTypeKey = useState<String?>(null);
    final selectedCurrency = useState<CurrencyCode?>(null);
    final trackByValue = useState(false);
    final openingToday = useState(true);
    final onBudget = useState(true);
    final openingDate = useState<DateTime?>(null);
    final successAccountLabel = useState<String>(l10n.accountTypeOther);
    final showSearchingOverlay = useState(false);
    final selectedInstitution = useState<Institution?>(null);
    final locationCode = useMemoized(_resolveLocationCode);
    // Keep step scroll state ephemeral so returning between wizard steps always
    // starts from the top instead of restoring page-storage offsets.
    final searchScrollController = useScrollController(keepScrollOffset: false);
    final unlinkedScrollController = useScrollController(
      keepScrollOffset: false,
    );
    final accountTypeScrollController = useScrollController(
      keepScrollOffset: false,
    );
    final entityAsync = ref.watch(entityDetailProvider(entityId));
    final institutionCatalogAsync = ref.watch(
      institutionCatalogProvider(locationCode),
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
    final baseCurrency = CurrencyCode.tryParse(
      entityAsync.value?.baseCurrencyCode ?? '',
    );
    final accountCurrency = selectedCurrency.value ?? baseCurrency;
    final isLiabilityKind = selectedType?.kind.isLiability ?? false;
    final sourceChoices = selectedType?.kind.allowedBalanceSources ?? const {};
    final canChooseSource = sourceChoices.length > 1;
    final balanceSource = canChooseSource
        ? (trackByValue.value
              ? AccountBalanceSource.valuations
              : AccountBalanceSource.transactions)
        : (sourceChoices.firstOrNull ?? AccountBalanceSource.transactions);

    useListenable(nameController);
    useListenable(balanceController);
    useListenable(walletAddressController);
    useListenable(searchController);

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

    final balanceDecimals = accountCurrency?.decimals ?? 2;
    final balanceValue = parseMoneyInput(
      balanceController.text,
      decimals: balanceDecimals,
      allowNegative: true,
    );
    final isWalletType = selectedType?.kind == AccountKind.crypto;
    final canSubmit =
        selectedType != null &&
        nameController.text.trim().isNotEmpty &&
        (isWalletType
            ? walletAddressController.text.trim().isNotEmpty
            : balanceValue != null);
    final institutionCatalog =
        institutionCatalogAsync.asData?.value ?? const <Institution>[];

    Future<void> startLinkedBankFlow(Institution institution) async {
      final institutionName = institution.name.trim();
      if (showSearchingOverlay.value || institutionName.isEmpty) return;
      selectedInstitution.value = institution;

      final isMobilePlaidPlatform =
          !kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.android);
      if (!isMobilePlaidPlatform) {
        showSearchingOverlay.value = true;
        try {
          final imported = await ref
              .read(plaidAccountLinkProvider.notifier)
              .importSandboxAccounts(
                entityId: entityId,
                plaidInstitutionId: institution.plaidInstitutionId,
              );

          if (!context.mounted) return;
          if (imported.plaidItemId.isNotEmpty) {
            context.goNamed(
              accountListRoute,
              pathParameters: {'entityId': entityId},
            );
            return;
          }
        } on Exception catch (_) {
          // Fall back to unlinked setup while preserving institution context.
        } finally {
          showSearchingOverlay.value = false;
        }

        step.value = _AddAccountStep.unlinkedAccount;
        showAppToast(
          context,
          message: l10n.accountsLinkedMobileOnly,
          variant: AppToastVariant.warning,
        );
        return;
      }

      showSearchingOverlay.value = true;
      try {
        final linkToken = await ref
            .read(plaidAccountLinkProvider.notifier)
            .createLinkToken(entityId: entityId);
        final publicToken = await _runPlaidLink(linkToken: linkToken);
        if (!context.mounted) return;

        if (publicToken == null || publicToken.isEmpty) {
          step.value = _AddAccountStep.unlinkedAccount;
          showAppToast(
            context,
            message: l10n.accountsLinkedNotCompleted(institutionName),
            variant: AppToastVariant.warning,
          );
          return;
        }

        final imported = await ref
            .read(plaidAccountLinkProvider.notifier)
            .exchangePublicToken(entityId: entityId, publicToken: publicToken);
        if (!context.mounted) return;

        if (imported.plaidItemId.isEmpty) {
          step.value = _AddAccountStep.unlinkedAccount;
          showAppToast(
            context,
            message: l10n.accountsLinkedNothingImported,
            variant: AppToastVariant.warning,
          );
          return;
        }

        context.goNamed(
          accountListRoute,
          pathParameters: {'entityId': entityId},
        );
      } on Exception catch (_) {
        if (!context.mounted) return;
        step.value = _AddAccountStep.unlinkedAccount;
        showAppToast(
          context,
          message: l10n.accountsLinkedUnavailable(institutionName),
          variant: AppToastVariant.error,
        );
      } finally {
        showSearchingOverlay.value = false;
      }
    }

    Future<void> submitUnlinkedAccount() async {
      if (!canSubmit || isSubmitting.value) return;
      final chosenTypeKey = selectedTypeKey.value;
      if (chosenTypeKey == null || chosenTypeKey.isEmpty) return;
      final chosenType = selectedType;

      isSubmitting.value = true;

      final parsedBalance = balanceValue ?? 0;
      final openingMinor = isLiabilityKind
          ? -parsedBalance.abs()
          : parsedBalance;
      final chosenDate = openingDate.value;
      final date = openingToday.value || chosenDate == null
          ? null
          : DateTime.utc(chosenDate.year, chosenDate.month, chosenDate.day);

      try {
        await ref
            .read(accountActionsProvider.notifier)
            .createAccount(
              entityId: entityId,
              name: nameController.text.trim(),
              kind: chosenType.kind,
              currencyCode: accountCurrency?.code ?? '',
              balanceSource: balanceSource,
              onBudget: chosenType.kind.canBeOnBudget && onBudget.value,
              openingBalanceMinor: openingMinor == 0 ? null : openingMinor,
              openingDate: date,
              institutionId: selectedInstitution.value?.id?.toString(),
            );
        if (!context.mounted) return;
        isSubmitting.value = false;
        successAccountLabel.value = chosenType.label;
        step.value = _AddAccountStep.success;
      } on Exception catch (_) {
        if (!context.mounted) return;
        isSubmitting.value = false;
        showAppToast(
          context,
          message: l10n.accountCreateError,
          variant: AppToastVariant.error,
        );
      }
    }

    return RepaintBoundary(
      key: addAccountScreenCaptureBoundaryKey,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading:
              step.value == _AddAccountStep.loading ||
                  step.value == _AddAccountStep.loadingInstitutions ||
                  step.value == _AddAccountStep.searchBank
              ? null
              : IconButton(
                  icon: const SkribbleIcon(data: OpenBudgetIcons.back),
                  tooltip: l10n.accountsBackAction,
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
              _AddAccountStep.loadingInstitutions =>
                l10n.budgetOnboardingAddAccountsCta,
              _AddAccountStep.searchBank => l10n.budgetOnboardingAddAccountsCta,
              _AddAccountStep.walletConnection => l10n.addAccountConnectWallet,
              _AddAccountStep.unlinkedAccount => l10n.addAccountUnlinkedTitle,
              _AddAccountStep.accountType => l10n.addAccountSelectAccountType,
              _AddAccountStep.success => l10n.addAccountSuccessTitle,
            },
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            IconButton(
              icon: const SkribbleIcon(data: OpenBudgetIcons.close),
              tooltip: l10n.accountsCloseAction,
              onPressed: () => context.goNamed(
                accountListRoute,
                pathParameters: {'entityId': entityId},
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            switch (step.value) {
              _AddAccountStep.loading => const _StepFrame(
                child: _LoadingStep(titleKey: _LoadingStepKey.loading),
              ),
              _AddAccountStep.loadingInstitutions => const _StepFrame(
                child: _LoadingStep(
                  titleKey: _LoadingStepKey.loadingInstitutions,
                ),
              ),
              _AddAccountStep.searchBank => _StepFrame(
                child: _BankSearchStep(
                  scrollController: searchScrollController,
                  searchController: searchController,
                  searchQuery: searchController.text,
                  institutions: institutionCatalog,
                  isLoadingInstitutions: institutionCatalogAsync.isLoading,
                  onInstitutionTap: startLinkedBankFlow,
                  onAddWallet: () =>
                      step.value = _AddAccountStep.walletConnection,
                  onAddUnlinked: () {
                    selectedInstitution.value = null;
                    step.value = _AddAccountStep.unlinkedAccount;
                  },
                ),
              ),
              _AddAccountStep.walletConnection => _StepFrame(
                maxWidth: 720,
                child: AddWalletStep(
                  entityId: entityId,
                  onDone: () => context.goNamed(
                    accountListRoute,
                    pathParameters: {'entityId': entityId},
                  ),
                ),
              ),
              _AddAccountStep.unlinkedAccount => _StepFrame(
                maxWidth: 720,
                child: _UnlinkedAccountStep(
                  scrollController: unlinkedScrollController,
                  nameController: nameController,
                  balanceController: balanceController,
                  currencyDecimals: balanceDecimals,
                  currencyCode: accountCurrency?.code ?? '',
                  canPickCurrency: true,
                  onPickCurrency: () async {
                    final picked = await _selectCurrency(
                      context,
                      accountCurrency,
                    );
                    if (picked != null) selectedCurrency.value = picked;
                  },
                  walletAddressController: walletAddressController,
                  showWalletAddress: isWalletType,
                  selectedTypeLabel:
                      selectedType?.label ??
                      l10n.addAccountSelectTypePlaceholder,
                  hasSelectedType: selectedType != null,
                  canBeOnBudget: selectedType?.kind.canBeOnBudget ?? false,
                  onBudget: onBudget.value,
                  onBudgetChanged: (value) => onBudget.value = value,
                  canChooseSource: canChooseSource,
                  trackByValue: trackByValue.value,
                  onTrackByValueChanged: (value) => trackByValue.value = value,
                  openingToday: openingToday.value,
                  onOpeningTodayChanged: (value) => openingToday.value = value,
                  selectedInstitutionName: selectedInstitution.value?.name,
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
                  selectedInstitution.value = null;
                  step.value = _AddAccountStep.unlinkedAccount;
                },
                onDone: () => context.goNamed(
                  accountListRoute,
                  pathParameters: {'entityId': entityId},
                ),
              ),
            },
            if (showSearchingOverlay.value)
              ColoredBox(
                color: theme.ob.ink.withValues(alpha: 0.45),
                child: Center(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: SpacingTokens.lg,
                        vertical: SpacingTokens.md,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: SpacingTokens.md),
                          Text(l10n.addAccountLoadingInstitutions),
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
                      : Text(l10n.dialogNext),
                ),
              ),
            ),
          ),
          _AddAccountStep.success => null,
          _AddAccountStep.walletConnection ||
          _AddAccountStep.searchBank ||
          _AddAccountStep.accountType => null,
        },
      ),
    );
  }

  Future<CurrencyCode?> _selectCurrency(
    BuildContext context,
    CurrencyCode? current,
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
            selected: currency == current,
            trailing: currency == current
                ? const SkribbleIcon(data: OpenBudgetIcons.check)
                : null,
            onTap: () => Navigator.of(context).pop(currency),
          );
        },
      ),
    ),
  );

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

class _StepFrame extends HookWidget {
  const _StepFrame({required this.child, this.maxWidth = 980});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
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

enum _LoadingStepKey { loading, loadingInstitutions }

class _LoadingStep extends HookWidget {
  const _LoadingStep({required this.titleKey});

  final _LoadingStepKey titleKey;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final title = switch (titleKey) {
      _LoadingStepKey.loading => l10n.loadingTitle,
      _LoadingStepKey.loadingInstitutions => l10n.addAccountLoadingInstitutions,
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 300;
        final content = Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? SpacingTokens.lg : SpacingTokens.xl,
            vertical: compact ? SpacingTokens.md : SpacingTokens.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: compact ? 56 : 76,
                height: compact ? 56 : 76,
                alignment: Alignment.center,
                decoration: ObRoughDecoration(
                  color: palette.wash(ObTone.brand),
                  outline: palette.quietPen,
                  radius: RadiusTokens.lg,
                  seed: 23,
                ),
                child: SkribbleIcon(
                  data: OpenBudgetIcons.bank,
                  size: compact ? 28 : 38,
                  color: palette.hue(ObTone.brand),
                ),
              ),
              SizedBox(height: compact ? SpacingTokens.xs : SpacingTokens.sm),
              ObLoadingPanel(label: title),
              if (!compact)
                Text(
                  l10n.loadingHint,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: palette.mutedInk,
                  ),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        );
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(child: content),
          ),
        );
      },
    );
  }
}

class _BankSearchStep extends HookWidget {
  const _BankSearchStep({
    required this.scrollController,
    required this.searchController,
    required this.searchQuery,
    required this.institutions,
    required this.isLoadingInstitutions,
    required this.onInstitutionTap,
    required this.onAddWallet,
    required this.onAddUnlinked,
  });

  final ScrollController scrollController;
  final TextEditingController searchController;
  final String searchQuery;
  final List<Institution> institutions;
  final bool isLoadingInstitutions;
  final Future<void> Function(Institution institution) onInstitutionTap;
  final VoidCallback onAddWallet;
  final VoidCallback onAddUnlinked;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final normalizedQuery = searchQuery.trim().toLowerCase();
    final popularInstitutions = institutions.take(8).toList(growable: false);
    final filteredInstitutions = normalizedQuery.isEmpty
        ? popularInstitutions
        : institutions
              .where(
                (institution) =>
                    institution.name.toLowerCase().contains(normalizedQuery) ||
                    (institution.website ?? '').toLowerCase().contains(
                      normalizedQuery,
                    ),
              )
              .toList(growable: false);
    final sectionTitle = normalizedQuery.isEmpty
        ? l10n.addAccountPopularOptions
        : l10n.searchResults;

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
          l10n.addAccountSearchForBank,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: SpacingTokens.sm),
        Text(
          l10n.addAccountSearchByInstitutionName,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: SpacingTokens.xs),
        TextField(
          controller: searchController,
          onSubmitted: (_) => FocusScope.of(context).unfocus(),
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            prefixIcon: ObFieldIcon(data: OpenBudgetIcons.search),
          ),
        ),
        const SizedBox(height: SpacingTokens.xs),
        Text(
          l10n.addAccountSearchHint,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).ob.mutedInk,
          ),
        ),
        const SizedBox(height: SpacingTokens.md),
        ObSectionHeader(
          title: sectionTitle,
          padding: EdgeInsets.zero,
        ),
        const SizedBox(height: SpacingTokens.sm),
        if (isLoadingInstitutions)
          ObLoadingPanel(label: l10n.addAccountLoadingInstitutions)
        else if (filteredInstitutions.isEmpty)
          ObStatePanel.empty(
            title: l10n.addAccountNoInstitutionsFound,
            doodle: WiredDoodleKind.cloud,
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
                        onTap: () => onInstitutionTap(institution),
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
                l10n.orText,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).ob.mutedInk,
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
          child: Text(l10n.addAccountAddUnlinked),
        ),
        const SizedBox(height: SpacingTokens.sm),
        FilledButton.icon(
          onPressed: onAddWallet,
          icon: const SkribbleIcon(data: OpenBudgetIcons.wallet),
          label: Text(l10n.addAccountConnectWallet),
        ),
      ],
    );
  }
}

class _InstitutionTile extends HookWidget {
  const _InstitutionTile({required this.option, required this.onTap});

  final Institution option;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ObCard(
    onTap: onTap,
    child: SizedBox(
      height: 84,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.sm),
          child: Text(
            option.name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).ob.ink,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ),
  );
}

class _UnlinkedAccountStep extends HookWidget {
  const _UnlinkedAccountStep({
    required this.scrollController,
    required this.nameController,
    required this.balanceController,
    required this.currencyDecimals,
    required this.currencyCode,
    required this.canPickCurrency,
    required this.onPickCurrency,
    required this.walletAddressController,
    required this.showWalletAddress,
    required this.selectedTypeLabel,
    required this.hasSelectedType,
    required this.canBeOnBudget,
    required this.onBudget,
    required this.onBudgetChanged,
    required this.canChooseSource,
    required this.trackByValue,
    required this.onTrackByValueChanged,
    required this.openingToday,
    required this.onOpeningTodayChanged,
    required this.selectedInstitutionName,
    required this.onChooseType,
  });

  final ScrollController scrollController;
  final TextEditingController nameController;
  final TextEditingController balanceController;
  final int currencyDecimals;
  final String currencyCode;
  final bool canPickCurrency;
  final VoidCallback onPickCurrency;
  final TextEditingController walletAddressController;
  final bool showWalletAddress;
  final String selectedTypeLabel;
  final bool hasSelectedType;
  final bool canBeOnBudget;
  final bool onBudget;
  final ValueChanged<bool> onBudgetChanged;
  final bool canChooseSource;
  final bool trackByValue;
  final ValueChanged<bool> onTrackByValueChanged;
  final bool openingToday;
  final ValueChanged<bool> onOpeningTodayChanged;
  final String? selectedInstitutionName;
  final VoidCallback onChooseType;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final headingStyle = theme.textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w700,
      color: palette.ink,
    );
    final introStyle = theme.textTheme.bodyMedium?.copyWith(
      color: palette.mutedInk,
    );
    final formValueStyle = theme.textTheme.bodyLarge?.copyWith(
      color: palette.ink,
    );
    final introText = showWalletAddress
        ? l10n.addAccountWalletIntro
        : l10n.addAccountUnlinkedIntro;
    final balanceError = moneyInputError(
      balanceController.text,
      decimals: currencyDecimals,
      allowNegative: true,
      message: l10n.amountInvalidFormat(currencyDecimals),
    );

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
          if (selectedInstitutionName != null &&
              selectedInstitutionName!.trim().isNotEmpty) ...[
            const SizedBox(height: SpacingTokens.sm),
            ObCard(
              tone: ObTone.brand,
              padding: const EdgeInsets.all(SpacingTokens.sm),
              child: Row(
                children: [
                  SkribbleIcon(
                    data: OpenBudgetIcons.bank,
                    size: 18,
                    color: palette.hue(ObTone.brand),
                  ),
                  const SizedBox(width: SpacingTokens.xs),
                  Expanded(
                    child: Text(
                      l10n.accountsInstitutionLabel(selectedInstitutionName!),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: palette.ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: SpacingTokens.md),
          Text(l10n.addAccountNicknameQuestion, style: headingStyle),
          const SizedBox(height: SpacingTokens.xs),
          TextField(
            key: _addAccountUnlinkedNicknameFieldKey,
            controller: nameController,
            textInputAction: TextInputAction.next,
            style: formValueStyle,
            decoration: InputDecoration(
              hintText: l10n.addAccountNicknameHint,
            ),
          ),
          const SizedBox(height: SpacingTokens.md),
          Text(l10n.addAccountTypeQuestion, style: headingStyle),
          const SizedBox(height: SpacingTokens.xs),
          ObCard(
            child: ListTile(
              key: _addAccountUnlinkedTypeTileKey,
              onTap: onChooseType,
              title: Text(
                selectedTypeLabel,
                style: formValueStyle?.copyWith(
                  color: hasSelectedType ? palette.ink : palette.mutedInk,
                  fontWeight: hasSelectedType
                      ? FontWeight.w600
                      : FontWeight.w500,
                ),
              ),
              trailing: const SkribbleIcon(
                data: OpenBudgetIcons.chevronRight,
                size: 20,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.sm,
              ),
            ),
          ),
          const SizedBox(height: SpacingTokens.md),
          if (showWalletAddress) ...[
            ObCard(
              tone: ObTone.brand,
              padding: const EdgeInsets.all(SpacingTokens.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkribbleIcon(
                    data: OpenBudgetIcons.wallet,
                    color: palette.hue(ObTone.brand),
                  ),
                  const SizedBox(width: SpacingTokens.sm),
                  Expanded(
                    child: Text(
                      l10n.addAccountWalletAutoSyncHint,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: palette.ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: SpacingTokens.md),
            Text(l10n.addAccountWalletAddressQuestion, style: headingStyle),
            const SizedBox(height: SpacingTokens.xs),
            TextField(
              key: _addAccountUnlinkedWalletAddressFieldKey,
              controller: walletAddressController,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.done,
              style: formValueStyle?.copyWith(fontFamily: 'monospace'),
              decoration: InputDecoration(
                hintText: l10n.addAccountWalletAddressExample,
              ),
            ),
            const SizedBox(height: SpacingTokens.xs),
            Text(
              l10n.addAccountWalletPublicAddressOnly,
              style: theme.textTheme.bodySmall?.copyWith(
                color: palette.mutedInk,
              ),
            ),
          ] else ...[
            if (canPickCurrency) ...[
              Text(l10n.addAccountCurrencyQuestion, style: headingStyle),
              const SizedBox(height: SpacingTokens.xs),
              ObCard(
                child: ListTile(
                  onTap: onPickCurrency,
                  title: Text(
                    currencyCode.isEmpty
                        ? l10n.addAccountSelectCurrencyPlaceholder
                        : currencyCode,
                    style: formValueStyle?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: const SkribbleIcon(
                    data: OpenBudgetIcons.chevronRight,
                    size: 20,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: SpacingTokens.sm,
                  ),
                ),
              ),
              const SizedBox(height: SpacingTokens.md),
            ],
            if (canBeOnBudget)
              SwitchListTile(
                title: Text(l10n.addAccountOnBudgetQuestion),
                subtitle: Text(l10n.addAccountOnBudgetHint),
                value: onBudget,
                onChanged: onBudgetChanged,
                contentPadding: EdgeInsets.zero,
              ),
            if (canChooseSource) ...[
              Text(l10n.addAccountTrackByQuestion, style: headingStyle),
              const SizedBox(height: SpacingTokens.xs),
              SegmentedButton<bool>(
                segments: [
                  ButtonSegment(
                    value: false,
                    label: Text(l10n.addAccountTrackByTransactions),
                  ),
                  ButtonSegment(
                    value: true,
                    label: Text(l10n.addAccountTrackByValue),
                  ),
                ],
                selected: {trackByValue},
                onSelectionChanged: (values) =>
                    onTrackByValueChanged(values.first),
              ),
            ],
            const SizedBox(height: SpacingTokens.md),
            Text(l10n.addAccountBalanceQuestion, style: headingStyle),
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
                hintText: l10n.addAccountBalanceExample,
                errorText: balanceError,
                prefixText: currencyCode.isEmpty ? null : '$currencyCode ',
              ),
            ),
            const SizedBox(height: SpacingTokens.xs),
            SwitchListTile(
              title: Text(l10n.addAccountOpeningToday),
              value: openingToday,
              onChanged: onOpeningTodayChanged,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ],
      ),
    );
  }
}

class _AccountTypeStep extends HookWidget {
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
    final theme = Theme.of(context);
    final palette = theme.ob;
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
          ObSectionHeader(
            title: section.title,
            subtitle: section.subtitle,
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
          ),
          for (final option in section.options) ...[
            ObCard(
              margin: const EdgeInsets.only(bottom: SpacingTokens.xs),
              child: ListTile(
                key: ValueKey('add-account-type-option-${option.key}'),
                onTap: () => onSelected(option),
                leading: SkribbleIcon(
                  data: _iconForType(option.key),
                  size: 20,
                  color: palette.hue(ObTone.brand),
                ),
                title: Text(option.label),
                trailing: option.key == selectedTypeKey
                    ? SkribbleIcon(
                        data: OpenBudgetIcons.check,
                        color: palette.hue(ObTone.brand),
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: SpacingTokens.sm,
                ),
              ),
            ),
          ],
          const SizedBox(height: SpacingTokens.md),
        ],
      ],
    );
  }

  static WiredSvgIconData _iconForType(String type) => switch (type) {
    'savings' => OpenBudgetIcons.savings,
    'cash' => OpenBudgetIcons.cash,
    'creditCard' => OpenBudgetIcons.creditCard,
    'loan' || 'otherLiability' => OpenBudgetIcons.scale,
    'mortgage' => OpenBudgetIcons.home,
    'investment' => OpenBudgetIcons.trendingUp,
    'property' => OpenBudgetIcons.home,
    'vehicle' => OpenBudgetIcons.transport,
    'crypto' => OpenBudgetIcons.solana,
    'checking' => OpenBudgetIcons.bank,
    _ => OpenBudgetIcons.receipt,
  };
}

class _SuccessStep extends HookWidget {
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
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: _StepFrame(
        maxWidth: 720,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(SpacingTokens.md),
          child: ObStatePanel.empty(
            title: l10n.addAccountSuccessHeadline,
            message: l10n.addAccountSuccessMessage(accountTypeLabel),
            doodle: WiredDoodleKind.confetti,
            action: ObStateAction(label: l10n.dialogDone, onPressed: onDone),
            secondaryAction: ObStateAction(
              label: l10n.addAccountSuccessAddAnother,
              onPressed: onAddAnother,
            ),
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
    required this.kind,
  });

  final String key;
  final String label;
  final AccountKind kind;
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

List<_AccountTypeSection> _accountTypeSections(AppLocalizations l10n) => [
  _AccountTypeSection(
    title: l10n.addAccountSectionCashAccounts,
    subtitle: l10n.addAccountSectionCashAccountsHint,
    options: [
      _AccountTypeOption(
        key: 'checking',
        label: l10n.accountTypeChecking,
        kind: AccountKind.checking,
      ),
      _AccountTypeOption(
        key: 'savings',
        label: l10n.accountTypeSavings,
        kind: AccountKind.savings,
      ),
      _AccountTypeOption(
        key: 'cash',
        label: l10n.accountTypeCash,
        kind: AccountKind.cash,
      ),
    ],
  ),
  _AccountTypeSection(
    title: l10n.addAccountSectionCreditAccounts,
    subtitle: l10n.addAccountSectionCreditAccountsHint,
    options: [
      _AccountTypeOption(
        key: 'creditCard',
        label: l10n.accountTypeCreditCard,
        kind: AccountKind.creditCard,
      ),
      _AccountTypeOption(
        key: 'loan',
        label: l10n.addAccountTypePersonalLoan,
        kind: AccountKind.loan,
      ),
      _AccountTypeOption(
        key: 'mortgage',
        label: l10n.addAccountTypeMortgage,
        kind: AccountKind.mortgage,
      ),
      _AccountTypeOption(
        key: 'otherLiability',
        label: l10n.addAccountTypeOtherDebt,
        kind: AccountKind.otherLiability,
      ),
    ],
  ),
  _AccountTypeSection(
    title: l10n.addAccountSectionTrackingAccounts,
    subtitle: l10n.addAccountSectionTrackingAccountsHint,
    options: [
      _AccountTypeOption(
        key: 'investment',
        label: l10n.addAccountTypeAssetExample,
        kind: AccountKind.investment,
      ),
      _AccountTypeOption(
        key: 'property',
        label: l10n.addAccountTypeProperty,
        kind: AccountKind.property,
      ),
      _AccountTypeOption(
        key: 'vehicle',
        label: l10n.addAccountTypeVehicle,
        kind: AccountKind.vehicle,
      ),
      _AccountTypeOption(
        key: 'crypto',
        label: l10n.addAccountTypeSolanaWallet,
        kind: AccountKind.crypto,
      ),
      _AccountTypeOption(
        key: 'otherAsset',
        label: l10n.addAccountTypeOtherAsset,
        kind: AccountKind.otherAsset,
      ),
    ],
  ),
];

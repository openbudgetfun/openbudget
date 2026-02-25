import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_actions_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_app/src/theme/openbudget_palette.dart';
import 'package:openbudget_app/src/utils/currency_code_utils.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

enum _AddAccountStep {
  loading,
  loadingInstitutions,
  searchBank,
  unlinkedAccount,
  accountType,
  success,
}

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
    final searchController = useTextEditingController();
    final isSubmitting = useState(false);
    final selectedTypeKey = useState<String?>(null);
    final selectedCurrency = useState(CurrencyCode.usd);
    final didHydrateBudgetCurrency = useState(false);
    final showSearchingOverlay = useState(false);
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

    final balanceValue = double.tryParse(balanceController.text.trim());
    final canSubmit =
        nameController.text.trim().isNotEmpty &&
        balanceValue != null &&
        selectedType != null;

    Future<void> startLinkedBankFlow(String institutionName) async {
      if (showSearchingOverlay.value || institutionName.trim().isEmpty) return;
      showSearchingOverlay.value = true;
      await Future<void>.delayed(const Duration(milliseconds: 700));
      if (!context.mounted) return;

      showSearchingOverlay.value = false;
      step.value = _AddAccountStep.unlinkedAccount;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Linked connections for "$institutionName" are coming soon. '
            'Add an unlinked account for now.',
          ),
        ),
      );
    }

    Future<void> submitUnlinkedAccount() async {
      if (!canSubmit || isSubmitting.value) return;
      final chosenType = selectedType;
      final budget = budgetAsync.value;
      if (budget == null) return;

      isSubmitting.value = true;

      var balanceCents =
          (balanceValue * _pow10(selectedCurrency.value.decimals)).round();
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
            );
        if (!context.mounted) return;
        isSubmitting.value = false;
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

    return Scaffold(
      backgroundColor: OpenBudgetPalette.appBackground,
      appBar: AppBar(
        backgroundColor: OpenBudgetPalette.appBackground,
        surfaceTintColor: Colors.transparent,
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
                  switch (step.value) {
                    case _AddAccountStep.loading:
                    case _AddAccountStep.loadingInstitutions:
                      break;
                    case _AddAccountStep.searchBank:
                      break;
                    case _AddAccountStep.unlinkedAccount:
                      step.value = _AddAccountStep.searchBank;
                    case _AddAccountStep.accountType:
                      step.value = _AddAccountStep.unlinkedAccount;
                    case _AddAccountStep.success:
                      step.value = _AddAccountStep.unlinkedAccount;
                  }
                },
              ),
        title: Text(
          switch (step.value) {
            _AddAccountStep.loading => '',
            _AddAccountStep.loadingInstitutions => 'Add Accounts',
            _AddAccountStep.searchBank => 'Add Accounts',
            _AddAccountStep.unlinkedAccount => 'Add Unlinked Account',
            _AddAccountStep.accountType => 'Select Account Type',
            _AddAccountStep.success => 'Add Unlinked Account',
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
            _AddAccountStep.loading => const _LoadingStep(
              title: 'Loading...',
              includeSpinner: false,
            ),
            _AddAccountStep.loadingInstitutions => const _LoadingStep(
              title: 'Loading institutions...',
              includeSpinner: true,
            ),
            _AddAccountStep.searchBank => _BankSearchStep(
              searchController: searchController,
              searchQuery: searchController.text,
              onInstitutionTap: startLinkedBankFlow,
              onAddUnlinked: () => step.value = _AddAccountStep.unlinkedAccount,
            ),
            _AddAccountStep.unlinkedAccount => _UnlinkedAccountStep(
              nameController: nameController,
              balanceController: balanceController,
              selectedTypeLabel:
                  selectedType?.label ?? 'Select account type...',
              hasSelectedType: selectedType != null,
              selectedCurrency: selectedCurrency.value,
              onChooseType: () => step.value = _AddAccountStep.accountType,
              onCurrencyChanged: (code) =>
                  selectedCurrency.value = parseCurrencyCode(code),
            ),
            _AddAccountStep.accountType => _AccountTypeStep(
              sections: typeSections,
              selectedTypeKey: selectedTypeKey.value,
              onSelected: (option) {
                selectedTypeKey.value = option.key;
                step.value = _AddAccountStep.unlinkedAccount;
              },
            ),
            _AddAccountStep.success => _SuccessStep(
              accountTypeLabel: selectedType?.label ?? 'Account',
              onAddAnother: () {
                nameController.clear();
                balanceController.clear();
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
              color: Colors.black.withAlpha(120),
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
        _AddAccountStep.unlinkedAccount => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              SpacingTokens.md,
              SpacingTokens.sm,
              SpacingTokens.md,
              SpacingTokens.md,
            ),
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
        _AddAccountStep.success => null,
        _AddAccountStep.searchBank || _AddAccountStep.accountType => null,
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

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.xl),
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
                color: OpenBudgetPalette.mutedText,
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
      ),
    );
  }
}

class _BankSearchStep extends StatelessWidget {
  const _BankSearchStep({
    required this.searchController,
    required this.searchQuery,
    required this.onInstitutionTap,
    required this.onAddUnlinked,
  });

  final TextEditingController searchController;
  final String searchQuery;
  final Future<void> Function(String institution) onInstitutionTap;
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
          decoration: const InputDecoration(
            hintText: 'Search by institution name or web address (URL)',
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
              color: OpenBudgetPalette.surface,
              border: Border.all(color: OpenBudgetPalette.divider),
              borderRadius: BorderRadius.circular(RadiusTokens.md),
            ),
            child: Text(
              'No institutions found. Try another name or add an unlinked account.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: OpenBudgetPalette.mutedText,
              ),
            ),
          )
        else
          Wrap(
            spacing: SpacingTokens.sm,
            runSpacing: SpacingTokens.sm,
            children: [
              for (final institution in filteredInstitutions)
                _InstitutionTile(
                  option: institution,
                  onTap: () => onInstitutionTap(institution.name),
                ),
            ],
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
                  color: OpenBudgetPalette.mutedText,
                ),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: SpacingTokens.md),
        OutlinedButton(
          onPressed: onAddUnlinked,
          child: const Text('Add an Unlinked Account'),
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
    return SizedBox(
      width:
          (MediaQuery.sizeOf(context).width - (SpacingTokens.md * 2) - 12) / 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(RadiusTokens.md),
        child: Container(
          height: 84,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: OpenBudgetPalette.surface,
            border: Border.all(color: OpenBudgetPalette.divider),
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
      ),
    );
  }
}

@immutable
class _InstitutionOption {
  const _InstitutionOption({required this.name});

  final String name;
}

class _UnlinkedAccountStep extends StatelessWidget {
  const _UnlinkedAccountStep({
    required this.nameController,
    required this.balanceController,
    required this.selectedTypeLabel,
    required this.hasSelectedType,
    required this.selectedCurrency,
    required this.onChooseType,
    required this.onCurrencyChanged,
  });

  final TextEditingController nameController;
  final TextEditingController balanceController;
  final String selectedTypeLabel;
  final bool hasSelectedType;
  final CurrencyCode selectedCurrency;
  final VoidCallback onChooseType;
  final ValueChanged<String> onCurrencyChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        SpacingTokens.md,
        SpacingTokens.md,
        SpacingTokens.md,
        SpacingTokens.xl,
      ),
      children: [
        Text(
          "Let's go! And don't worry - if you change your mind, "
          'you can link your account at any time.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: SpacingTokens.md),
        Text(
          'Give it a nickname',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: SpacingTokens.xs),
        TextField(
          controller: nameController,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(hintText: 'Enter nickname'),
        ),
        const SizedBox(height: SpacingTokens.md),
        Text(
          'What type of account are you adding?',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: SpacingTokens.xs),
        ListTile(
          onTap: onChooseType,
          title: Text(
            selectedTypeLabel,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: hasSelectedType ? null : OpenBudgetPalette.mutedText,
              fontWeight: hasSelectedType ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
          trailing: const Icon(Icons.chevron_right_rounded),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.sm,
          ),
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: OpenBudgetPalette.divider),
            borderRadius: BorderRadius.circular(RadiusTokens.md),
          ),
        ),
        const SizedBox(height: SpacingTokens.md),
        Text(
          'What is your current account balance?',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: SpacingTokens.xs),
        TextField(
          controller: balanceController,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: true,
          ),
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(hintText: '5000'),
        ),
        const SizedBox(height: SpacingTokens.md),
        DropdownButtonFormField<String>(
          initialValue: selectedCurrency.code,
          items: CurrencyCode.values
              .map(
                (currency) => DropdownMenuItem(
                  value: currency.code,
                  child: Text('${currency.code} (${currency.symbol})'),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value == null) return;
            onCurrencyChanged(value);
          },
          decoration: const InputDecoration(
            labelText: 'Currency',
            prefixIcon: Icon(Icons.language_rounded),
          ),
        ),
      ],
    );
  }
}

class _AccountTypeStep extends StatelessWidget {
  const _AccountTypeStep({
    required this.sections,
    required this.selectedTypeKey,
    required this.onSelected,
  });

  final List<_AccountTypeSection> sections;
  final String? selectedTypeKey;
  final ValueChanged<_AccountTypeOption> onSelected;

  @override
  Widget build(BuildContext context) {
    return ListView(
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
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: OpenBudgetPalette.mutedText),
          ),
          const SizedBox(height: SpacingTokens.sm),
          for (final option in section.options) ...[
            ListTile(
              onTap: () => onSelected(option),
              title: Text(option.label),
              trailing: option.key == selectedTypeKey
                  ? const Icon(
                      Icons.check_rounded,
                      color: OpenBudgetPalette.accentBlue,
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.sm,
              ),
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: OpenBudgetPalette.divider),
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
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 72,
                    color: OpenBudgetPalette.progressGreen,
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
                      color: OpenBudgetPalette.mutedText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              SpacingTokens.md,
              SpacingTokens.sm,
              SpacingTokens.md,
              SpacingTokens.md,
            ),
            child: Row(
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
          ),
        ),
      ],
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
      subtitle: 'Credit accounts let you spend borrowed money to repay later.',
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
      subtitle: "Accounts with an outstanding balance you're paying off.",
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
  ];
}

double _pow10(int exponent) {
  var result = 1.0;
  for (var i = 0; i < exponent; i++) {
    result *= 10;
  }
  return result;
}

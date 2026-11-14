import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/home/providers/entity_detail_provider.dart';
import 'package:openbudget_app/src/features/tax/providers/tax_actions_provider.dart';
import 'package:openbudget_app/src/features/tax/providers/tax_providers.dart';
import 'package:openbudget_app/src/features/tax/tax_formatting.dart';
import 'package:openbudget_app/src/features/tax/tax_labels.dart';
import 'package:openbudget_app/src/features/tax/tax_profile_form_values.dart';
import 'package:openbudget_app/src/features/tax/widgets/tax_question_field.dart';
import 'package:openbudget_app/src/widgets/app_toast.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// Asks the questions that change how a budget's figures are taxed.
class TaxProfileScreen extends HookConsumerWidget {
  const TaxProfileScreen({required this.entityId, super.key});

  final String entityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final profileAsync = ref.watch(taxProfileProvider(entityId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.taxProfileTitle)),
      body: profileAsync.when(
        loading: () => Center(
          child: ObLoadingPanel(label: l10n.taxProfileLoading),
        ),
        error: (error, _) => Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(SpacingTokens.lg),
            child: ObStatePanel.problem(
              title: l10n.taxProfileLoadError,
              message: taxErrorMessage(error, l10n.taxProfileLoadError),
              action: ObStateAction(
                label: l10n.taxCategoryLoadRetry,
                onPressed: () => ref.invalidate(taxProfileProvider(entityId)),
              ),
            ),
          ),
        ),
        data: (record) => _TaxProfileForm(
          key: ValueKey(
            record?.updatedAt.microsecondsSinceEpoch ?? record?.id?.toString(),
          ),
          entityId: entityId,
          existing: record == null
              ? null
              : parseTaxProfileJson(record.profileJson),
        ),
      ),
    );
  }
}

/// The form for one entity: the pack's questions for the chosen kind of
/// books, answered and saved without knowing which country they are for.
class _TaxProfileForm extends HookConsumerWidget {
  const _TaxProfileForm({
    required this.entityId,
    required this.existing,
    super.key,
  });

  final String entityId;
  final TaxProfile? existing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final entity = ref.watch(entityDetailProvider(entityId)).value;

    // The country comes from the entity and is not editable here. It
    // follows the entity when its detail resolves after the first frame
    // (the default only covers the loading frame).
    final country =
        (entity == null
            ? null
            : TaxJurisdiction.fromCountryCode(entity.countryCode)) ??
        TaxJurisdiction.gb;
    final pack = TaxRules.forJurisdiction(country);
    final currency =
        CurrencyCode.tryParse(country.currencyCode) ??
        (throw StateError('Unknown currency ${country.currencyCode}'));

    // What the user has changed so far, over the stored profile's answers.
    final edits = useState<TaxFormValues>(const {});
    final errors = useState<Map<String, TaxFieldError>>(const {});
    final formError = useState<String?>(null);
    final isSaving = useState(false);

    // The kind starts as the entity's, and the first question may override
    // it for this profile.
    final kind = EntityKind.values.byName(
      edits.value[taxEntityKindKey] as String? ??
          entity?.kind.name ??
          EntityKind.individual.name,
    );
    final base = switch (existing) {
      final profile? when profile.jurisdiction == country => profile,
      _ => pack.profileFromJson({
        'jurisdiction': country.countryCode,
        'entityKind': kind.name,
      }),
    };
    final questions = pack.profileQuestions(kind);
    final values = taxFormValues(
      questions: questions,
      stored: {...base.toAnswers(), taxEntityKindKey: kind.name},
      edits: edits.value,
      decimals: currency.decimals,
    );

    void answer(String key, Object? value) {
      edits.value = {...edits.value, key: value};
      if (errors.value.containsKey(key)) {
        errors.value = {...errors.value}..remove(key);
      }
    }

    Future<void> save() async {
      formError.value = null;
      final result = taxFormAnswers(
        questions: questions,
        values: values,
        decimals: currency.decimals,
      );
      errors.value = result.errors;
      if (result.errors.isNotEmpty) return;

      final TaxProfile profile;
      try {
        profile = base.withAnswers(result.answers);
      } on FormatException {
        formError.value = l10n.taxProfileSaveError;
        return;
      }
      isSaving.value = true;
      try {
        await ref
            .read(taxActionsProvider.notifier)
            .saveProfile(
              entityId: entityId,
              jurisdiction:
                  entity?.countryCode ?? profile.jurisdiction.countryCode,
              entityKind: entity?.kind.name ?? profile.entityKind.name,
              profileJson: jsonEncode(profile.toJson()),
            );
        if (!context.mounted) return;
        showAppToast(
          context,
          message: l10n.taxProfileSaved,
          variant: AppToastVariant.success,
        );
        if (context.canPop()) {
          context.pop();
        } else {
          isSaving.value = false;
        }
      } on Exception catch (error) {
        isSaving.value = false;
        if (!context.mounted) return;
        formError.value = taxErrorMessage(error, l10n.taxProfileSaveError);
      }
    }

    // The kind of books is asked first, above the country's own card; the
    // rest are the card's rows.
    final kindQuestion = questions
        .where((question) => question.key == taxEntityKindKey)
        .firstOrNull;
    final rows = [
      for (final question in questions)
        if (question.key != taxEntityKindKey &&
            taxQuestionVisible(question, values))
          question,
    ];

    return ObReadableWidth(
      padding: const EdgeInsets.fromLTRB(
        SpacingTokens.md,
        SpacingTokens.sm,
        SpacingTokens.md,
        SpacingTokens.xl,
      ),
      builder: (context, padding) => ListView(
        padding: padding,
        children: [
          Text(
            l10n.taxSetupMessage,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: palette.mutedInk,
            ),
          ),
          const SizedBox(height: SpacingTokens.md),
          if (kindQuestion != null)
            TaxQuestionField(
              question: kindQuestion,
              values: values,
              currency: currency,
              onChanged: answer,
              padded: false,
            ),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            l10n.taxCountryLabel,
            style: theme.textTheme.bodySmall?.copyWith(
              color: palette.mutedInk,
            ),
          ),
          Text(
            taxJurisdictionLabel(l10n, country),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: SpacingTokens.md),
          ObSectionHeader(
            title: taxJurisdictionLabel(l10n, country),
            padding: const EdgeInsets.fromLTRB(
              0,
              SpacingTokens.lg,
              0,
              SpacingTokens.xs,
            ),
          ),
          ObCard(
            child: Column(
              children: [
                for (var i = 0; i < rows.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  TaxQuestionField(
                    question: rows[i],
                    values: values,
                    currency: currency,
                    error: errors.value[rows[i].key],
                    onChanged: answer,
                  ),
                ],
              ],
            ),
          ),
          if (formError.value case final message?) ...[
            const SizedBox(height: SpacingTokens.md),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: palette.overspent,
              ),
            ),
          ],
          const SizedBox(height: SpacingTokens.lg),
          ObFilledButton(
            onPressed: isSaving.value ? null : save,
            isLoading: isSaving.value,
            loadingLabel: l10n.taxProfileSave,
            child: Text(l10n.taxProfileSave),
          ),
          const SizedBox(height: SpacingTokens.md),
          Text(
            l10n.taxDisclaimer,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(color: palette.mutedInk),
          ),
        ],
      ),
    );
  }
}

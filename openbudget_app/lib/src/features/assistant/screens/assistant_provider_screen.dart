import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/assistant/models/assistant_failure.dart';
import 'package:openbudget_app/src/features/assistant/providers/assistant_provider_settings_provider.dart';
import 'package:openbudget_app/src/widgets/app_toast.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// Connects the user's own OpenAI-compatible provider for the assistant.
class AssistantProviderScreen extends HookConsumerWidget {
  const AssistantProviderScreen({super.key});

  static const baseUrlFieldKey = Key('assistant-provider-base-url');
  static const modelFieldKey = Key('assistant-provider-model');
  static const apiKeyFieldKey = Key('assistant-provider-api-key');
  static const saveButtonKey = Key('assistant-provider-save');
  static const removeButtonKey = Key('assistant-provider-remove');
  static const replaceButtonKey = Key('assistant-provider-replace');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settingsAsync = ref.watch(assistantProviderSettingsProvider);
    final baseUrl = useTextEditingController();
    final model = useTextEditingController();
    final apiKey = useTextEditingController();
    final isEditing = useState(false);
    final isSaving = useState(false);
    final errorText = useState<String?>(null);
    final settings = settingsAsync.asData?.value;

    useEffect(() {
      if (settings == null) return null;
      baseUrl.text = settings.baseUrl;
      model.text = settings.model;
      return null;
    }, [settings?.baseUrl, settings?.model, baseUrl, model]);

    Future<void> save() async {
      final url = baseUrl.text.trim();
      final modelName = model.text.trim();
      final key = apiKey.text.trim();
      final validation = _validate(
        l10n: l10n,
        baseUrl: url,
        model: modelName,
        apiKey: key,
      );
      if (validation != null) {
        errorText.value = validation;
        return;
      }

      errorText.value = null;
      isSaving.value = true;
      try {
        await ref
            .read(assistantProviderSettingsProvider.notifier)
            .save(baseUrl: url, model: modelName, apiKey: key);
        if (!context.mounted) return;

        apiKey.clear();
        isEditing.value = false;
        showAppToast(
          context,
          message: l10n.assistantProviderSavedToast,
          variant: AppToastVariant.success,
        );
      } on Object catch (error) {
        if (!context.mounted) return;
        final failure = assistantFailureFrom(error);
        errorText.value = failure is AssistantValidationFailure
            ? failure.message
            : l10n.assistantProviderSaveError;
      } finally {
        isSaving.value = false;
      }
    }

    Future<void> remove() async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.assistantProviderRemoveTitle),
          content: Text(l10n.assistantProviderRemoveMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.dialogCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.assistantProviderRemove),
            ),
          ],
        ),
      );
      if (confirmed != true || !context.mounted) return;

      try {
        await ref.read(assistantProviderSettingsProvider.notifier).remove();
        if (!context.mounted) return;
        showAppToast(
          context,
          message: l10n.assistantProviderRemovedToast,
          variant: AppToastVariant.success,
        );
      } on Object {
        if (context.mounted) {
          showAppToast(
            context,
            message: l10n.assistantProviderRemoveError,
            variant: AppToastVariant.error,
          );
        }
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.assistantProviderTitle)),
      body: settingsAsync.when(
        loading: () => ObLoadingPanel(label: l10n.assistantProviderLoading),
        error: (_, _) => SingleChildScrollView(
          padding: const EdgeInsets.all(SpacingTokens.md),
          child: ObStatePanel.problem(
            title: l10n.assistantProviderLoadError,
            action: ObStateAction(
              label: l10n.assistantRetry,
              onPressed: () =>
                  ref.invalidate(assistantProviderSettingsProvider),
            ),
          ),
        ),
        data: (saved) {
          final showForm = saved == null || isEditing.value;

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              SpacingTokens.md,
              SpacingTokens.md,
              SpacingTokens.md,
              SpacingTokens.xl,
            ),
            children: [
              if (showForm)
                _ProviderForm(
                  l10n: l10n,
                  baseUrl: baseUrl,
                  model: model,
                  apiKey: apiKey,
                  hasSavedProvider: saved != null,
                  isSaving: isSaving.value,
                  errorText: errorText.value,
                  onSave: save,
                  onCancel: saved == null
                      ? null
                      : () => isEditing.value = false,
                )
              else
                _SavedProvider(
                  l10n: l10n,
                  settings: saved,
                  onReplace: () {
                    errorText.value = null;
                    isEditing.value = true;
                  },
                  onRemove: remove,
                ),
            ],
          );
        },
      ),
    );
  }

  String? _validate({
    required AppLocalizations l10n,
    required String baseUrl,
    required String model,
    required String apiKey,
  }) {
    if (baseUrl.isEmpty) return l10n.assistantProviderUrlRequired;
    final uri = Uri.tryParse(baseUrl);
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty) {
      return l10n.assistantProviderUrlInvalid;
    }
    if (model.isEmpty) return l10n.assistantProviderModelRequired;
    if (apiKey.isEmpty) return l10n.assistantProviderKeyRequired;
    return null;
  }
}

class _ProviderForm extends HookWidget {
  const _ProviderForm({
    required this.l10n,
    required this.baseUrl,
    required this.model,
    required this.apiKey,
    required this.hasSavedProvider,
    required this.isSaving,
    required this.errorText,
    required this.onSave,
    required this.onCancel,
  });

  final AppLocalizations l10n;
  final TextEditingController baseUrl;
  final TextEditingController model;
  final TextEditingController apiKey;
  final bool hasSavedProvider;
  final bool isSaving;
  final String? errorText;
  final VoidCallback onSave;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;
    final hintStyle = theme.textTheme.bodySmall?.copyWith(
      color: palette.mutedInk,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.assistantProviderIntro,
          style: theme.textTheme.bodyLarge?.copyWith(color: palette.mutedInk),
        ),
        const SizedBox(height: SpacingTokens.md),
        ObTextField(
          key: AssistantProviderScreen.baseUrlFieldKey,
          controller: baseUrl,
          labelText: l10n.assistantProviderBaseUrl,
          hintText: l10n.assistantProviderBaseUrlHint,
          keyboardType: TextInputType.url,
        ),
        const SizedBox(height: SpacingTokens.sm),
        ObTextField(
          key: AssistantProviderScreen.modelFieldKey,
          controller: model,
          labelText: l10n.assistantProviderModel,
          hintText: l10n.assistantProviderModelHint,
        ),
        const SizedBox(height: SpacingTokens.sm),
        ObTextField(
          key: AssistantProviderScreen.apiKeyFieldKey,
          controller: apiKey,
          labelText: l10n.assistantProviderApiKey,
          hintText: l10n.assistantProviderApiKeyHint,
          obscureText: true,
        ),
        if (hasSavedProvider) ...[
          const SizedBox(height: SpacingTokens.xs),
          Text(l10n.assistantProviderEnterKeyAgain, style: hintStyle),
        ],
        const SizedBox(height: SpacingTokens.sm),
        Text(l10n.assistantProviderPrivacy, style: hintStyle),
        if (errorText case final message?) ...[
          const SizedBox(height: SpacingTokens.sm),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: palette.overspent,
            ),
          ),
        ],
        const SizedBox(height: SpacingTokens.md),
        Wrap(
          spacing: SpacingTokens.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ObFilledButton(
              key: AssistantProviderScreen.saveButtonKey,
              onPressed: isSaving ? null : onSave,
              isLoading: isSaving,
              loadingLabel: l10n.assistantProviderSave,
              child: Text(l10n.assistantProviderSave),
            ),
            if (onCancel case final cancel?)
              ObTextButton(onPressed: cancel, child: Text(l10n.dialogCancel)),
          ],
        ),
      ],
    );
  }
}

class _SavedProvider extends HookWidget {
  const _SavedProvider({
    required this.l10n,
    required this.settings,
    required this.onReplace,
    required this.onRemove,
  });

  final AppLocalizations l10n;
  final AgentProviderSettingsView settings;
  final VoidCallback onReplace;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;
    final labelStyle = theme.textTheme.bodySmall?.copyWith(
      color: palette.mutedInk,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ObCard(
          padding: const EdgeInsets.all(SpacingTokens.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SkribbleIcon(
                    data: OpenBudgetIcons.verified,
                    color: palette.funded,
                  ),
                  const SizedBox(width: SpacingTokens.xs),
                  Expanded(
                    child: Text(
                      l10n.assistantProviderSavedTitle,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SpacingTokens.sm),
              Text(l10n.assistantProviderBaseUrl, style: labelStyle),
              Text(settings.baseUrl, style: theme.textTheme.bodyLarge),
              const SizedBox(height: SpacingTokens.xs),
              Text(l10n.assistantProviderModel, style: labelStyle),
              Text(settings.model, style: theme.textTheme.bodyLarge),
              const SizedBox(height: SpacingTokens.xs),
              Text(l10n.assistantProviderApiKey, style: labelStyle),
              Text(
                l10n.assistantProviderKeyStored(settings.keyHint),
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: SpacingTokens.sm),
              Text(
                l10n.assistantProviderPrivacy,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: palette.mutedInk,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: SpacingTokens.md),
        Wrap(
          spacing: SpacingTokens.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ObTextButton(
              key: AssistantProviderScreen.replaceButtonKey,
              onPressed: onReplace,
              child: Text(l10n.assistantProviderReplace),
            ),
            ObTextButton(
              key: AssistantProviderScreen.removeButtonKey,
              onPressed: onRemove,
              child: Text(l10n.assistantProviderRemove),
            ),
          ],
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/tax/providers/tax_url_launcher_provider.dart';
import 'package:openbudget_app/src/features/tax/tax_labels.dart';
import 'package:openbudget_app/src/widgets/app_toast.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

// The pieces every cited figure in the app shares: the tax screens' rates and
// thresholds, and the Money guide's sources sheet. Keeping them in one place
// keeps a secondary source looking the same wherever it appears.

/// The badge that says how firmly a source backs a figure.
class SourceGradeChip extends HookWidget {
  const SourceGradeChip({required this.grade, super.key});

  final SourceGrade grade;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ObToneChip(
      label: taxSourceGradeLabel(l10n, grade),
      tone: switch (grade) {
        SourceGrade.primary => ObTone.funded,
        SourceGrade.secondary => ObTone.review,
        SourceGrade.inferred => ObTone.underfunded,
        SourceGrade.background => ObTone.neutral,
      },
    );
  }
}

/// A source's short name as an underlined link that opens it outside the
/// app.
///
/// [label] is what the reader sees, usually the source's website;
/// [semanticLabel] is what a screen reader says, and [tooltip] carries the
/// full citation. Without a [url] the label is plain, muted text.
class SourceLinkText extends HookConsumerWidget {
  const SourceLinkText({
    required this.label,
    required this.semanticLabel,
    required this.tooltip,
    required this.url,
    super.key,
  });

  final String label;
  final String semanticLabel;
  final String tooltip;
  final Uri? url;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final palette = theme.ob;
    final link = url;

    if (link == null) {
      return Tooltip(
        message: tooltip,
        child: Text(
          label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(color: palette.mutedInk),
        ),
      );
    }
    return Semantics(
      link: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          borderRadius: BorderRadius.circular(RadiusTokens.sm),
          onTap: () => openSourceLink(context, ref, link),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: palette.brand,
                  decoration: TextDecoration.underline,
                  decorationColor: palette.brand,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Opens [url] outside the app, telling the person in plain words when the
/// device has nothing to open it with.
Future<void> openSourceLink(
  BuildContext context,
  WidgetRef ref,
  Uri url,
) async {
  final message = AppLocalizations.of(context).taxLinkOpenFailed;
  var opened = false;
  try {
    opened = await ref.read(taxUrlLauncherProvider).openPage(url);
  } on Exception {
    opened = false;
  }
  if (!opened && context.mounted) {
    showAppToast(context, message: message, variant: AppToastVariant.error);
  }
}

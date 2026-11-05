import 'package:flutter/material.dart';
import 'package:openbudget_app/src/theme/openbudget_palette.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

enum AppToastVariant { info, success, warning, error }

/// Shows a short message on a paper card that sits above the page.
///
/// Each variant lays its own tone wash under the words: success on the funded
/// wash, errors on the overspent wash, information on the brand wash. The
/// icon takes the tone's hue and the message stays ink, so the meaning also
/// reads in words.
void showAppToast(
  BuildContext context, {
  required String message,
  AppToastVariant variant = AppToastVariant.info,
  String? actionLabel,
  VoidCallback? onAction,
  Duration duration = const Duration(seconds: 4),
}) {
  final theme = Theme.of(context);
  final palette = theme.ob;
  final messenger = ScaffoldMessenger.of(context);
  final tone = switch (variant) {
    AppToastVariant.info => ObTone.brand,
    AppToastVariant.success => ObTone.funded,
    AppToastVariant.warning => ObTone.underfunded,
    AppToastVariant.error => ObTone.overspent,
  };
  final icon = switch (variant) {
    AppToastVariant.info => OpenBudgetIcons.info,
    AppToastVariant.success => OpenBudgetIcons.checkCircle,
    AppToastVariant.warning => OpenBudgetIcons.warning,
    AppToastVariant.error => OpenBudgetIcons.error,
  };
  final hue = palette.hue(tone);

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: OpenBudgetPalette.transparentFor(theme),
        elevation: 0,
        duration: duration,
        dismissDirection: DismissDirection.none,
        margin: const EdgeInsets.fromLTRB(
          SpacingTokens.md,
          0,
          SpacingTokens.md,
          SpacingTokens.md,
        ),
        content: GestureDetector(
          onVerticalDragEnd: (_) => messenger.hideCurrentSnackBar(),
          child: Dismissible(
            key: ValueKey(
              'toast-${DateTime.now().microsecondsSinceEpoch}-${message.hashCode}',
            ),
            onDismissed: (_) => messenger.hideCurrentSnackBar(),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.md,
                vertical: SpacingTokens.sm,
              ),
              decoration: ObRoughDecoration(
                color: palette.wash(tone),
                outline: palette.quietPen,
                seed: 23,
              ),
              child: Row(
                children: [
                  SkribbleIcon(data: icon, size: 20, color: hue),
                  const SizedBox(width: SpacingTokens.sm),
                  Expanded(
                    child: Semantics(
                      liveRegion: true,
                      child: Text(
                        message,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: palette.ink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  if (actionLabel != null && onAction != null) ...[
                    const SizedBox(width: SpacingTokens.sm),
                    TextButton(
                      onPressed: () {
                        messenger.hideCurrentSnackBar();
                        onAction();
                      },
                      style: TextButton.styleFrom(
                        minimumSize: const Size(48, 48),
                        padding: const EdgeInsets.symmetric(
                          horizontal: SpacingTokens.sm,
                        ),
                        foregroundColor: hue,
                      ),
                      child: Text(
                        actionLabel,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: hue,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
}

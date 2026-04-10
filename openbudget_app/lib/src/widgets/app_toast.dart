import 'package:flutter/material.dart';
import 'package:openbudget_app/src/theme/openbudget_palette.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

enum AppToastVariant { info, success, warning, error }

void showAppToast(
  BuildContext context, {
  required String message,
  AppToastVariant variant = AppToastVariant.info,
  String? actionLabel,
  VoidCallback? onAction,
  Duration duration = const Duration(seconds: 4),
}) {
  final theme = Theme.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final config = _ToastStyleConfig.forVariant(theme: theme, variant: variant);

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
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: config.backgroundColor,
                borderRadius: BorderRadius.circular(RadiusTokens.md),
                border: Border.all(color: config.borderColor),
                boxShadow: [
                  BoxShadow(
                    color: OpenBudgetPalette.fgPrimaryFor(theme).withAlpha(35),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: SpacingTokens.md,
                  vertical: SpacingTokens.sm,
                ),
                child: Row(
                  children: [
                    Icon(config.icon, size: 18, color: config.iconColor),
                    const SizedBox(width: SpacingTokens.sm),
                    Expanded(
                      child: Text(
                        message,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: config.textColor,
                          fontWeight: FontWeight.w600,
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
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(
                            horizontal: SpacingTokens.sm,
                            vertical: SpacingTokens.xs,
                          ),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          foregroundColor: config.iconColor,
                        ),
                        child: Text(
                          actionLabel,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: config.iconColor,
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
      ),
    );
}

class _ToastStyleConfig {
  const _ToastStyleConfig({
    required this.icon,
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    required this.textColor,
  });

  factory _ToastStyleConfig.forVariant({
    required ThemeData theme,
    required AppToastVariant variant,
  }) => switch (variant) {
    AppToastVariant.info => _ToastStyleConfig(
      icon: Icons.info_rounded,
      backgroundColor: OpenBudgetPalette.bgInfoFor(theme).withAlpha(220),
      borderColor: OpenBudgetPalette.bgBrandFor(theme).withAlpha(150),
      iconColor: OpenBudgetPalette.bgBrandFor(theme),
      textColor: OpenBudgetPalette.fgPrimaryFor(theme),
    ),
    AppToastVariant.success => _ToastStyleConfig(
      icon: Icons.check_circle_rounded,
      backgroundColor: OpenBudgetPalette.bgTagSuccessFor(theme).withAlpha(230),
      borderColor: OpenBudgetPalette.fgSuccessFor(theme).withAlpha(160),
      iconColor: OpenBudgetPalette.fgSuccessFor(theme),
      textColor: OpenBudgetPalette.fgPrimaryFor(theme),
    ),
    AppToastVariant.warning => _ToastStyleConfig(
      icon: Icons.warning_amber_rounded,
      backgroundColor: OpenBudgetPalette.bgWarningFor(theme).withAlpha(50),
      borderColor: OpenBudgetPalette.bgWarningFor(theme).withAlpha(190),
      iconColor: OpenBudgetPalette.fgTagWarningFor(theme),
      textColor: OpenBudgetPalette.fgPrimaryFor(theme),
    ),
    AppToastVariant.error => _ToastStyleConfig(
      icon: Icons.error_rounded,
      backgroundColor: OpenBudgetPalette.bgTagErrorFor(theme).withAlpha(220),
      borderColor: OpenBudgetPalette.fgErrorFor(theme).withAlpha(160),
      iconColor: OpenBudgetPalette.fgErrorFor(theme),
      textColor: OpenBudgetPalette.fgPrimaryFor(theme),
    ),
  };

  final IconData icon;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final Color textColor;
}

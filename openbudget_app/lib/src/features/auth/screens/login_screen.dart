import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/auth/providers/auth_provider.dart';
import 'package:openbudget_app/src/features/auth/providers/auth_state.dart';
import 'package:openbudget_app/src/features/settings/providers/display_options_provider.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_app/src/theme/openbudget_palette.dart';
import 'package:openbudget_app/src/widgets/app_toast.dart';
import 'package:openbudget_ui/openbudget_ui.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    useListenable(emailController);
    useListenable(passwordController);

    final authState = ref.watch(authProvider);
    final isLoading = authState is AuthLoading;
    final errorMessage = authState is AuthError ? authState.message : null;
    final obscurePassword = useState(true);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final canLogin =
        !isLoading &&
        emailController.text.trim().isNotEmpty &&
        passwordController.text.isNotEmpty;

    final client = ref.watch(serverpodClientProvider);
    final supportsSocialSignIn =
        kIsWeb ||
        switch (theme.platform) {
          TargetPlatform.android || TargetPlatform.iOS => true,
          _ => false,
        };
    final showGoogleSignIn =
        supportsSocialSignIn && const bool.hasEnvironment('GOOGLE_CLIENT_ID');
    final showAppleSignIn =
        supportsSocialSignIn &&
        const bool.hasEnvironment('APPLE_SERVICE_IDENTIFIER') &&
        const bool.hasEnvironment('APPLE_REDIRECT_URI');
    final showSocialSection = showGoogleSignIn || showAppleSignIn;
    final statusBarStyle =
        (theme.brightness == Brightness.light
                ? SystemUiOverlayStyle.dark
                : SystemUiOverlayStyle.light)
            .copyWith(statusBarColor: OpenBudgetPalette.transparentFor(theme));

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: statusBarStyle,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(SpacingTokens.md),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: SpacingTokens.xl),
                    const Align(
                      child: _OpenBudgetMark(
                        key: Key('login-openbudget-mark'),
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.md),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: SpacingTokens.sm,
                      children: [
                        ObHighlighter(
                          child: Text(
                            l10n.authLoginHeadline,
                            style: theme.textTheme.displaySmall,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        WiredDoodle(
                          kind: WiredDoodleKind.sun,
                          size: 56,
                          seed: 4,
                          color: palette.brand,
                        ),
                      ],
                    ),
                    const SizedBox(height: SpacingTokens.xs),
                    Text(
                      l10n.authLoginSubtitle,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: palette.mutedInk,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: SpacingTokens.lg),
                    ObCard(
                      padding: const EdgeInsets.all(SpacingTokens.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (showSocialSection) ...[
                            if (showAppleSignIn)
                              AppleSignInWidget(
                                client: client,
                                minimumWidth: 320,
                                onAuthenticated: () {
                                  unawaited(
                                    ref
                                        .read(authProvider.notifier)
                                        .syncExternalAuthState(),
                                  );
                                },
                                onError: (error) {
                                  ref
                                      .read(authProvider.notifier)
                                      .setExternalAuthError(error);
                                },
                              ),
                            if (showAppleSignIn && showGoogleSignIn)
                              const SizedBox(height: SpacingTokens.sm),
                            if (showGoogleSignIn)
                              GoogleSignInWidget(
                                client: client,
                                minimumWidth: 320,
                                onAuthenticated: () {
                                  unawaited(
                                    ref
                                        .read(authProvider.notifier)
                                        .syncExternalAuthState(),
                                  );
                                },
                                onError: (error) {
                                  ref
                                      .read(authProvider.notifier)
                                      .setExternalAuthError(error);
                                },
                              ),
                            const SizedBox(height: SpacingTokens.md),
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: palette.line,
                                    height: 1,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: SpacingTokens.md,
                                  ),
                                  child: Text(
                                    l10n.loginOrSeparator,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: palette.mutedInk,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: palette.line,
                                    height: 1,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: SpacingTokens.md),
                          ],
                          if (errorMessage != null) ...[
                            Semantics(
                              liveRegion: true,
                              child: Container(
                                padding: const EdgeInsets.all(
                                  SpacingTokens.sm,
                                ),
                                decoration: ObRoughDecoration(
                                  color: palette.wash(ObTone.overspent),
                                  outline: palette.quietPen,
                                  radius: RadiusTokens.sm,
                                  seed: 7,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SkribbleIcon(
                                      data: OpenBudgetIcons.error,
                                      size: 18,
                                      color: palette.overspent,
                                    ),
                                    const SizedBox(width: SpacingTokens.sm),
                                    Expanded(
                                      child: Text(
                                        errorMessage,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(color: palette.ink),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: SpacingTokens.md),
                          ],
                          _LoginTextField(
                            controller: emailController,
                            labelText: l10n.loginEmailLabel,
                            prefixIcon: OpenBudgetIcons.email,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: SpacingTokens.sm),
                          _LoginTextField(
                            controller: passwordController,
                            labelText: l10n.loginPasswordLabel,
                            prefixIcon: OpenBudgetIcons.lock,
                            obscureText: obscurePassword.value,
                            textInputAction: TextInputAction.done,
                            suffixIcon: IconButton(
                              tooltip: obscurePassword.value
                                  ? l10n.authShowPassword
                                  : l10n.authHidePassword,
                              onPressed: () => obscurePassword.value =
                                  !obscurePassword.value,
                              icon: SkribbleIcon(
                                data: obscurePassword.value
                                    ? OpenBudgetIcons.visible
                                    : OpenBudgetIcons.hidden,
                              ),
                            ),
                            onSubmitted: canLogin
                                ? (_) => _login(
                                    ref,
                                    emailController,
                                    passwordController,
                                  )
                                : null,
                          ),
                          const SizedBox(height: SpacingTokens.md),
                          ObFilledButton(
                            onPressed: canLogin
                                ? () => _login(
                                    ref,
                                    emailController,
                                    passwordController,
                                  )
                                : null,
                            isLoading: isLoading,
                            loadingLabel: l10n.loginLoading,
                            child: Text(l10n.loginButton),
                          ),
                          const SizedBox(height: SpacingTokens.sm),
                          TextButton(
                            onPressed: () => _showUnavailable(
                              context,
                              l10n.loginForgotPassword,
                            ),
                            child: Text(l10n.loginForgotPassword),
                          ),
                          TextButton(
                            onPressed: () => context.go(registerPath),
                            child: Text(l10n.loginCreateAccount),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.md),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _login(
    WidgetRef ref,
    TextEditingController emailController,
    TextEditingController passwordController,
  ) {
    unawaited(
      ref
          .read(authProvider.notifier)
          .login(
            email: emailController.text.trim(),
            password: passwordController.text,
          ),
    );
  }

  void _showUnavailable(BuildContext context, String provider) {
    final l10n = AppLocalizations.of(context);
    showAppToast(
      context,
      message: l10n.loginProviderUnavailable(provider),
      variant: AppToastVariant.warning,
    );
  }
}

class _OpenBudgetMark extends HookConsumerWidget {
  const _OpenBudgetMark({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final palette = theme.ob;
    final appIconStyle = ref.watch(appIconStyleProvider);
    return SizedBox(
      height: 96,
      width: 96,
      child: Image.asset(
        appIconStyle.previewAssetPathFor(theme.brightness),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => DecoratedBox(
          decoration: ObRoughDecoration(
            color: palette.wash(ObTone.brand),
            outline: palette.quietPen,
            seed: 9,
          ),
          child: Center(
            child: SkribbleIcon(
              data: OpenBudgetIcons.wallet,
              color: palette.hue(ObTone.brand),
              size: 44,
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginTextField extends HookWidget {
  const _LoginTextField({
    required this.controller,
    required this.labelText,
    required this.prefixIcon,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.suffixIcon,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String labelText;
  final WiredSvgIconData prefixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final Widget? suffixIcon;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).ob;
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: SkribbleIcon(
          data: prefixIcon,
          size: 20,
          color: palette.mutedInk,
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }
}

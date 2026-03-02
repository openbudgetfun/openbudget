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
    final backgroundColor = OpenBudgetPalette.bgAuthFor(theme);
    final cardColor = OpenBudgetPalette.bgSecondaryFor(theme).withAlpha(240);
    final dividerColor = OpenBudgetPalette.borderSubtleFor(theme);
    final statusBarStyle =
        (theme.brightness == Brightness.light
                ? SystemUiOverlayStyle.dark
                : SystemUiOverlayStyle.light)
            .copyWith(statusBarColor: OpenBudgetPalette.transparentFor(theme));

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: statusBarStyle,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: Stack(
          children: [
            _LoginBackdrop(
              backgroundColor: backgroundColor,
              accentColor: theme.colorScheme.primary.withAlpha(35),
              secondaryAccentColor: theme.colorScheme.tertiary.withAlpha(30),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(SpacingTokens.md),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: SpacingTokens.xl),
                        const _OpenBudgetMark(
                          key: Key('login-openbudget-mark'),
                        ),
                        const SizedBox(height: SpacingTokens.md),
                        Text(
                          'Welcome Back',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: SpacingTokens.xs),
                        Text(
                          'Continue building better money habits.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: OpenBudgetPalette.fgSecondaryFor(theme),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: SpacingTokens.lg),
                        Container(
                          padding: const EdgeInsets.all(SpacingTokens.md),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(
                              RadiusTokens.lg,
                            ),
                            border: Border.all(color: dividerColor),
                            boxShadow: [
                              BoxShadow(
                                color: OpenBudgetPalette.overlayScrimFor(
                                  theme,
                                ).withAlpha(18),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (showSocialSection) ...[
                                if (showAppleSignIn)
                                  AppleSignInWidget(
                                    client: client,
                                    minimumWidth: 320,
                                    onAuthenticated: () {
                                      ref
                                          .read(authProvider.notifier)
                                          .syncExternalAuthState();
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
                                      ref
                                          .read(authProvider.notifier)
                                          .syncExternalAuthState();
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
                                        color: dividerColor,
                                        height: 1,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: SpacingTokens.md,
                                      ),
                                      child: Text(
                                        l10n.loginOrSeparator,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color:
                                                  OpenBudgetPalette.fgSecondaryFor(
                                                    theme,
                                                  ),
                                            ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Divider(
                                        color: dividerColor,
                                        height: 1,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: SpacingTokens.md),
                              ],
                              if (errorMessage != null) ...[
                                Container(
                                  padding: const EdgeInsets.all(
                                    SpacingTokens.sm,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.errorContainer,
                                    borderRadius: BorderRadius.circular(
                                      RadiusTokens.sm,
                                    ),
                                  ),
                                  child: Text(
                                    errorMessage,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onErrorContainer,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: SpacingTokens.md),
                              ],
                              _LoginTextField(
                                controller: emailController,
                                hintText: l10n.loginEmailLabel,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                              ),
                              const SizedBox(height: SpacingTokens.sm),
                              _LoginTextField(
                                controller: passwordController,
                                hintText: l10n.loginPasswordLabel,
                                obscureText: obscurePassword.value,
                                textInputAction: TextInputAction.done,
                                suffixIcon: IconButton(
                                  onPressed: () => obscurePassword.value =
                                      !obscurePassword.value,
                                  icon: Icon(
                                    obscurePassword.value
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: OpenBudgetPalette.fgSecondaryFor(
                                      theme,
                                    ),
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
                              FilledButton(
                                onPressed: canLogin
                                    ? () => _login(
                                        ref,
                                        emailController,
                                        passwordController,
                                      )
                                    : null,
                                style: FilledButton.styleFrom(
                                  elevation: 0,
                                  minimumSize: const Size.fromHeight(48),
                                  backgroundColor: OpenBudgetPalette.bgBrandFor(
                                    theme,
                                  ),
                                  foregroundColor:
                                      OpenBudgetPalette.fgOnBrandFor(theme),
                                  disabledBackgroundColor: dividerColor,
                                  disabledForegroundColor:
                                      OpenBudgetPalette.fgSecondaryFor(theme),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      RadiusTokens.sm,
                                    ),
                                  ),
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(l10n.loginButton),
                              ),
                              const SizedBox(height: SpacingTokens.sm),
                              TextButton(
                                onPressed: () => _showUnavailable(
                                  context,
                                  l10n.loginForgotPassword,
                                ),
                                child: Text(
                                  l10n.loginForgotPassword,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: OpenBudgetPalette.bgBrandFor(theme),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () => context.go(registerPath),
                                child: Text(
                                  l10n.loginCreateAccount,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: OpenBudgetPalette.bgBrandFor(theme),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
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
          ],
        ),
      ),
    );
  }

  void _login(
    WidgetRef ref,
    TextEditingController emailController,
    TextEditingController passwordController,
  ) {
    ref
        .read(authProvider.notifier)
        .login(
          email: emailController.text.trim(),
          password: passwordController.text,
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
    final appIconStyle = ref.watch(appIconStyleProvider);
    final fallbackColor = OpenBudgetPalette.bgBrandFor(theme);
    return SizedBox(
      height: 96,
      width: 96,
      child: Image.asset(
        appIconStyle.previewAssetPathFor(theme.brightness),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return DecoratedBox(
            decoration: BoxDecoration(
              color: fallbackColor.withAlpha(22),
              borderRadius: BorderRadius.circular(RadiusTokens.md),
            ),
            child: Icon(
              Icons.account_balance_wallet_outlined,
              color: fallbackColor,
              size: 44,
            ),
          );
        },
      ),
    );
  }
}

class _LoginBackdrop extends StatelessWidget {
  const _LoginBackdrop({
    required this.backgroundColor,
    required this.accentColor,
    required this.secondaryAccentColor,
  });

  final Color backgroundColor;
  final Color accentColor;
  final Color secondaryAccentColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(color: backgroundColor),
          ),
        ),
        Positioned(
          top: -140,
          left: -90,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              color: accentColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          bottom: -110,
          right: -80,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              color: secondaryAccentColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}

class _LoginTextField extends HookWidget {
  const _LoginTextField({
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.suffixIcon,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final Widget? suffixIcon;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: theme.textTheme.bodyLarge?.copyWith(
          color: OpenBudgetPalette.fgSecondaryFor(theme),
        ),
        filled: true,
        fillColor: OpenBudgetPalette.bgTertiaryFor(theme),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.sm),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.sm),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.sm),
          borderSide: BorderSide(
            color: OpenBudgetPalette.borderSubtleFor(theme),
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.md,
          vertical: SpacingTokens.md,
        ),
      ),
    );
  }
}

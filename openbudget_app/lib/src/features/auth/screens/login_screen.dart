import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/auth/providers/auth_provider.dart';
import 'package:openbudget_app/src/features/auth/providers/auth_state.dart';
import 'package:openbudget_app/src/theme/ynab_palette.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

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

    return Scaffold(
      backgroundColor: const Color(0xFFF5F4F2),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(SpacingTokens.md),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: SpacingTokens.xxl),
                  const _YnabMark(key: Key('login-ynab-mark')),
                  const SizedBox(height: SpacingTokens.xl + SpacingTokens.sm),
                  _LoginProviderButton(
                    icon: const Icon(Icons.apple_rounded, size: 22),
                    label: l10n.loginContinueWithApple,
                    onPressed: () =>
                        _showUnavailable(context, l10n.loginContinueWithApple),
                  ),
                  const SizedBox(height: SpacingTokens.sm),
                  _LoginProviderButton(
                    icon: Text(
                      'G',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: const Color(0xFFDB4437),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    label: l10n.loginContinueWithGoogle,
                    onPressed: () =>
                        _showUnavailable(context, l10n.loginContinueWithGoogle),
                  ),
                  const SizedBox(height: SpacingTokens.md),
                  Row(
                    children: [
                      const Expanded(
                        child: Divider(color: YnabPalette.divider, height: 1),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: SpacingTokens.md,
                        ),
                        child: Text(
                          l10n.loginOrSeparator,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: YnabPalette.mutedText,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Divider(color: YnabPalette.divider, height: 1),
                      ),
                    ],
                  ),
                  const SizedBox(height: SpacingTokens.md),
                  if (errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(SpacingTokens.sm),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(RadiusTokens.sm),
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
                      onPressed: () =>
                          obscurePassword.value = !obscurePassword.value,
                      icon: Icon(
                        obscurePassword.value
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: YnabPalette.mutedText,
                      ),
                    ),
                    onSubmitted: canLogin
                        ? (_) =>
                              _login(ref, emailController, passwordController)
                        : null,
                  ),
                  const SizedBox(height: SpacingTokens.md),
                  FilledButton(
                    onPressed: canLogin
                        ? () => _login(ref, emailController, passwordController)
                        : null,
                    style: FilledButton.styleFrom(
                      elevation: 0,
                      minimumSize: const Size.fromHeight(48),
                      backgroundColor: YnabPalette.accentBlue,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: YnabPalette.divider,
                      disabledForegroundColor: YnabPalette.mutedText,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(RadiusTokens.sm),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.loginButton),
                  ),
                  const SizedBox(height: SpacingTokens.sm),
                  TextButton(
                    onPressed: () =>
                        _showUnavailable(context, l10n.loginForgotPassword),
                    child: Text(
                      l10n.loginForgotPassword,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: YnabPalette.accentBlue,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
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
    ref
        .read(authProvider.notifier)
        .login(
          email: emailController.text.trim(),
          password: passwordController.text,
        );
  }

  void _showUnavailable(BuildContext context, String provider) {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.loginProviderUnavailable(provider))),
    );
  }
}

class _LoginProviderButton extends HookWidget {
  const _LoginProviderButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final Widget icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextButton.icon(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: YnabPalette.surfaceMuted,
        foregroundColor: theme.colorScheme.onSurface,
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.sm),
        ),
      ),
      icon: icon,
      label: Text(
        label,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _YnabMark extends HookWidget {
  const _YnabMark({super.key});

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.park_rounded,
      color: YnabPalette.accentBlue,
      size: 96,
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
          color: YnabPalette.mutedText,
        ),
        filled: true,
        fillColor: YnabPalette.surfaceMuted,
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
          borderSide: const BorderSide(color: YnabPalette.divider),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.md,
          vertical: SpacingTokens.md,
        ),
      ),
    );
  }
}

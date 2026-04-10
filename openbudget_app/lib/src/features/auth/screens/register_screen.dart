import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/auth/providers/auth_provider.dart';
import 'package:openbudget_app/src/features/auth/providers/auth_state.dart';
import 'package:openbudget_app/src/features/auth/widgets/auth_backdrop.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_app/src/theme/openbudget_palette.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class RegisterScreen extends HookConsumerWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final step = useState(0);
    final emailController = useTextEditingController();
    final codeController = useTextEditingController();
    final passwordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();
    final isSubmitting = useState(false);
    final errorMessage = useState<String?>(null);
    final accountRequestId = useState<String?>(null);
    final registrationToken = useState<String?>(null);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    ref.listen(authProvider, (_, next) {
      if (next is Authenticated) {
        context.go(homePath);
      }
      if (next is AuthError) {
        isSubmitting.value = false;
        errorMessage.value = next.message;
      }
    });

    Future<void> handleStartRegistration() async {
      final email = emailController.text.trim();
      if (email.isEmpty) {
        errorMessage.value = l10n.registerEmailRequired;
        return;
      }
      isSubmitting.value = true;
      errorMessage.value = null;
      try {
        final requestId = await ref
            .read(authProvider.notifier)
            .startRegistration(email: email);
        accountRequestId.value = requestId;
        step.value = 1;
      } on Exception catch (_) {
        errorMessage.value = l10n.registerEmailError;
      } finally {
        isSubmitting.value = false;
      }
    }

    Future<void> handleVerifyCode() async {
      final code = codeController.text.trim();
      if (code.isEmpty) {
        errorMessage.value = l10n.registerCodeRequired;
        return;
      }
      isSubmitting.value = true;
      errorMessage.value = null;
      try {
        final token = await ref
            .read(authProvider.notifier)
            .verifyRegistrationCode(
              accountRequestId: accountRequestId.value!,
              verificationCode: code,
            );
        registrationToken.value = token;
        step.value = 2;
      } on Exception catch (_) {
        errorMessage.value = l10n.registerCodeError;
      } finally {
        isSubmitting.value = false;
      }
    }

    Future<void> handleFinishRegistration() async {
      final password = passwordController.text;
      final confirmPassword = confirmPasswordController.text;
      if (password.isEmpty) {
        errorMessage.value = l10n.registerPasswordRequired;
        return;
      }
      if (password != confirmPassword) {
        errorMessage.value = l10n.registerPasswordMismatch;
        return;
      }
      isSubmitting.value = true;
      errorMessage.value = null;
      await ref
          .read(authProvider.notifier)
          .finishRegistration(
            registrationToken: registrationToken.value!,
            password: password,
          );
    }

    return Scaffold(
      backgroundColor: OpenBudgetPalette.bgAuthFor(theme),
      body: AuthBackdrop(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(SpacingTokens.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: OpenBudgetPalette.bgSecondaryFor(
                    theme,
                  ).withAlpha(theme.brightness == Brightness.dark ? 214 : 236),
                  borderRadius: BorderRadius.circular(RadiusTokens.xl),
                  border: Border.all(
                    color: OpenBudgetPalette.borderSubtleFor(theme).withAlpha(
                      theme.brightness == Brightness.dark ? 204 : 255,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: OpenBudgetPalette.overlayScrimFor(theme).withAlpha(
                        theme.brightness == Brightness.dark ? 130 : 55,
                      ),
                      blurRadius: 28,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(SpacingTokens.lg),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(RadiusTokens.xl),
                        ),
                        child: Icon(
                          Icons.person_add_rounded,
                          size: 40,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: SpacingTokens.lg),
                      Text(
                        l10n.registerTitle,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: SpacingTokens.sm),
                      Text(
                        _stepSubtitle(l10n, step.value),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: SpacingTokens.sm),
                      _StepIndicator(currentStep: step.value),
                      const SizedBox(height: SpacingTokens.lg),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(SpacingTokens.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (errorMessage.value != null) ...[
                                Container(
                                  padding: const EdgeInsets.all(
                                    SpacingTokens.sm,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.errorContainer,
                                    borderRadius: BorderRadius.circular(
                                      RadiusTokens.sm,
                                    ),
                                  ),
                                  child: Text(
                                    errorMessage.value!,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onErrorContainer,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: SpacingTokens.md),
                              ],
                              if (step.value == 0) ...[
                                TextField(
                                  controller: emailController,
                                  decoration: InputDecoration(
                                    labelText: l10n.loginEmailLabel,
                                    prefixIcon: const Icon(
                                      Icons.email_outlined,
                                    ),
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.done,
                                  onSubmitted: isSubmitting.value
                                      ? null
                                      : (_) => handleStartRegistration(),
                                ),
                                const SizedBox(height: SpacingTokens.lg),
                                FilledButton(
                                  onPressed: isSubmitting.value
                                      ? null
                                      : handleStartRegistration,
                                  child: isSubmitting.value
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(l10n.registerSendCode),
                                ),
                              ],
                              if (step.value == 1) ...[
                                TextField(
                                  controller: codeController,
                                  decoration: InputDecoration(
                                    labelText: l10n.registerCodeLabel,
                                    prefixIcon: const Icon(Icons.pin_outlined),
                                  ),
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.done,
                                  onSubmitted: isSubmitting.value
                                      ? null
                                      : (_) => handleVerifyCode(),
                                ),
                                const SizedBox(height: SpacingTokens.lg),
                                FilledButton(
                                  onPressed: isSubmitting.value
                                      ? null
                                      : handleVerifyCode,
                                  child: isSubmitting.value
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(l10n.registerVerifyCode),
                                ),
                              ],
                              if (step.value == 2) ...[
                                TextField(
                                  controller: passwordController,
                                  decoration: InputDecoration(
                                    labelText: l10n.loginPasswordLabel,
                                    prefixIcon: const Icon(Icons.lock_outlined),
                                  ),
                                  obscureText: true,
                                  textInputAction: TextInputAction.next,
                                ),
                                const SizedBox(height: SpacingTokens.md),
                                TextField(
                                  controller: confirmPasswordController,
                                  decoration: InputDecoration(
                                    labelText: l10n.registerConfirmPassword,
                                    prefixIcon: const Icon(Icons.lock_outlined),
                                  ),
                                  obscureText: true,
                                  textInputAction: TextInputAction.done,
                                  onSubmitted: isSubmitting.value
                                      ? null
                                      : (_) => handleFinishRegistration(),
                                ),
                                const SizedBox(height: SpacingTokens.lg),
                                FilledButton(
                                  onPressed: isSubmitting.value
                                      ? null
                                      : handleFinishRegistration,
                                  child: isSubmitting.value
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(l10n.registerCreateAccount),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: SpacingTokens.lg),
                      TextButton(
                        onPressed: () => context.go(loginPath),
                        child: Text(l10n.registerAlreadyHaveAccount),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _stepSubtitle(AppLocalizations l10n, int step) => switch (step) {
    0 => l10n.registerStepEmail,
    1 => l10n.registerStepCode,
    2 => l10n.registerStepPassword,
    _ => '',
  };
}

class _StepIndicator extends HookWidget {
  const _StepIndicator({required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isActive = index <= currentStep;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.xs),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isActive ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive
                  ? colorScheme.primary
                  : colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }
}

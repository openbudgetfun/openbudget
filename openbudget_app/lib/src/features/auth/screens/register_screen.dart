import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/auth/providers/auth_provider.dart';
import 'package:openbudget_app/src/features/auth/providers/auth_state.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
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
    final palette = theme.ob;

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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(SpacingTokens.md),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: SpacingTokens.lg),
                  Center(
                    child: WiredDoodle(
                      kind: WiredDoodleKind.sparkle,
                      size: 72,
                      seed: 6,
                      color: palette.brand,
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.sm),
                  Text(
                    l10n.registerTitle,
                    style: theme.textTheme.headlineLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: SpacingTokens.xs),
                  Text(
                    _stepSubtitle(l10n, step.value),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: palette.mutedInk,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: SpacingTokens.sm),
                  _StepIndicator(currentStep: step.value),
                  const SizedBox(height: SpacingTokens.lg),
                  ObCard(
                    padding: const EdgeInsets.all(SpacingTokens.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (errorMessage.value != null) ...[
                          Semantics(
                            liveRegion: true,
                            child: Container(
                              padding: const EdgeInsets.all(SpacingTokens.sm),
                              decoration: ObRoughDecoration(
                                color: palette.wash(ObTone.overspent),
                                outline: palette.quietPen,
                                radius: RadiusTokens.sm,
                                seed: 15,
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
                                      errorMessage.value!,
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
                        if (step.value == 0) ...[
                          TextField(
                            controller: emailController,
                            decoration: InputDecoration(
                              labelText: l10n.loginEmailLabel,
                              prefixIcon: ObFieldIcon(
                                data: OpenBudgetIcons.email,
                                size: 20,
                                color: palette.mutedInk,
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            onSubmitted: isSubmitting.value
                                ? null
                                : (_) => handleStartRegistration(),
                          ),
                          const SizedBox(height: SpacingTokens.lg),
                          ObFilledButton(
                            onPressed: isSubmitting.value
                                ? null
                                : handleStartRegistration,
                            isLoading: isSubmitting.value,
                            loadingLabel: l10n.registerSubmitting,
                            child: Text(l10n.registerSendCode),
                          ),
                        ],
                        if (step.value == 1) ...[
                          TextField(
                            controller: codeController,
                            decoration: InputDecoration(
                              labelText: l10n.registerCodeLabel,
                              prefixIcon: ObFieldIcon(
                                data: OpenBudgetIcons.keypad,
                                size: 20,
                                color: palette.mutedInk,
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.done,
                            onSubmitted: isSubmitting.value
                                ? null
                                : (_) => handleVerifyCode(),
                          ),
                          const SizedBox(height: SpacingTokens.lg),
                          ObFilledButton(
                            onPressed: isSubmitting.value
                                ? null
                                : handleVerifyCode,
                            isLoading: isSubmitting.value,
                            loadingLabel: l10n.registerSubmitting,
                            child: Text(l10n.registerVerifyCode),
                          ),
                        ],
                        if (step.value == 2) ...[
                          TextField(
                            controller: passwordController,
                            decoration: InputDecoration(
                              labelText: l10n.loginPasswordLabel,
                              prefixIcon: ObFieldIcon(
                                data: OpenBudgetIcons.lock,
                                size: 20,
                                color: palette.mutedInk,
                              ),
                            ),
                            obscureText: true,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: SpacingTokens.md),
                          TextField(
                            controller: confirmPasswordController,
                            decoration: InputDecoration(
                              labelText: l10n.registerConfirmPassword,
                              prefixIcon: ObFieldIcon(
                                data: OpenBudgetIcons.lock,
                                size: 20,
                                color: palette.mutedInk,
                              ),
                            ),
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            onSubmitted: isSubmitting.value
                                ? null
                                : (_) => handleFinishRegistration(),
                          ),
                          const SizedBox(height: SpacingTokens.lg),
                          ObFilledButton(
                            onPressed: isSubmitting.value
                                ? null
                                : handleFinishRegistration,
                            isLoading: isSubmitting.value,
                            loadingLabel: l10n.registerSubmitting,
                            child: Text(l10n.registerCreateAccount),
                          ),
                        ],
                      ],
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
    final l10n = AppLocalizations.of(context);
    final palette = Theme.of(context).ob;

    return Semantics(
      label: l10n.authStepProgress(currentStep + 1, 3),
      child: ExcludeSemantics(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final isActive = index <= currentStep;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.xs),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isActive ? 24 : 10,
                height: 10,
                decoration: ObRoughDecoration(
                  color: isActive ? palette.brandWash : palette.surface,
                  outline: isActive ? palette.firmPen : palette.quietPen,
                  radius: RadiusTokens.sm,
                  seed: 5 + index,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

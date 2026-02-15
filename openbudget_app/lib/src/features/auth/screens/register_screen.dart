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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: WiredCard(
              height: 420,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.registerTitle,
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _stepSubtitle(l10n, step.value),
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    if (errorMessage.value != null) ...[
                      Text(
                        errorMessage.value!,
                        style: const TextStyle(color: ColorTokens.error),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (step.value == 0) ...[
                      WiredInput(
                        controller: emailController,
                        hintText: l10n.loginEmailLabel,
                      ),
                      const SizedBox(height: 24),
                      WiredButton(
                        onPressed: isSubmitting.value
                            ? () {}
                            : handleStartRegistration,
                        child: Text(
                          isSubmitting.value
                              ? l10n.registerSubmitting
                              : l10n.registerSendCode,
                        ),
                      ),
                    ],
                    if (step.value == 1) ...[
                      WiredInput(
                        controller: codeController,
                        hintText: l10n.registerCodeLabel,
                      ),
                      const SizedBox(height: 24),
                      WiredButton(
                        onPressed: isSubmitting.value
                            ? () {}
                            : handleVerifyCode,
                        child: Text(
                          isSubmitting.value
                              ? l10n.registerSubmitting
                              : l10n.registerVerifyCode,
                        ),
                      ),
                    ],
                    if (step.value == 2) ...[
                      WiredInput(
                        controller: passwordController,
                        hintText: l10n.loginPasswordLabel,
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),
                      WiredInput(
                        controller: confirmPasswordController,
                        hintText: l10n.registerConfirmPassword,
                        obscureText: true,
                      ),
                      const SizedBox(height: 24),
                      WiredButton(
                        onPressed: isSubmitting.value
                            ? () {}
                            : handleFinishRegistration,
                        child: Text(
                          isSubmitting.value
                              ? l10n.registerSubmitting
                              : l10n.registerCreateAccount,
                        ),
                      ),
                    ],
                    const Spacer(),
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
    );
  }

  String _stepSubtitle(AppLocalizations l10n, int step) {
    return switch (step) {
      0 => l10n.registerStepEmail,
      1 => l10n.registerStepCode,
      2 => l10n.registerStepPassword,
      _ => '',
    };
  }
}

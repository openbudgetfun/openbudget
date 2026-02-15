import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/auth/providers/auth_provider.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: WiredCard(
              height: 380,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.loginTitle,
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    WiredInput(
                      controller: emailController,
                      hintText: l10n.loginEmailLabel,
                    ),
                    const SizedBox(height: 16),
                    WiredInput(
                      controller: passwordController,
                      hintText: l10n.loginPasswordLabel,
                      obscureText: true,
                    ),
                    const SizedBox(height: 24),
                    WiredButton(
                      onPressed: () {
                        ref
                            .read(authProvider.notifier)
                            .login(
                              email: emailController.text,
                              password: passwordController.text,
                            );
                      },
                      child: Text(l10n.loginButton),
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
}

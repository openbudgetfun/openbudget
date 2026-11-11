import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/assistant/models/assistant_failure.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// Explains why the assistant stopped and offers the next step that can
/// unblock it.
class AssistantFailurePanel extends HookWidget {
  const AssistantFailurePanel({
    required this.entityId,
    required this.failure,
    required this.onRetry,
    super.key,
  });

  final String entityId;
  final AssistantFailure failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (title, message) = _copy(l10n, failure);

    final providerAction = ObStateAction(
      label: l10n.assistantErrorUseOwnProvider,
      onPressed: () => _openProvider(context),
    );
    final retryAction = ObStateAction(
      label: l10n.assistantErrorTryAgain,
      onPressed: onRetry,
    );

    final (action, secondaryAction) = switch (failure) {
      AssistantEntitlementRequired() => _entitlementActions(
        context,
        l10n,
        providerAction,
      ),
      AssistantAllowanceExhausted() => (providerAction, null),
      AssistantProviderUnavailable() => (providerAction, retryAction),
      AssistantValidationFailure() ||
      AssistantNetworkFailure() ||
      AssistantUnknownFailure() => (retryAction, null),
    };

    return ObStatePanel.problem(
      title: title,
      message: message,
      action: action,
      secondaryAction: secondaryAction,
    );
  }

  void _openProvider(BuildContext context) {
    unawaited(
      context.pushNamed(
        assistantProviderRoute,
        pathParameters: {'entityId': entityId},
      ),
    );
  }

  (ObStateAction, ObStateAction?) _entitlementActions(
    BuildContext context,
    AppLocalizations l10n,
    ObStateAction providerAction,
  ) {
    final plusLocation = _plusLocation(context, entityId);
    if (plusLocation == null) {
      return (providerAction, null);
    }

    return (
      ObStateAction(
        label: l10n.assistantErrorGetPlus,
        onPressed: () => unawaited(GoRouter.of(context).push(plusLocation)),
      ),
      providerAction,
    );
  }

  (String, String) _copy(AppLocalizations l10n, AssistantFailure failure) =>
      switch (failure) {
        AssistantEntitlementRequired() => (
          l10n.assistantErrorEntitlementTitle,
          l10n.assistantErrorEntitlementMessage,
        ),
        AssistantAllowanceExhausted() => (
          l10n.assistantErrorAllowanceTitle,
          l10n.assistantErrorAllowanceMessage,
        ),
        AssistantProviderUnavailable() => (
          l10n.assistantErrorProviderTitle,
          l10n.assistantErrorProviderMessage,
        ),
        AssistantValidationFailure(:final message) => (
          l10n.assistantErrorValidationTitle,
          message,
        ),
        AssistantNetworkFailure() => (
          l10n.assistantErrorNetworkTitle,
          l10n.assistantErrorNetworkMessage,
        ),
        AssistantUnknownFailure() => (
          l10n.assistantErrorUnknownTitle,
          l10n.assistantErrorUnknownMessage,
        ),
      };
}

/// Returns the location of the optional "plus" route, when this build has
/// one. Billing ships separately, so the assistant invites an upgrade only
/// when the route is actually reachable.
String? _plusLocation(BuildContext context, String entityId) {
  final router = GoRouter.maybeOf(context);
  if (router == null) return null;

  for (final pathParameters in <Map<String, String>>[
    {'entityId': entityId},
    const {},
  ]) {
    try {
      return router.namedLocation('plus', pathParameters: pathParameters);
    } on Object {
      // The route is missing, or it does not take this parameter set.
    }
  }
  return null;
}

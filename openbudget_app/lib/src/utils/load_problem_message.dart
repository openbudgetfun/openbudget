import 'dart:async';

import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_client/openbudget_client.dart';

/// Explains why a screen's data did not load, in words a person can act on.
///
/// Error panels used to print the raw exception, which showed class names
/// and status codes. This maps the failures the client can raise to a short
/// localized sentence, so every load error reads the same way.
String loadProblemMessage(AppLocalizations l10n, Object error) =>
    switch (error) {
      // A screen's code that could not be fetched is almost always the
      // connection.
      ServerpodClientNetworkException() ||
      DeferredLoadException() => l10n.loadProblemOffline,
      AuthenticationRequiredException() ||
      ServerpodClientUnauthorized() => l10n.loadProblemSignedOut,
      NotFoundException() ||
      ForbiddenException() ||
      ServerpodClientNotFound() ||
      ServerpodClientForbidden() => l10n.loadProblemNotFound,
      _ => l10n.loadProblemGeneric,
    };

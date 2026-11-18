import 'package:flutter_test/flutter_test.dart';
import 'package:openbudget_app/l10n/generated/app_localizations_en.dart';
import 'package:openbudget_app/src/utils/load_problem_message.dart';
import 'package:openbudget_client/openbudget_client.dart';

void main() {
  final l10n = AppLocalizationsEn();

  group('loadProblemMessage', () {
    test('asks to check the connection when the server is unreachable', () {
      expect(
        loadProblemMessage(
          l10n,
          const ServerpodClientNetworkException('Failed host lookup'),
        ),
        l10n.loadProblemOffline,
      );
    });

    test('asks to sign in again when the session has ended', () {
      expect(
        loadProblemMessage(l10n, ServerpodClientUnauthorized()),
        l10n.loadProblemSignedOut,
      );
      expect(
        loadProblemMessage(l10n, AuthenticationRequiredException()),
        l10n.loadProblemSignedOut,
      );
    });

    test('explains a missing or forbidden item', () {
      for (final error in <Object>[
        NotFoundException(),
        ForbiddenException(),
        ServerpodClientNotFound(),
        ServerpodClientForbidden(),
      ]) {
        expect(loadProblemMessage(l10n, error), l10n.loadProblemNotFound);
      }
    });

    test('never shows the raw exception text', () {
      final message = loadProblemMessage(
        l10n,
        StateError('Envelope abc is not part of this month view'),
      );

      expect(message, l10n.loadProblemGeneric);
      expect(message, isNot(contains('StateError')));
      expect(
        loadProblemMessage(l10n, ServerpodClientInternalServerError()),
        l10n.loadProblemGeneric,
      );
    });
  });
}

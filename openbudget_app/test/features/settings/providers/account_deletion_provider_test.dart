import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/src/features/auth/providers/auth_provider.dart';
import 'package:openbudget_app/src/features/auth/providers/auth_state.dart';
import 'package:openbudget_app/src/features/settings/providers/account_deletion_provider.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';

import '../../../support/fake_endpoint_client.dart';

/// An auth notifier that starts signed in and records the sign-out.
class FakeAuthNotifier extends AuthNotifier {
  int forgotten = 0;

  @override
  AuthState build() => const Authenticated(userId: 'user-1');

  @override
  Future<void> forgetDeletedAccount() async {
    forgotten++;
    state = const Unauthenticated();
  }
}

void main() {
  ProviderContainer containerFor(FakeEndpointClient client) {
    final container = ProviderContainer(
      overrides: [
        serverpodClientProvider.overrideWithValue(client),
        authProvider.overrideWith(FakeAuthNotifier.new),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('deleteAccount calls the server and signs this device out', () async {
    final client = FakeEndpointClient()
      ..handle('settings', 'deleteAccount', (_) => null);
    final container = containerFor(client);
    expect(container.read(authProvider), isA<Authenticated>());

    final deleted = await container
        .read(accountDeletionProvider.notifier)
        .deleteAccount();

    expect(deleted, isTrue);
    expect(client.callsTo('settings', 'deleteAccount'), hasLength(1));
    expect(container.read(authProvider), isA<Unauthenticated>());
    expect(
      container.read(accountDeletionProvider),
      const AsyncValue<void>.data(null),
    );
  });

  test(
    'a refused deletion keeps the user signed in and holds the error',
    () async {
      final client = FakeEndpointClient()
        ..handle(
          'settings',
          'deleteAccount',
          (_) => throw ValidationException(message: 'Cancel first'),
        );
      final container = containerFor(client);

      final deleted = await container
          .read(accountDeletionProvider.notifier)
          .deleteAccount();

      expect(deleted, isFalse);
      expect(container.read(authProvider), isA<Authenticated>());
      expect(
        container.read(accountDeletionProvider).error,
        isA<ValidationException>(),
      );
    },
  );
}

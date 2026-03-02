import 'package:flutter_test/flutter_test.dart';
import 'package:openbudget_app/src/features/auth/providers/auth_state.dart';
import 'package:openbudget_app/src/routing/app_router.dart';
import 'package:openbudget_app/src/routing/route_names.dart';

void main() {
  group('authRedirectForLocation', () {
    test('keeps loading users on startup route', () {
      expect(
        authRedirectForLocation(
          authState: const AuthLoading(),
          location: startupPath,
        ),
        isNull,
      );
    });

    test('redirects loading users to startup route', () {
      expect(
        authRedirectForLocation(
          authState: const AuthLoading(),
          location: loginPath,
        ),
        startupPath,
      );
      expect(
        authRedirectForLocation(authState: const AuthLoading(), location: '/'),
        startupPath,
      );
    });

    test('redirects unauthenticated users from startup to login', () {
      expect(
        authRedirectForLocation(
          authState: const Unauthenticated(),
          location: startupPath,
        ),
        loginPath,
      );
    });

    test('keeps unauthenticated users on auth routes', () {
      expect(
        authRedirectForLocation(
          authState: const Unauthenticated(),
          location: loginPath,
        ),
        isNull,
      );
      expect(
        authRedirectForLocation(
          authState: const Unauthenticated(),
          location: registerPath,
        ),
        isNull,
      );
    });

    test('redirects authenticated users away from startup and auth routes', () {
      expect(
        authRedirectForLocation(
          authState: const Authenticated(userId: '1'),
          location: startupPath,
        ),
        homePath,
      );
      expect(
        authRedirectForLocation(
          authState: const Authenticated(userId: '1'),
          location: loginPath,
        ),
        homePath,
      );
      expect(
        authRedirectForLocation(
          authState: const Authenticated(userId: '1'),
          location: registerPath,
        ),
        homePath,
      );
    });

    test('allows authenticated users on non-auth routes', () {
      expect(
        authRedirectForLocation(
          authState: const Authenticated(userId: '1'),
          location: createBudgetPath,
        ),
        isNull,
      );
    });
  });
}

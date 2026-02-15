import 'package:openbudget_app/src/features/auth/providers/auth_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() {
    return const AuthState.unauthenticated();
  }

  Future<void> login({required String email, required String password}) async {
    state = const AuthState.loading();

    // Placeholder: simulate a login delay
    await Future<void>.delayed(const Duration(milliseconds: 500));

    if (!ref.mounted) return;

    // For now, always succeed with a mock user
    state = AuthState.authenticated(userId: 'mock-user-$email');
  }

  void logout() {
    state = const AuthState.unauthenticated();
  }
}

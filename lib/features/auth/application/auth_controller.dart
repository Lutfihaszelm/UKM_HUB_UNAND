import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_state.dart';

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  void toggleObscurePassword() {
    state = state.copyWith(obscurePassword: !state.obscurePassword);
  }

  void toggleRememberMe() {
    state = state.copyWith(rememberMe: !state.rememberMe);
  }

  /// Returns true on success. Wires up loading/error UI state.
  /// TODO: replace the simulated delay with a real REST API call
  /// (POST /auth/login) once the backend contract is defined.
  Future<bool> submitLogin({
    required String emailOrNim,
    required String password,
  }) async {
    if (emailOrNim.trim().isEmpty || password.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Email/NIM dan kata sandi wajib diisi.',
      );
      return false;
    }

    state = state.copyWith(isSubmitting: true, errorMessage: null);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    state = state.copyWith(isSubmitting: false);
    return true;
  }
}

import '../../../models/user.dart';

/// UI state for the Login screen.
class AuthState {
  const AuthState({
    this.obscurePassword = true,
    this.rememberMe = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.user,
  });

  final bool obscurePassword;
  final bool rememberMe;
  final bool isSubmitting;
  final String? errorMessage;
  final User? user;

  AuthState copyWith({
    bool? obscurePassword,
    bool? rememberMe,
    bool? isSubmitting,
    String? errorMessage,
    User? user,
  }) {
    return AuthState(
      obscurePassword: obscurePassword ?? this.obscurePassword,
      rememberMe: rememberMe ?? this.rememberMe,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
      user: user ?? this.user,
    );
  }
}

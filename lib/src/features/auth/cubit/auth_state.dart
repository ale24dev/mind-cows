// ignore_for_file: avoid_final_parameters

part of 'auth_cubit.dart';

enum AuthStatus { initial, loading, success, authenticated, error }

extension AuthStatusX on AuthStatus {
  bool get isLoading => this == AuthStatus.loading;
  bool get isSuccess => this == AuthStatus.success;
  bool get isError => this == AuthStatus.error;
  bool get isAuthenticated => this == AuthStatus.authenticated;
}

@freezed
class AuthState with _$AuthState {
  const factory AuthState({
    @Default(AuthStatus.initial) final AuthStatus authStatus,
    final User? user,
    String? errorMessage,
  }) = _AuthState;
}

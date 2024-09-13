import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:my_app/src/features/auth/data/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_state.dart';
part 'auth_cubit.freezed.dart';

@injectable
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._authRepository, this._client) : super(const AuthState()) {
    _listenSupabaseSession();
  }

  final AuthRepository _authRepository;
  final SupabaseClient _client;

  void _listenSupabaseSession() {
    _client.auth.onAuthStateChange.listen((authSupState) {
      log('AUTH message');
      if (_client.auth.currentUser != null) {
        emit(
          state.copyWith(
            authStatus: AuthStatus.authenticated,
            user: _client.auth.currentUser,
          ),
        );
      }
      return switch (authSupState.event) {
        AuthChangeEvent.signedIn => emit(
            state.copyWith(
              authStatus: AuthStatus.authenticated,
              user: authSupState.session!.user,
            ),
          ),
        _ => emit(state),
      };
    });
  }

  Future<void> signUp({required String email, required String password}) async {
    emit(const AuthState(authStatus: AuthStatus.loading));

    final result =
        await _authRepository.signUp(email: email, password: password);

    result.fold(
      (error) => emit(
        const AuthState(
          authStatus: AuthStatus.error,
          errorMessage: 'Error signup',
        ),
      ),
      (success) => emit(const AuthState(authStatus: AuthStatus.authenticated)),
    );
  }

  Future<void> signIn({required String email, required String password}) async {
    emit(const AuthState(authStatus: AuthStatus.loading));

    final result =
        await _authRepository.signIn(email: email, password: password);

    result.fold(
      (error) => emit(
        const AuthState(
          authStatus: AuthStatus.error,
          errorMessage: 'Error signin',
        ),
      ),
      (success) => emit(const AuthState(authStatus: AuthStatus.authenticated)),
    );
  }

  void refresh() {
    emit(const AuthState());
  }
}

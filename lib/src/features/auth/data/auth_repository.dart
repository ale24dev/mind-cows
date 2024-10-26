import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:my_app/src/core/exceptions.dart';
import 'package:my_app/src/core/utils/object_extensions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@singleton
class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient _client;

  Future<Either<Exception, bool>> signUp({
    required String email,
    required String password,
  }) async {
    try {
      await _client.auth.signUp(email: email, password: password);
      return right(true);
    } catch (e) {
      return left(Exception('Error sign up'));
    }
  }

  Future<Either<Exception, bool>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
      return right(true);
    } catch (e) {
      return left(Exception('Error sign up'));
    }
  }

  Future<Either<Exception, bool>> logout() async {
    try {
      await _client.auth.signOut();
      return right(true);
    } catch (e) {
      return left(Exception('Error sign up'));
    }
  }

  Future<Either<Exception, bool>> removeAccount() async {
    try {
      final supabase = SupabaseClient(
          dotenv.get('SUPABASE_URL'), dotenv.get('SERVICE_ROLE_KEY'),);
      final resp =
          await supabase.auth.admin.deleteUser(_client.auth.currentUser!.id);
      return right(true);
    } catch (e) {
      return left(Exception('Error removing account'));
    }
  }

  Future<Either<AppException, bool>> refreshToken() async {
    try {
      final refreshToken = _client.auth.currentSession?.refreshToken;
      if (refreshToken.isNull) throw AuthSessionMissingException();
      await _client.auth.refreshSession();
      return right(true);
    } catch (e) {
      return left(const AuthorizationException('Error refreshing token'));
    }
  }
}

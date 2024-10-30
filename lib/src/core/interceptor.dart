// ignore_for_file: avoid_dynamic_calls

import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:mind_cows/src/core/di/dependency_injection.dart';
import 'package:mind_cows/src/core/exceptions.dart';
import 'package:mind_cows/src/core/utils/object_extensions.dart';
import 'package:mind_cows/src/features/auth/data/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum QueryOption { select, insert, uploadStorage, update, delete }

@singleton
class SupabaseServiceImpl {
  SupabaseServiceImpl();

  /// Executes a query to the database.
  ///
  /// [table] The name of the table.
  /// [fromJsonParse] Function to parse JSON response.
  /// [querySelect] Columns to select in the query.
  /// [request] Function to execute the query.
  /// [queryOption] The query option to execute.
  /// [parseResult] Whether to parse the result.
  /// [responseNullable] Whether the response can be null.
  Future<Either<AppException, T?>> query<T>({
    required String table,
    required Future<dynamic> Function() request,
    required QueryOption queryOption,
    Function? fromJsonParse,
    String? querySelect,
    bool parseResult = true,
    bool responseNullable = false,
  }) async {
    final logger = Logger();

    try {
      logger.d(
        '🟡 Request $request to -> ${queryOption.name} $table',
      );

      final response = await request();

      if (responseNullable &&
          (response == null || (response is List && response.isEmpty))) {
        logger.d('✅ Request to -> ${queryOption.name} $table is nullable');
        return right(null);
      }

      if (!parseResult) {
        return right(response as T);
      }

      T parsedData;
      if (response is FunctionResponse && fromJsonParse.isNotNull) {
        final responseString = json.decode(response.data.toString());
        parsedData = fromJsonParse!(responseString['data']) as T;
      } else {
        parsedData = fromJsonParse != null
            ? fromJsonParse(response) as T
            : response as T;
      }

      logger.d('✅ Request to -> ${queryOption.name} $table');
      return right(parsedData);
    } catch (e, s) {
      logger
        ..e(
          '''
          ❌ Request to -> ${queryOption.name} $table \n
          Error message: ${_getErrorMessage(e)}
          ''',
        )
        ..f('❌ Fatal Error', stackTrace: s);

      if (e is PostgrestException && e.code == 'PGRST301') {
        logger.e('❌ Token expired');
        await _handleTokenExpiration(
          () => query<T>(
            table: table,
            fromJsonParse: fromJsonParse,
            querySelect: querySelect,
            request: request,
            queryOption: queryOption,
            responseNullable: responseNullable,
          ),
        ).then((response) {
          return response;
        });
      } else {
        logger.e('❌ $e');
        return left(_handleException(e as Exception));
      }
      return left(_handleException(e));
    }
  }

  static AppException _handleException(Exception e) {
    final exception = switch (e.runtimeType) {
      const (PostgrestException) => PostresAppException(e.toString()),
      const (CustomAppException) => CustomAppException(e.toString()),
      const (AuthApiException) => AuthenticationException(e.toString()),
      const (AuthorizationException) => AuthorizationException(e.toString()),
      const (NetworkException) => NetworkException(e.toString()),
      _ => CustomAppException(e.toString()),
    };

    return exception;
  }

  /// Refreshes the token and retries the given [callbackFunction].
  static Future<Either<AppException, T?>> _handleTokenExpiration<T>(
    Future<T?> Function() callbackFunction,
  ) async {
    final authRepository = getIt.get<AuthRepository>();

    final response = await authRepository.refreshToken();

    return response.fold(
      left,
      (success) async {
        final result = await callbackFunction();
        return right(result);
      },
    );
  }

  /// Returns the error message from the exception [e].
  static String _getErrorMessage(dynamic e) {
    if (e is PostgrestException) {
      return e.message;
    } else {
      return e.toString();
    }
  }
}

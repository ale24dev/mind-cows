/// Base class from which all exceptions that are specific to the app should extend.
sealed class AppException implements Exception {
  const AppException([this.message]);
  final String? message;
}

class PostresAppException extends AppException {
  const PostresAppException([super.message]);
}

class CustomAppException extends AppException {
  const CustomAppException([super.message]);
}

class AuthenticationException extends AppException {
  const AuthenticationException([super.message]);
}

class AuthorizationException extends AppException {
  const AuthorizationException([super.message]);
}

class NetworkException extends AppException {
  const NetworkException([super.message]);
}

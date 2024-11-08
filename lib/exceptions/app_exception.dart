
class AppException implements Exception {
  final String? message;
  final ExceptionType? type;

  AppException({
    this.message,
    this.type,
  });
}

enum ExceptionType{
  internet,
  format,
  http,
  api,
  timeout,
  other,
}
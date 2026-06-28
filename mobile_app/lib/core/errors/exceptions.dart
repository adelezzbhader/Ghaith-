class ServerException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, List<String>> fieldErrors;

  ServerException({
    required this.message,
    this.statusCode,
    this.fieldErrors = const {},
  });
}

class CacheException implements Exception {
  final String message;
  CacheException({required this.message});
}

class AuthException implements Exception {
  final String message;
  AuthException({required this.message});
}

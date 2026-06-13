/// Excepciones personalizadas para la capa de red.
/// Cada tipo de error HTTP tiene su propia excepción para facilitar 
/// el manejo específico en las capas superiores.

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message (status: $statusCode)';
}

class NetworkException extends ApiException {
  NetworkException(String message) : super(message);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(String message) : super(message, statusCode: 401);
}

class ForbiddenException extends ApiException {
  ForbiddenException(String message) : super(message, statusCode: 403);
}

class NotFoundException extends ApiException {
  NotFoundException(String message) : super(message, statusCode: 404);
}

class ValidationApiException extends ApiException {
  final dynamic errors;
  ValidationApiException(String message, {this.errors})
      : super(message, statusCode: 422);
}

class ServerException extends ApiException {
  ServerException(String message) : super(message, statusCode: 500);
}

/// Modelo genérico de respuesta API.
/// Envuelve la respuesta HTTP proporcionando una interfaz limpia 
/// para acceder a los datos, el código de estado y mensajes opcionales.
class ApiResponse {
  final bool success;
  final dynamic data;
  final int statusCode;
  final String? message;

  ApiResponse({
    required this.success,
    this.data,
    required this.statusCode,
    this.message,
  });
}

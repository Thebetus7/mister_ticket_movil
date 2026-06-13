---
name: flutter-best-practices
description: >
  Buenas prácticas de arquitectura Flutter para el proyecto MisterTicket.
  Define la estructura de carpetas, el patrón modular de API (ApiClient → ModuleApi → Service → Repository → Provider),
  componentes reutilizables, y convenciones de código obligatorias.
---

# 🏗️ Buenas Prácticas de Arquitectura Flutter — MisterTicket

Este skill establece las reglas **obligatorias** de arquitectura, estructura de carpetas, patrón de diseño de API modular y componentes reutilizables para el proyecto **mister_ticket_movil**.

> ⚠️ **REGLA DE ORO**: Toda modificación o adición de código DEBE respetar esta estructura. No se permiten excepciones.

---

## 1. Estructura de Carpetas

```
lib/
├── main.dart                          # Entry point de la app
│
├── config/                            # Configuración global de la app
│   ├── routes.dart                    # Definición de rutas nombradas
│   ├── theme.dart                     # ThemeData (colores, tipografía, etc.)
│   └── app_config.dart                # Variables de entorno (dev, staging, prod)
│
├── core/                              # Núcleo compartido (NO lógica de negocio)
│   ├── constants/                     # Constantes globales
│   │   ├── api_constants.dart         # Base URL y endpoints base
│   │   ├── app_constants.dart         # Constantes de la app (nombres, versiones)
│   │   └── storage_keys.dart          # Keys para SharedPreferences/SecureStorage
│   │
│   ├── network/                       # Capa de red
│   │   ├── api_client.dart            # Cliente HTTP genérico (GET, POST, PUT, DELETE, PATCH)
│   │   ├── api_interceptor.dart       # Interceptores (auth, logging, retry)
│   │   ├── api_response.dart          # Modelo genérico de respuesta API
│   │   └── api_exceptions.dart        # Excepciones personalizadas de red
│   │
│   ├── api/                           # 🔥 APIs modulares por dominio
│   │   ├── auth_api.dart              # Endpoints de autenticación
│   │   ├── user_api.dart              # Endpoints de usuario
│   │   ├── product_api.dart           # Endpoints de productos
│   │   ├── event_api.dart             # Endpoints de eventos (ejemplo futuro)
│   │   └── ticket_api.dart            # Endpoints de tickets (ejemplo futuro)
│   │
│   ├── exceptions/                    # Excepciones personalizadas del dominio
│   │   ├── app_exception.dart         # Excepción base de la app
│   │   ├── auth_exception.dart        # Excepciones de autenticación
│   │   └── validation_exception.dart  # Excepciones de validación
│   │
│   ├── utils/                         # Utilidades y helpers
│   │   ├── validators.dart            # Validadores de formulario
│   │   ├── formatters.dart            # Formateadores (fecha, moneda, etc.)
│   │   ├── logger.dart                # Logger centralizado
│   │   └── extensions/               # Extension methods de Dart
│   │       ├── string_extensions.dart
│   │       ├── context_extensions.dart
│   │       └── datetime_extensions.dart
│   │
│   └── widgets/                       # 🎨 Widgets reutilizables globales
│       ├── buttons/
│       │   ├── app_button.dart        # Botón primario estándar
│       │   ├── app_icon_button.dart   # Botón con icono
│       │   └── app_text_button.dart   # Botón de texto
│       ├── inputs/
│       │   ├── app_text_field.dart    # Campo de texto estándar
│       │   ├── app_dropdown.dart      # Dropdown estándar
│       │   └── app_search_field.dart  # Campo de búsqueda
│       ├── feedback/
│       │   ├── app_loading.dart       # Indicador de carga
│       │   ├── app_error_widget.dart  # Widget de error
│       │   ├── app_empty_state.dart   # Widget de estado vacío
│       │   └── app_snackbar.dart      # SnackBar personalizado
│       ├── layout/
│       │   ├── app_scaffold.dart      # Scaffold personalizado
│       │   ├── app_app_bar.dart       # AppBar personalizado
│       │   └── app_drawer.dart        # Drawer lateral
│       └── cards/
│           ├── app_card.dart          # Card estándar
│           └── app_info_card.dart     # Card informativa
│
├── data/                              # Capa de datos
│   ├── models/                        # Modelos de datos (DTOs)
│   │   ├── user_model.dart
│   │   ├── product_model.dart
│   │   ├── event_model.dart           # (ejemplo futuro)
│   │   └── ticket_model.dart          # (ejemplo futuro)
│   │
│   ├── services/                      # Servicios (lógica de negocio + parseo)
│   │   ├── auth_service.dart
│   │   ├── product_service.dart
│   │   └── storage_service.dart       # Servicio de almacenamiento local
│   │
│   └── repositories/                  # Repositorios (abstracción para providers)
│       ├── auth_repository.dart
│       └── product_repository.dart
│
└── presentation/                      # Capa de presentación (UI)
    ├── state/                         # State management (Providers)
    │   ├── auth_provider.dart
    │   └── product_provider.dart
    │
    ├── pages/                         # Páginas/Screens completas
    │   ├── auth/                      # Módulo de autenticación
    │   │   ├── login_page.dart
    │   │   ├── register_page.dart
    │   │   └── forgot_password_page.dart
    │   ├── dashboard/
    │   │   └── dashboard_page.dart
    │   ├── products/
    │   │   ├── products_page.dart
    │   │   └── product_detail_page.dart
    │   └── profile/
    │       └── profile_page.dart
    │
    └── widgets/                       # Widgets específicos de la UI (no reutilizables globalmente)
        ├── product_card.dart          # Card específica de producto
        ├── event_card.dart            # Card específica de evento
        └── dashboard_stat_card.dart   # Card de estadísticas del dashboard
```

---

## 2. 🔥 Patrón de Diseño de API Modular

### Flujo obligatorio de datos

```
UI (Page/Widget)
    ↓ interactúa con
Provider (State Management)
    ↓ delega a
Repository (Abstracción / try-catch)
    ↓ delega a
Service (Lógica de negocio + parseo de respuesta)
    ↓ usa
Module API (core/api/xxx_api.dart) — Endpoints específicos del módulo
    ↓ delega HTTP a
ApiClient (core/network/api_client.dart) — Cliente HTTP genérico
    ↓ realiza
HTTP Request al Backend
```

### 2.1 ApiClient — Cliente HTTP Genérico (`core/network/api_client.dart`)

El `ApiClient` es el **ÚNICO** punto de contacto con HTTP. Maneja:
- Headers (Content-Type, Authorization)
- Todos los métodos HTTP (GET, POST, PUT, DELETE, PATCH)
- Manejo básico de errores de red
- Timeout

```dart
// core/network/api_client.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import 'api_exceptions.dart';
import 'api_response.dart';

class ApiClient {
  final http.Client _client = http.Client();
  static const Duration _timeout = Duration(seconds: 30);

  // ─── Headers ───
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ─── GET ───
  Future<ApiResponse> get(String url, {Map<String, String>? queryParams}) async {
    try {
      final uri = Uri.parse(url).replace(queryParameters: queryParams);
      final headers = await _getHeaders();
      final response = await _client.get(uri, headers: headers).timeout(_timeout);
      return _handleResponse(response);
    } on SocketException {
      throw NetworkException('Sin conexión a internet');
    } on http.ClientException {
      throw NetworkException('Error de conexión con el servidor');
    }
  }

  // ─── POST ───
  Future<ApiResponse> post(String url, {Map<String, dynamic>? body}) async {
    try {
      final headers = await _getHeaders();
      final response = await _client
          .post(Uri.parse(url), headers: headers, body: jsonEncode(body))
          .timeout(_timeout);
      return _handleResponse(response);
    } on SocketException {
      throw NetworkException('Sin conexión a internet');
    } on http.ClientException {
      throw NetworkException('Error de conexión con el servidor');
    }
  }

  // ─── PUT ───
  Future<ApiResponse> put(String url, {Map<String, dynamic>? body}) async {
    try {
      final headers = await _getHeaders();
      final response = await _client
          .put(Uri.parse(url), headers: headers, body: jsonEncode(body))
          .timeout(_timeout);
      return _handleResponse(response);
    } on SocketException {
      throw NetworkException('Sin conexión a internet');
    } on http.ClientException {
      throw NetworkException('Error de conexión con el servidor');
    }
  }

  // ─── DELETE ───
  Future<ApiResponse> delete(String url) async {
    try {
      final headers = await _getHeaders();
      final response = await _client.delete(Uri.parse(url), headers: headers).timeout(_timeout);
      return _handleResponse(response);
    } on SocketException {
      throw NetworkException('Sin conexión a internet');
    } on http.ClientException {
      throw NetworkException('Error de conexión con el servidor');
    }
  }

  // ─── PATCH ───
  Future<ApiResponse> patch(String url, {Map<String, dynamic>? body}) async {
    try {
      final headers = await _getHeaders();
      final response = await _client
          .patch(Uri.parse(url), headers: headers, body: jsonEncode(body))
          .timeout(_timeout);
      return _handleResponse(response);
    } on SocketException {
      throw NetworkException('Sin conexión a internet');
    } on http.ClientException {
      throw NetworkException('Error de conexión con el servidor');
    }
  }

  // ─── Manejo de respuesta ───
  ApiResponse _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;

    if (statusCode >= 200 && statusCode < 300) {
      return ApiResponse(success: true, data: body, statusCode: statusCode);
    }

    switch (statusCode) {
      case 401:
        throw UnauthorizedException('Sesión expirada. Inicie sesión nuevamente.');
      case 403:
        throw ForbiddenException('No tiene permisos para esta acción.');
      case 404:
        throw NotFoundException('Recurso no encontrado.');
      case 422:
        throw ValidationApiException('Error de validación.', errors: body);
      case 500:
        throw ServerException('Error interno del servidor.');
      default:
        throw ApiException('Error inesperado ($statusCode)', statusCode: statusCode);
    }
  }

  void dispose() {
    _client.close();
  }
}
```

### 2.2 ApiResponse — Respuesta Genérica (`core/network/api_response.dart`)

```dart
// core/network/api_response.dart
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
```

### 2.3 ApiExceptions — Excepciones de Red (`core/network/api_exceptions.dart`)

```dart
// core/network/api_exceptions.dart
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
  ValidationApiException(String message, {this.errors}) : super(message, statusCode: 422);
}

class ServerException extends ApiException {
  ServerException(String message) : super(message, statusCode: 500);
}
```

### 2.4 Module API — API por Módulo (`core/api/xxx_api.dart`)

Cada módulo del backend tiene su propia clase API. Esta clase:
- Recibe el `ApiClient` por inyección
- Define TODOS los endpoints del módulo
- Retorna `ApiResponse` (NO parsea modelos, eso lo hace el Service)

```dart
// core/api/auth_api.dart
import '../network/api_client.dart';
import '../network/api_response.dart';
import '../constants/api_constants.dart';

class AuthApi {
  final ApiClient _client;

  AuthApi(this._client);

  Future<ApiResponse> login(String username, String password) {
    return _client.post(ApiConstants.login, body: {
      'username': username,
      'password': password,
    });
  }

  Future<ApiResponse> getProfile() {
    return _client.get(ApiConstants.profile);
  }

  Future<ApiResponse> refreshToken(String refreshToken) {
    return _client.post(ApiConstants.refreshToken, body: {
      'refresh': refreshToken,
    });
  }
}
```

```dart
// core/api/product_api.dart
import '../network/api_client.dart';
import '../network/api_response.dart';
import '../constants/api_constants.dart';

class ProductApi {
  final ApiClient _client;

  ProductApi(this._client);

  Future<ApiResponse> getAll({Map<String, String>? queryParams}) {
    return _client.get(ApiConstants.products, queryParams: queryParams);
  }

  Future<ApiResponse> getById(int id) {
    return _client.get('${ApiConstants.products}$id/');
  }

  Future<ApiResponse> create(Map<String, dynamic> data) {
    return _client.post(ApiConstants.products, body: data);
  }

  Future<ApiResponse> update(int id, Map<String, dynamic> data) {
    return _client.put('${ApiConstants.products}$id/', body: data);
  }

  Future<ApiResponse> delete(int id) {
    return _client.delete('${ApiConstants.products}$id/');
  }
}
```

### 2.5 Service — Lógica de Negocio (`data/services/xxx_service.dart`)

El service:
- Recibe la API del módulo correspondiente
- Parsea la respuesta API a modelos Dart
- Maneja lógica de negocio (guardar tokens, transformar datos)

```dart
// data/services/auth_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api/auth_api.dart';
import '../../core/network/api_client.dart';

class AuthService {
  final AuthApi _authApi;

  AuthService() : _authApi = AuthApi(ApiClient());

  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await _authApi.login(username, password);
    final data = response.data as Map<String, dynamic>;

    // Guardar tokens
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', data['access']);
    await prefs.setString('refresh_token', data['refresh']);

    return data;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }
}
```

```dart
// data/services/product_service.dart
import '../../core/api/product_api.dart';
import '../../core/network/api_client.dart';
import '../models/product_model.dart';

class ProductService {
  final ProductApi _productApi;

  ProductService() : _productApi = ProductApi(ApiClient());

  Future<List<ProductModel>> getProducts() async {
    final response = await _productApi.getAll();
    final List<dynamic> data = response.data as List<dynamic>;
    return data.map((json) => ProductModel.fromJson(json)).toList();
  }

  Future<ProductModel> getProductById(int id) async {
    final response = await _productApi.getById(id);
    return ProductModel.fromJson(response.data);
  }
}
```

### 2.6 Repository — Abstracción (`data/repositories/xxx_repository.dart`)

El repository:
- Envuelve el service en try-catch
- Proporciona una interfaz limpia al Provider
- NUNCA importa el ApiClient directamente

```dart
// data/repositories/auth_repository.dart
import '../services/auth_service.dart';

class AuthRepository {
  final AuthService _authService = AuthService();

  Future<bool> login(String username, String password) async {
    try {
      await _authService.login(username, password);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
  }
}
```

### 2.7 Provider — State Management (`presentation/state/xxx_provider.dart`)

El provider:
- SOLO usa el Repository, NUNCA el Service o API directamente
- Maneja estados: `isLoading`, `error`, datos
- Llama `notifyListeners()` tras cada cambio de estado

```dart
// presentation/state/product_provider.dart
import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';

class ProductProvider extends ChangeNotifier {
  final ProductRepository _productRepository = ProductRepository();
  List<ProductModel> _products = [];
  bool _isLoading = false;
  String? _error;

  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await _productRepository.fetchProducts();
    } catch (e) {
      _error = e.toString();
      _products = [];
    }

    _isLoading = false;
    notifyListeners();
  }
}
```

---

## 3. Diagrama de Flujo Completo

```
┌────────────────────────────────────────────────────────────┐
│                        UI (Page)                           │
│  Provider.of<ProductProvider>(context).loadProducts()      │
└──────────────────────────┬─────────────────────────────────┘
                           │
                           ▼
┌────────────────────────────────────────────────────────────┐
│                 Provider (ProductProvider)                  │
│  _productRepository.fetchProducts()                        │
└──────────────────────────┬─────────────────────────────────┘
                           │
                           ▼
┌────────────────────────────────────────────────────────────┐
│               Repository (ProductRepository)               │
│  _productService.getProducts()  ← try/catch                │
└──────────────────────────┬─────────────────────────────────┘
                           │
                           ▼
┌────────────────────────────────────────────────────────────┐
│                 Service (ProductService)                    │
│  _productApi.getAll()  ← parsea response a modelos         │
└──────────────────────────┬─────────────────────────────────┘
                           │
                           ▼
┌────────────────────────────────────────────────────────────┐
│               Module API (ProductApi)                      │
│  _client.get(ApiConstants.products)  ← define endpoints    │
└──────────────────────────┬─────────────────────────────────┘
                           │
                           ▼
┌────────────────────────────────────────────────────────────┐
│                   ApiClient (genérico)                      │
│  HTTP GET → parse response → ApiResponse                   │
└──────────────────────────┬─────────────────────────────────┘
                           │
                           ▼
                    🌐 Backend API
```

---

## 4. 🎨 Componentes Reutilizables — Casos de Uso

### 4.1 Cuándo crear un widget reutilizable en `core/widgets/`

| Señal                                                    | Acción                                                  |
| -------------------------------------------------------- | ------------------------------------------------------- |
| Un widget se repite en **2+ páginas**                    | Moverlo a `core/widgets/`                               |
| Un patrón de UI se usa con variaciones mínimas           | Crear un widget parametrizable en `core/widgets/`       |
| Es específico de UNA sola página                         | Dejarlo en `presentation/widgets/`                      |
| Es una variación visual de un widget existente del core  | Agregar un parámetro al widget del core, NO crear otro  |

### 4.2 Ejemplos de Componentes Reutilizables Obligatorios

#### AppButton — Botón primario estándar
```dart
// core/widgets/buttons/app_button.dart
import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final double? width;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final buttonChild = isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
              Text(text),
            ],
          );

    final button = isOutlined
        ? OutlinedButton(onPressed: isLoading ? null : onPressed, child: buttonChild)
        : ElevatedButton(onPressed: isLoading ? null : onPressed, child: buttonChild);

    return width != null ? SizedBox(width: width, child: button) : button;
  }
}
```

#### AppTextField — Campo de texto estándar
```dart
// core/widgets/inputs/app_text_field.dart
import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final bool enabled;

  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.obscureText = false,
    this.validator,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
```

#### AppLoading — Indicador de carga
```dart
// core/widgets/feedback/app_loading.dart
import 'package:flutter/material.dart';

class AppLoading extends StatelessWidget {
  final String? message;

  const AppLoading({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}
```

#### AppErrorWidget — Widget de error
```dart
// core/widgets/feedback/app_error_widget.dart
import 'package:flutter/material.dart';
import '../buttons/app_button.dart';

class AppErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const AppErrorWidget({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              AppButton(text: 'Reintentar', onPressed: onRetry, icon: Icons.refresh),
            ],
          ],
        ),
      ),
    );
  }
}
```

#### AppEmptyState — Estado vacío
```dart
// core/widgets/feedback/app_empty_state.dart
import 'package:flutter/material.dart';

class AppEmptyState extends StatelessWidget {
  final String message;
  final IconData icon;

  const AppEmptyState({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }
}
```

#### AppSnackbar — SnackBar personalizado
```dart
// core/widgets/feedback/app_snackbar.dart
import 'package:flutter/material.dart';

class AppSnackbar {
  static void success(BuildContext context, String message) {
    _show(context, message, Colors.green, Icons.check_circle);
  }

  static void error(BuildContext context, String message) {
    _show(context, message, Colors.red, Icons.error);
  }

  static void info(BuildContext context, String message) {
    _show(context, message, Colors.blue, Icons.info);
  }

  static void warning(BuildContext context, String message) {
    _show(context, message, Colors.orange, Icons.warning);
  }

  static void _show(BuildContext context, String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
```

---

## 5. 📏 Convenciones de Código Obligatorias

### 5.1 Nomenclatura

| Elemento            | Convención                 | Ejemplo                       |
| ------------------- | -------------------------- | ----------------------------- |
| Archivos            | `snake_case.dart`          | `product_service.dart`        |
| Clases              | `PascalCase`               | `ProductService`              |
| Variables/funciones | `camelCase`                | `getProducts()`               |
| Constantes          | `camelCase` o `UPPER_CASE` | `baseUrl` / `MAX_RETRY_COUNT` |
| Carpetas            | `snake_case`               | `auth_api/`                   |
| APIs de módulo      | `{Module}Api`              | `ProductApi`, `AuthApi`       |
| Services            | `{Module}Service`          | `ProductService`              |
| Repositories        | `{Module}Repository`       | `ProductRepository`           |
| Providers           | `{Module}Provider`         | `ProductProvider`             |
| Models              | `{Module}Model`            | `ProductModel`                |
| Pages               | `{Name}Page`               | `LoginPage`                   |

### 5.2 Reglas de Imports

```dart
// ✅ CORRECTO — Orden de imports
// 1. Dart SDK
import 'dart:convert';
import 'dart:io';

// 2. Paquetes externos
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 3. Imports del proyecto (con rutas relativas)
import '../../core/api/product_api.dart';
import '../../core/network/api_client.dart';
import '../models/product_model.dart';

// ❌ INCORRECTO — No mezclar categorías
```

### 5.3 Reglas de Dependencia (Quién importa a quién)

```
✅ PERMITIDO:
  Page         → Provider
  Provider     → Repository
  Repository   → Service
  Service      → Module API (core/api/)
  Module API   → ApiClient (core/network/)

❌ PROHIBIDO:
  Page         → Service (saltar el Provider)
  Page         → ApiClient (acceso directo a red)
  Provider     → Service (saltar el Repository)
  Provider     → ApiClient (acceso directo a red)
  Repository   → ApiClient (saltar el Module API y Service)
  Module API   → Models (el parseo es del Service)
```

### 5.4 Modelo de Datos — Reglas

```dart
// ✅ CORRECTO — Modelo con fromJson y toJson
class ProductModel {
  final int id;
  final String nombre;
  final String descripcion;
  final double precio;
  final int stock;

  ProductModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.stock,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'] ?? '',
      precio: double.parse(json['precio'].toString()),
      stock: json['stock'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'stock': stock,
    };
  }
}
```

---

## 6. 🆕 Checklist para Agregar un Nuevo Módulo

Al agregar un nuevo módulo (ejemplo: `evento`), se deben crear los siguientes archivos en este orden:

1. **`core/constants/api_constants.dart`** — Agregar los endpoints del módulo
2. **`core/api/event_api.dart`** — Crear la clase `EventApi` con todos los endpoints
3. **`data/models/event_model.dart`** — Crear el modelo con `fromJson()` y `toJson()`
4. **`data/services/event_service.dart`** — Crear el service que use `EventApi`
5. **`data/repositories/event_repository.dart`** — Crear el repository que use `EventService`
6. **`presentation/state/event_provider.dart`** — Crear el provider que use `EventRepository`
7. **`presentation/pages/events/`** — Crear las páginas del módulo
8. **`config/routes.dart`** — Registrar las nuevas rutas
9. **`main.dart`** — Registrar el nuevo Provider en `MultiProvider`

### Ejemplo de endpoint en api_constants.dart

```dart
class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // Auth endpoints
  static const String login = '$baseUrl/usuarios/login/';
  static const String profile = '$baseUrl/usuarios/perfil/';
  static const String refreshToken = '$baseUrl/usuarios/token/refresh/';

  // Product endpoints
  static const String products = '$baseUrl/productos/';

  // Event endpoints (nuevo módulo)
  static const String events = '$baseUrl/eventos/';

  // Ticket endpoints (nuevo módulo)
  static const String tickets = '$baseUrl/tickets/';
}
```

---

## 7. ⚠️ Reglas Críticas — NO ROMPER

1. **NUNCA** crear un `ApiClient` dentro de un Service. Se pasa al `ModuleApi` y el `ModuleApi` se inyecta en el Service.
2. **NUNCA** hacer llamadas HTTP fuera de `ApiClient`.
3. **NUNCA** parsear modelos en las clases de `core/api/`. El parseo es responsabilidad del Service.
4. **NUNCA** importar un Service desde un Provider. Los providers SOLO usan Repositories.
5. **NUNCA** poner lógica de UI en Services, Repositories o APIs.
6. **NUNCA** duplicar widgets. Si ya existe un `AppButton`, usarlo en vez de crear botones ad-hoc.
7. **SIEMPRE** usar `AppSnackbar` en vez de `ScaffoldMessenger` directamente.
8. **SIEMPRE** manejar estados de carga (`isLoading`) y error (`error`) en los Providers.
9. **SIEMPRE** agregar `toJson()` y `fromJson()` a los modelos.
10. **SIEMPRE** seguir el flujo: Page → Provider → Repository → Service → API → ApiClient.

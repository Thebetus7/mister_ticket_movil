import '../network/api_client.dart';
import '../network/api_response.dart';
import '../constants/api_constants.dart';

/// API modular de productos.
/// Define TODOS los endpoints relacionados con productos.
/// NO parsea modelos — eso es responsabilidad del Service.
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

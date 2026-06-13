import '../../core/api/product_api.dart';
import '../../core/network/api_client.dart';
import '../models/product_model.dart';

/// Service de productos.
/// Usa ProductApi (módulo API) — NUNCA ApiClient directamente.
/// Se encarga del parseo de respuesta JSON a modelos Dart.
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

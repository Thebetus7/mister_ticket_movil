import '../models/product_model.dart';
import '../services/product_service.dart';

class ProductRepository {
  final ProductService _productService = ProductService();

  Future<List<ProductModel>> fetchProducts() async {
    return await _productService.getProducts();
  }
}

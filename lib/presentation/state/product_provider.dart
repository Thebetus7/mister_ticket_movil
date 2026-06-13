import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';

/// Provider de productos.
/// SOLO usa Repository, NUNCA Service o API directamente.
/// Maneja estados: isLoading, error, datos.
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

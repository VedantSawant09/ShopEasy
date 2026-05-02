import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';

class ProductProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  List<String> _categories = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  
  bool _isLoading = false;
  String _errorMessage = '';

  List<Product> get products => _filteredProducts;
  List<String> get categories => ['All', ..._categories];
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchProducts() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _products = await _apiService.getProducts();
      _filteredProducts = _products;
      
      try {
        _categories = await _apiService.getCategories();
      } catch (e) {
        // Ignore category fetching errors, we still have products
        _categories = [];
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void filterProducts() {
    _filteredProducts = _products.where((product) {
      final matchesCategory = _selectedCategory == 'All' || product.category == _selectedCategory;
      final matchesSearch = product.title.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    filterProducts();
  }

  void search(String query) {
    _searchQuery = query;
    filterProducts();
  }
}

import 'dart:async';

import 'package:product_app/products/product_model.dart';

class ProductListservice {
  bool isInternetConnectivityAvailable = true;
  bool isProductLoading = false;
  int skip = 0;
  List<ProductModel> productList = <ProductModel>[];

  final StreamController<List<ProductModel>> _productListController = StreamController<List<ProductModel>>.broadcast();
  Sink<List<ProductModel>> get _addProductsList => _productListController.sink; // Adds data to the sink
  Stream<List<ProductModel>> get getProductsList => _productListController.stream;  //listen to the stream

  ProductListservice() {
    startListeners();
  }

void dispose() {
  _productListController.close();
}
  
  void startListeners() {
    _productListController.stream.listen((product) { 
      isProductLoading = false;
    });
  }

  void addProducts(List<ProductModel> addToProductList) {
    // Add new products to the existing Products List
    if (addToProductList.isNotEmpty) {
      isProductLoading = true;
      productList.addAll(addToProductList);
    }
    _addProductsList.add(productList);

  }

  // If there is error 
  void aaddProductError(String error) {
    isProductLoading = false;
    _productListController.addError(error);
  }

  void refreshCurrentListProduct() {
    _addProductsList.add(productList);
  }

  void clearProduct() {
    skip = 0;
    productList.clear();
    _addProductsList.add([]);
  }
}
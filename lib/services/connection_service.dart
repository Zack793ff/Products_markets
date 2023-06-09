import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:product_app/services/products/products_list_service.dart';


class ConnectionService {
  late StreamSubscription<ConnectivityResult> connectivity;
  late ProductListservice productListservice;  

  ConnectionService(ProductListservice service) {
    productListservice = service;
  }

  Future<bool> isInternetConnectivityAvailable () async {
    bool isConnectionAvailable = true;

    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      isConnectionAvailable = false;
      productListservice.isInternetConnectivityAvailable = false;
      productListservice.isProductLoading = false;
      productListservice.aaddProductError("Internet connection is currently not available");
      //TODO: Alert the product service that no internet is available
    }
    return isInternetConnectivityAvailable();
  }

  void watchConnectivity(ProductListservice productListservice) {
    connectivity = Connectivity().onConnectivityChanged.listen((ConnectivityResult status) { 
      switch (status) {
        case ConnectivityResult.none:
          productListservice.isInternetConnectivityAvailable = false;
          productListservice.isProductLoading = false;
          productListservice.aaddProductError("Internet Connection is currently unavailable");
          break;
        default:
          productListservice.isInternetConnectivityAvailable = true;
          productListservice.refreshCurrentListProduct();
      }

    });

  }

  void cancel() {
    connectivity.cancel();
  }
}
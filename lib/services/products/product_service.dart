import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:product_app/products/product_list_model.dart';
import 'package:product_app/services/auth/api_values_services.dart';
import 'package:product_app/services/products/products_list_service.dart';
import 'package:http/http.dart' as http;

class ProductService {
  
  late ProductListservice productListService;

  ProductService(ProductListservice service) {
    productListService = service;
  }

  getProducts(String authToken) async {
    if (authToken.isNotEmpty) {
      Uri url = Uri.https(ApiServiceValues.productsBaseUrl, ApiServiceValues.productsBaseUrlPath, {
        'limit': 10,
        'skip': productListService.skip.toString(),
        //'select': title, price 
      }
      );

      await http.get(
      url,
      headers: {
        'Connection': 'Kepp-Alive',
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
        }
      ).then((response) {
        if (response.statusCode == 200) {
          // Three ways to parse info:  Default, via computeand via isolate spawn - Message
          productListService.isProductLoading = true;
          //Default
          final productListModel = ProductListModel.fromRawJson(response.body);
          productListService.addProducts(productListModel.products);
          productListService.skip += 10;
          productListService.isProductLoading = false;

          //(2) Via computes: Spawn an isolates
          // ProductServiceBackgroundParser().parseViaCompute(response.body).then((productList) {print('');
          //   productListService.addProducts(productList.products);
          //   productListService.skip += 10;
          //   productListService.isProductLoading = false;
          // });

          // (3) via isolates spawn: manually spawn isolates plus message
          // Note: might not work on web
            //  ProductServiceBackgroundParser().parseViaIsolate(response.body).then((productList) {
            //   productListService.addProducts(productList.products);
            //   productListService.skip += 10;
            //   productListService.isProductLoading = false;
            //  });

        } else if (response.statusCode == 404) {
          productListService.isProductLoading = false;
          productListService.aaddProductError('Failed to load products:\n 404 not found');
        } else {
          productListService.isProductLoading = false;
          productListService.aaddProductError('Failed to load products:\n Unknown error');
        }
      }).onError((error, stackTrace) {
       // debugPrint('stackTrace: $stackTrace');
       productListService.isProductLoading = false;
       productListService.aaddProductError('Failed to Load Products:\n $error');
      });
    } else {
      productListService.isProductLoading = false;
      productListService.aaddProductError('Failed to Load Products');
    }
  }
}

@immutable
class ProductServiceBacgroundMessage {
  final SendPort sendPort;
  final String encodedJson;

  const ProductServiceBacgroundMessage({
    required this.sendPort, 
    required this.encodedJson
    });  
}


class ProductServiceBackgroundParser {
  // Background parser via compute
  Future<ProductListModel> parseViaCompute(String encodedJson) async {
    return await compute(_fromRawJsonViaCompute, encodedJson);

  }

  ProductListModel _fromRawJsonViaCompute(String body) {
    return ProductListModel.fromRawJson(body);
  }

  // Background parser via isolate spawn
  Future<ProductListModel> parseViaIsolate(String encodedJson) async {
    final ReceivePort receivePort = ReceivePort();
    ProductServiceBacgroundMessage productServiceBackgroundMessage = 
      ProductServiceBacgroundMessage(
        sendPort: receivePort.sendPort, 
        encodedJson: encodedJson
        );
        await Isolate.spawn(_fromRawJsonViaIsolate, productServiceBackgroundMessage);
        // Note Arguments can also be passed as a list of dynamic parameter
       // await Isolate.spawn(_fromRawJsonViaIsolateDynamic, [receivePort.sendPort, encodedJson]);
        return await receivePort.first;
  }

  void _fromRawJsonViaIsolate(ProductServiceBacgroundMessage productServiceBackgroundMessage) {
    SendPort sendPort = productServiceBackgroundMessage.sendPort;
    String encodedJson = productServiceBackgroundMessage.encodedJson;
    final result = ProductListModel.fromRawJson(encodedJson);
    Isolate.exit(sendPort, result);
  }

  // Parameters could also recieve isolates as (list<dynamic> parameters)
/**
 * Future<void> _fromRawJsonViaIsolateDynamic(List<dynamic> parameters) {
    SendPort sendPort = parameters[0];
    String encodedJson = parameters[1];
    final result = ProductListModel.fromRawJson(encodedJson);
    Isolate.exit(sendPort, result);
  }
 *  */  
}
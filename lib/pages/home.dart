import 'package:flutter/material.dart';
import 'package:product_app/helpers/app_helpers.dart';
import 'package:product_app/products/product_model.dart';
import 'package:product_app/services/auth/auth_service.dart';
import 'package:product_app/services/products/product_service.dart';
import 'package:product_app/services/products/products_list_service.dart';
import 'package:product_app/widget/product_list_view.dart';
import 'package:product_app/widget/status_message.dart';

import '../services/connection_service.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late ConnectionService connectionService;
  late ProductService productService;
  AuthServiceResponse authServiceResponse = AuthServiceResponse();
  final ProductListservice productListService = ProductListservice();
  final ScrollController scrollController = ScrollController();
  ValueNotifier<SelectedListType> selectedListType = ValueNotifier<SelectedListType>(SelectedListType.card);

  @override
  void initState() { 
    super.initState();
    connectionService = ConnectionService(productListService);
    connectionService.watchConnectivity(productListService);
    productService = ProductService(productListService);
    getAuth();
    // check if scroll has reached the bottom, then retrirve the text
    scrollController.addListener(() {
      if (scrollController.offset == scrollController.position.maxScrollExtent && !productListService.isProductLoading) {
        // Todo: Get products...the next 10 products.
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
 
  Future<bool> checkInternetConnection() async {
    productListService.isInternetConnectivityAvailable = await connectionService.isInternetConnectivityAvailable();
    if (!productListService.isInternetConnectivityAvailable) {
      productListService.isInternetConnectivityAvailable = false;
      productListService.isProductLoading = false;
      productListService.aaddProductError('Internet Connection is currently unavailable');
    }
    return productListService.isInternetConnectivityAvailable;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder(
          initialData: const [],
          stream: productListService.getProductsList,
          builder: (context, snapshot) {
            if (snapshot.hasData && (snapshot.connectionState == ConnectionState.active)) {
              final productList = snapshot.data as List<ProductModel>;
              return Text('Products: ${productList.length}');  
            } else {
              return const Text('Products');
            }
          }
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: getProducts, 
            icon: const Icon(Icons.refresh),
            ),
            const SizedBox(width: 4),
            ValueListenableBuilder(
              valueListenable: selectedListType,
              builder: (context, value, child) {
                return DropdownButton(
                  value: selectedListType.value.name.toLowerCase(),
                  focusColor: Colors.transparent,
                  style: TextStyle(color: Theme.of(context).primaryColorLight),
                  items: [
                    DropdownMenuItem(
                      value: 'card',
                      child: Row(
                        children: const [ 
                          Icon(Icons.view_agenda_outlined),
                          SizedBox(width: 4),
                          Text('Card')
                        ],
                      ),
                        ),
                    DropdownMenuItem(
                      value: 'list1',
                      child: Row(
                        children: const [
                          Icon(Icons.view_day_outlined),
                          SizedBox(width: 4),
                          Text('List 1'),
                          
                        ],
                      ),
                        ),
                        DropdownMenuItem(
                      value: 'list2',
                      child: Row(
                        children: const [
                          Icon(Icons.view_list_outlined),
                          SizedBox(width: 4),
                          Text('List 2')
                        ],
                    ),
                   ),
                  ], 
                  onChanged: (selectedValue) {
                    if (selectedValue != selectedListType.value.name.toLowerCase()) {
                      selectedListType.value = SelectedListType.values.firstWhere((element) => 
                        element.name == selectedValue.toString().toLowerCase(),
                      );
                      productListService.refreshCurrentListProduct();
                    }
                  }
                  );
              },
            ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder(
          initialData: const [],
          stream: productListService.getProductsList,
          builder: (context, snapshot) {
            if (!productListService.isInternetConnectivityAvailable) {
              return const StatusMessage(
                message: "Internet is currently Unavailable", 
                bannerMessage: "None", 
                bannerColor: Colors.yellow, 
                textColor: Colors.blue
                );
            }
                //Todo: Check snapshot connection state
            switch(snapshot.connectionState) {
              
              case ConnectionState.none:
                // TODO: Handle this case.
                break;
              case ConnectionState.waiting:
                return const Center(
                  child: CircularProgressIndicator(),
                  );
              case ConnectionState.active:
                if (snapshot.hasError) {
                  return StatusMessage(
                    message: '${snapshot.error}', 
                    bannerMessage: !productListService.isInternetConnectivityAvailable ? 'None' : 'error',
                    bannerColor: !productListService.isInternetConnectivityAvailable ? Colors.yellow : Colors.red,
                    textColor: !productListService.isInternetConnectivityAvailable ? Colors.black : Colors.white,
                    );  
                } else if (snapshot.hasData) {
                   final productList = snapshot.data as List<ProductModel>;
                  
                  return ProductListView(
                    productsList: productList, 
                    scrollController: scrollController, 
                    selectedListType: selectedListType.value,
                    );
                //  return const Text('data');
                   
                } else {
                  return const StatusMessage(
                      message: 'Not able to retrieve products', 
                      bannerMessage: 'error', 
                      bannerColor: Colors.red, 
                      textColor: Colors.white
                      );
                }
              case ConnectionState.done:
                // TODO: Handle this case.
                break;
            }

            return const Text('Hello');
          }
          ),
        )
    );
  }
  
  Future<void> getAuth() async{
    productListService.isInternetConnectivityAvailable = await checkInternetConnection();
    if (!productListService.isInternetConnectivityAvailable) {
      return;
    }

    // Authenticate User and look for credentials error
    authServiceResponse = await AuthService.login();
    if (authServiceResponse.statusCode == 200 && authServiceResponse.error != 'Error Response') {
       productListService.isProductLoading = false;
       getProducts();  // Get products
    } else {
      productListService.isProductLoading = false;
      final String error = authServiceResponse.error;
      productListService.aaddProductError(error);
    }
  }

  Future<void> getProducts() async {
    if (productListService.isProductLoading) {
      return;
    }
    productListService.isProductLoading = true;

    // make sure we did not loose connectivity since our last product fetch
    productListService.isInternetConnectivityAvailable = await checkInternetConnection();
    if (!productListService.isInternetConnectivityAvailable) {
      return;
    }

    // Future Enhancement: Check if authServiceResponse has not expired, otherwise re-Authenticated
    if (authServiceResponse.token.isEmpty) {
      getAuth();
      return;
    }

    // Retrieve the next products
    productService.getProducts(authServiceResponse.token);
  }
}
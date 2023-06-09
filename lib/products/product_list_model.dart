import 'dart:convert';

import 'package:product_app/products/product_model.dart';

ProductListModel productListModelFromJson(String str) => ProductListModel.fromJson(json.decode(str));

String productListModelToJson(ProductListModel data) => json.encode(data.toJson());

class ProductListModel {
    List<ProductModel> products;
    int total;
    String skip;  // TODO: The DummyJson.com Mockup service is returning a String instead of an integer. once they fix it, change the string to an int.
    int limit;

    ProductListModel({
        required this.products,
        required this.total,
        required this.skip,
        required this.limit,
    });

    factory ProductListModel.fromRawJson(String str) => ProductListModel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory ProductListModel.fromJson(Map<String, dynamic> json) => ProductListModel(
        products: List<ProductModel>.from(json["products"].map((x) => ProductModel.fromJson(x))),
        total: json["total"],
        skip: json["skip"],
        limit: json["limit"],
    );

    Map<String, dynamic> toJson() => {
        "products": List<dynamic>.from(products.map((x) => x.toJson())),
        "total": total,
        "skip": skip,
        "limit": limit,
    };
}


// Json

/**
 * {
  "products": [

{
  "id": 1,
  "title": "iPhone 9",
  "description": "An apple mobile which is nothing like apple",
  "price": 549,
  "discountPercentage": 12.96,
  "rating": 4.69,
  "stock": 94,
  "brand": "Apple",
  "category": "smartphones",
  "thumbnail": "https://i.dummyjson.com/data/products/1/thumbnail.jpg",
  "images": ["https://i.dummyjson.com/data/products/1/1.jpg", 
             "https://i.dummyjson.com/data/products/1/2.jpg", 
             "https://i.dummyjson.com/data/products/1/3.jpg",
             "https://i.dummyjson.com/data/products/1/4.jpg",
             "https://i.dummyjson.com/data/products/1/thumbnail.jpg"]
},

{
  "id": 2,
  "title": "iPhone X",
  "description": "An apple mobile which is nothing like apple",
  "price": 549,
  "discountPercentage": 12.96,
  "rating": 4.69,
  "stock": 94,
  "brand": "Apple",
  "category": "smartphones",
  "thumbnail": "https://i.dummyjson.com/data/products/2/thumbnail.jpg",
  "images": ["https://i.dummyjson.com/data/products/2/1.jpg", 
            "https://i.dummyjson.com/data/products/2/2.jpg", 
            "https://i.dummyjson.com/data/products/2/3.jpg",
            "https://i.dummyjson.com/data/products/2/4.jpg",
            "https://i.dummyjson.com/data/products/2/thumbnail.jpg"
            ]
}

],
 "total": 100,
  "skip": 0,
  "limit": 10
}
 */
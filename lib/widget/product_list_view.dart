import 'package:flutter/material.dart';
import 'package:product_app/helpers/app_helpers.dart';
import 'package:product_app/products/product_model.dart';
import 'package:product_app/widget/products/productlistview_item_list1.dart';
import 'package:product_app/widget/products/products_listview_item_card.dart';

class ProductListView extends StatelessWidget {
  const ProductListView({super.key, 
      required this.productsList, 
      required this.scrollController, 
      required this.selectedListType
      });

  final List<ProductModel> productsList;
  final ScrollController scrollController;
  final SelectedListType selectedListType;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        const SliverToBoxAdapter(
          child: Icon(Icons.flutter_dash, size: 48),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
            switch (selectedListType) {
              
              case SelectedListType.card:
                return ProductsListViewItem1(productModel: productsList, index: index);
              case SelectedListType.list1:
               return ProductsListViewItem1(productModel: productsList, index: index);
              case SelectedListType.list2:
             return ProductsListViewItem1(productModel: productsList, index: index);
            }
          },
          
          ),
        ),
      ],
    );
  }
}
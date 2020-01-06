import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';
import '../widgets/product_item.dart';

class ProductsGrid extends StatelessWidget {
  final bool showFavs;

  ProductsGrid(this.showFavs);

  @override
  Widget build(BuildContext context) {
    // to listen to the provider, stablish a direct communication with athe products provider
    // only rebuild the widgets listening to it
    final prodData = Provider.of<Products>(context);
    final prod = showFavs ? prodData.favoriteItems : prodData.items;

    return GridView.builder(
      padding: const EdgeInsets.all(1),
      itemCount: prod.length,
      // use Changenotifier.value on grid and list
      itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
        value: prod[index],
        child: ProductItem(),
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
    );
  }
}

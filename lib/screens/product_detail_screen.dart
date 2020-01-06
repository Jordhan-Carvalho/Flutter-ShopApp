import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';

class ProductDetailScreen extends StatelessWidget {
  static const routeName = '/product-detail';

  @override
  Widget build(BuildContext context) {
    final prodId = ModalRoute.of(context).settings.arguments as String;
    // before adding findById method
    // final prod = Provider.of<Products>(context)
    //     .items
    //     .firstWhere((prod) => prod.id == prodId);

// listen to false, so it wont rebuild when products update
    final prod = Provider.of<Products>(context, listen: false).findById(prodId);

    return Scaffold(
      appBar: AppBar(
        title: Text(prod.title),
      ),
    );
  }
}

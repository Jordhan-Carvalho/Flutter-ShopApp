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
      // appBar: AppBar(
      //   title: Text(prod.title),
      // ),
      body: CustomScrollView(
        // slivers = scrollable areas of the screen
        slivers: <Widget>[
          SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                  title: Text(prod.title),
                  background: Hero(
                    tag: prod.id,
                    child: Image.network(
                      prod.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ))),
          SliverList(
            delegate: SliverChildListDelegate([
              SizedBox(height: 10),
              Text(
                '\$${prod.price}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 20,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                width: double.infinity,
                child: Text(
                  prod.description,
                  textAlign: TextAlign.center,
                  softWrap: true,
                ),
              ),
              SizedBox(
                height: 800,
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

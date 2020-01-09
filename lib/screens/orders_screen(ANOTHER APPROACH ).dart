import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/nav_drawer.dart';
import '../providers/orders.dart' show Orders;
import '../widgets/order_item.dart';

// THIS APPROACH WE DISH OUT STATEFUL WITH SETSTATE AND INITSTATE
// USING FUTURE BUILDER

class OrdersScreen extends StatelessWidget {
  static const routeName = '/orders';

  Future<void> _fetchData(BuildContext ctx) async {
    await Provider.of<Orders>(ctx, listen: false).fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Orders'),
      ),
      drawer: MainDrawer(),
      body: FutureBuilder(
        future: _fetchData(context),
        builder: (ctx, dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            if (dataSnapshot.error != null) {
              //.. error handling
              return Center(
                child: Text('Error'),
              );
            } else {
              return RefreshIndicator(
                onRefresh: () => _fetchData(context),
                child: Consumer<Orders>(
                  builder: (ctx, orderData, child) => ListView.builder(
                    itemCount: orderData.orders.length,
                    itemBuilder: (ctx, i) => OrderItem(orderData.orders[i]),
                  ),
                ),
              );
            }
          }
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './providers/auth.dart';
import './screens/auth-screen.dart';
import './screens/user_products_screen.dart';
import './screens/orders_screen.dart';
import './screens/cart_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/products_overview_screen.dart';
import './screens/product_detail_screen.dart';
import './providers/cart.dart';
import './providers/orders.dart';
import './providers/products.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => Auth(),
        ),
        // Passing the token value, ProductsProvider is now dependent on auth provider, its listening to it
        ChangeNotifierProxyProvider<Auth, Products>(
            create: (_) => Products(),
            update: (ctx, authData, prevProds) {
              prevProds..authToken = authData.token;
              prevProds..userId = authData.userId;
              return prevProds;
            }),
        ChangeNotifierProvider(
          create: (_) => Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (_) => Orders(),
          update: (_, authData, prevOrders) =>
              prevOrders..authToken = authData.token,
        ),
      ],
      // whemever auth changes it rebuilds
      child: Consumer<Auth>(
        builder: (ctx, authData, _) => MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.purple,
            accentColor: Colors.deepOrange,
            fontFamily: 'Lato',
          ),
          // home: ProductsOverviewScreen(),
          home: authData.isAuth ? ProductsOverviewScreen() : AuthScreen(),
          routes: {
            ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
            CartScreen.routeName: (_) => CartScreen(),
            OrdersScreen.routeName: (_) => OrdersScreen(),
            UserProductsScreen.routeName: (_) => UserProductsScreen(),
            EditProductScreen.routeName: (_) => EditProductScreen(),
            AuthScreen.routeName: (_) => AuthScreen(),
          },
        ),
      ),
    );
  }
}

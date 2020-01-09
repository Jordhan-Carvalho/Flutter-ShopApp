import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  String _authToken;

  set authToken(String value) {
    _authToken = value;
  }

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url =
        'https://flutter-shopapp-200b2.firebaseio.com/orders.json?auth=$_authToken';
    final timeStamp = DateTime.now();
    try {
      final res = await http.post(url,
          body: json.encode({
            'amount': total,
            'products': cartProducts
                .map((cp) => {
                      'id': cp.id,
                      'title': cp.title,
                      'quantity': cp.quantity,
                      'price': cp.price
                    })
                .toList(),
            'dateTime': timeStamp.toIso8601String(),
          }));
      _orders.insert(
          0,
          OrderItem(
            id: json.decode(res.body)['name'],
            amount: total,
            products: cartProducts,
            dateTime: timeStamp,
          ));

      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> fetchOrders() async {
    final url =
        'https://flutter-shopapp-200b2.firebaseio.com/orders.json?auth=$_authToken';
    try {
      final res = await http.get(url);

      final extractedData = json.decode(res.body) as Map<String, dynamic>;
      final List<OrderItem> loadedOrders = [];
      if (extractedData == null) {
        return;
      }
      extractedData.forEach((key, value) {
        loadedOrders.add(OrderItem(
          id: key,
          amount: value['amount'],
          dateTime: DateTime.parse(value['dateTime']),
          products: (value['products'] as List<dynamic>)
              .map((item) => CartItem(
                    id: item['id'],
                    price: item['price'],
                    title: item['title'],
                    quantity: item['quantity'],
                  ))
              .toList(),
        ));
      });
      _orders = loadedOrders.reversed.toList();

      notifyListeners();
    } catch (e) {
      throw e;
    }
  }
}

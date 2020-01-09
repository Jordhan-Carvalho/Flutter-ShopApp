import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';
import './product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  // var _showFavoritesOnly = false;

  List<Product> get favoriteItems {
    return _items.where((pro) => pro.isFavorite).toList();
  }

  List<Product> get items {
    // if (_showFavoritesOnly) {
    //   return _items.where((prod) => prod.isFavorite).toList();
    // }
    return [..._items];
  }

  Future<void> addProduct(Product prod) async {
    const url = 'https://flutter-shopapp-200b2.firebaseio.com/products.json';
    try {
      final resp = await http.post(
        url,
        body: json.encode({
          'title': prod.title,
          'description': prod.description,
          'imageUrl': prod.imageUrl,
          'price': prod.price,
          'isFavorite': prod.isFavorite,
        }),
      );

      final newProd = Product(
        title: prod.title,
        price: prod.price,
        description: prod.description,
        imageUrl: prod.imageUrl,
        id: json.decode(resp.body)['name'],
      );
      _items.add(newProd);
      // _items.insert(0, newProd); //at the start of the list
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> updateProduct(String id, Product newProd) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url =
          'https://flutter-shopapp-200b2.firebaseio.com/products/$id.json';
      try {
        await http.patch(url,
            body: json.encode({
              'title': newProd.title,
              'description': newProd.description,
              'imageUrl': newProd.imageUrl,
              'price': newProd.price
            }));
        _items[prodIndex] = newProd;
        notifyListeners();
      } catch (e) {
        throw e;
      }
    } else {
      print('...');
    }
  }

  Future<void> deleteProduct(String id) async {
    final url =
        'https://flutter-shopapp-200b2.firebaseio.com/products/$id.json';
    //OPTIMISTIC update
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProd = _items[prodIndex];
    _items.removeAt(prodIndex);
    notifyListeners();
    // DELETE PATCH PUT DOESNT TRHOW ERRORS
    final res = await http.delete(url);
    if (res.statusCode >= 400) {
      _items.insert(prodIndex, existingProd);
      notifyListeners();
      //custom exception created on models folder
      throw HttpException('Could not delete product.');
    }
    existingProd = null;
  }

  Future<void> fetchProducts() async {
    const url = 'https://flutter-shopapp-200b2.firebaseio.com/products.json';
    try {
      final resp = await http.get(url);
      final extractedData = json.decode(resp.body) as Map<String, dynamic>;
      final List<Product> loadedProds = [];
      if (extractedData == null) {
        return;
      }
      extractedData.forEach((key, value) {
        loadedProds.add(Product(
          id: key,
          title: value['title'],
          description: value['description'],
          imageUrl: value['imageUrl'],
          price: value['price'],
          isFavorite: value['isFavorite'],
        ));
      });
      _items = loadedProds;
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Product findById(String id) {
    return items.firstWhere((prod) => prod.id == id);
  }

// FOR GLOBAL FILTERING
  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }
}

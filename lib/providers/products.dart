import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';
import './product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [];

  String _authToken;
  String _userId;

  set authToken(String value) {
    _authToken = value;
  }

  set userId(String value) {
    _userId = value;
  }

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
    final url =
        'https://flutter-shopapp-200b2.firebaseio.com/products.json?auth=$_authToken';
    try {
      final resp = await http.post(
        url,
        body: json.encode({
          'title': prod.title,
          'description': prod.description,
          'imageUrl': prod.imageUrl,
          'price': prod.price,
          'creatorId': _userId,
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
          'https://flutter-shopapp-200b2.firebaseio.com/products/$id.json?auth=$_authToken';
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
        'https://flutter-shopapp-200b2.firebaseio.com/products/$id.json?auth=$_authToken';
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

  Future<void> fetchProducts([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? '&orderBy="creatorId"&equalTo="$_userId"' : '';
    var url =
        'https://flutter-shopapp-200b2.firebaseio.com/products.json?auth=$_authToken$filterString';
    try {
      final resp = await http.get(url);
      final extractedData = json.decode(resp.body) as Map<String, dynamic>;
      final List<Product> loadedProds = [];
      if (extractedData == null) {
        return;
      }

      final favRes = await http.get(
          'https://flutter-shopapp-200b2.firebaseio.com/userFavorites/$_userId.json?auth=$_authToken');
      final favData = json.decode(favRes.body);

      // key is prodId value is prodData
      extractedData.forEach((key, value) {
        loadedProds.add(Product(
          id: key,
          title: value['title'],
          description: value['description'],
          imageUrl: value['imageUrl'],
          price: value['price'],
          // ?? check if the object is null, incase its null it takes the value provided after ??
          isFavorite: favData == null ? false : favData[key] ?? false,
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

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/http_exception.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
  });

  Future<void> toggleFavoriteStatus(String token, String userId) async {
    isFavorite = !isFavorite;
    notifyListeners();
    final url =
        'https://flutter-shopapp-200b2.firebaseio.com/userFavorites/$userId/$id.json?auth=$token';
    // DELETE PUT AND PATCH DOESNT HAVE TRHOWN ERROR
    final res = await http.put(url, body: json.encode(isFavorite));
    if (res.statusCode >= 400) {
      isFavorite = !isFavorite;
      notifyListeners();
      throw HttpException('Not possible to change the fav status');
    }
  }
}

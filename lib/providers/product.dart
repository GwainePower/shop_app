import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';

class Product with ChangeNotifier {
  final String? id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });

  Future<void> toggleFavorite(String authToken, String userId) async {
    final url = Uri.parse(
      'https://flutter-shop-educ-default-rtdb.europe-west1.firebasedatabase.app/userFavorites/$userId/$id.json?auth=$authToken',
    );
    bool? storedIsFavorite = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    final response = await http.put(
      url,
      body: json.encode(
        isFavorite,
      ),
    );
    if (response.statusCode >= 400) {
      isFavorite = storedIsFavorite;
      notifyListeners();
      throw HttpException(
          'COULD NOT FAVORITE THE PRODUCT!! ERROR CODE ${response.statusCode}');
    }
    storedIsFavorite = null;
  }
}

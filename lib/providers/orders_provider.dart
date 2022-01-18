import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import './cart_provider.dart';

class OrderItem {
  final String id;
  final double totalPrice;
  final List<CartItem> cartItems;
  final DateTime date;

  OrderItem({
    required this.id,
    required this.totalPrice,
    required this.cartItems,
    required this.date,
  });
}

class OrdersProvider with ChangeNotifier {
  final String? _authToken;
  final String? _userId;

  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  // set authToken(String value) {
  //   _authToken = value;
  // }

  OrdersProvider(this._authToken, this._userId, this._orders);

  Future<void> fetchAndSetOrders() async {
    final url = Uri.parse(
        'https://flutter-shop-educ-default-rtdb.europe-west1.firebasedatabase.app/orders/$_userId.json?auth=$_authToken');
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>?;
      final List<OrderItem> loadedOrders = [];
      if (extractedData == null) {
        return;
      }
      extractedData.forEach((key, orderData) {
        loadedOrders.insert(
            0,
            OrderItem(
              id: key,
              totalPrice: orderData['totalPrice'].toDouble(),
              cartItems: (orderData['cartItems'] as List<dynamic>)
                  .map(
                    (cartItem) => CartItem(
                      id: cartItem['id'],
                      price: cartItem['price'].toDouble(),
                      quantity: cartItem['quantity'],
                      title: cartItem['title'],
                    ),
                  )
                  .toList(),
              date: DateTime.parse(orderData['date']),
            ));
      });
      _orders = loadedOrders;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> addOrder(List<CartItem> cartProducts, double totalPrice) async {
    final url = Uri.parse(
        'https://flutter-shop-educ-default-rtdb.europe-west1.firebasedatabase.app/orders/$_userId.json?auth=$_authToken');
    final createdTimeStamp = DateTime.now();
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'cartItems': cartProducts
              .map((cartProduct) => {
                    'id': cartProduct.id,
                    'title': cartProduct.title,
                    'price': cartProduct.price,
                    'quantity': cartProduct.quantity,
                  })
              .toList(),
          'totalPrice': totalPrice,
          'date': createdTimeStamp.toIso8601String(),
        }),
      );

      _orders.insert(
        0,
        OrderItem(
          id: json.decode(response.body)['name'],
          totalPrice: totalPrice,
          cartItems: cartProducts,
          date: createdTimeStamp,
        ),
      );
      notifyListeners();
    } catch (error) {
      print(error);
      rethrow;
    }
  }
}

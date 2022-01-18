import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart'
    as http; // пишем так чтобы не было лишних столкновений имен

import '../models/http_exception.dart';
import './product.dart';

class ProductsProvider with ChangeNotifier {
  final String? _authToken;
  final String? _userId;

  List<Product> _items = [];

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((product) => product.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((product) => id == product.id);
  }

  // set authToken(String value) {
  //   _authToken = value;
  // }

  // set userId(String value) {
  //   _userId = value;
  // }

  ProductsProvider(this._authToken, this._userId, this._items);

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? '&orderBy="creatorId"&equalTo="$_userId"' : '';
    var url = Uri.parse(
      'https://flutter-shop-educ-default-rtdb.europe-west1.firebasedatabase.app/products.json?auth=$_authToken$filterString',
    );
    // Тут происходит важная вещь по REST API - GET. Запрашиваем данные
    // с сервера. Разумеется это всё может провалиться изза коннекта,
    // поэтому оборачиваем в try - catch
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>?;
      print(extractedData);
      if (extractedData == null) {
        return;
      }
      // Далее теперь берем isFavorite данные из отдельного хранилища, так как
      // теперь они подвязаны под айди отдельного юзера
      url = Uri.parse(
        'https://flutter-shop-educ-default-rtdb.europe-west1.firebasedatabase.app/userFavorites/$_userId.json?auth=$_authToken',
      );
      final favoritesResponse = await http.get(url);
      final favoritesData = json.decode(favoritesResponse.body);
      final List<Product> loadedProducts = [];
      extractedData.forEach((key, productData) {
        loadedProducts.insert(
            0,
            Product(
              id: key,
              title: productData['title'],
              description: productData['description'],
              price: productData['price'].toDouble(),
              imageUrl: productData['imageUrl'],
              isFavorite:
                  favoritesData == null ? false : favoritesData[key] ?? false,
            ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  // Важная вещь. Фьючер, который *ничего* не возвращает, завернут
  // в async (параллельно выполняющийся код, не сразу дающий результат);
  // результатом возврата является финальная переменная response -
  // завернута она в await. Далее результат обрабатывается в newProduct
  // и вставляется в _items.insert, в приложухе самой уже постится продукт
  // Ловля ошибок идёт через try {} catch {}. Заворачивать надо тот код,
  // который может выдать что-то типа юзер инпута или как тут - инет запрос
  Future<void> addProduct(Product product) async {
    // final url = Uri.https(
    //     'flutter-shop-educ-default-rtdb.europe-west1.firebasedatabase.app',
    //     '/products.json');
    final url = Uri.parse(
      'https://flutter-shop-educ-default-rtdb.europe-west1.firebasedatabase.app/products.json?auth=$_authToken',
    );
    // Далее - http. - вспомним и посмотрим что наверху написано as http
    // POST - важная вещь из REST API. "Постим" запись в онлайн бд
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'price': product.price,
          'imageUrl': product.imageUrl,
          'creatorId': _userId,
        }),
      );

      final newProduct = Product(
        id: json.decode(response.body)['name'],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      );

      _items.insert(0, newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<void> updateExistingProduct(
      String productId, Product productWithNewData) async {
    // final url = Uri.https(
    //     'flutter-shop-educ-default-rtdb.europe-west1.firebasedatabase.app',
    //     '/products/$productId.json');
    final url = Uri.parse(
      'https://flutter-shop-educ-default-rtdb.europe-west1.firebasedatabase.app/products/$productId.json?auth=$_authToken',
    );
    // Важная вещь по REST API - PATCH. через http.patch модифицируем
    // отдельные значения в базе данных. Принять во внимание,
    // что кроме титла, описания, цены и ссылки на картинку
    // есть ещё isFavorite, но в методе оно не указано, так как меняем
    // isFavorite в другом отсеке
    try {
      await http.patch(
        url,
        body: json.encode({
          'title': productWithNewData.title,
          'description': productWithNewData.description,
          'price': productWithNewData.price,
          'imageUrl': productWithNewData.imageUrl,
        }),
      );
      final productIndex =
          _items.indexWhere((product) => productId == product.id);
      _items[productIndex] = productWithNewData;
      notifyListeners();
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  // Важная вещь по REST API - DELETE. Тут попроще, чем с POST или PATCH,
  // так как по сути мы отправляем запрос на удаление записи по её id.
  // Однако, если проблемы с коннектом, то в итоге запись на сервере не
  // удалится, а в приложении удалится, при этом ошибку не кинет.
  // Тут надо создать собственный EXCEPTION, причем это упирается засчёт
  // кода ответа - всё, что больше или равно 400 - плохо, а плохое должно
  // кидать ошибку, что мы тут и реализуем.
  Future<void> removeExistingProduct(String id) async {
    // final url = Uri.https(
    //     'flutter-shop-educ-default-rtdb.europe-west1.firebasedatabase.app',
    //     '/products/$id.json');
    final url = Uri.parse(
      'https://flutter-shop-educ-default-rtdb.europe-west1.firebasedatabase.app/products/$id.json?auth=$_authToken',
    );
    final existingProductIndex =
        _items.indexWhere((product) => product.id == id);
    Product? existingProduct = _items[existingProductIndex];

    // Далее идёт порядок действий
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException(
          'COULD NOT DELETE THE PRODUCT!! ERROR CODE ${response.statusCode}');
    }
    existingProduct = null;
  }
}

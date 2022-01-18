import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/cart_screen.dart';

import '../providers/products_provider.dart';
import '../providers/cart_provider.dart';

import '../widgets/main_drawer.dart';
import '../widgets/products_grid.dart';
import '../widgets/badge.dart';

enum FilterOptions {
  favorites,
  all,
}

class ProductsOverviewScreen extends StatefulWidget {
  const ProductsOverviewScreen({Key? key}) : super(key: key);
  static const routeName = '/products-overview';

  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _showOnlyFavorites = false;
  var _isLoading = false;

  @override
  void initState() {
    setState(() => _isLoading = true);
    Provider.of<ProductsProvider>(context, listen: false)
        .fetchAndSetProducts()
        .then((_) => setState(() => _isLoading = false));
    // код внизу выдаст ошибку в любом случае
    // Future.delayed(Duration.zero).then(
    //   (_) => Provider.of<ProductsProvider>(context).fetchAndSetProducts(),
    // );
    super.initState();
  }

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<ProductsProvider>(context, listen: false)
        .fetchAndSetProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Товарчики'),
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (_) => [
              const PopupMenuItem(
                child: Text('Только избранное'),
                value: FilterOptions.favorites,
              ),
              const PopupMenuItem(
                child: Text('Показывать всё'),
                value: FilterOptions.all,
              ),
            ],
            onSelected: (FilterOptions selectedValue) {
              setState(
                () {
                  if (selectedValue == FilterOptions.favorites) {
                    _showOnlyFavorites = true;
                  } else {
                    _showOnlyFavorites = false;
                  }
                },
              );
            },
          ),
          Consumer<CartProvider>(
            builder: (_, cartProvider, chld) => Badge(
              color: Colors.red,
              child: chld!,
              value: cartProvider.allItemsCount.toString(),
            ),
            child: IconButton(
              icon: const Icon(Icons.shopping_cart),
              alignment: Alignment.bottomCenter,
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          ),
        ],
      ),
      drawer: const MainDrawer(),
      body: RefreshIndicator(
        onRefresh: () => _refreshProducts(context),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ProductsGrid(
                showOnlyFavorites: _showOnlyFavorites,
              ),
      ),
    );
  }
}

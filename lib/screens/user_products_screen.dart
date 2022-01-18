import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products_provider.dart';

import './edit_product_screen.dart';

import '../widgets/user_product_item.dart';
import '../widgets/main_drawer.dart';

class UserProductsScreen extends StatelessWidget {
  const UserProductsScreen({Key? key}) : super(key: key);
  static const routeName = '/user-products';

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<ProductsProvider>(context, listen: false)
        .fetchAndSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    // final productsData = Provider.of<ProductsProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактируем магазин!'),
        actions: [
          IconButton(
            onPressed: () =>
                Navigator.of(context).pushNamed(EditProductScreen.routeName),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      drawer: const MainDrawer(),
      body: FutureBuilder(
          future: _refreshProducts(context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              if (snapshot.error != null) {
                return Center(
                    child: SizedBox(
                  width: double.infinity,
                  height: 400,
                  child: Column(
                    children: [
                      const Text(
                        'Упс:',
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        snapshot.error.toString(),
                      ),
                    ],
                  ),
                ));
              } else {
                return RefreshIndicator(
                  onRefresh: () => _refreshProducts(context),
                  child: Consumer<ProductsProvider>(
                    builder: (__, productsData, _) => Padding(
                      padding: const EdgeInsets.all(10),
                      child: ListView.builder(
                        itemCount: productsData.items.length,
                        itemBuilder: (_, i) => Column(
                          children: [
                            UserProductsItem(
                              productsData.items[i].id!,
                              productsData.items[i].title,
                              productsData.items[i].imageUrl,
                            ),
                            const Divider(),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }
            }
          }),
    );
  }
}

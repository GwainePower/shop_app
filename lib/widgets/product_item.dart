import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../providers/product.dart';
import '../providers/auth_provider.dart';

import '../screens/product_detail_screen.dart';

class ProductItem extends StatelessWidget {
  const ProductItem({
    Key? key,
    // required this.id,
    // required this.title,
    // required this.imageUrl,
  }) : super(key: key);

  // final String id;
  // final String title;
  // final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final product = Provider.of<Product>(context);
    final cartItem = Provider.of<CartProvider>(context, listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: GridTile(
        header: GridTileBar(
          leading: IconButton(
            icon: const Icon(
              Icons.add_shopping_cart,
              color: Colors.green,
            ),
            onPressed: () {
              cartItem.addItem(product.id!, product.title, product.price);
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('${product.title} добавлен в список покупочек!!!'),
                  duration: const Duration(seconds: 1, milliseconds: 500),
                  action: SnackBarAction(
                    label: 'ОТМЕНА',
                    onPressed: () => cartItem.removeSingleItem(product.id!),
                  ),
                ),
              );
            },
          ),
          title: const Text(''),
          trailing: Consumer<AuthProvider>(
            builder: (_, authProvider, __) => IconButton(
              icon: Icon(
                Icons.favorite,
                color: product.isFavorite ? Colors.red : Colors.grey,
              ),
              onPressed: () async {
                try {
                  await product.toggleFavorite(
                      authProvider.token!, authProvider.userId!);
                } catch (error) {
                  scaffoldMessenger.hideCurrentSnackBar();
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      duration: Duration(seconds: 1, milliseconds: 500),
                      content: Text(
                        'Добавить в избранное не получилось...',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ),
        footer: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(ProductDetailScreen.routeName,
                arguments: product.id);
          },
          child: GridTileBar(
            backgroundColor: Colors.black38,
            title: Text(
              product.title,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(ProductDetailScreen.routeName,
                arguments: product.id);
          },
          child: Hero(
            tag: product.id!,
            child: FadeInImage(
              placeholder: const AssetImage(
                  'assets/images/product-image-placeholder.png'),
              image: NetworkImage(product.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}

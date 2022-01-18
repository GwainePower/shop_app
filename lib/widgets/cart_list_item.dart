import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';

class CartItem extends StatelessWidget {
  const CartItem(
    this.id,
    this.productId,
    this.title,
    this.price,
    this.quantity, {
    Key? key,
  }) : super(key: key);

  final String id;
  final String productId;
  final String title;
  final double price;
  final int quantity;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) {
        return showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Серьезно?'),
            content: Text('Точно хотите удалить $title из списка покупочек?!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                // onPressed: () {
                //   Navigator.of(ctx).pop();
                //   showDialog(
                //     context: ctx,
                //     builder: (ctx) => AlertDialog(
                //       title: const Text('НУ ТЫ ЧЁ'),
                //       content: Text(
                //           'УВЕРЕНЫ??! $title ОЧЕНЬ ВАЖНАЯ ВЕЩЬ В ВАШЕЙ ЖИЗНИ И ДРУГОГО ШАНСА МОЖЕТ НЕ ВЫПАСТЬ!! ВСЁ ТАКИ УДАЛИТЬ??!'),
                //       actions: [
                //         TextButton(
                //           onPressed: () {
                //             Provider.of<CartProvider>(context, listen: false)
                //                 .removeItem(productId);
                //             Navigator.of(context).pop();
                //           },
                //           child: const Text('ДА'),
                //         ),
                //         TextButton(
                //           onPressed: () => Navigator.of(ctx).pop(false),
                //           child: const Text('ладно, не..'),
                //         ),
                //       ],
                //     ),
                //   );
                // },
                child: const Text('ДА!!!'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('не..'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        Provider.of<CartProvider>(context, listen: false).removeItem(productId);
      },
      background: Container(
        color: Theme.of(context).errorColor,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 40,
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(
          vertical: 4,
          horizontal: 15,
        ),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(
          vertical: 4,
          horizontal: 15,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ListTile(
            leading: Chip(
              backgroundColor: Theme.of(context).primaryColor,
              label: Text('₽${price.toStringAsFixed(0)}'),
            ),
            title: Text(title),
            subtitle:
                Text('Стоимость: ₽${(price * quantity).toStringAsFixed(0)}'),
            trailing: Text('${quantity}x'),
          ),
        ),
      ),
    );
  }
}

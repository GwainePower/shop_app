import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart' show CartProvider;
import '../providers/orders_provider.dart';

import '../widgets/cart_list_item.dart';
import '../widgets/error_message.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);
  static const routeName = '/shop-cart';

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ваши покупочки'),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(15),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ВСЕГО:',
                    style: TextStyle(fontSize: 20),
                  ),
                  const Spacer(),
                  Chip(
                    label: Text(
                      '₽${cart.totalPrice.toStringAsFixed(0)}',
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  OrderButton(
                    cart: cart,
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (ctx, i) => CartItem(
                cart.items.values.toList()[i].id,
                cart.items.keys.toList()[i],
                cart.items.values.toList()[i].title,
                cart.items.values.toList()[i].price,
                cart.items.values.toList()[i].quantity,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({Key? key, required this.cart}) : super(key: key);

  final CartProvider cart;

  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    return TextButton(
      onPressed: (widget.cart.allItemsCount == 0 || _isLoading)
          ? null
          : () async {
              setState(() => _isLoading = true);
              try {
                await Provider.of<OrdersProvider>(context, listen: false)
                    .addOrder(
                  widget.cart.items.values.toList(),
                  widget.cart.totalPrice,
                );
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Заказ оформлен!',
                      textAlign: TextAlign.center,
                    ),
                    duration: Duration(seconds: 1, milliseconds: 500),
                  ),
                );
              } catch (error) {
                await showDialog(
                  context: context,
                  builder: (ctx) => ErrorMessage(error: error),
                );
              }
              widget.cart.clear();
              setState(() => _isLoading = false);
            },
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Text(
              'Оформить заказик',
              style: TextStyle(color: Theme.of(context).primaryColorLight),
            ),
    );
  }
}

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../providers/orders_provider.dart' as ordobj;

class OrderItem extends StatefulWidget {
  const OrderItem(this.order, {Key? key}) : super(key: key);

  final ordobj.OrderItem order;

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: Column(
        children: [
          ListTile(
            title: Text('₽${widget.order.totalPrice.toStringAsFixed(0)}'),
            subtitle: Text(
                DateFormat.yMMMMd('ru').add_Hm().format(widget.order.date)),
            trailing: IconButton(
              icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  _expanded = !_expanded;
                });
              },
            ),
          ),
          // if (_expanded)
          AnimatedContainer(
            // constraints: BoxConstraints(
            //   minHeight: _expanded
            //       ? min(widget.order.cartItems.length * 25.0 + 10, 180)
            //       : 0,
            //   maxHeight: _expanded
            //       ? min(widget.order.cartItems.length * 25.0 + 10, 180)
            //       : 0,
            // ),
            curve: Curves.easeIn,
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            height: _expanded
                ? min(widget.order.cartItems.length * 25.0 + 10, 180)
                : 0,
            child: ListView(
              children: widget.order.cartItems
                  .map((item) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${item.quantity}x ₽${item.price}',
                            style: const TextStyle(
                                fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

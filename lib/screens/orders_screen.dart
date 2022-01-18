import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders_provider.dart' show OrdersProvider;

import '../widgets/order_item.dart';
import '../widgets/main_drawer.dart';
import '../widgets/error_message.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);
  static const routeName = '/shop-orders';

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  Future? _storedOrdersFuture;

  // Метод снизу и переменная сверху нужны для того, чтобы в
  // Future билдере не было постоянного ПЕРЕЗАПРОСА при перепостроении
  // виджета. Поэтому запихиваем запрос в переменную и вызываем только её
  Future _obtainOrdersFuture() {
    return Provider.of<OrdersProvider>(context, listen: false)
        .fetchAndSetOrders();
  }

  @override
  void initState() {
    _storedOrdersFuture = _obtainOrdersFuture();
    // setState(() => _isLoading = true);
    // Provider.of<OrdersProvider>(context, listen: false)
    //     .fetchAndSetOrders()
    //     .then((_) => setState(() => _isLoading = false));
    super.initState();
  }

  Future<void> _refreshOrders(BuildContext context) async {
    try {
      await Provider.of<OrdersProvider>(context, listen: false)
          .fetchAndSetOrders();
    } catch (error) {
      await showDialog(
        context: context,
        builder: (ctx) => ErrorMessage(error: error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // final orderData = Provider.of<OrdersProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Заказики'),
      ),
      drawer: const MainDrawer(),
      body: RefreshIndicator(
        onRefresh: () => _refreshOrders(context),
        child: FutureBuilder(
          future: _storedOrdersFuture,
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
                return Consumer<OrdersProvider>(
                  builder: (context, orderData, child) => ListView.builder(
                    itemCount: orderData.orders.length,
                    itemBuilder: (ctx, i) => OrderItem(orderData.orders[i]),
                  ),
                );
              }
            }
          },
        ),
      ),
    );
  }
}

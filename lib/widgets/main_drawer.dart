import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/helpers/custom_route.dart';

import '../providers/auth_provider.dart';

import '../screens/orders_screen.dart';
import '../screens/user_products_screen.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({Key? key}) : super(key: key);

  Widget buildListTile(IconData icon, String title, VoidCallback tapHandler) {
    return ListTile(
      leading: Icon(
        icon,
        size: 26,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Omniglot',
          fontSize: 24,
        ),
      ),
      onTap: tapHandler,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    return Drawer(
      child: Column(
        children: [
          Container(
            height: mediaQuery.size.height * 0.15,
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            alignment: Alignment.centerLeft,
            color: appTheme.primaryColor,
            child: Text(
              'Меню',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
                color: appTheme.textTheme.headline6!.color,
              ),
            ),
          ),
          SizedBox(
            height: mediaQuery.size.height * 0.1,
          ),
          const Divider(),
          buildListTile(
            Icons.shopping_cart,
            'Товарчики',
            () {
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
          const Divider(),
          buildListTile(
            Icons.payment,
            'Заказики',
            () {
              Navigator.of(context)
                  .pushReplacementNamed(OrdersScreen.routeName);
              // Navigator.of(context).pushReplacement(
              //   CustomRoute(
              //     builder: (ctx) => const OrdersScreen(),
              //   ),
              // );
            },
          ),
          const Divider(),
          buildListTile(
            Icons.edit,
            'Редактор продуктиков',
            () {
              Navigator.of(context)
                  .pushReplacementNamed(UserProductsScreen.routeName);
            },
          ),
          const Divider(),
          buildListTile(Icons.logout, 'Выйти', () {
            Navigator.of(context).pop();
            Navigator.of(context).pushReplacementNamed('/');
            Provider.of<AuthProvider>(context, listen: false).logout();
          }),
        ],
      ),
    );
  }
}

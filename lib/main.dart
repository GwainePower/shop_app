import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import './screens/product_detail_screen.dart';
import './screens/products_overview_screen.dart';
import './screens/cart_screen.dart';
import './screens/orders_screen.dart';
import './screens/user_products_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/auth_screen.dart';
import './screens/splash_screen.dart';

import './providers/auth_provider.dart';
import './providers/products_provider.dart';
import './providers/cart_provider.dart';
import './providers/orders_provider.dart';

import './helpers/custom_route.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);
  final darkTheme = ThemeData.dark();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // AuthProvider должен быть в топе так как токен передается от него
        // всем, кто ниже и *нуждается* в нём, т.е. Products и Orders
        ChangeNotifierProvider(
          create: (ctx) => AuthProvider(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ProductsProvider>(
          create: (_) => ProductsProvider(null, null, []),
          update: (_, authProvider, previousProductsProvider) =>
              ProductsProvider(
                  authProvider.token,
                  authProvider.userId,
                  previousProductsProvider == null
                      ? []
                      : previousProductsProvider.items),
        ),
        ChangeNotifierProvider(
          create: (_) => CartProvider(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, OrdersProvider>(
          create: (_) => OrdersProvider(null, null, []),
          update: (_, authProvider, previousOrdersProvider) => OrdersProvider(
              authProvider.token,
              authProvider.userId,
              previousOrdersProvider == null
                  ? []
                  : previousOrdersProvider.orders),
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authData, _) => MaterialApp(
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''),
            Locale('ru', ''),
          ],
          debugShowCheckedModeBanner: false,
          title: 'Магазин :)',
          theme: ThemeData(
            colorScheme: darkTheme.copyWith().colorScheme,
            fontFamily: 'Tellural',
            pageTransitionsTheme: PageTransitionsTheme(builders: {
              TargetPlatform.android: CustomPageTransitionBuilder(),
              TargetPlatform.iOS: CustomPageTransitionBuilder(),
            }),
          ),
          home: authData.isAuthenticated
              ? const ProductsOverviewScreen()
              : FutureBuilder(
                  future: authData.tryAutoSignIn(),
                  builder: (context, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? const SplashScreen()
                          : const AuthScreen(),
                ),
          initialRoute: '/',
          routes: {
            ProductsOverviewScreen.routeName: (ctx) =>
                const ProductsOverviewScreen(),
            ProductDetailScreen.routeName: (ctx) => const ProductDetailScreen(),
            CartScreen.routeName: (ctx) => const CartScreen(),
            OrdersScreen.routeName: (ctx) => const OrdersScreen(),
            UserProductsScreen.routeName: (ctx) => const UserProductsScreen(),
            EditProductScreen.routeName: (ctx) => const EditProductScreen(),
          },
        ),
      ),
    );
  }
}

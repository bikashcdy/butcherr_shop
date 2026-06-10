// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants.dart';
import 'services/cart_provider.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const ChickenShopApp());
}

class ChickenShopApp extends StatelessWidget {
  const ChickenShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CartProvider(),
      child: MaterialApp(
        title: kShopName,
        debugShowCheckedModeBanner: false,
        theme: appTheme(),
        home: const SplashScreen(),
      ),
    );
  }
}
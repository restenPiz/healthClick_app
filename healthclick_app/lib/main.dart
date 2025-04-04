import 'package:flutter/material.dart';
import 'package:healthclick_app/screens/auth/Login.dart';
import 'package:healthclick_app/screens/product/Product.dart';
import 'package:healthclick_app/screens/welcome/HomePage.dart';
import 'package:healthclick_app/screens/welcome/OnBoarding.dart';
import 'package:healthclick_app/screens/layouts/AppBottom.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SaudeClick',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: HomePage(),
      // home: AppBottomNav(),
    );
  }
}

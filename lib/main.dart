import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

// ignore: camel_case_types
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tranfer Central',
      theme: ThemeData(
          // Your app theme configuration
          ),
      home: const SplashScreen(), // Set SplashScreen as the initial screen
    );
  }
}

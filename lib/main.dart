import 'package:flutter/material.dart';
import 'package:transfercentral/screens/favorite_teams_dialog.dart';
import 'package:transfercentral/screens/home_screen.dart';
import 'constants.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Transfer Central',
      theme: ThemeData(
        primarySwatch: AppColors.primaryColor,
      ),
      initialRoute: SplashScreen.routeName,
      routes:{
        '/splash': (context) => const SplashScreen(),
        '/home': (context) => HomeScreen(),
        '/favoriteTeams': (context) => const FavoriteTeamsDialog(teams: [],),
      },// Set SplashScreen as the initial screen
    );
  }
}

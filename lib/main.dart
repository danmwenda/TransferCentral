// ignore_for_file: avoid_print, duplicate_ignore

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:transfercentral/constants.dart';
import 'package:transfercentral/screens/favorite_teams_dialog.dart';
import 'package:transfercentral/screens/home_screen.dart';
import 'package:transfercentral/screens/team_news_screen.dart';
import 'package:transfercentral/screens/splash_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  MobileAds.instance.initialize();
  runApp(const MyApp());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.notification?.title}');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    messaging.requestPermission();
    messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // ignore: avoid_print
      print('Received message: ${message.notification?.title}');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Opened app from notification: ${message.notification?.title}');
    });

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Transfer Central',
      theme: ThemeData(
        primarySwatch: AppColors.primaryColor,
        fontFamily: 'Roboto',
      ),
      initialRoute: SplashScreen.routeName,
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
        '/favoriteTeams': (context) => const FavoriteTeamsDialog(teams: []),
      },
      onGenerateRoute: (settings) {
        if (settings.name == TeamNewsScreen.routeName) {
          final teamName = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => TeamNewsScreen(teamName: teamName),
          );
        }
        return null;
      },
    );
  }
}

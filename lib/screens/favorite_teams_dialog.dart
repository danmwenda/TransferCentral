import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class FavoriteTeamsDialog extends StatefulWidget {
  static const String routeName = '/favoriteTeams';
  final List<String> teams;

  const FavoriteTeamsDialog({Key? key, required this.teams}) : super(key: key);

  @override
  _FavoriteTeamsDialogState createState() => _FavoriteTeamsDialogState();
}

class _FavoriteTeamsDialogState extends State<FavoriteTeamsDialog> {
  List<String> selectedTeams = [];
  bool _isLoading = false;
  late FirebaseMessaging _firebaseMessaging;

  @override
  void initState() {
    super.initState();
    loadSelectedTeams();
    _firebaseMessaging = FirebaseMessaging.instance;
    _firebaseMessaging.requestPermission();
  }

  Future<void> loadSelectedTeams() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteTeams = prefs.getStringList('favoriteTeams');
    setState(() {
      selectedTeams = favoriteTeams ?? [];
    });
  }

  Future<void> saveSelectedTeams() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favoriteTeams', selectedTeams);
  }

  Future<void> subscribeToTeams() async {
    final deviceToken = await _firebaseMessaging
        .getToken(); // Replace with actual FCM token obtained in your app.
    const url =
        'https://us-central1-transfer-central.cloudfunctions.net/api/subscribe-to-teams'; // Replace with your Cloud Function URL

    try {
      setState(() {
        _isLoading = true;
      });

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'token': deviceToken,
          'favoriteTeams': selectedTeams,
        }),
      );

      if (response.statusCode == 200) {
        // Subscription success
        print('Subscribed to teams: $selectedTeams');
      } else {
        // Subscription failed
        print('Failed to subscribe to teams');
      }
    } catch (error) {
      // Handle errors
      print('Error subscribing to teams: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> unsubscribeFromTeams() async {
    final deviceToken = await _firebaseMessaging
        .getToken(); // Replace with actual FCM token obtained in your app.
    const url =
        'https://us-central1-transfer-central.cloudfunctions.net/api/unsubscribe-from-teams'; // Replace with your Cloud Function URL

    try {
      setState(() {
        _isLoading = true;
      });

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'token': deviceToken,
          'favoriteTeams': selectedTeams,
        }),
      );

      if (response.statusCode == 200) {
        // Unsubscription success
        print('Unsubscribed from teams: $selectedTeams');
      } else {
        // Unsubscription failed
        print('Failed to unsubscribe from teams');
      }
    } catch (error) {
      // Handle errors
      print('Error unsubscribing from teams: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Favorite Teams'),
      content: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (String team in widget.teams)
                  CheckboxListTile(
                    title: Text(
                      team,
                      style: const TextStyle(
                          fontSize: 14), // Adjust the font size as needed
                      overflow: TextOverflow
                          .ellipsis, // Truncate the text if it exceeds the available space
                    ),
                    value: selectedTeams.contains(team),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value != null) {
                          if (value) {
                            selectedTeams.add(team);
                          } else {
                            selectedTeams.remove(team);
                          }
                        }
                      });
                    },
                  ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: LoadingAnimationWidget.fourRotatingDots(
                    color: const Color(0xFF158744), size: 50),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            await saveSelectedTeams();
            await unsubscribeFromTeams();
            await subscribeToTeams();

            Navigator.pop(context, selectedTeams);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

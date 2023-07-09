import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteTeamsDialog extends StatefulWidget {
  static const String routeName = '/favoriteTeams';
  final List<String> teams;

  const FavoriteTeamsDialog({Key? key, required this.teams}) : super(key: key);

  @override
  _FavoriteTeamsDialogState createState() => _FavoriteTeamsDialogState();
}

class _FavoriteTeamsDialogState extends State<FavoriteTeamsDialog> {
  List<String> selectedTeams = [];

  @override
  void initState() {
    super.initState();
    loadSelectedTeams();
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Favorite Teams'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (String team in widget.teams)
            RadioListTile<String>(
              title: Text(team),
              value: team,
              groupValue: selectedTeams.isNotEmpty ? selectedTeams[0] : null,
              onChanged: (String? value) {
                if (value != null) {
                  setState(() {
                    selectedTeams = [value];
                  });
                }
              },
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
          onPressed: () {
            saveSelectedTeams();
            Navigator.pop(context, selectedTeams);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

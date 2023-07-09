import 'package:flutter/material.dart';

import 'favorite_teams_dialog.dart';

class HomeScreen extends StatelessWidget {
  static const String routeName = '/home';
  final List<String> teams = [
    'Manchester United',
    'Manchester City',
    'Liverpool',
    'Chelsea',
    'Arsenal',
    'Tottenham Hotspur',
    'Barcelona',
    'Real Madrid',
    'Juventus',
    'Ac Milan',
    'Inter Milan',
    'Bayern Munich',
    'Paris Saint Germain(PSG)',
  ];

  final Map<String, String> teamLogos = {
    'Manchester United': 'assets/images/manutd.png',
    'Manchester City': 'assets/images/mancity.png',
    'Liverpool': 'assets/images/liverpool.png',
    'Chelsea': 'assets/images/chelsea.png',
    'Arsenal': 'assets/images/arsenal.png',
    'Tottenham Hotspur': 'assets/images/tottenham.png',
    'Barcelona': 'assets/images/barca.png',
    'Real Madrid': 'assets/images/real.png',
    'Juventus': 'assets/images/juve.png',
    'Ac Milan': 'assets/images/acmilan.png',
    'Inter Milan': 'assets/images/intermilan.png',
    'Bayern Munich': 'assets/images/bayern.png',
    'Paris Saint Germain(PSG)': 'assets/images/psg.png',
  };

  HomeScreen({Key? key}) : super(key: key);

  void showFavoriteTeamsDialog(BuildContext context) async {
    final selectedTeams = await showDialog<List<String>>(
      context: context,
      builder: (context) {
        return FavoriteTeamsDialog(teams: teams);
      },
    );

    // Do something with the selected teams
    if (selectedTeams != null) {
      // Handle the selected teams
      print('Selected teams: $selectedTeams');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teams'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: teams.length,
        itemBuilder: (context, index) {
          final teamName = teams[index];
          final logoPath = teamLogos[teamName]!;
          return GestureDetector(
              onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TeamNewsScreen(teamName: teamName),
              ),
            );
          },
          child: Container(
          decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey),
          ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  logoPath,
                  width: 100,
                  height: 100,
                ),
                const SizedBox(height: 10),
                Text(
                  teamName,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          )
          );
        },
      ),
    );
  }
}
class TeamNewsScreen extends StatelessWidget {
  final String teamName;

  const TeamNewsScreen({Key? key, required this.teamName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(teamName),
      ),
      body: Center(
        child: Text(
          'News for $teamName',
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

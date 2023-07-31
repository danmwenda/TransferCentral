import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transfercentral/screens/admob.dart';
import 'package:transfercentral/screens/team_news_screen.dart';
import 'favorite_teams_dialog.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';

  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> teams = [
    'Manchester United F.C.',
    'Manchester City F.C.',
    'Liverpool F.C.',
    'Chelsea F.C.',
    'Arsenal F.C.',
    'Tottenham Hotspur F.C.',
    'FC Barcelona',
    'Real Madrid CF',
    'Juventus F.C.',
    'A.C. Milan',
    'Inter Milan',
    'FC Bayern Munich',
    'Borussia Dortmund',
    'Paris Saint-Germain F.C.',
  ];

  final Map<String, String> teamLogos = {
    'Manchester United F.C.': 'assets/images/manutd.png',
    'Manchester City F.C.': 'assets/images/mancity.png',
    'Liverpool F.C.': 'assets/images/liverpool.png',
    'Chelsea F.C.': 'assets/images/chelsea.png',
    'Arsenal F.C.': 'assets/images/arsenal.png',
    'Tottenham Hotspur F.C.': 'assets/images/tottenham.png',
    'FC Barcelona': 'assets/images/barca.png',
    'Real Madrid CF': 'assets/images/real.png',
    'Juventus F.C.': 'assets/images/juve.png',
    'A.C. Milan': 'assets/images/acmilan.png',
    'Inter Milan': 'assets/images/intermilan.png',
    'FC Bayern Munich': 'assets/images/bayern.png',
    'Borussia Dortmund': 'assets/images/borussia.png',
    'Paris Saint-Germain F.C.': 'assets/images/psg.png',
  };

  late bool _hasInternet;
  bool _favoriteTeamsShown = false;
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    _checkInternetConnection();
    _showFavoriteTeamsDialogIfNeeded();

    // Listen for changes in internet connectivity status
    Connectivity().onConnectivityChanged.listen((result) {
      setState(() {
        _hasInternet = result != ConnectivityResult.none;
      });
      if (_hasInternet) {
        _refreshScreen();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _interstitialAd?.dispose();
  }

  Future<void> _checkInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _hasInternet = connectivityResult != ConnectivityResult.none;
    });
    if (!_hasInternet) {
      // Show the red alert at the bottom of the screen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red, // Red background color for the alert
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.white,
              ),
              SizedBox(width: 8),
              Text(
                'No Internet Connection',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          duration: Duration(
              seconds: 3), // Duration for how long the alert should be shown
        ),
      );
    } else {
      // If the internet connection is restored, hide any visible SnackBar
      _refreshScreen();
    }
  }

  Future<void> _showFavoriteTeamsDialogIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteTeamsShown = prefs.getBool('favoriteTeamsShown') ?? false;
    if (!favoriteTeamsShown) {
      // ignore: use_build_context_synchronously
      await _showFavoriteTeamsDialog(context);
      await prefs.setBool('favoriteTeamsShown', true);
      setState(() {
        _favoriteTeamsShown = true;
      });
    } else {
      setState(() {
        _favoriteTeamsShown = true;
      });
    }
  }

  Future<void> _showFavoriteTeamsDialog(BuildContext context) async {
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

  void _navigateToTeamNewsScreen(BuildContext context, String teamName) {
    if (_hasInternet) {
      Navigator.pushNamed(
        context,
        TeamNewsScreen.routeName,
        arguments: teamName,
      );
    }
  }

  void _refreshScreen() {
    setState(() {
      _showFavoriteTeamsDialogIfNeeded();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_favoriteTeamsShown) {
      // Show loading indicator or splash screen
      return Scaffold(
        body: Center(
          child: LoadingAnimationWidget.fourRotatingDots(
              color: const Color(0xFF158744), size: 50),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teams'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () async {
              await _showFavoriteTeamsDialog(context);
            },
          ),
        ],
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
          return InkWell(
            onTap: () {
              _navigateToTeamNewsScreen(context, teamName);
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
            ),
          );
        },
      ),
      bottomNavigationBar: const AdBanner(),
    );
  }
}

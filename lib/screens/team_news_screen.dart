import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'dart:convert';

import 'admob.dart';
import 'article_screen.dart';
import 'models/news_articles_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class TeamNewsScreen extends StatefulWidget {
  static const String routeName = '/teamNews';
  final String teamName;

  const TeamNewsScreen({Key? key, required this.teamName}) : super(key: key);

  @override
  _TeamNewsScreenState createState() => _TeamNewsScreenState();
}

class _TeamNewsScreenState extends State<TeamNewsScreen> {
  late Future<List<NewsArticle>> _newsFuture;
  late bool _hasInternet;
  InterstitialAd? _interstitialAd;
  bool _adShown = false;
  var adUnitId = 'ca-app-pub-2888500068840166/2469943874';

  @override
  void initState() {
    super.initState();
    _createInterstitialAd();
    _newsFuture = fetchTeamNews(widget.teamName);

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

  Future<List<NewsArticle>> fetchTeamNews(String teamName) async {
    final apiUrl =
        'https://us-central1-transfer-central.cloudfunctions.net/api/team-news/$teamName';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<NewsArticle> newsArticles = data.map((item) {
          // Check if the url starts with the correct base URL, if not, append it
          String url = item['url'];
          if (!url.startsWith('https://news.google.com')) {
            url = 'https://news.google.com$url';
          }

          return NewsArticle(
            title: item['title'] ?? '',
            source: item['source'] ?? '',
            url: url,
            urlToImage: item['urlToImage'] ?? '',
            publishedAt: DateTime.parse(item['publishedAt'] ?? ''),
          );
        }).toList();
        newsArticles.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
        return newsArticles;
      } else {
        throw Exception('Failed to fetch team news');
      }
    } catch (error) {
      print('Error fetching team news: $error');
      throw Exception('Failed to fetch team news');
    }
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

  void _refreshScreen() {
    setState(() {
      _newsFuture = fetchTeamNews(widget.teamName);
    });
  }

  Future<void> _refreshData() async {
    setState(() {
      if (!_adShown) {
        _showInterstitialAd();
      }
      _newsFuture = fetchTeamNews(widget.teamName);
    });
  }

  /// Loads an interstitial ad.
  void _createInterstitialAd() {
    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('$ad loaded.');
          _interstitialAd = ad;
          // Show the ad as soon as it is loaded.
          if (!_adShown) {
            _showInterstitialAd();
          }
        },
        onAdFailedToLoad: (error) {
          if (kDebugMode) {
            print('Ad failed to load: $error');
          }
        },
      ),
    );
  }

  void _showInterstitialAd() async {
    if (_interstitialAd == null) {
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        if (_adShown) {
          Navigator.of(context).pop();
        } else {
          setState(() {
            _adShown = true;
          });
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        if (kDebugMode) {
          print('$ad onAdFailedToShowFullScreenContent: $error');
        }
      },
    );

    _interstitialAd!.show();
    _interstitialAd = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.teamName} News'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: FutureBuilder<List<NewsArticle>>(
          future: _newsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: LoadingAnimationWidget.fourRotatingDots(
                  color: const Color(0xFF158744),
                  size: 50,
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else if (snapshot.hasData) {
              final newsArticles = snapshot.data!;
              return ListView.builder(
                itemCount: newsArticles.length,
                itemBuilder: (context, index) {
                  final article = newsArticles[index];
                  final formattedDate = timeago.format(article.publishedAt);
                  return GestureDetector(
                    onTap: () {
                      _showInterstitialAd();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ArticleScreen(article: article),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 2, // Add a subtle shadow to the card
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          5,
                        ), // Rounded corners for the card
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 70.0,
                            width: 80.0,
                            decoration: BoxDecoration(
                              //let's add the height
                              image: DecorationImage(
                                image: NetworkImage(article.urlToImage),
                                fit: BoxFit.fill,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  child: Image.network(
                                    article.source,
                                    fit: BoxFit.fill,
                                    height: 20.0,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  article.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                  ),
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  formattedDate,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 12.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else {
              return const Center(
                child: Text('No news available'),
              );
            }
          },
        ),
      ),
      bottomNavigationBar: const AdBanner(),
    );
  }
}

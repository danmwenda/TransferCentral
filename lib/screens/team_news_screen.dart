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

  @override
  void initState() {
    super.initState();
    _newsFuture = fetchTeamNews(widget.teamName);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.teamName} News'),
      ),
      body: FutureBuilder<List<NewsArticle>>(
        future: _newsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: LoadingAnimationWidget.fourRotatingDots(
                  color: const Color(0xFF158744), size: 50),
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
                    // Add the onTap property here
                    onTap: () {
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
                            5), // Rounded corners for the card
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 200.0,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              //let's add the height

                              image: DecorationImage(
                                  image: NetworkImage(article.urlToImage),
                                  fit: BoxFit.cover),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          const SizedBox(
                            height: 8.0,
                          ),
                          Container(
                            padding: const EdgeInsets.all(6.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFF158744),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: Text(
                              formattedDate,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 8.0,
                          ),
                          Text(
                            article.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          )
                        ],
                      ),
                    ));
              },
            );
          } else {
            return const Center(
              child: Text('No news available'),
            );
          }
        },
      ),
      bottomNavigationBar: const AdBanner(),
    );
  }
}

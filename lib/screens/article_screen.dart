import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'admob.dart';
import 'models/news_articles_model.dart';

class ArticleScreen extends StatefulWidget {
  final NewsArticle article;

  const ArticleScreen({Key? key, required this.article}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ArticleScreenState createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  late final WebViewController _controller;
  final ValueNotifier<bool> _isLoading = ValueNotifier(true);
  final ValueNotifier<bool> _isError = ValueNotifier(false);
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    _createInterstitialAd();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            _isLoading.value = progress < 100;
          },
          onPageStarted: (String url) {
            _isLoading.value = true;
            _isError.value = false;
          },
          onPageFinished: (String url) {
            _isLoading.value = false;
            _isError.value = false;
            _controller.clearCache();
          },
          onWebResourceError: (WebResourceError error) {
            _isLoading.value = false;
            _isError.value = true;
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.article.url));
  }

  @override
  void dispose() {
    super.dispose();
    _interstitialAd?.dispose();
  }

  /// Loads an interstitial ad.
  final adUnitId = 'ca-app-pub-2888500068840166/2469943874';
  void _createInterstitialAd() {
    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          print(error.message);
        },
      ),
    );
  }

  void _showInterstitialAd() {
    if (_interstitialAd == null) {
      _createInterstitialAd();
    }

    _interstitialAd?.show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Article'),
        leading:
            _isLoading.value // Show the back button if the page is not loading
                ? IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      _showInterstitialAd();
                      _controller.clearCache();
                      Navigator.pop(context);
                    },
                  )
                : Container(),
        bottom: _isLoading
                .value // Show the LinearProgressIndicator at the bottom of the AppBar
            ? const PreferredSize(
                preferredSize: Size.fromHeight(4),
                child: LinearProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF158744)),
                ),
              )
            : null,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isError.value)
            const Center(
              child: Text(
                'Failed to load the article',
                style: TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
      bottomNavigationBar: const AdBanner(),
    );
  }
}

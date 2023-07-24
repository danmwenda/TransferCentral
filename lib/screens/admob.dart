import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdBanner extends StatefulWidget {
  const AdBanner({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AdBannerState createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  final AdSize adSize = const AdSize(height: 60, width: 380);

  // TODO: replace this test ad unit with your own ad unit.
  final adUnitId = 'ca-app-pub-2888500068840166/2584589987';

  @override
  void initState() {
    super.initState();
    loadAd();
  }

  /// Loads a banner ad.
  void loadAd() {
    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      size: adSize,
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          debugPrint('$ad loaded.');
          setState(() {
            _isLoaded = true;
          });
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAd failed to load: $error');
          // Dispose the ad here to free resources.
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    super.dispose();
    // Dispose the ad when the widget is removed from the widget tree
    _bannerAd?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: _isLoaded ? 60 : 0,
        color: Colors.grey, // Adjust the height as needed
        child: _isLoaded
            ? AdWidget(ad: _bannerAd!)
            : Container(
                height: 100,
                color: Colors.grey,
                child: const Center(
                  child: Text('Ads Container'),
                ),
              ) // Display an empty container if the ad is not loaded yet
        );
  }
}

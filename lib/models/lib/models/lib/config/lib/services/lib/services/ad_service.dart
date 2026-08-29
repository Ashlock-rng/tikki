import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../models/user_model.dart';

class AdService {
  static const int videosBetweenAds = 5;
  static const int adDurationSeconds = 6;

  InterstitialAd? _interstitialAd;
  int _videoViewCount = 0;
  bool _isAdReady = false;

  void onVideoViewed(UserModel? currentUser) {
    if (currentUser == null || currentUser.isAdFree) return;

    _videoViewCount++;
    if (_videoViewCount >= videosBetweenAds) {
      _videoViewCount = 0;
      _showInterstitialAd();
    }
  }

  Future<void> loadInterstitialAd() async {
    await InterstitialAd.load(
      adUnitId: _getAdUnitId(),
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isAdReady = true;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _isAdReady = false;
              loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _isAdReady = false;
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isAdReady = false;
        },
      ),
    );
  }

  void _showInterstitialAd() {
    if (_isAdReady && _interstitialAd != null) {
      _interstitialAd!.show();
    } else {
      loadInterstitialAd();
    }
  }

  String _getAdUnitId() {
    // Replace with your real AdMob Interstitial ID later
    return 'ca-app-pub-3940256099942544/1033173712';
  }

  void dispose() {
    _interstitialAd?.dispose();
  }
}

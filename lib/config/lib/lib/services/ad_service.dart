import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../models/user_model.dart';

class AdService {
  InterstitialAd? _interstitialAd;
  bool _isAdReady = false;

  // ========== FINAL FORMULA ==========
  /// Returns maximum number of ads allowed for a video
  static int maxAdsAllowed(int videoDurationSeconds) {
    if (videoDurationSeconds < 30) {
      // 15s or under 30s → maximum 2 ads
      return 2;
    }

    // 1 ad every 3 minutes (rounded up)
    final minutes = videoDurationSeconds / 60.0;
    return (minutes / 3).ceil();
  }

  /// Can this video show ads?
  static bool canShowAds(int videoDurationSeconds) {
    return videoDurationSeconds >= 15;
  }

  // ========== AD LOADING ==========
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
              loadInterstitialAd(); // preload next
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

  // ========== SHOW AD ==========
  /// Call this when you want to show an ad
  /// Pass how many ads have already been shown on this video
  bool tryShowAd({
    required UserModel? currentUser,
    required int videoDurationSeconds,
    required int adsAlreadyShown,
  }) {
    // Ad-free users never see ads
    if (currentUser == null || currentUser.isAdFree) return false;

    // Too short
    if (!canShowAds(videoDurationSeconds)) return false;

    // Already reached max ads for this video
    final maxAds = maxAdsAllowed(videoDurationSeconds);
    if (adsAlreadyShown >= maxAds) return false;

    // Show the ad
    if (_isAdReady && _interstitialAd != null) {
      _interstitialAd!.show();
      return true;
    } else {
      loadInterstitialAd();
      return false;
    }
  }

  String _getAdUnitId() {
    // Replace with your real AdMob Interstitial ID later
    return 'ca-app-pub-3940256099942544/1033173712'; // Test ID
  }

  void dispose() {
    _interstitialAd?.dispose();
  }
}

class ViewService {
  /// Only real human valid watches count for earnings
  static bool isValidView({
    required int videoDurationSeconds,
    required int watchedSeconds,
  }) {
    if (videoDurationSeconds <= 0 || watchedSeconds <= 0) return false;

    if (videoDurationSeconds < 30) {
      // 15s or under 30s → must watch the full video
      return watchedSeconds >= videoDurationSeconds;
    }
    if (videoDurationSeconds <= 60) {
      return watchedSeconds >= (videoDurationSeconds * 0.80).round();
    }
    if (videoDurationSeconds <= 300) {
      return watchedSeconds >= 60; // 1 minute
    }
    return watchedSeconds >= 120; // 2 minutes
  }

  /// Can this video show ads?
  static bool canShowAds(int videoDurationSeconds) {
    return videoDurationSeconds >= 15;
  }

  /// Maximum ads allowed (same formula as AdService)
  static int maxAdsAllowed(int videoDurationSeconds) {
    if (videoDurationSeconds < 30) {
      return 2; // 15s or under 30s
    }
    final minutes = videoDurationSeconds / 60.0;
    return (minutes / 3).ceil(); // 1 ad every 3 minutes
  }
}

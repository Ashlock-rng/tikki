class ViewService {
  /// Only real human valid watches count
  static bool isValidView({
    required int videoDurationSeconds,
    required int watchedSeconds,
  }) {
    if (videoDurationSeconds <= 0 || watchedSeconds <= 0) return false;

    if (videoDurationSeconds < 30) {
      // 15s or any video under 30s → must watch full video
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
}

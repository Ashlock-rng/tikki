class AppConstants {
  // ========== SUBSCRIPTION PRICES ==========
  static const double basicSubscriptionPrice = 5.0;   // Blue check – Ad-free
  static const double premiumPrice = 8.0;             // Green check – 2-week premium celebrity posts
  static const double celebrityPrice = 11.0;          // Path to Red check (verification)

  // Old names kept for compatibility
  static const double fanPremiumPrice = premiumPrice;
  static const double celebrityPremiumPrice = celebrityPrice;

  // Revenue splits
  static const double giftPlatformShare = 0.50;       // 50%
  static const double giftReceiverShare = 0.50;       // 50%
  static const double celebrityVdPlatformShare = 0.30; // 30%
  static const double celebrityVdCreatorShare = 0.70;  // 70%

  // Payout
  static const double minimumPayoutAmount = 50.0;

  // Ads
  static const int videosBetweenAds = 5;
  static const int adSkipAfterSeconds = 6;

  // Premium access
  static const int premiumAccessDays = 14; // 2 weeks for $8 Premium

  // Gift price range
  static const double minGiftPrice = 10.0;
  static const double maxGiftPrice = 100000.0;
}

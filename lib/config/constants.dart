class AppConstants {
  // ========== VIEW EARNINGS (Pure Organic) ==========
  static const double premiumRatePerThousand = 1.00;   // $1.00 per 1,000 views
  static const double celebrityRatePerThousand = 1.55; // $1.55 per 1,000 views

  // ========== BOOST PRICES (Poster pays you) ==========
  // Price to buy boost views (you keep 100%)
  static const Map<int, double> boostPackages = {
    1000: 2.50,      // 1,000 views  → $2.50
    5000: 10.00,     // 5,000 views  → $10
    10000: 18.00,    // 10,000 views → $18
    50000: 75.00,    // 50,000 views → $75
    100000: 140.00,  // 100,000 views → $140
    500000: 600.00,  // 500,000 views → $600
    1000000: 1100.00 // 1,000,000 views → $1,100
  };

  // Minimum payout
  static const double minimumPayoutAmount = 50.0;
}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/constants.dart';
import 'revenue_service.dart';

class BoostService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final RevenueService _revenue = RevenueService();

  /// Get all available boost packages
  Map<int, double> get packages => AppConstants.boostPackages;

  /// Buy a boost for a video
  Future<bool> buyBoost({
    required String posterId,
    required String videoId,
    required int viewsWanted,
  }) async {
    final price = AppConstants.boostPackages[viewsWanted];
    if (price == null) {
      throw Exception('Invalid boost package');
    }

    // Here you would normally charge the user with Stripe / Paystack first
    // After successful payment, call this:

    await _revenue.processBoostPayment(
      posterId: posterId,
      videoId: videoId,
      viewsBought: viewsWanted,
      amountPaid: price,
    );

    return true;
  }

  /// Get active boosts for a video
  Stream<QuerySnapshot> getActiveBoosts(String videoId) {
    return _db
        .collection('boosts')
        .where('videoId', isEqualTo: videoId)
        .where('status', isEqualTo: 'active')
        .snapshots();
  }
}

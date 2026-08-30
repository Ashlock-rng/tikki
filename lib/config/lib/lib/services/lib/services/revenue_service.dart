import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/constants.dart';
import 'view_service.dart';

class RevenueService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Pure organic view earnings
  Future<void> recordOrganicView({
    required String creatorId,
    required String videoId,
    required int videoDurationSeconds,
    required int watchedSeconds,
    required bool isCelebrity,
    required bool isPremiumCreator,
  }) async {
    // Must be a valid view
    if (!ViewService.isValidView(
      videoDurationSeconds: videoDurationSeconds,
      watchedSeconds: watchedSeconds,
    )) return;

    // Decide rate
    double ratePerThousand = 0.0;
    if (isCelebrity) {
      ratePerThousand = AppConstants.celebrityRatePerThousand; // $1.55
    } else if (isPremiumCreator) {
      ratePerThousand = AppConstants.premiumRatePerThousand;   // $1.00
    } else {
      return; // Free / Basic earn $0 from views
    }

    final double earnings = ratePerThousand / 1000;

    final batch = _db.batch();

    // Credit creator
    batch.update(_db.collection('users').doc(creatorId), {
      'earnings.availableBalance': FieldValue.increment(earnings),
      'earnings.lifetimeEarnings': FieldValue.increment(earnings),
      'earnings.totalValidViews': FieldValue.increment(1),
    });

    // Ledger
    batch.set(_db.collection('earnings_ledger').doc(), {
      'userId': creatorId,
      'source': 'organic_view',
      'ratePerThousand': ratePerThousand,
      'amount': earnings,
      'videoId': videoId,
      'watchedSeconds': watchedSeconds,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'available',
    });

    await batch.commit();
  }

  /// When someone buys a Boost → platform gets 100%
  Future<void> processBoostPayment({
    required String posterId,
    required String videoId,
    required int viewsBought,
    required double amountPaid,
  }) async {
    final batch = _db.batch();

    final boostRef = _db.collection('boosts').doc();
    batch.set(boostRef, {
      'videoId': videoId,
      'posterId': posterId,
      'viewsBought': viewsBought,
      'amountPaid': amountPaid,
      'viewsDelivered': 0,
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Platform keeps 100% of boost money
    batch.set(_db.collection('platform_earnings').doc(), {
      'source': 'boost',
      'amount': amountPaid,
      'boostId': boostRef.id,
      'videoId': videoId,
      'posterId': posterId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  /// Request payout (minimum $50)
  Future<String?> requestPayout({
    required String userId,
    required double amount,
    required String method,
  }) async {
    final userDoc = await _db.collection('users').doc(userId).get();
    if (!userDoc.exists) return null;

    final data = userDoc.data() as Map<String, dynamic>;
    final available = (data['earnings']?['availableBalance'] ?? 0).toDouble();

    if (available < AppConstants.minimumPayoutAmount) {
      throw Exception('Minimum payout is \$${AppConstants.minimumPayoutAmount}');
    }
    if (amount > available) {
      throw Exception('Insufficient balance');
    }

    final batch = _db.batch();

    batch.update(_db.collection('users').doc(userId), {
      'earnings.availableBalance': FieldValue.increment(-amount),
    });

    final payoutRef = _db.collection('payouts').doc();
    batch.set(payoutRef, {
      'userId': userId,
      'amount': amount,
      'method': method,
      'status': 'pending',
      'requestedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
    return payoutRef.id;
  }
}

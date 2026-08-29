import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/gift_model.dart';

class RevenueService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> processGift({
    required String senderId,
    required String receiverId,
    required GiftCatalogItem gift,
    String? liveId,
  }) async {
    final amount = gift.priceUsd;
    final platformShare = amount * 0.50;
    final receiverShare = amount * 0.50;

    final batch = _db.batch();

    final txRef = _db.collection('gift_transactions').doc();
    batch.set(txRef, {
      'senderId': senderId,
      'receiverId': receiverId,
      'giftId': gift.id,
      'giftName': gift.name,
      'amountUsd': amount,
      'platformShare': platformShare,
      'receiverShare': receiverShare,
      'liveId': liveId,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'completed',
    });

    final receiverRef = _db.collection('users').doc(receiverId);
    batch.update(receiverRef, {
      'earnings.availableBalance': FieldValue.increment(receiverShare),
      'earnings.lifetimeEarnings': FieldValue.increment(receiverShare),
    });

    final ledgerRef = _db.collection('earnings_ledger').doc();
    batch.set(ledgerRef, {
      'userId': receiverId,
      'source': 'gift',
      'grossAmount': amount,
      'platformShare': platformShare,
      'creatorShare': receiverShare,
      'relatedId': txRef.id,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'available',
    });

    await batch.commit();
  }

  Future<void> processCelebrityPremiumVDPurchase({
    required String buyerId,
    required String celebrityId,
    required String videoId,
    required double amountUsd,
  }) async {
    final platformShare = amountUsd * 0.30;
    final celebrityShare = amountUsd * 0.70;

    final batch = _db.batch();

    final celebRef = _db.collection('users').doc(celebrityId);
    batch.update(celebRef, {
      'earnings.availableBalance': FieldValue.increment(celebrityShare),
      'earnings.lifetimeEarnings': FieldValue.increment(celebrityShare),
    });

    final ledgerRef = _db.collection('earnings_ledger').doc();
    batch.set(ledgerRef, {
      'userId': celebrityId,
      'source': 'premium_vd',
      'grossAmount': amountUsd,
      'platformShare': platformShare,
      'creatorShare': celebrityShare,
      'relatedId': videoId,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'available',
    });

    await batch.commit();
  }

  Future<void> processPlatformSubscription({
    required String userId,
    required SubscriptionType type,
    required double amountUsd,
    required DateTime endDate,
  }) async {
    await _db.collection('subscriptions').add({
      'userId': userId,
      'type': type == SubscriptionType.basic ? 'basic' : 'fan_premium',
      'amountUsd': amountUsd,
      'startDate': FieldValue.serverTimestamp(),
      'endDate': Timestamp.fromDate(endDate),
      'status': 'active',
    });

    await _db.collection('users').doc(userId).update({
      'subscription': {
        'type': type == SubscriptionType.basic ? 'basic' : 'fan_premium',
        'startDate': FieldValue.serverTimestamp(),
        'endDate': Timestamp.fromDate(endDate),
        'autoRenew': true,
      },
    });
  }

  Future<String?> requestPayout({
    required String userId,
    required double amount,
    required String method,
  }) async {
    final userDoc = await _db.collection('users').doc(userId).get();
    if (!userDoc.exists) return null;

    final earnings = EarningsInfo.fromMap(
        (userDoc.data() as Map)['earnings'] ?? {});

    if (earnings.availableBalance < 50.0) {
      throw Exception('Minimum payout is \$50. Current balance: \$${earnings.availableBalance.toStringAsFixed(2)}');
    }

    if (amount > earnings.availableBalance) {
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
      'completedAt': null,
    });

    await batch.commit();
    return payoutRef.id;
  }
}

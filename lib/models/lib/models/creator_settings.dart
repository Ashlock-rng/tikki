import 'package:cloud_firestore/cloud_firestore.dart';

class CreatorSettings {
  final String userId;
  final bool acceptsSubscriptions;
  final double monthlyPriceUsd;
  final String currency;
  final DateTime updatedAt;

  CreatorSettings({
    required this.userId,
    this.acceptsSubscriptions = false,
    this.monthlyPriceUsd = 4.99,
    this.currency = 'USD',
    required this.updatedAt,
  });

  factory CreatorSettings.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return CreatorSettings(
      userId: doc.id,
      acceptsSubscriptions: data['acceptsSubscriptions'] ?? false,
      monthlyPriceUsd: (data['monthlyPriceUsd'] ?? 4.99).toDouble(),
      currency: data['currency'] ?? 'USD',
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'acceptsSubscriptions': acceptsSubscriptions,
      'monthlyPriceUsd': monthlyPriceUsd,
      'currency': currency,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

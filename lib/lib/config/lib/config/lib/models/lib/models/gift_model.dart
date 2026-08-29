import 'package:cloud_firestore/cloud_firestore.dart';

class GiftCatalogItem {
  final String id;
  final String name;
  final String imageUrl;
  final String? animationUrl;
  final double priceUsd;
  final bool isActive;

  GiftCatalogItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.animationUrl,
    required this.priceUsd,
    this.isActive = true,
  });

  factory GiftCatalogItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GiftCatalogItem(
      id: doc.id,
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      animationUrl: data['animationUrl'],
      priceUsd: (data['priceUsd'] ?? 0).toDouble(),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'animationUrl': animationUrl,
      'priceUsd': priceUsd,
      'isActive': isActive,
    };
  }
}

class GiftTransaction {
  final String id;
  final String senderId;
  final String receiverId;
  final String giftId;
  final String giftName;
  final double amountUsd;
  final double platformShare;
  final double receiverShare;
  final String? liveId;
  final DateTime createdAt;
  final String status;

  GiftTransaction({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.giftId,
    required this.giftName,
    required this.amountUsd,
    required this.platformShare,
    required this.receiverShare,
    this.liveId,
    required this.createdAt,
    this.status = 'completed',
  });

  factory GiftTransaction.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GiftTransaction(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      receiverId: data['receiverId'] ?? '',
      giftId: data['giftId'] ?? '',
      giftName: data['giftName'] ?? '',
      amountUsd: (data['amountUsd'] ?? 0).toDouble(),
      platformShare: (data['platformShare'] ?? 0).toDouble(),
      receiverShare: (data['receiverShare'] ?? 0).toDouble(),
      liveId: data['liveId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      status: data['status'] ?? 'completed',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'giftId': giftId,
      'giftName': giftName,
      'amountUsd': amountUsd,
      'platformShare': platformShare,
      'receiverShare': receiverShare,
      'liveId': liveId,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status,
    };
  }
}

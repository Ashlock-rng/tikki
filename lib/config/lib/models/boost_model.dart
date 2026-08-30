import 'package:cloud_firestore/cloud_firestore.dart';

class BoostModel {
  final String id;
  final String videoId;
  final String posterId;
  final int viewsBought;
  final double amountPaid;
  final int viewsDelivered;
  final String status; // pending, active, completed, cancelled
  final DateTime createdAt;
  final DateTime? completedAt;

  BoostModel({
    required this.id,
    required this.videoId,
    required this.posterId,
    required this.viewsBought,
    required this.amountPaid,
    this.viewsDelivered = 0,
    this.status = 'pending',
    required this.createdAt,
    this.completedAt,
  });

  factory BoostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BoostModel(
      id: doc.id,
      videoId: data['videoId'] ?? '',
      posterId: data['posterId'] ?? '',
      viewsBought: data['viewsBought'] ?? 0,
      amountPaid: (data['amountPaid'] ?? 0).toDouble(),
      viewsDelivered: data['viewsDelivered'] ?? 0,
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'videoId': videoId,
      'posterId': posterId,
      'viewsBought': viewsBought,
      'amountPaid': amountPaid,
      'viewsDelivered': viewsDelivered,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }
}

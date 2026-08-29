import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String username;
  final String? photoUrl;
  final String? bio;
  final bool isCelebrity;
  final bool isAdmin;
  final int followersCount;
  final int followingCount;
  final DateTime createdAt;
  final SubscriptionInfo subscription;
  final EarningsInfo earnings;
  final VerificationInfo verification;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.username,
    this.photoUrl,
    this.bio,
    this.isCelebrity = false,
    this.isAdmin = false,
    this.followersCount = 0,
    this.followingCount = 0,
    required this.createdAt,
    required this.subscription,
    required this.earnings,
    this.verification = const VerificationInfo(),
  });

  bool get isAdFree =>
      subscription.type == SubscriptionType.basic ||
      subscription.type == SubscriptionType.fanPremium ||
      subscription.type == SubscriptionType.celebrityPremium;

  bool get hasFanPremium =>
      subscription.type == SubscriptionType.fanPremium &&
      subscription.endDate.isAfter(DateTime.now());

  bool get hasCelebrityPremium =>
      subscription.type == SubscriptionType.celebrityPremium &&
      subscription.endDate.isAfter(DateTime.now());

  bool get isVerifiedCelebrity =>
      isCelebrity && verification.status == VerificationStatus.approved;

  CheckmarkType get checkmark {
    if (isVerifiedCelebrity) return CheckmarkType.celebrity;
    if (hasFanPremium || hasCelebrityPremium) return CheckmarkType.premium;
    if (subscription.type == SubscriptionType.basic) return CheckmarkType.subscriber;
    return CheckmarkType.none;
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      username: data['username'] ?? '',
      photoUrl: data['photoUrl'],
      bio: data['bio'],
      isCelebrity: data['isCelebrity'] ?? false,
      isAdmin: data['isAdmin'] ?? false,
      followersCount: data['followersCount'] ?? 0,
      followingCount: data['followingCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      subscription: SubscriptionInfo.fromMap(data['subscription'] ?? {}),
      earnings: EarningsInfo.fromMap(data['earnings'] ?? {}),
      verification: VerificationInfo.fromMap(data['verification'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'username': username,
      'photoUrl': photoUrl,
      'bio': bio,
      'isCelebrity': isCelebrity,
      'isAdmin': isAdmin,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'subscription': subscription.toMap(),
      'earnings': earnings.toMap(),
      'verification': verification.toMap(),
    };
  }
}

enum CheckmarkType { none, subscriber, premium, celebrity }

extension CheckmarkTypeExtension on CheckmarkType {
  Color get color {
    switch (this) {
      case CheckmarkType.subscriber:
        return const Color(0xFF1DA1F2);
      case CheckmarkType.premium:
        return const Color(0xFF00C853);
      case CheckmarkType.celebrity:
        return const Color(0xFFE53935);
      case CheckmarkType.none:
        return Colors.transparent;
    }
  }

  IconData get icon => Icons.verified;

  String get label {
    switch (this) {
      case CheckmarkType.subscriber:
        return 'Subscriber';
      case CheckmarkType.premium:
        return 'Premium';
      case CheckmarkType.celebrity:
        return 'Verified Celebrity';
      case CheckmarkType.none:
        return '';
    }
  }
}

enum SubscriptionType { none, basic, fanPremium, celebrityPremium }

class SubscriptionInfo {
  final SubscriptionType type;
  final DateTime? startDate;
  final DateTime endDate;
  final bool autoRenew;

  SubscriptionInfo({
    this.type = SubscriptionType.none,
    this.startDate,
    DateTime? endDate,
    this.autoRenew = false,
  }) : endDate = endDate ?? DateTime.now();

  factory SubscriptionInfo.fromMap(Map<String, dynamic> map) {
    return SubscriptionInfo(
      type: _parseType(map['type']),
      startDate: map['startDate'] != null
          ? (map['startDate'] as Timestamp).toDate()
          : null,
      endDate: map['endDate'] != null
          ? (map['endDate'] as Timestamp).toDate()
          : DateTime.now(),
      autoRenew: map['autoRenew'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'endDate': Timestamp.fromDate(endDate),
      'autoRenew': autoRenew,
    };
  }

  static SubscriptionType _parseType(String? value) {
    switch (value) {
      case 'basic':
        return SubscriptionType.basic;
      case 'fan_premium':
        return SubscriptionType.fanPremium;
      case 'celebrity_premium':
        return SubscriptionType.celebrityPremium;
      default:
        return SubscriptionType.none;
    }
  }
}

enum VerificationStatus { none, pending, approved, rejected }

class VerificationInfo {
  final VerificationStatus status;
  final String? idDocumentUrl;
  final String? selfieUrl;
  final String? rejectionReason;
  final DateTime? submittedAt;
  final DateTime? reviewedAt;

  const VerificationInfo({
    this.status = VerificationStatus.none,
    this.idDocumentUrl,
    this.selfieUrl,
    this.rejectionReason,
    this.submittedAt,
    this.reviewedAt,
  });

  factory VerificationInfo.fromMap(Map<String, dynamic> map) {
    return VerificationInfo(
      status: _parseStatus(map['status']),
      idDocumentUrl: map['idDocumentUrl'],
      selfieUrl: map['selfieUrl'],
      rejectionReason: map['rejectionReason'],
      submittedAt: map['submittedAt'] != null
          ? (map['submittedAt'] as Timestamp).toDate()
          : null,
      reviewedAt: map['reviewedAt'] != null
          ? (map['reviewedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status.name,
      'idDocumentUrl': idDocumentUrl,
      'selfieUrl': selfieUrl,
      'rejectionReason': rejectionReason,
      'submittedAt':
          submittedAt != null ? Timestamp.fromDate(submittedAt!) : null,
      'reviewedAt': reviewedAt != null ? Timestamp.fromDate(reviewedAt!) : null,
    };
  }

  static VerificationStatus _parseStatus(String? value) {
    switch (value) {
      case 'pending':
        return VerificationStatus.pending;
      case 'approved':
        return VerificationStatus.approved;
      case 'rejected':
        return VerificationStatus.rejected;
      default:
        return VerificationStatus.none;
    }
  }
}

class EarningsInfo {
  final double availableBalance;
  final double pendingBalance;
  final double lifetimeEarnings;
  final DateTime? lastPayoutAt;

  EarningsInfo({
    this.availableBalance = 0.0,
    this.pendingBalance = 0.0,
    this.lifetimeEarnings = 0.0,
    this.lastPayoutAt,
  });

  bool get canWithdraw => availableBalance >= 50.0;

  factory EarningsInfo.fromMap(Map<String, dynamic> map) {
    return EarningsInfo(
      availableBalance: (map['availableBalance'] ?? 0).toDouble(),
      pendingBalance: (map['pendingBalance'] ?? 0).toDouble(),
      lifetimeEarnings: (map['lifetimeEarnings'] ?? 0).toDouble(),
      lastPayoutAt: map['lastPayoutAt'] != null
          ? (map['lastPayoutAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'availableBalance': availableBalance,
      'pendingBalance': pendingBalance,
      'lifetimeEarnings': lifetimeEarnings,
      'lastPayoutAt':
          lastPayoutAt != null ? Timestamp.fromDate(lastPayoutAt!) : null,
    };
  }
}

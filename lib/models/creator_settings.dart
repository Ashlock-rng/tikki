import 'package:cloud_firestore/cloud_firestore.dart';

enum PostVisibility {
  public,
  subscribersOnly,
}

class VideoModel {
  final String id;
  final String authorId;
  final String title;
  final String description;
  final String videoUrl;
  final String thumbnailUrl;
  final int duration;
  final bool isPremiumVD;
  final bool isCelebrityContent;
  final bool isPlatformCurated;
  final int accessDurationDays;
  final double price;
  final int viewsCount;
  final int likesCount;
  final DateTime createdAt;
  final PostVisibility visibility;

  VideoModel({
    required this.id,
    required this.authorId,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.thumbnailUrl,
    this.duration = 0,
    this.isPremiumVD = false,
    this.isCelebrityContent = false,
    this.isPlatformCurated = false,
    this.accessDurationDays = 14,
    this.price = 0.0,
    this.viewsCount = 0,
    this.likesCount = 0,
    required this.createdAt,
    this.visibility = PostVisibility.public,
  });

  bool canView(bool isLoggedIn, bool hasActiveSubscription) {
    if (visibility == PostVisibility.public) return true;
    return isLoggedIn && hasActiveSubscription;
  }

  factory VideoModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VideoModel(
      id: doc.id,
      authorId: data['authorId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      videoUrl: data['videoUrl'] ?? '',
      thumbnailUrl: data['thumbnailUrl'] ?? '',
      duration: data['duration'] ?? 0,
      isPremiumVD: data['isPremiumVD'] ?? false,
      isCelebrityContent: data['isCelebrityContent'] ?? false,
      isPlatformCurated: data['isPlatformCurated'] ?? false,
      accessDurationDays: data['accessDurationDays'] ?? 14,
      price: (data['price'] ?? 0).toDouble(),
      viewsCount: data['viewsCount'] ?? 0,
      likesCount: data['likesCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      visibility: _parseVisibility(data['visibility']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'authorId': authorId,
      'title': title,
      'description': description,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'duration': duration,
      'isPremiumVD': isPremiumVD,
      'isCelebrityContent': isCelebrityContent,
      'isPlatformCurated': isPlatformCurated,
      'accessDurationDays': accessDurationDays,
      'price': price,
      'viewsCount': viewsCount,
      'likesCount': likesCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'visibility': visibility.name,
    };
  }

  static PostVisibility _parseVisibility(String? value) {
    switch (value) {
      case 'subscribersOnly':
        return PostVisibility.subscribersOnly;
      default:
        return PostVisibility.public;
    }
  }
}

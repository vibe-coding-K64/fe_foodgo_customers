import 'package:cloud_firestore/cloud_firestore.dart';

class BannerModel {
  final String id;
  final String title;
  final String imageUrl;
  final String? storeId;
  final bool isActive;
  final int order;

  BannerModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.storeId,
    required this.isActive,
    this.order = 0,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] as String,
      title: json['title'] as String,
      imageUrl: json['imageUrl'] as String,
      storeId: json['storeId'] as String?,
      isActive: json['isActive'] as bool,
      order: json['order'] as int? ?? 0,
    );
  }

  // Tao doi tuong tu Firestore DocumentSnapshot.
  factory BannerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Du lieu Firestore cua BannerModel bi null');
    }
    return BannerModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      storeId: data['storeId'] as String?,
      isActive: data['isActive'] as bool? ?? false,
      order: data['order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'storeId': storeId,
      'isActive': isActive,
      'order': order,
    };
  }
}

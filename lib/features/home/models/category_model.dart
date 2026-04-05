import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final String imageUrl;
  final int order;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.imageUrl,
    this.order = 0,
  });

  // Tao doi tuong tu JSON
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? json['image'] as String? ?? '',
      order: json['order'] as int? ?? json['displayOrder'] as int? ?? 0,
    );
  }

  // Tao doi tuong tu Firestore DocumentSnapshot.
  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Du lieu Firestore cua CategoryModel bi null');
    }
    return CategoryModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      icon: data['icon'] as String? ?? '',
      // Ho tro ca 'imageUrl' va 'image' (backward compatibility).
      imageUrl: data['imageUrl'] as String? ?? data['image'] as String? ?? '',
      order: data['order'] as int? ?? data['displayOrder'] as int? ?? 0,
    );
  }

  // Chuyen doi tuong thanh JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'imageUrl': imageUrl,
      'order': order,
    };
  }

  // Tao ban sao doi tuong voi cac truong thay doi
  CategoryModel copyWith({
    String? id,
    String? name,
    String? icon,
    String? imageUrl,
    int? order,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      imageUrl: imageUrl ?? this.imageUrl,
      order: order ?? this.order,
    );
  }
}

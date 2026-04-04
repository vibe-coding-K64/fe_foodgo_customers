class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final String imageUrl;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.imageUrl,
  });

  // Tao doi tuong tu JSON
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      imageUrl: json['imageUrl'] as String,
    );
  }

  // Chuyen doi tuong thanh JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'imageUrl': imageUrl,
    };
  }

  // Tao ban sao doi tuong voi cac truong thay doi
  CategoryModel copyWith({
    String? id,
    String? name,
    String? icon,
    String? imageUrl,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

class SearchHistoryModel {
  final String id;
  final String userId;
  final String keyword;
  final DateTime createdAt;
  final DateTime? deletedAt;

  SearchHistoryModel({
    required this.id,
    required this.userId,
    required this.keyword,
    required this.createdAt,
    this.deletedAt,
  });

  factory SearchHistoryModel.fromJson(Map<String, dynamic> json) {
    return SearchHistoryModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      keyword: json['keyword'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'keyword': keyword,
      'createdAt': createdAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  SearchHistoryModel copyWith({
    String? id,
    String? userId,
    String? keyword,
    DateTime? createdAt,
    DateTime? deletedAt,
  }) {
    return SearchHistoryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      keyword: keyword ?? this.keyword,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}

class Comment {
  final int? id;
  final int productId;
  final String username;
  final String content;
  final DateTime createdAt;
  final double? rating;

  Comment({
    this.id,
    required this.productId,
    required this.username,
    required this.content,
    required this.createdAt,
    this.rating,
  });

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'],
      productId: map['productId'],
      username: map['username'],
      content: map['content'],
      createdAt: DateTime.parse(map['createdAt']),
      rating: map['rating']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'username': username,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'rating': rating,
    };
  }
}
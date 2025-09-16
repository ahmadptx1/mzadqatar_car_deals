class Category {
  final int id;
  final String name;
  final String description;
  final int count;

  Category({
    required this.id,
    required this.name,
    required this.description,
    required this.count,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      count: map['count'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'count': count,
    };
  }
}
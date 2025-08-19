class CarListing {
  final int? id;
  final String title;
  final String description;
  final int price;
  final String imageUrl;
  final String url;
  final DateTime postedAt;

  CarListing({
    this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.url,
    required this.postedAt,
  });

  factory CarListing.fromMap(Map<String, dynamic> map) {
    return CarListing(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      price: map['price'],
      imageUrl: map['imageUrl'],
      url: map['url'],
      postedAt: DateTime.parse(map['postedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'url': url,
      'postedAt': postedAt.toIso8601String(),
    };
  }
}
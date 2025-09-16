class ProductDetails {
  final int id;
  final String title;
  final String description;
  final int price;
  final String imageUrl;
  final String url;
  final DateTime postedAt;
  final String sellerName;
  final String sellerPhone;
  final String location;
  final int year;
  final String brand;
  final String model;
  final int mileage;
  final String fuelType;
  final String transmission;
  final List<String> features;
  final List<String> images;

  ProductDetails({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.url,
    required this.postedAt,
    required this.sellerName,
    required this.sellerPhone,
    required this.location,
    required this.year,
    required this.brand,
    required this.model,
    required this.mileage,
    required this.fuelType,
    required this.transmission,
    required this.features,
    required this.images,
  });

  factory ProductDetails.fromMap(Map<String, dynamic> map) {
    return ProductDetails(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      price: map['price'],
      imageUrl: map['imageUrl'],
      url: map['url'],
      postedAt: DateTime.parse(map['postedAt']),
      sellerName: map['sellerName'],
      sellerPhone: map['sellerPhone'],
      location: map['location'],
      year: map['year'],
      brand: map['brand'],
      model: map['model'],
      mileage: map['mileage'],
      fuelType: map['fuelType'],
      transmission: map['transmission'],
      features: List<String>.from(map['features'] ?? []),
      images: List<String>.from(map['images'] ?? []),
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
      'sellerName': sellerName,
      'sellerPhone': sellerPhone,
      'location': location,
      'year': year,
      'brand': brand,
      'model': model,
      'mileage': mileage,
      'fuelType': fuelType,
      'transmission': transmission,
      'features': features,
      'images': images,
    };
  }
}
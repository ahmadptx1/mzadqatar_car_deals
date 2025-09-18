import 'dart:convert';

class CarListing {
  final int? id;
  final String productId;
  final String title;
  final String description;
  final int? price;
  final String? imageUrl;
  final String? url;
  final DateTime postedAt;
  final int? dateOfAdvertiseEpoch;

  // Additional fields
  final String? sellerId;
  final String? sellerName;
  final int? isCompany;
  final int? km;
  final int? manufactureYear;
  final String? model;
  final String? cityName;
  final List<String>? images;
  final String? rawJson;
  final int recommended;
  final String? notifiedAt;

  CarListing({
    this.id,
    required this.productId,
    required this.title,
    required this.description,
    this.price,
    this.imageUrl,
    this.url,
    required this.postedAt,
    this.sellerId,
    this.sellerName,
    this.isCompany,
    this.km,
    this.manufactureYear,
    this.model,
    this.cityName,
    this.images,
    this.rawJson,
    this.dateOfAdvertiseEpoch,
    this.recommended = 0,
    this.notifiedAt,
  });

  factory CarListing.fromMap(Map<String, dynamic> map) {
    List<String>? imgs;
    try {
      if (map['images'] != null) {
        final decoded = map['images'];
        if (decoded is String) {
          imgs = List<String>.from(json.decode(decoded));
        } else if (decoded is List) {
          imgs = decoded.map((e) => e.toString()).toList();
        }
      }
    } catch (_) {
      imgs = null;
    }

    return CarListing(
      id: map['id'],
      productId: map['productId']?.toString() ?? map['url']?.toString() ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      price: map['price'] is int ? map['price'] : (int.tryParse(map['price']?.toString() ?? '') ?? 0),
      imageUrl: map['imageUrl'],
      url: map['url'],
  postedAt: map['postedAt'] is String ? (DateTime.tryParse(map['postedAt']) ?? DateTime.now()) : DateTime.now(),
  dateOfAdvertiseEpoch: map['dateOfAdvertiseEpoch'] is int ? map['dateOfAdvertiseEpoch'] : int.tryParse(map['dateOfAdvertiseEpoch']?.toString() ?? ''),
      sellerId: map['sellerId']?.toString(),
      sellerName: map['sellerName'],
  isCompany: map['isCompany'] is int ? map['isCompany'] : (int.tryParse(map['isCompany']?.toString() ?? '') ?? 0),
  km: map['km'] is int ? map['km'] : int.tryParse(map['km']?.toString() ?? ''),
  manufactureYear: map['manufactureYear'] is int ? map['manufactureYear'] : int.tryParse(map['manufactureYear']?.toString() ?? ''),
      model: map['model'],
      cityName: map['cityName'],
      images: imgs,
      rawJson: map['rawJson'],
      recommended: map['recommended'] is int ? map['recommended'] : (int.tryParse(map['recommended']?.toString() ?? '') ?? 0),
      notifiedAt: map['notifiedAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'title': title,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'url': url,
  'postedAt': postedAt.toIso8601String(),
  'dateOfAdvertiseEpoch': dateOfAdvertiseEpoch,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'isCompany': isCompany,
      'km': km,
      'manufactureYear': manufactureYear,
      'model': model,
      'cityName': cityName,
      'images': images != null ? json.encode(images) : null,
      'rawJson': rawJson,
      'recommended': recommended,
      'notifiedAt': notifiedAt,
    };
  }
}
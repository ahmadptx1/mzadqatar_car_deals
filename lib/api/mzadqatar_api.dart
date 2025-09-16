import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/car_listing.dart';
import '../models/comment.dart';
import '../models/category.dart';
import '../models/product_details.dart';

class MzadQatarApi {
  static const String baseUrl = 'https://api.mzadqatar.com'; // Replace with actual base URL
  
  static Future<List<CarListing>> fetchCarListings() async {
    // This is a placeholder endpoint. Replace with the actual API endpoint if available.
    final url = Uri.parse('https://api.npoint.io/4712ebcd2f3f5859c2e3'); // Example JSON endpoint

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => CarListing(
        title: e['title'],
        description: e['description'],
        price: e['price'],
        imageUrl: e['imageUrl'],
        url: e['url'],
        postedAt: DateTime.parse(e['postedAt']),
      )).toList();
    } else {
      throw Exception('Failed to load car listings');
    }
  }

  /// Get category data with pagination support
  static Future<Map<String, dynamic>> getCategoryData({
    int page = 1,
    int limit = 20,
    String? category,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
      if (category != null) 'category': category,
    };
    
    final uri = Uri.parse('$baseUrl/get-category-data').replace(
      queryParameters: queryParams,
    );

    try {
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        return {
          'listings': (data['listings'] as List<dynamic>).map((e) => CarListing(
            title: e['title'] ?? '',
            description: e['description'] ?? '',
            price: e['price'] ?? 0,
            imageUrl: e['imageUrl'] ?? '',
            url: e['url'] ?? '',
            postedAt: DateTime.tryParse(e['postedAt'] ?? '') ?? DateTime.now(),
          )).toList(),
          'categories': (data['categories'] as List<dynamic>? ?? []).map((e) => Category.fromMap(e)).toList(),
          'totalCount': data['totalCount'] ?? 0,
          'currentPage': data['currentPage'] ?? page,
          'totalPages': data['totalPages'] ?? 1,
        };
      } else {
        throw Exception('Failed to load category data: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock data for development
      return _getMockCategoryData(page, limit);
    }
  }

  /// Get comments for a specific product
  static Future<List<Comment>> getProductComments(int productId) async {
    final uri = Uri.parse('$baseUrl/get-product-comments').replace(
      queryParameters: {'productId': productId.toString()},
    );

    try {
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => Comment.fromMap(e)).toList();
      } else {
        throw Exception('Failed to load product comments: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock comments for development
      return _getMockComments(productId);
    }
  }

  /// Get detailed information about a specific product
  static Future<ProductDetails> getProductDetails(int productId) async {
    final uri = Uri.parse('$baseUrl/get-product-details').replace(
      queryParameters: {'productId': productId.toString()},
    );

    try {
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ProductDetails.fromMap(data);
      } else {
        throw Exception('Failed to load product details: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock product details for development
      return _getMockProductDetails(productId);
    }
  }

  /// Get related ads from the same user
  static Future<List<CarListing>> getRelatedUserAds(String userId, {int limit = 10}) async {
    final uri = Uri.parse('$baseUrl/related-user-ads').replace(
      queryParameters: {
        'userId': userId,
        'limit': limit.toString(),
      },
    );

    try {
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => CarListing(
          title: e['title'] ?? '',
          description: e['description'] ?? '',
          price: e['price'] ?? 0,
          imageUrl: e['imageUrl'] ?? '',
          url: e['url'] ?? '',
          postedAt: DateTime.tryParse(e['postedAt'] ?? '') ?? DateTime.now(),
        )).toList();
      } else {
        throw Exception('Failed to load related user ads: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock related ads for development
      return _getMockRelatedAds(userId, limit);
    }
  }

  // Mock data methods for development/testing
  static Map<String, dynamic> _getMockCategoryData(int page, int limit) {
    final mockListings = List.generate(limit, (index) {
      final id = (page - 1) * limit + index + 1;
      return CarListing(
        title: 'Toyota Camry $id',
        description: 'Well maintained Toyota Camry in excellent condition',
        price: 45000 + (id * 1000),
        imageUrl: 'https://via.placeholder.com/300x200',
        url: 'https://mzadqatar.com/listing/$id',
        postedAt: DateTime.now().subtract(Duration(days: id)),
      );
    });

    final mockCategories = [
      Category(id: 1, name: 'Toyota', description: 'Toyota vehicles', count: 150),
      Category(id: 2, name: 'BMW', description: 'BMW vehicles', count: 120),
      Category(id: 3, name: 'Mercedes', description: 'Mercedes vehicles', count: 90),
    ];

    return {
      'listings': mockListings,
      'categories': mockCategories,
      'totalCount': 500,
      'currentPage': page,
      'totalPages': 25,
    };
  }

  static List<Comment> _getMockComments(int productId) {
    return [
      Comment(
        id: 1,
        productId: productId,
        username: 'Ahmad',
        content: 'Great car! Very clean and well maintained.',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        rating: 5.0,
      ),
      Comment(
        id: 2,
        productId: productId,
        username: 'Sarah',
        content: 'Good price for this model. Interested!',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        rating: 4.0,
      ),
    ];
  }

  static ProductDetails _getMockProductDetails(int productId) {
    return ProductDetails(
      id: productId,
      title: 'Toyota Camry 2020',
      description: 'Excellent condition Toyota Camry with full service history.',
      price: 48000,
      imageUrl: 'https://via.placeholder.com/400x300',
      url: 'https://mzadqatar.com/listing/$productId',
      postedAt: DateTime.now().subtract(const Duration(days: 5)),
      sellerName: 'Ahmed Al-Mansouri',
      sellerPhone: '+974 5555 1234',
      location: 'Doha, Qatar',
      year: 2020,
      brand: 'Toyota',
      model: 'Camry',
      mileage: 45000,
      fuelType: 'Petrol',
      transmission: 'Automatic',
      features: ['Sunroof', 'Leather Seats', 'Navigation System', 'Backup Camera'],
      images: [
        'https://via.placeholder.com/400x300/1',
        'https://via.placeholder.com/400x300/2',
        'https://via.placeholder.com/400x300/3',
      ],
    );
  }

  static List<CarListing> _getMockRelatedAds(String userId, int limit) {
    return List.generate(limit.clamp(1, 5), (index) {
      final id = index + 1;
      return CarListing(
        title: 'Related Car $id',
        description: 'Another great car from the same seller',
        price: 35000 + (id * 5000),
        imageUrl: 'https://via.placeholder.com/300x200',
        url: 'https://mzadqatar.com/listing/related-$id',
        postedAt: DateTime.now().subtract(Duration(days: id * 2)),
      );
    });
  }
}
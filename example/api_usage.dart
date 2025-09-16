// Example usage of MzadQatar APIs

import 'package:mzadqatar_car_deals/api/mzadqatar_api.dart';
import 'package:mzadqatar_car_deals/models/car_listing.dart';
import 'package:mzadqatar_car_deals/models/comment.dart';
import 'package:mzadqatar_car_deals/models/category.dart';
import 'package:mzadqatar_car_deals/models/product_details.dart';

void main() async {
  // Example 1: Get category data with pagination
  print('=== Getting Category Data ===');
  try {
    final categoryData = await MzadQatarApi.getCategoryData(
      page: 1,
      limit: 10,
    );
    
    final listings = categoryData['listings'] as List<CarListing>;
    final categories = categoryData['categories'] as List<Category>;
    
    print('Found ${listings.length} listings');
    print('Available categories: ${categories.map((c) => c.name).join(', ')}');
    print('Total pages: ${categoryData['totalPages']}');
    
    // Example of filtering by category
    if (categories.isNotEmpty) {
      final filteredData = await MzadQatarApi.getCategoryData(
        category: categories.first.name,
        page: 1,
        limit: 5,
      );
      print('Filtered by ${categories.first.name}: ${filteredData['listings'].length} results');
    }
  } catch (e) {
    print('Error getting category data: $e');
  }

  // Example 2: Get product details
  print('\n=== Getting Product Details ===');
  try {
    final productDetails = await MzadQatarApi.getProductDetails(1);
    
    print('Car: ${productDetails.brand} ${productDetails.model} ${productDetails.year}');
    print('Price: QAR ${productDetails.price}');
    print('Seller: ${productDetails.sellerName}');
    print('Location: ${productDetails.location}');
    print('Features: ${productDetails.features.join(', ')}');
  } catch (e) {
    print('Error getting product details: $e');
  }

  // Example 3: Get product comments
  print('\n=== Getting Product Comments ===');
  try {
    final comments = await MzadQatarApi.getProductComments(1);
    
    print('Found ${comments.length} comments');
    for (final comment in comments) {
      print('${comment.username}: ${comment.content}');
      if (comment.rating != null) {
        print('  Rating: ${comment.rating}/5.0');
      }
    }
  } catch (e) {
    print('Error getting comments: $e');
  }

  // Example 4: Get related user ads
  print('\n=== Getting Related User Ads ===');
  try {
    final relatedAds = await MzadQatarApi.getRelatedUserAds('user1', limit: 3);
    
    print('Found ${relatedAds.length} related ads');
    for (final ad in relatedAds) {
      print('${ad.title} - QAR ${ad.price}');
    }
  } catch (e) {
    print('Error getting related ads: $e');
  }
}

// Example of using the models
void demonstrateModels() {
  // Creating a car listing
  final listing = CarListing(
    id: 1,
    title: 'Toyota Camry 2020',
    description: 'Excellent condition',
    price: 48000,
    imageUrl: 'https://example.com/car.jpg',
    url: 'https://mzadqatar.com/listing/1',
    postedAt: DateTime.now(),
    sellerId: 'seller123',
  );

  // Converting to/from map for database storage
  final listingMap = listing.toMap();
  final restoredListing = CarListing.fromMap(listingMap);
  
  print('Original: ${listing.title}');
  print('Restored: ${restoredListing.title}');

  // Creating a comment
  final comment = Comment(
    id: 1,
    productId: 1,
    username: 'Ahmad',
    content: 'Great car! Very satisfied.',
    createdAt: DateTime.now(),
    rating: 5.0,
  );

  // Creating a category
  final category = Category(
    id: 1,
    name: 'Toyota',
    description: 'Toyota vehicles',
    count: 150,
  );

  print('Comment by ${comment.username}: ${comment.content}');
  print('Category: ${category.name} (${category.count} items)');
}
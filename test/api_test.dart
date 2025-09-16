import 'package:flutter_test/flutter_test.dart';
import 'package:mzadqatar_car_deals/api/mzadqatar_api.dart';
import 'package:mzadqatar_car_deals/models/car_listing.dart';
import 'package:mzadqatar_car_deals/models/comment.dart';
import 'package:mzadqatar_car_deals/models/category.dart';
import 'package:mzadqatar_car_deals/models/product_details.dart';

void main() {
  group('MzadQatar API Tests', () {
    test('getCategoryData returns valid data structure', () async {
      final result = await MzadQatarApi.getCategoryData();
      
      expect(result, isA<Map<String, dynamic>>());
      expect(result['listings'], isA<List<CarListing>>());
      expect(result['categories'], isA<List<Category>>());
      expect(result['totalCount'], isA<int>());
      expect(result['currentPage'], isA<int>());
      expect(result['totalPages'], isA<int>());
    });

    test('getProductComments returns list of comments', () async {
      final comments = await MzadQatarApi.getProductComments(1);
      
      expect(comments, isA<List<Comment>>());
      expect(comments.length, greaterThan(0));
      
      final firstComment = comments.first;
      expect(firstComment.username, isNotNull);
      expect(firstComment.content, isNotNull);
      expect(firstComment.createdAt, isNotNull);
    });

    test('getProductDetails returns detailed product information', () async {
      final details = await MzadQatarApi.getProductDetails(1);
      
      expect(details, isA<ProductDetails>());
      expect(details.title, isNotNull);
      expect(details.brand, isNotNull);
      expect(details.model, isNotNull);
      expect(details.sellerName, isNotNull);
      expect(details.features, isA<List<String>>());
    });

    test('getRelatedUserAds returns list of car listings', () async {
      final relatedAds = await MzadQatarApi.getRelatedUserAds('user1');
      
      expect(relatedAds, isA<List<CarListing>>());
      expect(relatedAds.length, greaterThan(0));
      
      final firstAd = relatedAds.first;
      expect(firstAd.title, isNotNull);
      expect(firstAd.price, greaterThan(0));
    });

    test('getCategoryData supports pagination', () async {
      final page1 = await MzadQatarApi.getCategoryData(page: 1, limit: 5);
      final page2 = await MzadQatarApi.getCategoryData(page: 2, limit: 5);
      
      expect(page1['currentPage'], equals(1));
      expect(page2['currentPage'], equals(2));
      expect(page1['listings'].length, equals(5));
      expect(page2['listings'].length, equals(5));
    });

    test('category filtering works', () async {
      final allData = await MzadQatarApi.getCategoryData();
      final categories = allData['categories'] as List<Category>;
      
      if (categories.isNotEmpty) {
        final categoryName = categories.first.name;
        final filteredData = await MzadQatarApi.getCategoryData(category: categoryName);
        
        expect(filteredData['listings'], isA<List<CarListing>>());
      }
    });
  });

  group('Model Tests', () {
    test('CarListing fromMap and toMap work correctly', () {
      final map = {
        'id': 1,
        'title': 'Test Car',
        'description': 'Test Description',
        'price': 50000,
        'imageUrl': 'https://example.com/image.jpg',
        'url': 'https://example.com/listing',
        'postedAt': DateTime.now().toIso8601String(),
        'sellerId': 'seller123',
      };

      final listing = CarListing.fromMap(map);
      expect(listing.id, equals(1));
      expect(listing.title, equals('Test Car'));
      expect(listing.sellerId, equals('seller123'));

      final backToMap = listing.toMap();
      expect(backToMap['title'], equals('Test Car'));
      expect(backToMap['sellerId'], equals('seller123'));
    });

    test('Comment fromMap and toMap work correctly', () {
      final map = {
        'id': 1,
        'productId': 123,
        'username': 'testuser',
        'content': 'Great car!',
        'createdAt': DateTime.now().toIso8601String(),
        'rating': 4.5,
      };

      final comment = Comment.fromMap(map);
      expect(comment.username, equals('testuser'));
      expect(comment.rating, equals(4.5));

      final backToMap = comment.toMap();
      expect(backToMap['content'], equals('Great car!'));
    });

    test('Category fromMap and toMap work correctly', () {
      final map = {
        'id': 1,
        'name': 'Toyota',
        'description': 'Toyota vehicles',
        'count': 150,
      };

      final category = Category.fromMap(map);
      expect(category.name, equals('Toyota'));
      expect(category.count, equals(150));

      final backToMap = category.toMap();
      expect(backToMap['name'], equals('Toyota'));
    });
  });
}
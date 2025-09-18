import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/car_listing.dart';

class MzadQatarApi {
  static Future<List<CarListing>> fetchCarListings() async {
    // This is a placeholder endpoint. Replace with the actual API endpoint if available.
    final url = Uri.parse('https://api.npoint.io/4712ebcd2f3f5859c2e3'); // Example JSON endpoint

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => CarListing(
        productId: e['productId']?.toString() ?? e['url']?.toString() ?? '',
        title: e['title'] ?? '',
        description: e['description'] ?? '',
        price: e['price'] is int ? e['price'] : (int.tryParse(e['price']?.toString() ?? '') ?? 0),
        imageUrl: e['imageUrl'],
        url: e['url'],
        postedAt: e['postedAt'] != null ? DateTime.tryParse(e['postedAt'].toString()) ?? DateTime.now() : DateTime.now(),
      )).toList();
    } else {
      throw Exception('Failed to load car listings');
    }
  }
}
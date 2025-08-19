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
}
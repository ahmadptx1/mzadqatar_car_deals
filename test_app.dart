import 'dart:async';
import 'package:mzadqatar_car_deals/api/mzadqatar_client.dart';
import 'package:mzadqatar_car_deals/config.dart';

void main() async {
  print('🧪 Testing MzadQatar Car Deals App Locally');
  print('=' * 50);

  // Create API client
  final client = MzadQatarClient(
    baseUrl: Config.baseUrl,
    token: Config.guestToken,
  );

  try {
    print('🔄 Attempting to sync car listings...');

    // Try to fetch category data
    final listings = await client.fetchCategory(page: 1, perPage: 5);

    print('✅ Sync successful!');
    print('📊 Found ${listings.length} car listings');

    if (listings.isNotEmpty) {
      print('\n🚗 Sample listings:');
      for (var i = 0; i < listings.length && i < 3; i++) {
        final listing = listings[i] as Map<String, dynamic>;
        print('  ${i + 1}. ${listing['title'] ?? 'No title'} - ${listing['price'] ?? 'No price'}');
      }
    }

    // Try to get details of first listing if available
    if (listings.isNotEmpty) {
      final firstListing = listings[0] as Map<String, dynamic>;
      final productId = firstListing['id']?.toString() ?? firstListing['productId']?.toString();

      if (productId != null) {
        print('\n🔍 Fetching details for product ID: $productId');
        final details = await client.fetchProductDetails(productId);
        print('✅ Details fetched successfully');
        print('📋 Title: ${details['title'] ?? 'N/A'}');
        print('💰 Price: ${details['price'] ?? 'N/A'}');
      }
    }

  } catch (e) {
    print('❌ Sync failed: $e');
    print('\n🔧 Troubleshooting:');
    print('  - Check internet connection');
    print('  - API may be blocked by Cloudflare protection');
    print('  - Try using proxy in debug mode');
  } finally {
    client.dispose();
  }

  print('\n' + '=' * 50);
  print('🏁 Test completed');
}
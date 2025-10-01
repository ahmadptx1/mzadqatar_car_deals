import 'dart:async';
import 'package:flutter/material.dart';
import 'services/sync_service.dart';
import 'db/database_helper.dart';
import 'models/car_listing.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('🧪 Testing MzadQatar Car Deals App...');

  try {
    print('📊 Checking database...');
    final db = DatabaseHelper.instance;
    var existingListings = await db.getListings();
    print('📊 Found ${existingListings.length} existing listings');

    if (existingListings.isEmpty) {
      print('🔄 No existing data, attempting to sync from API...');
      final sync = SyncService();

      try {
        await sync.fetchLastMonths(months: 1);
        print('✅ API sync successful!');
      } catch (e) {
        print('❌ API sync failed: $e');
        print('📝 Adding demo data...');

        final demoListings = [
          CarListing(
            productId: 'demo_1',
            title: 'Toyota Camry 2020 - Excellent Condition',
            description: 'Well maintained Toyota Camry with low mileage',
            price: 85000,
            imageUrl: 'https://via.placeholder.com/300x200?text=Toyota+Camry',
            url: 'https://mzadqatar.com/demo1',
            postedAt: DateTime.now().subtract(const Duration(days: 1)),
            dateOfAdvertiseEpoch: DateTime.now().millisecondsSinceEpoch,
            sellerName: 'Demo Seller',
            km: 45000,
            manufactureYear: 2020,
            model: 'Camry',
            cityName: 'Doha',
            recommended: 1,
          ),
          CarListing(
            productId: 'demo_2',
            title: 'Honda Civic 2019 - Single Owner',
            description: 'Honda Civic in perfect condition, single owner',
            price: 75000,
            imageUrl: 'https://via.placeholder.com/300x200?text=Honda+Civic',
            url: 'https://mzadqatar.com/demo2',
            postedAt: DateTime.now().subtract(const Duration(days: 2)),
            dateOfAdvertiseEpoch: DateTime.now().millisecondsSinceEpoch,
            sellerName: 'Demo Seller 2',
            km: 35000,
            manufactureYear: 2019,
            model: 'Civic',
            cityName: 'Doha',
            recommended: 1,
          ),
        ];

        for (final listing in demoListings) {
          await db.insertListing(listing);
          print('✅ Added demo listing: ${listing.title}');
        }
      }
    }

    // Check final state
    existingListings = await db.getListings();
    print('📊 Final database state: ${existingListings.length} listings');

    for (var i = 0; i < existingListings.length && i < 3; i++) {
      final listing = existingListings[i];
      print('   - ${listing.title} (${listing.price} QAR)');
    }

    print('🎉 Test completed successfully!');

  } catch (e, stackTrace) {
    print('💥 Test failed: $e');
    print('Stack trace: $stackTrace');
  }
}
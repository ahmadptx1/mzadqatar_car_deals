import 'package:mzadqatar_car_deals/db/database_helper.dart';
import 'package:mzadqatar_car_deals/models/car_listing.dart';

void main() async {
  print('🧪 Testing Database and Demo Data');
  print('=' * 50);

  final db = DatabaseHelper.instance;

  try {
    // Clear existing data
    print('🗑️ Clearing existing data...');
    await db.clearAllData();

    // Add demo data
    print('📝 Adding demo car listings...');
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
      CarListing(
        productId: 'demo_3',
        title: 'Nissan Altima 2021 - Low Mileage',
        description: '2021 Nissan Altima with very low mileage',
        price: 95000,
        imageUrl: 'https://via.placeholder.com/300x200?text=Nissan+Altima',
        url: 'https://mzadqatar.com/demo3',
        postedAt: DateTime.now().subtract(const Duration(days: 3)),
        dateOfAdvertiseEpoch: DateTime.now().millisecondsSinceEpoch,
        sellerName: 'Demo Seller 3',
        km: 25000,
        manufactureYear: 2021,
        model: 'Altima',
        cityName: 'Doha',
        recommended: 1,
      ),
    ];

    for (final listing in demoListings) {
      await db.insertListing(listing);
      print('✅ Added: ${listing.title}');
    }

    // Verify data was added
    print('\n📊 Verifying data...');
    final listings = await db.getListings();
    print('📈 Total listings in database: ${listings.length}');

    if (listings.isNotEmpty) {
      print('\n🚗 Current listings:');
      for (var i = 0; i < listings.length; i++) {
        print('  ${i + 1}. ${listings[i].title} - QR ${listings[i].price}');
      }

      // Test recommendations
      print('\n🎯 Testing recommendations...');
      final recommended = listings.where((l) => l.recommended == 1).toList();
      print('⭐ Recommended listings: ${recommended.length}');
    }

    print('\n✅ Database test completed successfully!');
    print('🎉 The app should now work with demo data when API is blocked.');

  } catch (e) {
    print('❌ Database test failed: $e');
  }

  print('\n' + '=' * 50);
  print('🏁 Test completed');
}
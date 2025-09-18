import 'package:flutter/material.dart';
import 'screens/listing_screen.dart';
import 'screens/recommended_exact_screen.dart';
import 'services/notification_service.dart';
import 'services/sync_service.dart';
import 'services/recommendation_service.dart';
import 'db/database_helper.dart';
import 'config.dart';
import 'models/car_listing.dart';

final _notifier = NotificationService();
final _sync = SyncService();
final _recommender = RecommendationService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Log proxy configuration for debug builds
  const bool isDebug = bool.fromEnvironment('dart.vm.product') == false;
  if (isDebug) {
    if (Config.useProxyInDebug) {
      print('🔧 DEBUG: Proxy enabled for debug builds - ${Config.proxyHost}:${Config.proxyPort}');
    } else {
      print('🔧 DEBUG: Proxy disabled for debug builds');
    }
  }

  await _notifier.init();
  runApp(const MzadQatarCarDealsApp());
}

class MzadQatarCarDealsApp extends StatelessWidget {
  const MzadQatarCarDealsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MzadQatar Car Deals',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const InitialSyncScreen(),
    );
  }
}

class InitialSyncScreen extends StatefulWidget {
  const InitialSyncScreen({super.key});

  @override
  State<InitialSyncScreen> createState() => _InitialSyncScreenState();
}

class _InitialSyncScreenState extends State<InitialSyncScreen> {
  String _status = 'Initializing...';

  @override
  void initState() {
    super.initState();
    _performInitialSync();
  }

  Future<void> _performInitialSync() async {
    try {
      setState(() => _status = 'Checking database...');

      // Check if we have data already
      final db = DatabaseHelper.instance;
      final existingListings = await db.getListings();

      if (existingListings.isEmpty) {
        setState(() => _status = 'Syncing car listings from MzadQatar...');
        try {
          await _sync.fetchLastMonths(months: 1); // Sync last month for faster initial load
        } catch (e) {
          if (e.toString().contains('Cloudflare') || e.toString().contains('403')) {
            setState(() => _status = 'MzadQatar API is temporarily blocked. Adding demo data...');
            await _addDemoData(db);
          } else {
            rethrow;
          }
        }
      } else {
        setState(() => _status = 'Loading existing data...');
      }

      setState(() => _status = 'Processing recommendations...');
      await _recommender.processLastTwoDays();

      setState(() => _status = 'Starting background sync...');
      _sync.startPeriodicSync(minutes: 5);

      // Navigate to recommended screen
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const RecommendedExactScreen()),
        );
      }
    } catch (e) {
      setState(() => _status = 'Error: $e');
      // Wait a bit then try again or show error
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ListingScreen()),
        );
      }
    }
  }

  Future<void> _addDemoData(DatabaseHelper db) async {
    // Add some demo car listings for testing when API is blocked
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(
              _status,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'This may take a few minutes on first run',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
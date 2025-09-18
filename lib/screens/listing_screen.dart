import 'package:flutter/material.dart';
import '../models/car_listing.dart';
import 'detail_screen.dart';
import 'recommended_exact_screen.dart';
import 'recommended_fuzzy_screen.dart';
import '../utils/analysis.dart';
import '../utils/text.dart';
import '../services/recommendation_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../db/database_helper.dart';
import '../services/sync_service.dart';

class ListingScreen extends StatefulWidget {
  const ListingScreen({super.key});

  @override
  State<ListingScreen> createState() => _ListingScreenState();
}

class _ListingScreenState extends State<ListingScreen> {
  late Future<List<CarListing>> _futureListings;
  final TextEditingController _modelController = TextEditingController();
  final DatabaseHelper _db = DatabaseHelper.instance;
  final SyncService _syncService = SyncService();

  @override
  void initState() {
    super.initState();
    _loadListings();
    // load saved exact model
    SharedPreferences.getInstance().then((prefs) {
      final saved = prefs.getString('exactModel');
      if (saved != null && saved.isNotEmpty) {
        _modelController.text = saved;
      }
    });
  }

  Future<void> _loadListings() async {
    setState(() {
      _futureListings = _db.getListings();
    });
  }

  Future<void> _refreshListings() async {
    await _syncService.quickSyncPageOne();
    await _loadListings();
  }

  @override
  void dispose() {
    _modelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MzadQatar Car Deals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.star),
            tooltip: 'Recommended Deals',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const RecommendedExactScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh listings',
            onPressed: _refreshListings,
          ),
          IconButton(
            icon: const Icon(Icons.check_circle_outline),
            tooltip: 'Recommended (Exact)',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const RecommendedExactScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Recommended (Fuzzy)',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const RecommendedFuzzyScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.analytics),
            tooltip: 'Market analysis',
            onPressed: () async {
                final listings = await _futureListings;
                if (!mounted) return;
                // capture context after await and mounted check
                final localContext = context;
                final stats = analyzeListings(listings);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  showDialog(
                    context: localContext,
                    builder: (_) => AlertDialog(
                      title: const Text('Market Analysis'),
                      content: Text(stats),
                    ),
                  );
                });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _modelController,
                    decoration: const InputDecoration(
                      labelText: 'Exact model (e.g. AT4 X) — press Go',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  child: const Text('Go'),
                    onPressed: () async {
                      final model = _modelController.text.trim();
                      if (model.isEmpty) return;
                      // persist the model
                      final messenger = ScaffoldMessenger.of(context);
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('exactModel', model);
                      final recommender = RecommendationService();
                      await recommender.processLastTwoDays(exactModel: model);
                      messenger.showSnackBar(SnackBar(content: Text('Saved and processed exact model: $model')));
                    },
                ),
                const SizedBox(width: 8),
                TextButton(
                  child: const Text('Clear'),
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('exactModel');
                    _modelController.clear();
                    messenger.showSnackBar(const SnackBar(content: Text('Cleared saved model')));
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<CarListing>>(
              future: _futureListings,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No listings found.'));
                }
                final listings = snapshot.data!;
                return ListView.builder(
                  itemCount: listings.length,
                  itemBuilder: (context, index) {
                    final car = listings[index];
                    return ListTile(
                      leading: (car.imageUrl != null && car.imageUrl!.isNotEmpty)
                          ? Image.network(car.imageUrl!, width: 60, fit: BoxFit.cover)
                          : Container(width: 60, color: Colors.grey),
                      title: Text(decodeUnicodeEscapes(car.title)),
                      subtitle: Text('QAR ${car.price ?? 0} - ${car.cityName ?? ''}'),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(car: car)));
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
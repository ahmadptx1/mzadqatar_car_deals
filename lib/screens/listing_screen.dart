import 'package:flutter/material.dart';
import '../models/car_listing.dart';
import '../api/mzadqatar_api.dart';
import 'detail_screen.dart';
import '../utils/analysis.dart';

class ListingScreen extends StatefulWidget {
  const ListingScreen({super.key});

  @override
  State<ListingScreen> createState() => _ListingScreenState();
}

class _ListingScreenState extends State<ListingScreen> {
  late Future<List<CarListing>> _futureListings;

  @override
  void initState() {
    super.initState();
    _futureListings = MzadQatarApi.fetchCarListings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MzadQatar Car Deals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () async {
              final listings = await _futureListings;
              final stats = analyzeListings(listings);
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Market Analysis'),
                  content: Text(stats),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<CarListing>>(
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
                leading: car.imageUrl.isNotEmpty
                    ? Image.network(car.imageUrl, width: 60, fit: BoxFit.cover)
                    : Container(width: 60, color: Colors.grey),
                title: Text(car.title),
                subtitle: Text('QAR ${car.price}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailScreen(car: car),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
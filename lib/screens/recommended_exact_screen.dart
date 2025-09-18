import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/car_listing.dart';
import 'detail_screen.dart';
import 'listing_screen.dart';
import '../utils/text.dart';

class RecommendedExactScreen extends StatefulWidget {
  const RecommendedExactScreen({super.key});

  @override
  State<RecommendedExactScreen> createState() => _RecommendedExactScreenState();
}

class _RecommendedExactScreenState extends State<RecommendedExactScreen> {
  final db = DatabaseHelper.instance;
  List<CarListing> _list = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final rows = await db.getListingsRaw(where: 'recommended = ? AND badDeal = 0 AND approached = 0', whereArgs: [1]);
    setState(() {
      _list = rows.map((r) => CarListing.fromMap(r)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recommended - Exact'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            tooltip: 'All Listings',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ListingScreen()));
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _list.length,
        itemBuilder: (context, idx) {
          final car = _list[idx];
          return ListTile(
            leading: car.imageUrl != null && car.imageUrl!.isNotEmpty
                ? Image.network(car.imageUrl!, width: 60, fit: BoxFit.cover)
                : Container(width: 60, color: Colors.grey),
            title: Text(decodeUnicodeEscapes(car.title)),
            subtitle: Text('QAR ${car.price}'),
            onTap: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(car: car)));
              await _load();
            },
            trailing: PopupMenuButton<String>(
              onSelected: (v) async {
                if (v == 'bad') await db.markBadDeal(car.productId, 1);
                if (v == 'approached') await db.markApproached(car.productId, 1);
                await _load();
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'bad', child: Text('Mark as Bad Deal')),
                const PopupMenuItem(value: 'approached', child: Text('Mark as Approached')),
              ],
            ),
          );
        },
      ),
    );
  }
}

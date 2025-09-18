import 'package:flutter/material.dart';
import '../models/car_listing.dart';
import '../db/database_helper.dart';
import 'package:flutter/services.dart';
import '../utils/text.dart';

class DetailScreen extends StatelessWidget {
  final CarListing car;

  const DetailScreen({super.key, required this.car});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(decodeUnicodeEscapes(car.title)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            if (car.imageUrl != null && car.imageUrl!.isNotEmpty)
              Image.network(car.imageUrl!, height: 200, fit: BoxFit.cover),
            const SizedBox(height: 16),
            Text(
              decodeUnicodeEscapes(car.title),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'QAR ${car.price}',
              style: const TextStyle(fontSize: 18, color: Colors.blue),
            ),
            const SizedBox(height: 16),
                    Text(decodeUnicodeEscapes(car.description)),
            const SizedBox(height: 16),
            Text('Posted at: ${car.postedAt.toLocal()}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                // Open URL in browser
                // You may want to use url_launcher package for real implementation
                if (car.url != null && car.url!.isNotEmpty) {
                  // capture messenger to avoid using context after async gap
                  final messenger = ScaffoldMessenger.of(context);
                  await Clipboard.setData(ClipboardData(text: car.url!));
                  messenger.showSnackBar(const SnackBar(content: Text('URL copied to clipboard')));
                }
              },
              child: const Text('View Original Listing'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () async {
                    // capture navigator to avoid using context after await
                    final navigator = Navigator.of(context);
                    await DatabaseHelper.instance.markBadDeal(car.productId, 1);
                    navigator.pop();
                  },
                  child: const Text('Mark as Bad Deal'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    await DatabaseHelper.instance.markApproached(car.productId, 1);
                    navigator.pop();
                  },
                  child: const Text('Mark as Approached'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (car.rawJson != null)
              ExpansionTile(
                title: const Text('Raw JSON'),
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    color: Colors.grey.shade100,
                    child: SingleChildScrollView(child: Text(car.rawJson!)),
                  )
                ],
              ),
          ],
        ),
      ),
    );
  }
}
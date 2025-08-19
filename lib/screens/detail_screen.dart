import 'package:flutter/material.dart';
import '../models/car_listing.dart';

class DetailScreen extends StatelessWidget {
  final CarListing car;

  const DetailScreen({super.key, required this.car});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(car.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            if (car.imageUrl.isNotEmpty)
              Image.network(car.imageUrl, height: 200, fit: BoxFit.cover),
            const SizedBox(height: 16),
            Text(
              car.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'QAR ${car.price}',
              style: const TextStyle(fontSize: 18, color: Colors.blue),
            ),
            const SizedBox(height: 16),
            Text(car.description),
            const SizedBox(height: 16),
            Text('Posted at: ${car.postedAt.toLocal()}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Open URL in browser
                // You may want to use url_launcher package for real implementation
              },
              child: const Text('View Original Listing'),
            ),
          ],
        ),
      ),
    );
  }
}
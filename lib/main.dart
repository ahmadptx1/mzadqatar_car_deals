import 'package:flutter/material.dart';
import 'screens/listing_screen.dart';

void main() {
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
      home: const ListingScreen(),
    );
  }
}
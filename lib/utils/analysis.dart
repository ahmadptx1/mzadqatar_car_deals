import '../models/car_listing.dart';

String analyzeListings(List<CarListing> listings) {
  if (listings.isEmpty) return 'No data to analyze.';
  final prices = listings.map((e) => e.price).toList();
  final averagePrice =
      prices.reduce((a, b) => a + b) / prices.length;
  final minPrice = prices.reduce((a, b) => a < b ? a : b);
  final maxPrice = prices.reduce((a, b) => a > b ? a : b);

  return '''
Total Listings: ${listings.length}
Average Price: QAR ${averagePrice.toStringAsFixed(0)}
Lowest Price: QAR $minPrice
Highest Price: QAR $maxPrice
''';
}
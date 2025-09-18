import '../models/car_listing.dart';

String analyzeListings(List<CarListing> listings) {
  if (listings.isEmpty) return 'No data to analyze.';
  final prices = listings.map((e) => e.price).toList();
  final nonNull = prices.where((p) => p != null).map((p) => p!).toList();
  if (nonNull.isEmpty) return 'No numeric price data.';
  final total = nonNull.reduce((a, b) => a + b);
  final averagePrice = total / nonNull.length;
  final minPrice = nonNull.reduce((a, b) => a < b ? a : b);
  final maxPrice = nonNull.reduce((a, b) => a > b ? a : b);

  return '''
Total Listings: ${listings.length}
Average Price: QAR ${averagePrice.toStringAsFixed(0)}
Lowest Price: QAR $minPrice
Highest Price: QAR $maxPrice
''';
}
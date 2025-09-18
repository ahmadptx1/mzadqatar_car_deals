import 'dart:async';
import '../api/mzadqatar_client.dart';
import '../config.dart';
import '../db/database_helper.dart';
import '../models/car_listing.dart';
import 'recommendation_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SyncService {
  final MzadQatarClient client = MzadQatarClient(baseUrl: Config.baseUrl, token: Config.guestToken);
  final DatabaseHelper db = DatabaseHelper.instance;
  final RecommendationService recommender = RecommendationService();

  /// Fetch ads for the last [months] months (default 2) and upsert into DB.
  /// This function pages through results until there are no more or until the
  /// page limit is reached. It's designed for local-only operation.
  Future<void> fetchLastMonths({int months = 2}) async {
    final now = DateTime.now();
    final cutoff = DateTime(now.year, now.month - months, now.day);

    int page = 1;
    const perPage = 50;
    bool keepGoing = true;
    int retryCount = 0;
    const maxRetries = 3;

    while (keepGoing && retryCount < maxRetries) {
      try {
        final products = await client.fetchCategory(page: page, perPage: perPage);
        if (products.isEmpty) break;
        retryCount = 0; // Reset retry count on success

        for (final p in products) {
          try {
            final productId = p['productId']?.toString() ?? '';
            final dateEpoch = int.tryParse(p['dateOfAdvertise']?.toString() ?? '') ?? 0;
            final postedAt = dateEpoch > 0 ? DateTime.fromMillisecondsSinceEpoch(dateEpoch) : DateTime.now();

            if (postedAt.isBefore(cutoff)) {
              keepGoing = false;
              break;
            }

            // Optionally fetch full product details to enrich fields
            Map<String, dynamic>? detail;
            try {
              detail = await client.fetchProductDetails(productId);
            } catch (_) {
              detail = null;
            }

            int? kmVal;
            int? yearVal;
            String? modelVal;
            int? dateEpochVal = dateEpoch;

            if (detail != null) {
              // parse properties array
              final props = detail['properties'];
              if (props is List) {
                for (final item in props) {
                  try {
                    final key = (item['Category'] ?? item['filterValue'] ?? '').toString().toLowerCase();
                    final val = (item['filterValue'] ?? item['filterVal'] ?? item['filterValue'] ?? item['filterValue']).toString();
                    if (key.contains('km') || (item['filterId'] == 'km')) {
                      kmVal = int.tryParse(val.replaceAll(RegExp('[^0-9]'), ''));
                    }
                    if (key.contains('manufacture') || key.contains('manufacture year') || item['filterId'] == 'manfactureYearId') {
                      yearVal = int.tryParse(val.replaceAll(RegExp('[^0-9]'), ''));
                    }
                    if (key.contains('model') || item['filterId'] == 'subsubsubCategoryId') {
                      modelVal = val;
                    }
                  } catch (_) {}
                }
              }

              // product detail may contain raw epoch
              final detEpoch = int.tryParse(detail['dateOfAdvertise']?.toString() ?? '') ?? dateEpoch;
              dateEpochVal = detEpoch;
            }

            final listing = CarListing(
              productId: productId,
              title: p['productName']?.toString() ?? '',
              description: p['productDescription']?.toString() ?? '',
              price: int.tryParse(p['productPrice']?.toString() ?? '') ?? 0,
              imageUrl: p['productMainImage']?.toString(),
              url: p['productUrlWeb']?.toString() ?? p['productUrl']?.toString(),
              postedAt: postedAt,
              dateOfAdvertiseEpoch: dateEpochVal,
              sellerId: p['userId']?.toString(),
              sellerName: p['userName']?.toString(),
              isCompany: p['isCompany'] is int ? p['isCompany'] : int.tryParse(p['isCompany']?.toString() ?? '') ?? 0,
              km: kmVal,
              manufactureYear: yearVal,
              model: modelVal,
              cityName: p['cityName']?.toString(),
              images: p['productImages'] != null ? List<String>.from(p['productImages']) : null,
              rawJson: detail != null ? detail.toString() : (p is Map ? p.toString() : null),
            );

            await db.insertListing(listing);
          } catch (e) {
            // ignore single product errors
          }
        }

        page += 1;
        // safety stop to avoid very long loops
        if (page > 100) break;
      } catch (e) {
        // Handle API errors with retry logic
        retryCount++;
        if (retryCount >= maxRetries) {
          throw Exception('Failed to sync after $maxRetries attempts: $e');
        }
        // Wait before retrying (exponential backoff)
        await Future.delayed(Duration(seconds: retryCount * 2));
        // Don't increment page on retry, try the same page again
      }
    }

    // After fetching up to 2 months, run recommendation processing for last 2 days
    await recommender.processLastTwoDays();
  }

  /// Quick sync: fetch only page 1 and insert new ads (by productId) to minimize traffic.
  Future<void> quickSyncPageOne() async {
  const perPage = 50;
    final products = await client.fetchCategory(page: 1, perPage: perPage);
    if (products.isEmpty) return;

    for (final p in products) {
      final productId = p['productId']?.toString() ?? '';
      if (productId.isEmpty) continue;
      final exists = await db.getListingByProductId(productId);
      if (exists != null) continue; // already known

      // Fetch details and insert similarly to fetchLastMonths flow
      Map<String, dynamic>? detail;
      try {
        detail = await client.fetchProductDetails(productId);
      } catch (_) {
        detail = null;
      }

      final dateEpoch = int.tryParse(p['dateOfAdvertise']?.toString() ?? '') ?? 0;
      final postedAt = dateEpoch > 0 ? DateTime.fromMillisecondsSinceEpoch(dateEpoch) : DateTime.now();

      int? kmVal;
      int? yearVal;
      String? modelVal;
      int? dateEpochVal = dateEpoch;

      if (detail != null) {
        final props = detail['properties'];
        if (props is List) {
          for (final item in props) {
            try {
              final key = (item['Category'] ?? item['filterValue'] ?? '').toString().toLowerCase();
              final val = (item['filterValue'] ?? item['filterVal'] ?? item['filterValue'] ?? item['filterValue']).toString();
              if (key.contains('km') || (item['filterId'] == 'km')) {
                kmVal = int.tryParse(val.replaceAll(RegExp('[^0-9]'), ''));
              }
              if (key.contains('manufacture') || key.contains('manufacture year') || item['filterId'] == 'manfactureYearId') {
                yearVal = int.tryParse(val.replaceAll(RegExp('[^0-9]'), ''));
              }
              if (key.contains('model') || item['filterId'] == 'subsubsubCategoryId') {
                modelVal = val;
              }
            } catch (_) {}
          }
        }
        dateEpochVal = int.tryParse(detail['dateOfAdvertise']?.toString() ?? '') ?? dateEpochVal;
      }

      final listing = CarListing(
        productId: productId,
        title: p['productName']?.toString() ?? '',
        description: p['productDescription']?.toString() ?? '',
        price: int.tryParse(p['productPrice']?.toString() ?? '') ?? 0,
        imageUrl: p['productMainImage']?.toString(),
        url: p['productUrlWeb']?.toString() ?? p['productUrl']?.toString(),
        postedAt: postedAt,
        dateOfAdvertiseEpoch: dateEpochVal,
        sellerId: p['userId']?.toString(),
        sellerName: p['userName']?.toString(),
        isCompany: p['isCompany'] is int ? p['isCompany'] : int.tryParse(p['isCompany']?.toString() ?? '') ?? 0,
        km: kmVal,
        manufactureYear: yearVal,
        model: modelVal,
        cityName: p['cityName']?.toString(),
        images: p['productImages'] != null ? List<String>.from(p['productImages']) : null,
        rawJson: detail != null ? detail.toString() : (p is Map ? p.toString() : null),
      );

      await db.insertListing(listing);
    }

    // After quick sync, process last two days to update recommendations
    try {
      final prefs = await SharedPreferences.getInstance();
      final model = prefs.getString('exactModel');
      if (model != null && model.isNotEmpty) {
        await recommender.processLastTwoDays(exactModel: model);
      } else {
        await recommender.processLastTwoDays();
      }
    } catch (_) {
      await recommender.processLastTwoDays();
    }
  }

  Timer? _timer;

  Timer? _dailyTimer;

  void startPeriodicSync({int minutes = 5}) {
    // Quick sync every [minutes]
    _timer?.cancel();
    _timer = Timer.periodic(Duration(minutes: minutes), (_) async {
      await quickSyncPageOne();
    });

    // Daily full 2-month sync: schedule at next midnight then every 24 hours
    _dailyTimer?.cancel();
    final now = DateTime.now();
    final next = DateTime(now.year, now.month, now.day + 1);
    final initialDelay = next.difference(now);
    Timer(initialDelay, () {
      // run once now at next midnight
      fetchLastMonths(months: 2);
      _dailyTimer = Timer.periodic(const Duration(hours: 24), (_) {
        fetchLastMonths(months: 2);
      });
    });
  }

  void stop() {
    _timer?.cancel();
    _dailyTimer?.cancel();
    client.dispose();
  }
}

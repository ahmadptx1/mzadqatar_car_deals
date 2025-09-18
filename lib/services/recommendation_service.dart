import '../db/database_helper.dart';
import 'notification_service.dart';

final _notifier = NotificationService();

class RecommendationService {
  final DatabaseHelper db = DatabaseHelper.instance;

  /// Process last 2 days of ads and mark recommended ones using rules:
  /// 1) Filter by model if provided in listing properties (kept permissive here)
  /// 2) Exclude sellers with more than 5 ads (showroom)
  /// 3) Prefer earlier posts (lower epoch)
  /// If [exactModel] is provided, only consider ads whose `model` exactly
  /// matches (case-insensitive). If null, use general scoring (fuzzy).
  Future<void> processLastTwoDays({String? exactModel}) async {
  final now = DateTime.now();
  const twoDaysDuration = Duration(days: 2);
  final twoDaysAgo = now.subtract(twoDaysDuration);

    final rows = await db.getListingsRaw(where: 'postedAt >= ?', whereArgs: [twoDaysAgo.toIso8601String()]);
    if (rows.isEmpty) return;

    // Count ads per seller
    final Map<String, int> sellerCounts = {};
    final List<Map<String, dynamic>> parsed = [];
    for (final r in rows) {
      final sellerId = r['sellerId']?.toString() ?? '';
      sellerCounts[sellerId] = (sellerCounts[sellerId] ?? 0) + 1;
      parsed.add(r);
    }

    // Candidate list: filter out showrooms, and apply exact model if provided
    final candidates = parsed.where((r) {
      final sellerId = r['sellerId']?.toString() ?? '';
      if ((sellerCounts[sellerId] ?? 0) > 5) return false; // showroom filter
      if (exactModel != null && exactModel.isNotEmpty) {
        final m = r['model']?.toString() ?? '';
        if (m.toLowerCase() != exactModel.toLowerCase()) return false;
      }
      return true;
    }).toList();

    // Sort by dateOfAdvertiseEpoch ascending (earlier first) if present
    candidates.sort((a, b) {
      final aEpoch = a['dateOfAdvertiseEpoch'] ?? 0;
      final bEpoch = b['dateOfAdvertiseEpoch'] ?? 0;
      return (aEpoch as int).compareTo(bEpoch as int);
    });

    // Score candidates (simple scoring) and pick top ones
    final scored = <Map<String, dynamic>>[];
    for (final c in candidates) {
      final productId = c['productId']?.toString() ?? c['url']?.toString() ?? '';
      if (productId.isEmpty) continue;
      int score = 0;
      // prefer lower km
  final km = c['km'] is int ? c['km'] as int? : int.tryParse(c['km']?.toString() ?? '');
      if (km != null) score += (km < 50000) ? 20 : (km < 100000 ? 10 : 0);
      // prefer newer manufacture year
  final year = c['manufactureYear'] is int ? c['manufactureYear'] as int? : int.tryParse(c['manufactureYear']?.toString() ?? '');
      if (year != null && year >= DateTime.now().year - 3) score += 10;
      // lower price bonus
  final price = c['price'] is int ? c['price'] as int? : (int.tryParse(c['price']?.toString() ?? '') ?? 0);
  final priceVal = price ?? 0;
  if (priceVal > 0 && priceVal < 100000) score += 5;
      // earlier posted (older within window)
  final epoch = c['dateOfAdvertiseEpoch'] ?? 0;
  score += (epoch as int) % 10; // tiny deterministic tie-breaker

      scored.add({'row': c, 'score': score, 'productId': productId, 'price': price});
    }

    scored.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));

  // Pick top N candidates to mark recommended and possibly notify
  final top = scored.take(20).toList();
    for (final s in top) {
      final productId = s['productId'] as String;
      await db.markRecommended(productId, 1);
      // Send notification if not already sent and throttle
      try {
        await _notifier.init();
        await _notifier.showNotification(productId, s['row']['productName']?.toString() ?? 'New Deal', s['row']['productDescription']?.toString() ?? '');
      } catch (_) {
        // ignore notification errors
      }
    }
  }
}

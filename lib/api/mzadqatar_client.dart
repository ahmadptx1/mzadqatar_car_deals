import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'dart:io';
import '../config.dart';

class MzadQatarClient {
  final String baseUrl; // e.g. https://api.mzadqatar.com
  final String token; // Guest-Token or Bearer token header value
  late final http.Client _client;

  MzadQatarClient({required this.baseUrl, required this.token}) {
    _initializeClient();
  }

  void _initializeClient() {
    // Configure proxy for debug builds
    const bool isDebug = bool.fromEnvironment('dart.vm.product') == false;
    if (isDebug && Config.useProxyInDebug) {
      final proxyUrl = '${Config.proxyHost}:${Config.proxyPort}';
      print('🔧 DEBUG: Using proxy server: $proxyUrl');
      final httpClient = HttpClient();
      httpClient.findProxy = (uri) {
        return 'PROXY $proxyUrl';
      };
      // Disable SSL verification for proxy (use with caution in production)
      httpClient.badCertificateCallback = (cert, host, port) => true;
      _client = IOClient(httpClient);
    } else {
      if (isDebug) {
        print('🔧 DEBUG: Proxy disabled, using direct connection');
      }
      // For release builds, configure HTTP client to handle SSL issues
      final httpClient = HttpClient();
      // Allow self-signed certificates for api.mzadqatar.com
      httpClient.badCertificateCallback = (X509Certificate cert, String host, int port) {
        // Only allow for the specific API domain
        return host == 'api.mzadqatar.com' || host.contains('mzadqatar.com');
      };
      _client = IOClient(httpClient);
    }
  }

  Future<Map<String, dynamic>> postJson(String path, Map<String, dynamic> body) async {
    final url = Uri.parse(baseUrl + path);
    final headers = {
      'Content-Type': 'application/json',
      'Guest-Token': token,
      'X-Requested-With': 'XMLHttpRequest',
      'Accept-Language': 'en',
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
      'Accept': 'application/json, text/plain, */*',
      'Accept-Encoding': 'gzip, deflate, br',
      'Connection': 'keep-alive',
    };

    try {
      print('🌐 DEBUG: Making request to ${url.toString()}');
      final resp = await _client.post(url, headers: headers, body: json.encode(body));
      print('📡 DEBUG: Response status: ${resp.statusCode}');

      if (resp.statusCode == 200) {
        return json.decode(resp.body) as Map<String, dynamic>;
      } else if (resp.statusCode == 403) {
        print('🚫 DEBUG: Cloudflare protection detected');
        throw Exception('API access blocked by Cloudflare protection. The service may be temporarily unavailable.');
      } else if (resp.statusCode == 429) {
        print('⏱️ DEBUG: Rate limit exceeded');
        throw Exception('API rate limit exceeded. Please try again later.');
      } else {
        print('❌ DEBUG: API error ${resp.statusCode}: ${resp.body}');
        throw Exception('API ${resp.statusCode}: ${resp.body}');
      }
    } catch (e) {
      print('💥 DEBUG: Network error: $e');
      if (e.toString().contains('Failed host lookup') || e.toString().contains('No address associated with hostname')) {
        throw Exception('Unable to connect to MzadQatar API. Please check your internet connection.');
      } else if (e.toString().contains('Connection timed out')) {
        throw Exception('Connection to MzadQatar API timed out. The service may be temporarily unavailable.');
      }
      rethrow;
    }
  }

  /// Fetch category data (listings) — wrapper for /get-category-data
  Future<List<dynamic>> fetchCategory({int page = 1, int perPage = 50}) async {
    final body = {
      'advertiseResolution': 'large',
      'countOfRow': 2,
      'isAdsSupported': true,
      'numberperpage': perPage,
      'lastupdatetime': 0,
      'page': page,
      'productId': 1,
      'isNewUpdate': 1,
      'searchStr': '',
      'productsLang': 'en',
      'categoryAdvertiseTypeId': '0',
      'userIpAddress': '127.0.0.1',
      'userDeviceModel': 'local',
      'userDeviceLanguage': 'en',
      'SetAdvertiseLanguage': 'en',
      'userDeviceType': 'Local',
      'versionNumber': '1.0',
      'userMacAddress': ''
    };
    final resp = await postJson('/get-category-data', body);
    if (resp.containsKey('products')) return resp['products'] as List<dynamic>;
    return [];
  }

  /// Fetch product details — wrapper for /get-product-details
  Future<Map<String, dynamic>> fetchProductDetails(String productId) async {
    final body = {
      'productId': productId,
      'userIpAddress': '127.0.0.1',
      'userDeviceModel': 'local',
      'userDeviceLanguage': 'en',
      'userDeviceType': 'Local',
      'versionNumber': '1.0',
      'userMacAddress': ''
    };
    return await postJson('/get-product-details', body);
  }

  /// Dispose of the HTTP client
  void dispose() {
    _client.close();
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

void main() async {
  print('Testing MzadQatar API connectivity...');

  final baseUrl = 'https://api.mzadqatar.com';
  final token = 'Bearer Guest/User/Token/6SP4ZCaQdXwr0XPoB7hrhNysc2Y4yXwI4fA2sbENioAFuGE0FDfKRkuR7bcDQztmEKmxGkBM41Sht6zQLkNTlYeKUyBHfv7nun5BHmwQ87kYr69UfHL/Guest/User/Token';

  final url = Uri.parse('$baseUrl/get-category-data');
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

  final body = {
    'advertiseResolution': 'large',
    'countOfRow': 2,
    'isAdsSupported': true,
    'numberperpage': 10,
    'lastupdatetime': 0,
    'page': 1,
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

  try {
    print('Making request to: $url');
    print('Headers: $headers');
    print('Body: ${json.encode(body)}');

    final response = await http.post(url, headers: headers, body: json.encode(body));

    print('Response status: ${response.statusCode}');
    print('Response headers: ${response.headers}');
    print('Response body length: ${response.body.length}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Success! Response data:');
      print(data);
    } else {
      print('Error response: ${response.body}');
    }
  } catch (e) {
    print('Exception: $e');
  }
}
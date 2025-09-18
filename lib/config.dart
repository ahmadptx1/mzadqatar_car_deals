class Config {
  // Base API URL discovered from example files
  static const String baseUrl = 'https://api.mzadqatar.com';

  // Token provided by user (Guest-Token)
  static const String guestToken = 'Bearer Guest/User/Token/6SP4ZCaQdXwr0XPoB7hrhNysc2Y4yXwI4fA2sbENioAFuGE0FDfKRkuR7bcDQztmEKmxGkBM41Sht6zQLkNTlYeKUyBHfv7nun5BHmwQ87kYr69UfHL/Guest/User/Token';

  // Proxy configuration for debug builds
  static const bool useProxyInDebug = true;
  static const String proxyHost = '10.161.101.15';
  static const String proxyPort = '8080';
}

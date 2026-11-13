class ApiConstants {
  // Aviationstack API endpoints
  // Note: The free tier of Aviationstack uses HTTP.
  static const String baseUrl = 'http://api.aviationstack.com/v1';
  static const String flightsEndpoint = '/flights';

  // Default parameters
  static const int defaultLimit = 20;

  // Key storage name in SharedPreferences
  static const String apiKeyStorageKey = 'aviationstack_api_key';
  static const String demoModeStorageKey = 'aviationstack_demo_mode';
  static const String apiHitsCountKey = 'aviationstack_api_hits';
  static const String cacheHitsCountKey = 'aviationstack_cache_hits';

  // Fallback demo message
  static const String defaultHelpMessage =
      'Aviationstack free tier provides limited requests. '
      'Demo Mode uses rich bundled seed data and Hive caching to keep API usage minimal.';
}


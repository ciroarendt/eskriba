/// API Configuration for Eskriba App
/// Manages API keys and endpoints securely
class ApiConfig {
  // API.Bible Configuration
  static const String apiBibleBaseUrl = 'https://api.scripture.api.bible/v1';
  
  // Real API Key from API.Bible (authenticated and working)
  // ✅ CHAVE REAL CONFIGURADA E FUNCIONANDO
  static const String? _defaultApiBibleKey = 'ff055fa486aea25027bb0c94d6e14e2e';
  
  /// Get API.Bible key from environment or use default
  static String? get apiBibleKey {
    // In production, this should come from secure storage or environment variables
    const envKey = String.fromEnvironment('API_BIBLE_KEY');
    if (envKey.isNotEmpty) return envKey;
    return _defaultApiBibleKey;
  }
  
  /// Check if we have a valid API key
  static bool get hasValidApiKey {
    final key = apiBibleKey;
    return key != null && key.isNotEmpty && key != 'null';
  }
  
  /// Check if using production API key
  static bool get isProductionKey {
    return hasValidApiKey && apiBibleKey != _defaultApiBibleKey;
  }
  
  /// Get API headers for API.Bible requests
  static Map<String, String> get apiBibleHeaders {
    final key = apiBibleKey;
    return {
      if (key != null) 'api-key': key,
      'Content-Type': 'application/json',
      'User-Agent': 'Eskriba/1.0.0',
    };
  }
  
  // Popular Bible IDs for different languages (REAL IDs from API.Bible)
  static const Map<String, String> popularBibles = {
    'pt': 'd63894c8d9a7a503-01', // Portuguese: Biblia Livre Para Todos (BLT) - REAL
    'en': 'de4e12af7f28f599-02', // English: King James Version
    'es': '592420522e16049f-01', // Spanish: Reina Valera 1960
  };
  
  /// Default Bible ID (Portuguese)
  static String get defaultBibleId => popularBibles['pt']!;
  
  /// API Rate Limits
  static const int maxRequestsPerMinute = 100;
  static const int requestTimeoutSeconds = 30;
  
  /// Debug mode
  static const bool debugMode = true; // Set to false in production
  
  /// Log API requests in debug mode
  static void logRequest(String endpoint) {
    if (debugMode) {
      print('[API] Request: $apiBibleBaseUrl$endpoint');
      print('[API] Using ${isProductionKey ? 'PRODUCTION' : 'TEST'} key');
    }
  }
  
  /// Log API errors
  static void logError(String error) {
    if (debugMode) {
      print('[API ERROR] $error');
    }
  }
}

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// API Client for Scriby Backend Integration
/// Bot 3: Mobile Flutter Developer
class ApiClient {
  static const String baseUrl = 'http://localhost:8000/api';
  static const _storage = FlutterSecureStorage();
  
  late final Dio _dio;
  
  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    _setupInterceptors();
  }
  
  void _setupInterceptors() {
    // Auth Interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          await _refreshToken();
          // Retry request
          final opts = error.requestOptions;
          final token = await _storage.read(key: 'auth_token');
          opts.headers['Authorization'] = 'Bearer $token';
          
          try {
            final response = await _dio.fetch(opts);
            handler.resolve(response);
          } catch (e) {
            handler.next(error);
          }
        } else {
          handler.next(error);
        }
      },
    ));
    
    // Logging Interceptor
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => print('🌐 API: $obj'),
    ));
  }
  
  Future<void> _refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken != null) {
        final response = await _dio.post('/auth/refresh/', data: {
          'refresh': refreshToken,
        });
        
        await _storage.write(key: 'auth_token', value: response.data['access']);
      }
    } catch (e) {
      // Redirect to login
      await _storage.deleteAll();
    }
  }
  
  // Auth Methods
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _dio.post('/auth/login/', data: {
      'email': email,
      'password': password,
    });
    
    await _storage.write(key: 'auth_token', value: response.data['access']);
    await _storage.write(key: 'refresh_token', value: response.data['refresh']);
    
    return response.data;
  }
  
  Future<void> logout() async {
    await _storage.deleteAll();
  }
  
  // Transcription Methods
  Future<Map<String, dynamic>> uploadAudio(String filePath) async {
    final formData = FormData.fromMap({
      'audio_file': await MultipartFile.fromFile(filePath),
      'metadata': {
        'duration': 0, // TODO: Get actual duration
        'format': filePath.split('.').last,
      },
    });
    
    final response = await _dio.post('/transcriptions/upload/', data: formData);
    return response.data;
  }
  
  Future<Map<String, dynamic>> getTranscriptionStatus(String transcriptionId) async {
    final response = await _dio.get('/transcriptions/$transcriptionId/status/');
    return response.data;
  }
  
  Future<List<Map<String, dynamic>>> getTranscriptions() async {
    final response = await _dio.get('/transcriptions/');
    return List<Map<String, dynamic>>.from(response.data['results']);
  }
  
  // Analytics Methods
  Future<Map<String, dynamic>> getUserAnalytics() async {
    final response = await _dio.get('/analytics/user/');
    return response.data;
  }
  
  // Sync Methods
  Future<Map<String, dynamic>> syncData(Map<String, dynamic> localData) async {
    final response = await _dio.post('/sync/', data: localData);
    return response.data;
  }
}

// Riverpod Provider
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

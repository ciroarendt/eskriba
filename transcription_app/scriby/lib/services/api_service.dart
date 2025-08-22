import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Use production backend URL (temporarily using DigitalOcean URL while DNS propagates)
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://eskriba-ce5xq.ondigitalocean.app/api',
  );
  static const String fallbackUrl = 'https://api.eskriba.app/api';
  String? _authToken;
  String _currentBaseUrl = baseUrl;
  
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
    
    // Test connectivity and set appropriate base URL
    await _testConnectivity();
  }
  
  Future<void> _testConnectivity() async {
    try {
      // Try primary URL first
      final response = await http.get(
        Uri.parse('$baseUrl/health/'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        _currentBaseUrl = baseUrl;
        return;
      }
    } catch (e) {
      print('Primary URL failed: $e');
    }
    
    try {
      // Try fallback URL
      final response = await http.get(
        Uri.parse('$fallbackUrl/health/'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        _currentBaseUrl = fallbackUrl;
        print('Using fallback URL: $fallbackUrl');
        return;
      }
    } catch (e) {
      print('Fallback URL failed: $e');
    }
    
    // Default to primary URL if both fail
    _currentBaseUrl = baseUrl;
    print('Both URLs failed, using primary: $baseUrl');
  }
  
  Future<Map<String, dynamic>> uploadAndTranscribe(String audioFilePath) async {
    try {
      final uri = Uri.parse('$_currentBaseUrl/recordings/');
      final request = http.MultipartRequest('POST', uri);
      
      // Add auth header
      if (_authToken != null) {
        request.headers['Authorization'] = 'Bearer $_authToken';
      }
      
      // Add audio file and metadata
      request.files.add(await http.MultipartFile.fromPath('audio_file', audioFilePath));
      request.fields['title'] = 'Recording ${DateTime.now().toIso8601String()}';
      request.fields['transcription_service'] = 'openai_whisper'; // Use OpenAI Whisper
      request.fields['ai_analysis'] = 'true'; // Enable AI analysis
      
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      
      if (response.statusCode == 201) {
        final data = json.decode(responseData);
        
        // Poll for transcription completion
        return await _pollForTranscription(data['id']);
      } else if (response.statusCode == 401) {
        throw Exception('Authentication required. Please login.');
      } else {
        final errorData = json.decode(responseData);
        throw Exception('Upload failed: ${errorData['detail'] ?? responseData}');
      }
    } catch (e) {
      if (e is SocketException) {
        throw Exception('Network error. Please check your internet connection.');
      }
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>> _pollForTranscription(int recordingId) async {
    const maxAttempts = 30;
    const pollInterval = Duration(seconds: 2);
    
    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      final response = await http.get(
        Uri.parse('$_currentBaseUrl/recordings/$recordingId/transcription/'),
        headers: _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 202) {
        // Still processing, wait and retry
        await Future.delayed(pollInterval);
        continue;
      } else {
        throw Exception('Transcription failed');
      }
    }
    
    throw Exception('Transcription timeout');
  }
  
  Future<List<Map<String, dynamic>>> getRecordings() async {
    final response = await http.get(
      Uri.parse('$_currentBaseUrl/recordings/'),
      headers: _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['results']);
    } else {
      throw Exception('Failed to fetch recordings');
    }
  }
  
  Future<Map<String, dynamic>> getAnalysis(int transcriptionId) async {
    final response = await http.get(
      Uri.parse('$_currentBaseUrl/transcriptions/$transcriptionId/analysis/'),
      headers: _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch analysis');
    }
  }
  
  Map<String, String> _getHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    
    return headers;
  }
  
  Future<void> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_currentBaseUrl/auth/login/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _authToken = data['access_token'];
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _authToken!);
    } else {
      throw Exception('Login failed');
    }
  }
  
  Future<void> logout() async {
    _authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
}
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://api.eskriba.app/api';
  static String? _authToken;
  
  // Set authentication token
  static void setAuthToken(String token) {
    _authToken = token;
  }
  
  // Get auth headers
  static Map<String, String> get _authHeaders => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    if (_authToken != null) 'Authorization': 'Token $_authToken',
  };
  
  // Register user
  static Future<Map<String, dynamic>?> register(String username, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register/'),
        headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );
      
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['token'] != null) {
          setAuthToken(data['token']);
        }
        return data;
      }
      return null;
    } catch (e) {
      print('Register error: $e');
      return null;
    }
  }
  
  // Login user
  static Future<Map<String, dynamic>?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login/'),
        headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['token'] != null) {
          setAuthToken(data['token']);
        }
        return data;
      }
      return null;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }
  
  // Test backend connectivity
  static Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/recordings/'),
        headers: _authHeaders,
      );
      print('Connection test response: ${response.statusCode}');
      return response.statusCode == 200 || response.statusCode == 401; // 401 means server is up but needs auth
    } catch (e) {
      print('Connection test error: $e');
      return false;
    }
  }
  
  // Get all recordings
  static Future<List<dynamic>> getRecordings() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/recordings/'),
        headers: _authHeaders,
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load recordings: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting recordings: $e');
      rethrow;
    }
  }
  
  // Upload recording
  static Future<Map<String, dynamic>?> uploadRecording(File audioFile, String title) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/recordings/upload/'),
      );
      
      request.headers.addAll(_authHeaders);
      request.fields['title'] = title;
      request.files.add(await http.MultipartFile.fromPath('audio_file', audioFile.path));
      
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      
      if (response.statusCode == 201) {
        return json.decode(responseBody);
      } else {
        throw Exception('Failed to upload recording: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading recording: $e');
      rethrow;
    }
  }
  
  // Start transcription
  static Future<Map<String, dynamic>> transcribeRecording(String recordingId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/recordings/$recordingId/transcribe/'),
        headers: _authHeaders,
      );
      
      if (response.statusCode == 202) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to start transcription: ${response.statusCode}');
      }
    } catch (e) {
      print('Error starting transcription: $e');
      rethrow;
    }
  }
  
  // Get transcriptions
  static Future<List<dynamic>> getTranscriptions() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/transcriptions/'),
        headers: _authHeaders,
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load transcriptions: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting transcriptions: $e');
      rethrow;
    }
  }
}

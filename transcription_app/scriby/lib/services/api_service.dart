import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api';
  String? _authToken;
  
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
  }
  
  Future<Map<String, dynamic>> uploadAndTranscribe(String audioFilePath) async {
    final uri = Uri.parse('$baseUrl/recordings/');
    final request = http.MultipartRequest('POST', uri);
    
    // Add auth header
    if (_authToken != null) {
      request.headers['Authorization'] = 'Bearer $_authToken';
    }
    
    // Add audio file
    request.files.add(await http.MultipartFile.fromPath('audio_file', audioFilePath));
    request.fields['title'] = 'Recording ${DateTime.now().toIso8601String()}';
    
    final response = await request.send();
    final responseData = await response.stream.bytesToString();
    
    if (response.statusCode == 201) {
      final data = json.decode(responseData);
      
      // Poll for transcription completion
      return await _pollForTranscription(data['id']);
    } else {
      throw Exception('Upload failed: $responseData');
    }
  }
  
  Future<Map<String, dynamic>> _pollForTranscription(int recordingId) async {
    const maxAttempts = 30;
    const pollInterval = Duration(seconds: 2);
    
    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      final response = await http.get(
        Uri.parse('$baseUrl/recordings/$recordingId/transcription/'),
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
      Uri.parse('$baseUrl/recordings/'),
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
      Uri.parse('$baseUrl/transcriptions/$transcriptionId/analysis/'),
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
      Uri.parse('$baseUrl/auth/login/'),
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
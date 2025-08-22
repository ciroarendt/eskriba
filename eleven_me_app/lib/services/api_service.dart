import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://api.eskriba.app/api';
  
  // Test backend connectivity
  static Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/recordings/'),
        headers: {'Accept': 'application/json'},
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }
  
  // Get all recordings
  static Future<List<dynamic>> getRecordings() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/recordings/'),
        headers: {'Accept': 'application/json'},
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
  
  // Upload audio file
  static Future<Map<String, dynamic>> uploadRecording(File audioFile, String title) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/recordings/upload/'),
      );
      
      request.fields['title'] = title;
      request.files.add(
        await http.MultipartFile.fromPath('audio_file', audioFile.path),
      );
      
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(responseBody);
      } else {
        throw Exception('Upload failed: ${response.statusCode} - $responseBody');
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
        headers: {'Accept': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Transcription failed: ${response.statusCode}');
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
        headers: {'Accept': 'application/json'},
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

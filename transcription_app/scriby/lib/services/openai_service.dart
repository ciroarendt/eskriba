import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIService {
  static const String _baseUrl = 'https://api.openai.com/v1';
  static const String _apiKey = String.fromEnvironment('OPENAI_API_KEY');
  
  // Whisper transcription (cost-optimized: $0.006/minute)
  Future<Map<String, dynamic>> transcribeAudio(String audioFilePath) async {
    try {
      final uri = Uri.parse('$_baseUrl/audio/transcriptions');
      final request = http.MultipartRequest('POST', uri);
      
      // Add headers
      request.headers['Authorization'] = 'Bearer $_apiKey';
      
      // Add audio file
      request.files.add(await http.MultipartFile.fromPath('file', audioFilePath));
      request.fields['model'] = 'whisper-1';
      request.fields['response_format'] = 'verbose_json';
      request.fields['timestamp_granularities[]'] = 'segment';
      
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        return json.decode(responseData);
      } else {
        throw Exception('Transcription failed: $responseData');
      }
    } catch (e) {
      if (e is SocketException) {
        throw Exception('Network error during transcription');
      }
      rethrow;
    }
  }
  
  // GPT-4o Mini for basic analysis (cost-optimized)
  Future<Map<String, dynamic>> analyzeTranscription(String transcriptionText) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'model': 'gpt-4o-mini',
          'messages': [
            {
              'role': 'system',
              'content': '''You are an AI assistant specialized in analyzing transcriptions from meetings, lectures, and conversations. 
              
Provide a structured analysis with:
1. **Summary**: Brief overview (2-3 sentences)
2. **Main Topics**: Key themes discussed
3. **Action Items**: Specific tasks or follow-ups mentioned
4. **Key Insights**: Important points or decisions
5. **Participants**: Speakers identified (if multiple voices)

Format your response as JSON with these exact keys: summary, main_topics, action_items, key_insights, participants.'''
            },
            {
              'role': 'user',
              'content': 'Please analyze this transcription:\n\n$transcriptionText'
            }
          ],
          'max_tokens': 1000,
          'temperature': 0.3,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['choices'][0]['message']['content'];
        
        try {
          // Try to parse as JSON
          return json.decode(content);
        } catch (e) {
          // If not valid JSON, return as text
          return {'analysis': content};
        }
      } else {
        throw Exception('Analysis failed: ${response.body}');
      }
    } catch (e) {
      if (e is SocketException) {
        throw Exception('Network error during analysis');
      }
      rethrow;
    }
  }
  
  // Generate meeting minutes
  Future<String> generateMeetingMinutes(String transcriptionText) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'model': 'gpt-4o-mini',
          'messages': [
            {
              'role': 'system',
              'content': '''You are an expert at creating professional meeting minutes. 
              
Create structured meeting minutes with:
- **Date & Time**: Meeting details
- **Attendees**: Participants identified
- **Agenda Items**: Topics discussed
- **Decisions Made**: Key outcomes
- **Action Items**: Tasks assigned with owners
- **Next Steps**: Follow-up actions

Format as clean, professional meeting minutes.'''
            },
            {
              'role': 'user',
              'content': 'Create meeting minutes from this transcription:\n\n$transcriptionText'
            }
          ],
          'max_tokens': 1500,
          'temperature': 0.2,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('Meeting minutes generation failed: ${response.body}');
      }
    } catch (e) {
      if (e is SocketException) {
        throw Exception('Network error during meeting minutes generation');
      }
      rethrow;
    }
  }
  
  // Check if API key is configured
  static bool get isConfigured => _apiKey.isNotEmpty;
}

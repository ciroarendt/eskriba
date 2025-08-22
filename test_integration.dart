import 'dart:convert';
import 'dart:io';

void main() async {
  print('Testing Eskriba Backend Integration...\n');
  
  final client = HttpClient();
  
  // Test 1: Backend connectivity
  try {
    final request = await client.getUrl(Uri.parse('https://api.eskriba.app/api/recordings/'));
    request.headers.set('Accept', 'application/json');
    final response = await request.close();
    
    if (response.statusCode == 200) {
      final responseBody = await response.transform(utf8.decoder).join();
      final recordings = json.decode(responseBody) as List;
      print('✅ Backend connectivity: SUCCESS');
      print('   Found ${recordings.length} recordings');
      
      if (recordings.isNotEmpty) {
        print('   Sample recording: ${recordings.first['title']}');
      }
    } else {
      print('❌ Backend connectivity: FAILED (${response.statusCode})');
    }
  } catch (e) {
    print('❌ Backend connectivity: ERROR - $e');
  }
  
  print('');
  
  // Test 2: Transcriptions endpoint
  try {
    final request2 = await client.getUrl(Uri.parse('https://api.eskriba.app/api/transcriptions/'));
    request2.headers.set('Accept', 'application/json');
    final response2 = await request2.close();
    
    if (response2.statusCode == 200) {
      final responseBody2 = await response2.transform(utf8.decoder).join();
      final transcriptions = json.decode(responseBody2) as List;
      print('✅ Transcriptions endpoint: SUCCESS');
      print('   Found ${transcriptions.length} transcriptions');
    } else {
      print('❌ Transcriptions endpoint: FAILED (${response2.statusCode})');
    }
  } catch (e) {
    print('❌ Transcriptions endpoint: ERROR - $e');
  }
  
  client.close();
  print('\n🎉 Integration test completed!');
}

#!/usr/bin/env python3
"""
Mobile Bot - Automated Flutter Development
Develops and maintains the Scriby mobile app using Flutter
"""

import os
import subprocess
import time
from pathlib import Path
import argparse
import sys

# Add scripts directory to path for bot_logger import
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from bot_logger import create_bot_logger
from pathlib import Path
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger('MobileBot')

class MobileBot:
    def __init__(self, project_path: str):
        self.project_path = Path(project_path)
        self.mobile_path = self.project_path / 'scriby'
        
    def implement_audio_recording(self):
        """Implement audio recording functionality"""
        logger.info("🔧 Implementing audio recording...")
        
        # Audio recording service
        audio_service = '''import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class AudioRecordingService {
  FlutterSoundRecorder? _recorder;
  FlutterSoundPlayer? _player;
  bool _isRecording = false;
  String? _currentRecordingPath;
  
  Future<void> initialize() async {
    _recorder = FlutterSoundRecorder();
    _player = FlutterSoundPlayer();
    
    await _recorder!.openRecorder();
    await _player!.openPlayer();
    
    // Request permissions
    await Permission.microphone.request();
    await Permission.storage.request();
  }
  
  Future<String?> startRecording() async {
    if (_isRecording) return null;
    
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'recording_${DateTime.now().millisecondsSinceEpoch}.aac';
      _currentRecordingPath = '${directory.path}/$fileName';
      
      await _recorder!.startRecorder(
        toFile: _currentRecordingPath,
        codec: Codec.aacADTS,
      );
      
      _isRecording = true;
      return _currentRecordingPath;
    } catch (e) {
      print('Error starting recording: $e');
      return null;
    }
  }
  
  Future<String?> stopRecording() async {
    if (!_isRecording) return null;
    
    try {
      await _recorder!.stopRecorder();
      _isRecording = false;
      return _currentRecordingPath;
    } catch (e) {
      print('Error stopping recording: $e');
      return null;
    }
  }
  
  Future<void> playRecording(String filePath) async {
    try {
      await _player!.startPlayer(fromURI: filePath);
    } catch (e) {
      print('Error playing recording: $e');
    }
  }
  
  bool get isRecording => _isRecording;
  
  void dispose() {
    _recorder?.closeRecorder();
    _player?.closePlayer();
  }
}'''
        
        # Recording screen
        recording_screen = '''import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/audio_recording_service.dart';
import '../services/api_service.dart';

class RecordingScreen extends StatefulWidget {
  @override
  _RecordingScreenState createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> with TickerProviderStateMixin {
  final AudioRecordingService _audioService = AudioRecordingService();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  bool _isRecording = false;
  bool _isProcessing = false;
  String? _recordingPath;
  Duration _recordingDuration = Duration.zero;
  
  @override
  void initState() {
    super.initState();
    _audioService.initialize();
    
    _pulseController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut)
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Record Audio'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple[100]!, Colors.white],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Recording duration
              if (_isRecording)
                Text(
                  _formatDuration(_recordingDuration),
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              
              SizedBox(height: 40),
              
              // Recording button
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _isRecording ? _pulseAnimation.value : 1.0,
                    child: GestureDetector(
                      onTap: _toggleRecording,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isRecording ? Colors.red : Colors.deepPurple,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Icon(
                          _isRecording ? Icons.stop : Icons.mic,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              SizedBox(height: 40),
              
              Text(
                _isRecording ? 'Recording...' : 'Tap to start recording',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
              
              if (_recordingPath != null && !_isRecording) ...[
                SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _uploadAndTranscribe,
                  icon: _isProcessing 
                    ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Icon(Icons.upload),
                  label: Text(_isProcessing ? 'Processing...' : 'Upload & Transcribe'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  void _toggleRecording() async {
    if (_isRecording) {
      final path = await _audioService.stopRecording();
      setState(() {
        _isRecording = false;
        _recordingPath = path;
      });
      _pulseController.stop();
    } else {
      final path = await _audioService.startRecording();
      if (path != null) {
        setState(() {
          _isRecording = true;
          _recordingPath = path;
        });
        _pulseController.repeat(reverse: true);
        _startTimer();
      }
    }
  }
  
  void _startTimer() {
    // Timer implementation for recording duration
  }
  
  void _uploadAndTranscribe() async {
    if (_recordingPath == null) return;
    
    setState(() => _isProcessing = true);
    
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final result = await apiService.uploadAndTranscribe(_recordingPath!);
      
      // Navigate to results screen
      Navigator.pushNamed(context, '/transcription-results', arguments: result);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }
  
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
  
  @override
  void dispose() {
    _audioService.dispose();
    _pulseController.dispose();
    super.dispose();
  }
}'''
        
        # Create directories and files
        services_dir = self.mobile_path / 'lib/services'
        screens_dir = self.mobile_path / 'lib/screens'
        services_dir.mkdir(parents=True, exist_ok=True)
        screens_dir.mkdir(parents=True, exist_ok=True)
        
        with open(services_dir / 'audio_recording_service.dart', 'w') as f:
            f.write(audio_service)
            
        with open(screens_dir / 'recording_screen.dart', 'w') as f:
            f.write(recording_screen)
            
        logger.info("✅ Audio recording functionality implemented")
        
    def setup_api_client(self):
        """Setup API client for backend integration"""
        logger.info("🔧 Setting up API client...")
        
        api_service = '''import 'dart:io';
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
}'''
        
        with open(self.mobile_path / 'lib/services/api_service.dart', 'w') as f:
            f.write(api_service)
            
        logger.info("✅ API client setup completed")
        
    def create_transcription_ui(self):
        """Create transcription results UI"""
        logger.info("🔧 Creating transcription UI...")
        
        transcription_results = '''import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TranscriptionResultsScreen extends StatefulWidget {
  final Map<String, dynamic> transcriptionData;
  
  const TranscriptionResultsScreen({Key? key, required this.transcriptionData}) : super(key: key);
  
  @override
  _TranscriptionResultsScreenState createState() => _TranscriptionResultsScreenState();
}

class _TranscriptionResultsScreenState extends State<TranscriptionResultsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transcription Results'),
        backgroundColor: Colors.deepPurple,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.text_fields), text: 'Text'),
            Tab(icon: Icon(Icons.summarize), text: 'Summary'),
            Tab(icon: Icon(Icons.topic), text: 'Topics'),
            Tab(icon: Icon(Icons.task_alt), text: 'Actions'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: _shareResults,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTranscriptionTab(),
          _buildSummaryTab(),
          _buildTopicsTab(),
          _buildActionItemsTab(),
        ],
      ),
    );
  }
  
  Widget _buildTranscriptionTab() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Full Transcription',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(Icons.copy),
                onPressed: () => _copyToClipboard(widget.transcriptionData['text']),
              ),
            ],
          ),
          SizedBox(height: 16),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: SingleChildScrollView(
                child: Text(
                  widget.transcriptionData['text'] ?? 'No transcription available',
                  style: TextStyle(fontSize: 16, height: 1.5),
                ),
              ),
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
              SizedBox(width: 8),
              Text(
                'Processed in ${widget.transcriptionData['processing_time'] ?? 'N/A'}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              Spacer(),
              Icon(Icons.verified, size: 16, color: Colors.green),
              SizedBox(width: 8),
              Text(
                'Confidence: ${((widget.transcriptionData['confidence_score'] ?? 0) * 100).toInt()}%',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildSummaryTab() {
    final analysis = widget.transcriptionData['analysis'];
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'AI Summary',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(Icons.copy),
                onPressed: () => _copyToClipboard(analysis?['summary']),
              ),
            ],
          ),
          SizedBox(height: 16),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[50]!, Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: SingleChildScrollView(
                child: Text(
                  analysis?['summary'] ?? 'Summary not available',
                  style: TextStyle(fontSize: 16, height: 1.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTopicsTab() {
    final analysis = widget.transcriptionData['analysis'];
    final topics = analysis?['key_topics'] as List<dynamic>? ?? [];
    
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Key Topics',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Expanded(
            child: topics.isEmpty
                ? Center(child: Text('No topics identified'))
                : ListView.builder(
                    itemCount: topics.length,
                    itemBuilder: (context, index) {
                      final topic = topics[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.deepPurple,
                            child: Text('${index + 1}'),
                          ),
                          title: Text(topic.toString()),
                          trailing: Icon(Icons.topic, color: Colors.deepPurple),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionItemsTab() {
    final analysis = widget.transcriptionData['analysis'];
    final actionItems = analysis?['action_items'] as List<dynamic>? ?? [];
    
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Action Items',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Expanded(
            child: actionItems.isEmpty
                ? Center(child: Text('No action items identified'))
                : ListView.builder(
                    itemCount: actionItems.length,
                    itemBuilder: (context, index) {
                      final item = actionItems[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Icon(Icons.task_alt, color: Colors.orange),
                          title: Text(item.toString()),
                          trailing: IconButton(
                            icon: Icon(Icons.check_circle_outline),
                            onPressed: () {
                              // Mark as completed
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
  
  void _copyToClipboard(String? text) {
    if (text != null) {
      Clipboard.setData(ClipboardData(text: text));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Copied to clipboard')),
      );
    }
  }
  
  void _shareResults() {
    // Implement sharing functionality
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}'''
        
        with open(self.mobile_path / 'lib/screens/transcription_results_screen.dart', 'w') as f:
            f.write(transcription_results)
            
        logger.info("✅ Transcription UI created")
        
    def update_pubspec(self):
        """Update pubspec.yaml with required dependencies"""
        logger.info("🔧 Updating pubspec.yaml...")
        
        pubspec_additions = '''
  # Audio recording
  flutter_sound: ^9.2.13
  permission_handler: ^11.0.1
  path_provider: ^2.1.1
  
  # HTTP and API
  http: ^1.1.0
  shared_preferences: ^2.2.2
  
  # State management
  provider: ^6.1.1
  
  # UI enhancements
  animations: ^2.0.11
'''
        
        pubspec_path = self.mobile_path / 'pubspec.yaml'
        if pubspec_path.exists():
            with open(pubspec_path, 'r') as f:
                content = f.read()
            
            # Add dependencies after the existing dependencies
            if 'dependencies:' in content:
                content = content.replace('dependencies:', f'dependencies:{pubspec_additions}')
                
                with open(pubspec_path, 'w') as f:
                    f.write(content)
                    
        logger.info("✅ pubspec.yaml updated")

def main():
    parser = argparse.ArgumentParser(description='Mobile Bot - Flutter Development')
    parser.add_argument('--continuous', action='store_true', help='Run in continuous mode')
    args = parser.parse_args()
    
    bot = MobileBot("/Users/ciroarendt/CURSOR/APP_11me/transcription_app")
    
    print("🤖 Mobile Bot - Starting Flutter Development")
    print("=" * 50)
    
    if args.continuous:
        print("🔄 Running in CONTINUOUS mode...")
        cycle = 0
        while True:
            try:
                cycle += 1
                print(f"\n🔄 Continuous cycle #{cycle}")
                
                # Run development tasks
                bot.implement_audio_recording()
                bot.setup_api_client()
                bot.create_transcription_ui()
                bot.update_pubspec()
                
                print(f"✅ Cycle #{cycle} completed")
                time.sleep(30)  # Wait 30 seconds between cycles
                
            except KeyboardInterrupt:
                print("\n🛑 Continuous mode stopped")
                break
            except Exception as e:
                print(f"❌ Error in cycle #{cycle}: {e}")
                time.sleep(10)  # Wait before retry
    else:
        # Single run mode
        try:
            bot.implement_audio_recording()
            bot.setup_api_client()
            bot.create_transcription_ui()
            bot.update_pubspec()
            
            print("🎉 Mobile Bot completed successfully!")
            print("📋 Next steps:")
            print("  1. cd scriby")
            print("  2. flutter pub get")
            print("  3. flutter run")
            
        except Exception as e:
            logger.error(f"❌ Mobile Bot failed: {e}")
            sys.exit(1)

if __name__ == "__main__":
    main()

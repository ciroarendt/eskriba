import 'dart:io';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioService {
  static final AudioRecorder _recorder = AudioRecorder();
  static final AudioPlayer _player = AudioPlayer();
  static bool _isRecording = false;
  static String? _currentRecordingPath;
  
  // Request microphone permission
  static Future<bool> requestPermission() async {
    final status = await Permission.microphone.request();
    return status == PermissionStatus.granted;
  }
  
  // Start recording
  static Future<bool> startRecording() async {
    try {
      if (!await requestPermission()) {
        print('Microphone permission denied');
        return false;
      }
      
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentRecordingPath = '${directory.path}/recording_$timestamp.m4a';
      
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: _currentRecordingPath!,
      );
      
      _isRecording = true;
      print('Recording started: $_currentRecordingPath');
      return true;
    } catch (e) {
      print('Error starting recording: $e');
      return false;
    }
  }
  
  // Stop recording
  static Future<String?> stopRecording() async {
    try {
      if (!_isRecording) return null;
      
      await _recorder.stop();
      _isRecording = false;
      
      final recordingPath = _currentRecordingPath;
      _currentRecordingPath = null;
      
      print('Recording stopped: $recordingPath');
      return recordingPath;
    } catch (e) {
      print('Error stopping recording: $e');
      return null;
    }
  }
  
  // Play audio file
  static Future<void> playAudio(String filePath) async {
    try {
      await _player.play(DeviceFileSource(filePath));
    } catch (e) {
      print('Error playing audio: $e');
    }
  }
  
  // Stop audio playback
  static Future<void> stopAudio() async {
    try {
      await _player.stop();
    } catch (e) {
      print('Error stopping audio: $e');
    }
  }
  
  // Check if currently recording
  static bool get isRecording => _isRecording;
  
  // Get current recording path
  static String? get currentRecordingPath => _currentRecordingPath;
  
  // Dispose resources
  static Future<void> dispose() async {
    await _recorder.dispose();
    await _player.dispose();
  }
}

import 'dart:io';
import 'dart:async';
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
  
  /// Play a snippet of an audio file starting at [from] for [duration].
  Future<void> playSnippet(
    String filePath, {
    required Duration from,
    required Duration duration,
  }) async {
    try {
      // Start the player if not already started, then seek to position
      await _player!.startPlayer(fromURI: filePath);
      // Some platforms require a small delay before seeking
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await _player!.seekToPlayer(from);
      // Stop after the desired duration
      Timer(duration, () async {
        try {
          await _player!.stopPlayer();
        } catch (_) {}
      });
    } catch (e) {
      print('Error playing snippet: $e');
    }
  }
  
  Future<void> stopPlayback() async {
    try {
      await _player?.stopPlayer();
    } catch (e) {
      print('Error stopping playback: $e');
    }
  }
  
  bool get isRecording => _isRecording;
  String? get currentRecordingPath => _currentRecordingPath;
  
  void dispose() {
    _recorder?.closeRecorder();
    _player?.closePlayer();
  }
}
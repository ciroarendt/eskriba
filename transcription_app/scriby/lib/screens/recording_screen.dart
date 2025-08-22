import 'package:flutter/material.dart';
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
}
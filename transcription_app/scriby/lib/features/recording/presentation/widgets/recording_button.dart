import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/services/mock_data_service.dart';
import '../../../../shared/themes/app_theme.dart';

/// Main Recording Button - Central component following "1 Toque para Gravar"
/// Implements the core recording functionality with visual feedback
class RecordingButton extends ConsumerStatefulWidget {
  const RecordingButton({super.key});

  @override
  ConsumerState<RecordingButton> createState() => _RecordingButtonState();
}

class _RecordingButtonState extends ConsumerState<RecordingButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;
  
  bool _isRecording = false;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    
    // Pulse animation for recording state
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    // Scale animation for button press
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _isPaused = false;
    });
    
    // Start pulse animation
    _pulseController.repeat(reverse: true);
    
    // TODO: Implement actual recording logic
    print('🎙️ Starting recording...');
  }

  void _stopRecording() {
    setState(() {
      _isRecording = false;
      _isPaused = false;
    });
    
    // Stop pulse animation
    _pulseController.stop();
    _pulseController.reset();
    
    // Simulate processing and navigate to results
    print('⏹️ Stopping recording...');
    
    // Show processing dialog briefly, then navigate
    _showProcessingAndNavigate();
  }
  
  void _showProcessingAndNavigate() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Processando transcrição...'),
          ],
        ),
      ),
    );
    
    // Simulate processing time, then navigate
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pop(); // Close dialog
      
      // Get sample data and navigate
      final sampleData = MockDataService.getSampleTranscriptionData();
      AppRouter.goToTranscriptionResults(context, sampleData);
    });
  }

  void _pauseRecording() {
    setState(() {
      _isPaused = !_isPaused;
    });
    
    if (_isPaused) {
      _pulseController.stop();
      print('⏸️ Pausing recording...');
    } else {
      _pulseController.repeat(reverse: true);
      print('▶️ Resuming recording...');
    }
    
    // TODO: Implement pause/resume logic
  }

  void _onButtonPressed() {
    // Scale animation feedback
    _scaleController.forward().then((_) {
      _scaleController.reverse();
    });
    
    if (!_isRecording) {
      _startRecording();
    } else {
      _stopRecording();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          // Main Recording Button
          AnimatedBuilder(
            animation: Listenable.merge([_pulseAnimation, _scaleAnimation]),
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _getButtonColor().withOpacity(0.3),
                        blurRadius: _isRecording ? 20 * _pulseAnimation.value : 10,
                        spreadRadius: _isRecording ? 5 * _pulseAnimation.value : 0,
                      ),
                    ],
                  ),
                  child: Material(
                    color: _getButtonColor(),
                    shape: const CircleBorder(),
                    elevation: 8,
                    child: InkWell(
                      onTap: _onButtonPressed,
                      customBorder: const CircleBorder(),
                      child: Container(
                        decoration: const BoxDecoration(shape: BoxShape.circle),
                        child: Icon(
                          _getButtonIcon(),
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 20),
          
          // Recording Status Text
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              _getStatusText(),
              key: ValueKey(_getStatusText()),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: _getButtonColor(),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Recording Duration (when recording)
          if (_isRecording) ...[
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Text(
                  '00:00:00', // TODO: Implement real duration
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.recordingColor,
                    fontWeight: FontWeight.bold,
                    fontFeatures: [const FontFeature.tabularFigures()],
                  ),
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            // Pause/Resume Button
            ElevatedButton.icon(
              onPressed: _pauseRecording,
              icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
              label: Text(_isPaused ? 'Retomar' : 'Pausar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isPaused 
                    ? AppTheme.secondaryColor 
                    : AppTheme.accentColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
          
          // Instructions (when not recording)
          if (!_isRecording) ...[
            Text(
              'Toque para iniciar a gravação',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            
            const SizedBox(height: 8),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
                const SizedBox(width: 4),
                Text(
                  'Gravação em alta qualidade',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getButtonColor() {
    if (_isRecording) {
      return _isPaused ? AppTheme.accentColor : AppTheme.recordingColor;
    }
    return AppTheme.primaryColor;
  }

  IconData _getButtonIcon() {
    if (_isRecording) {
      return Icons.stop_rounded;
    }
    return Icons.mic_rounded;
  }

  String _getStatusText() {
    if (_isRecording) {
      return _isPaused ? 'Gravação pausada' : 'Gravando...';
    }
    return 'Pronto para gravar';
  }
}

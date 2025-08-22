import 'package:flutter/material.dart';
import 'dart:async';

import '../../../../shared/themes/app_theme.dart';

/// Recording Controls Widget - Specialized controls for lecture mode
/// Provides recording functionality optimized for sermon/lecture context
class RecordingControlsWidget extends StatefulWidget {
  final bool isRecording;
  final Function(bool) onRecordingChanged;
  final Function(Duration) onDurationChanged;

  const RecordingControlsWidget({
    super.key,
    required this.isRecording,
    required this.onRecordingChanged,
    required this.onDurationChanged,
  });

  @override
  State<RecordingControlsWidget> createState() => _RecordingControlsWidgetState();
}

class _RecordingControlsWidgetState extends State<RecordingControlsWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;
  
  Timer? _timer;
  Duration _duration = Duration.zero;
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
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(RecordingControlsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isRecording != oldWidget.isRecording) {
      if (widget.isRecording) {
        _startTimer();
        _pulseController.repeat(reverse: true);
      } else {
        _stopTimer();
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Recording Status
          Text(
            _getStatusText(),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: _getStatusColor(),
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Instructions
          Text(
            _getInstructionText(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 32),
          
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
                        blurRadius: widget.isRecording ? 20 * _pulseAnimation.value : 10,
                        spreadRadius: widget.isRecording ? 5 * _pulseAnimation.value : 0,
                      ),
                    ],
                  ),
                  child: Material(
                    color: _getButtonColor(),
                    shape: const CircleBorder(),
                    elevation: 8,
                    child: InkWell(
                      onTap: _onMainButtonPressed,
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
          
          const SizedBox(height: 24),
          
          // Secondary Controls (when recording)
          if (widget.isRecording) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Pause/Resume Button
                ElevatedButton.icon(
                  onPressed: _togglePause,
                  icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                  label: Text(_isPaused ? 'Retomar' : 'Pausar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isPaused 
                        ? AppTheme.secondaryColor 
                        : AppTheme.accentColor,
                    foregroundColor: Colors.white,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Mark Important Moment
                ElevatedButton.icon(
                  onPressed: _markImportantMoment,
                  icon: const Icon(Icons.bookmark),
                  label: const Text('Marcar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Recording Tips
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Dicas para melhor gravação',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Mantenha o dispositivo próximo ao palestrante\n'
                    '• Use fones para monitorar o áudio\n'
                    '• Marque momentos importantes durante a mensagem',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
          
          // Pre-recording tips
          if (!widget.isRecording) ...[
            const SizedBox(height: 24),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.school,
                        color: Colors.blue,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Modo Aula Ativo',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Grave palestras, sermões e aulas com recursos especiais:\n'
                    '• Leitura bíblica integrada\n'
                    '• Anotações sincronizadas\n'
                    '• Marcação de momentos importantes',
                    style: TextStyle(fontSize: 12),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          _duration = Duration(seconds: _duration.inSeconds + 1);
        });
        widget.onDurationChanged(_duration);
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _duration = Duration.zero;
      _isPaused = false;
    });
    widget.onDurationChanged(_duration);
  }

  void _onMainButtonPressed() {
    // Scale animation feedback
    _scaleController.forward().then((_) {
      _scaleController.reverse();
    });
    
    widget.onRecordingChanged(!widget.isRecording);
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
    
    if (_isPaused) {
      _pulseController.stop();
    } else {
      _pulseController.repeat(reverse: true);
    }
  }

  void _markImportantMoment() {
    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Momento marcado em ${_formatDuration(_duration)}'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Color _getButtonColor() {
    if (widget.isRecording) {
      return _isPaused ? AppTheme.accentColor : AppTheme.recordingColor;
    }
    return AppTheme.primaryColor;
  }

  IconData _getButtonIcon() {
    if (widget.isRecording) {
      return Icons.stop_rounded;
    }
    return Icons.mic_rounded;
  }

  Color _getStatusColor() {
    if (widget.isRecording) {
      return _isPaused ? AppTheme.accentColor : AppTheme.recordingColor;
    }
    return AppTheme.primaryColor;
  }

  String _getStatusText() {
    if (widget.isRecording) {
      return _isPaused ? 'Gravação pausada' : 'Gravando aula...';
    }
    return 'Pronto para gravar';
  }

  String _getInstructionText() {
    if (widget.isRecording) {
      return 'Toque para finalizar a gravação';
    }
    return 'Toque para iniciar a gravação da palestra';
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
}

import 'package:flutter/material.dart';
import '../../../../shared/themes/app_theme.dart';

/// Compact Recording Controls Widget - Minimalist design for iPhone
/// Expandable horizontal controls optimized for mobile experience
class CompactRecordingControlsWidget extends StatefulWidget {
  final bool isRecording;
  final bool isPaused;
  final Duration duration;
  final VoidCallback? onRecordingToggle;
  final VoidCallback? onPauseToggle;
  final VoidCallback? onMarkMoment;
  final Function(bool)? onRecordingChanged;
  final Function(Duration)? onDurationChanged;

  const CompactRecordingControlsWidget({
    super.key,
    this.isRecording = false,
    this.isPaused = false,
    this.duration = Duration.zero,
    this.onRecordingToggle,
    this.onPauseToggle,
    this.onMarkMoment,
    this.onRecordingChanged,
    this.onDurationChanged,
  });

  @override
  State<CompactRecordingControlsWidget> createState() => _CompactRecordingControlsWidgetState();
}

class _CompactRecordingControlsWidgetState extends State<CompactRecordingControlsWidget>
    with TickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _expandController;
  late AnimationController _pulseController;
  late Animation<double> _expandAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    if (widget.isRecording) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(CompactRecordingControlsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isRecording && !oldWidget.isRecording) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isRecording && oldWidget.isRecording) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _expandController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _expandController.forward();
      } else {
        _expandController.reverse();
      }
    });
  }

  void _handleRecordingToggle() {
    widget.onRecordingToggle?.call();
    widget.onRecordingChanged?.call(!widget.isRecording);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: widget.isRecording 
            ? AppTheme.recordingColor.withOpacity(0.1)
            : AppTheme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: widget.isRecording 
              ? AppTheme.recordingColor.withOpacity(0.3)
              : AppTheme.primaryColor.withOpacity(0.2),
        ),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Main compact row
            Row(
              children: [
                // Recording status indicator
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: widget.isRecording ? _pulseAnimation.value : 1.0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: widget.isRecording 
                              ? AppTheme.recordingColor 
                              : Colors.grey[400],
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(width: 12),
                
                // Status text and timer
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.isRecording 
                            ? (widget.isPaused ? 'Pausado' : 'Gravando')
                            : 'Pronto para gravar',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: widget.isRecording 
                              ? AppTheme.recordingColor 
                              : AppTheme.primaryColor,
                        ),
                      ),
                      if (widget.isRecording || widget.duration.inSeconds > 0) ...[
                        const SizedBox(height: 2),
                        Text(
                          _formatDuration(widget.duration),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Main record button
                GestureDetector(
                  onTap: _handleRecordingToggle,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: widget.isRecording 
                          ? AppTheme.recordingColor 
                          : AppTheme.primaryColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (widget.isRecording 
                              ? AppTheme.recordingColor 
                              : AppTheme.primaryColor).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.isRecording ? Icons.stop : Icons.mic,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // Expand button
                GestureDetector(
                  onTap: _toggleExpanded,
                  child: AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.expand_more,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Expanded controls
            SizeTransition(
              sizeFactor: _expandAnimation,
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  
                  // Secondary controls row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Pause/Resume button
                      if (widget.isRecording) ...[
                        _buildSecondaryButton(
                          icon: widget.isPaused ? Icons.play_arrow : Icons.pause,
                          label: widget.isPaused ? 'Retomar' : 'Pausar',
                          onTap: widget.onPauseToggle,
                          color: AppTheme.secondaryColor,
                        ),
                        
                        // Mark moment button
                        _buildSecondaryButton(
                          icon: Icons.bookmark_add,
                          label: 'Marcar',
                          onTap: widget.onMarkMoment,
                          color: AppTheme.accentColor,
                        ),
                      ] else ...[
                        // Recording tips when not recording
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.lightbulb_outline,
                                  color: AppTheme.primaryColor,
                                  size: 20,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Toque para iniciar a gravação da palestra',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    
    if (duration.inHours > 0) {
      return '$hours:$minutes:$seconds';
    } else {
      return '$minutes:$seconds';
    }
  }
}

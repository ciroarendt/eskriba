import 'package:flutter/material.dart';

import '../../../../shared/themes/app_theme.dart';

/// Lecture Timer Widget - Displays recording duration with visual feedback
/// Optimized for lecture/sermon recording with clear time display
class LectureTimerWidget extends StatelessWidget {
  final Duration duration;
  final bool isRecording;

  const LectureTimerWidget({
    super.key,
    required this.duration,
    required this.isRecording,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Recording Indicator
        if (isRecording) ...[
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppTheme.recordingColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
        ],
        
        // Timer Display
        Text(
          _formatDuration(duration),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isRecording ? AppTheme.recordingColor : Colors.grey[600],
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        
        // Status Text
        const SizedBox(width: 8),
        Text(
          isRecording ? 'gravando' : 'parado',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    
    if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    } else {
      return "$twoDigitMinutes:$twoDigitSeconds";
    }
  }
}

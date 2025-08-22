import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../shared/themes/app_theme.dart';

/// Widget to display transcription text with segments and confidence scores
class TranscriptionTextWidget extends StatefulWidget {
  final String content;
  final List<dynamic> segments;
  final double confidence;

  const TranscriptionTextWidget({
    super.key,
    required this.content,
    required this.segments,
    required this.confidence,
  });

  @override
  State<TranscriptionTextWidget> createState() => _TranscriptionTextWidgetState();
}

class _TranscriptionTextWidgetState extends State<TranscriptionTextWidget> {
  bool _showSegments = false;
  double _fontSize = 16.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Controls Bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              // Confidence Score
              Row(
                children: [
                  Icon(
                    Icons.verified,
                    color: _getConfidenceColor(widget.confidence),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Confiança: ${(widget.confidence * 100).toInt()}%',
                    style: TextStyle(
                      color: _getConfidenceColor(widget.confidence),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: _copyToClipboard,
                    tooltip: 'Copiar texto',
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Controls Row
              Row(
                children: [
                  // Font Size Control
                  Icon(Icons.text_fields, color: Colors.grey[600]),
                  Expanded(
                    child: Slider(
                      value: _fontSize,
                      min: 12.0,
                      max: 24.0,
                      divisions: 6,
                      activeColor: AppTheme.primaryColor,
                      onChanged: (value) {
                        setState(() {
                          _fontSize = value;
                        });
                      },
                    ),
                  ),
                  Text('${_fontSize.toInt()}pt'),
                  
                  const SizedBox(width: 16),
                  
                  // Segments Toggle
                  Switch(
                    value: _showSegments,
                    activeColor: AppTheme.primaryColor,
                    onChanged: (value) {
                      setState(() {
                        _showSegments = value;
                      });
                    },
                  ),
                  const Text('Segmentos'),
                ],
              ),
            ],
          ),
        ),
        
        // Content
        Expanded(
          child: _showSegments && widget.segments.isNotEmpty
              ? _buildSegmentedView()
              : _buildContinuousView(),
        ),
      ],
    );
  }

  Widget _buildContinuousView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: SelectableText(
        widget.content,
        style: TextStyle(
          fontSize: _fontSize,
          height: 1.6,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
    );
  }

  Widget _buildSegmentedView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.segments.length,
      itemBuilder: (context, index) {
        final segment = widget.segments[index];
        final startTime = segment['start']?.toDouble() ?? 0.0;
        final endTime = segment['end']?.toDouble() ?? 0.0;
        final text = segment['text'] ?? '';
        final confidence = segment['confidence']?.toDouble() ?? 0.0;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timestamp and Confidence
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_formatTime(startTime)} - ${_formatTime(endTime)}',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (confidence > 0) ...[
                      Icon(
                        Icons.verified,
                        color: _getConfidenceColor(confidence),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${(confidence * 100).toInt()}%',
                        style: TextStyle(
                          color: _getConfidenceColor(confidence),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Segment Text
                SelectableText(
                  text,
                  style: TextStyle(
                    fontSize: _fontSize,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.orange;
    return Colors.red;
  }

  String _formatTime(double seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = (seconds % 60).floor();
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Texto copiado para a área de transferência'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

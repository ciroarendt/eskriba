import 'package:flutter/material.dart';

import '../../../../shared/themes/app_theme.dart';

/// Recent Recordings List - Shows latest recordings with quick access
/// Implements the organization principles from CLAUDE.md
class RecentRecordingsList extends StatelessWidget {
  const RecentRecordingsList({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with actual data from provider
    final mockRecordings = [
      _MockRecording(
        title: 'Reunião de Planejamento',
        duration: '45:32',
        date: 'Hoje, 14:30',
        type: RecordingType.meeting,
        hasTranscription: true,
        hasAnalysis: true,
      ),
      _MockRecording(
        title: 'Palestra sobre IA',
        duration: '1:23:15',
        date: 'Ontem, 10:00',
        type: RecordingType.lecture,
        hasTranscription: true,
        hasAnalysis: false,
      ),
      _MockRecording(
        title: 'Ligação com Cliente',
        duration: '12:45',
        date: '2 dias atrás',
        type: RecordingType.call,
        hasTranscription: false,
        hasAnalysis: false,
      ),
    ];

    if (mockRecordings.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      children: mockRecordings
          .map((recording) => _RecordingCard(recording: recording))
          .toList(),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.mic_off_rounded,
            size: 48,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma gravação ainda',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Suas gravações aparecerão aqui',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordingCard extends StatelessWidget {
  final _MockRecording recording;

  const _RecordingCard({required this.recording});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // TODO: Navigate to recording details
            print('🎵 Open recording: ${recording.title}');
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
              ),
            ),
            child: Row(
              children: [
                // Recording Type Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getTypeColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getTypeIcon(),
                    color: _getTypeColor(),
                    size: 20,
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Recording Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recording.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            recording.duration,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            recording.date,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Status Indicators
                Column(
                  children: [
                    if (recording.hasTranscription)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Transcrito',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppTheme.secondaryColor,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    if (recording.hasAnalysis) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Analisado',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppTheme.primaryColor,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                
                const SizedBox(width: 8),
                
                // More Options
                IconButton(
                  icon: const Icon(Icons.more_vert_rounded),
                  iconSize: 20,
                  onPressed: () {
                    // TODO: Show options menu
                    print('⚙️ Show options for: ${recording.title}');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getTypeColor() {
    switch (recording.type) {
      case RecordingType.meeting:
        return AppTheme.primaryColor;
      case RecordingType.lecture:
        return AppTheme.secondaryColor;
      case RecordingType.call:
        return AppTheme.accentColor;
      case RecordingType.personal:
        return Colors.purple;
    }
  }

  IconData _getTypeIcon() {
    switch (recording.type) {
      case RecordingType.meeting:
        return Icons.groups_rounded;
      case RecordingType.lecture:
        return Icons.school_rounded;
      case RecordingType.call:
        return Icons.phone_rounded;
      case RecordingType.personal:
        return Icons.person_rounded;
    }
  }
}

// Mock data classes
enum RecordingType { meeting, lecture, call, personal }

class _MockRecording {
  final String title;
  final String duration;
  final String date;
  final RecordingType type;
  final bool hasTranscription;
  final bool hasAnalysis;

  _MockRecording({
    required this.title,
    required this.duration,
    required this.date,
    required this.type,
    required this.hasTranscription,
    required this.hasAnalysis,
  });
}

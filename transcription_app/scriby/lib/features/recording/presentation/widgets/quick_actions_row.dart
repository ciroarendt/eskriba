import 'package:flutter/material.dart';

import '../../../../shared/themes/app_theme.dart';
import '../../../lecture/presentation/pages/lecture_mode_page.dart';

/// Quick Actions Row - Provides fast access to common features
/// Follows the simplified UX principles from CLAUDE.md
class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionCard(
            icon: Icons.upload_file_rounded,
            title: 'Importar Áudio',
            subtitle: 'Transcrever arquivo',
            color: AppTheme.secondaryColor,
            onTap: () {
              // TODO: Implement file import
              print('📁 Import audio file');
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.phone_rounded,
            title: 'Ligação',
            subtitle: 'Gravar chamada',
            color: AppTheme.accentColor,
            onTap: () {
              // TODO: Implement call recording
              print('📞 Record phone call');
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.school_rounded,
            title: 'Palestra',
            subtitle: 'Modo aula',
            color: AppTheme.primaryColor,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const LectureModeePage(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

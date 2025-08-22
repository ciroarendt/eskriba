import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/themes/app_theme.dart';
import '../../../lecture/presentation/pages/lecture_mode_page.dart';
import '../widgets/recording_button.dart';
import '../widgets/quick_actions_row.dart';
import '../widgets/recent_recordings_list.dart';
import '../../../../widgets/api_status_widget.dart';

/// Home Page - Main screen of Eskriba app
/// Follows the "1 Toque para Gravar" principle from CLAUDE.md
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 120,
              floating: true,
              pinned: false,
              backgroundColor: Colors.transparent,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.mic_rounded,
                      color: AppTheme.primaryColor,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Eskriba',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                centerTitle: true,
                titlePadding: const EdgeInsets.only(bottom: 16),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings_rounded),
                  onPressed: () {
                    // TODO: Navigate to settings
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),
            
            // Main Content
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 20),
                  
                  // Welcome Message
                  _buildWelcomeCard(),
                  
                  const SizedBox(height: 16),
                  
                  // API Status
                  const ApiStatusWidget(),
                  
                  const SizedBox(height: 32),
                  
                  // Main Recording Button
                  const RecordingButton(),
                  
                  const SizedBox(height: 32),
                  
                  // Quick Actions
                  const QuickActionsRow(),
                  
                  const SizedBox(height: 32),
                  
                  // Recent Recordings Section
                  _buildSectionHeader('Gravações Recentes'),
                  
                  const SizedBox(height: 16),
                  
                  const RecentRecordingsList(),
                  
                  const SizedBox(height: 32),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor.withOpacity(0.1),
            AppTheme.secondaryColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.lightbulb_rounded,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Bem-vindo ao Scriby!',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Transforme suas reuniões, palestras e conversas em insights acionáveis com transcrição inteligente e análise por IA.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFeatureChip('🎙️ Gravação HD'),
              _buildFeatureChip('📝 Transcrição IA'),
              _buildFeatureChip('🤖 Análise Inteligente'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: () {
            // TODO: Navigate to all recordings
          },
          child: const Text('Ver todas'),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/themes/app_theme.dart';
import '../widgets/transcription_text_widget.dart';
import '../widgets/action_items_widget.dart';

/// Transcription Results Page - Displays transcription and AI analysis
/// Shows text, summary, topics, action items in organized tabs
class TranscriptionResultsPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> transcriptionData;
  
  const TranscriptionResultsPage({
    super.key,
    required this.transcriptionData,
  });

  @override
  ConsumerState<TranscriptionResultsPage> createState() => _TranscriptionResultsPageState();
}

class _TranscriptionResultsPageState extends ConsumerState<TranscriptionResultsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transcription = widget.transcriptionData['transcription'] ?? {};
    final analysis = widget.transcriptionData['analysis'] ?? {};
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Resultados da Transcrição'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareResults,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportResults,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primaryColor,
          tabs: const [
            Tab(icon: Icon(Icons.text_fields), text: 'Texto'),
            Tab(icon: Icon(Icons.summarize), text: 'Resumo'),
            Tab(icon: Icon(Icons.topic), text: 'Tópicos'),
            Tab(icon: Icon(Icons.task_alt), text: 'Ações'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Transcription Text
                TranscriptionTextWidget(
                  content: transcription['content'] ?? 'Transcrição não disponível',
                  segments: transcription['segments'] ?? [],
                  confidence: transcription['confidence']?.toDouble() ?? 0.0,
                ),
                
                // Tab 2: Summary
                _buildSummaryTab(analysis),
                
                // Tab 3: Topics
                _buildTopicsTab(analysis),
                
                // Tab 4: Action Items
                ActionItemsWidget(
                  actionItems: analysis['action_items'] ?? [],
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _startNewRecording,
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.mic, color: Colors.white),
        label: const Text(
          'Nova Gravação',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildSummaryTab(Map<String, dynamic> analysis) {
    final summary = analysis['summary'] ?? 'Resumo não disponível';
    final keyPoints = analysis['key_points'] ?? [];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Card
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.summarize, color: AppTheme.primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        'Resumo Executivo',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    summary,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Key Points
          if (keyPoints.isNotEmpty) ...[
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.key, color: AppTheme.primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          'Pontos-Chave',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...keyPoints.map<Widget>((point) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(top: 8, right: 12),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              point.toString(),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTopicsTab(Map<String, dynamic> analysis) {
    final topics = analysis['topics'] ?? [];
    
    if (topics.isEmpty) {
      return const Center(
        child: Text('Nenhum tópico identificado'),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: topics.length,
      itemBuilder: (context, index) {
        final topic = topics[index];
        final relevance = (topic['relevance'] ?? 0.0).toDouble();
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        topic['name'] ?? 'Tópico ${index + 1}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getRelevanceColor(relevance).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${(relevance * 100).toInt()}%',
                        style: TextStyle(
                          color: _getRelevanceColor(relevance),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: relevance,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation(_getRelevanceColor(relevance)),
                ),
                if (topic['description'] != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    topic['description'],
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getRelevanceColor(double relevance) {
    if (relevance >= 0.8) return Colors.green;
    if (relevance >= 0.6) return Colors.orange;
    return Colors.red;
  }

  void _shareResults() {
    final transcription = widget.transcriptionData['transcription'] ?? {};
    final content = transcription['content'] ?? '';
    
    Clipboard.setData(ClipboardData(text: content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transcrição copiada para a área de transferência')),
    );
  }

  void _exportResults() {
    // TODO: Implement export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidade de exportação em desenvolvimento')),
    );
  }

  void _startNewRecording() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}

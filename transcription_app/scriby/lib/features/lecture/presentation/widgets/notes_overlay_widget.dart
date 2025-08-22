import 'package:flutter/material.dart';

import '../../../../shared/themes/app_theme.dart';

/// Notes Overlay Widget - Displays and manages notes during lectures
/// Provides synchronized note-taking with timestamps and verse references
class NotesOverlayWidget extends StatefulWidget {
  final List<Map<String, dynamic>> notes;
  final VoidCallback onClose;
  final Function(String) onNoteDeleted;
  final Function(String) onNoteAdded;

  const NotesOverlayWidget({
    super.key,
    required this.notes,
    required this.onClose,
    required this.onNoteDeleted,
    required this.onNoteAdded,
  });

  @override
  State<NotesOverlayWidget> createState() => _NotesOverlayWidgetState();
}

class _NotesOverlayWidgetState extends State<NotesOverlayWidget> {
  String _filterType = 'all';
  final List<String> _filterOptions = ['all', 'quick', 'verse', 'bookmark'];
  final TextEditingController _quickNoteController = TextEditingController();

  @override
  void dispose() {
    _quickNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredNotes = _getFilteredNotes();

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.note,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Anotações da Aula',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const Spacer(),
                Text(
                  '${widget.notes.length} anotações',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: widget.onClose,
                  icon: const Icon(Icons.close),
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),

          // Filter Tabs
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filterOptions.map((filter) {
                  final isSelected = _filterType == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(_getFilterLabel(filter)),
                      selected: isSelected,
                      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                      checkmarkColor: AppTheme.primaryColor,
                      onSelected: (selected) {
                        setState(() {
                          _filterType = filter;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Notes List
          Expanded(
            child: filteredNotes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.note_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _filterType == 'all' 
                              ? 'Nenhuma anotação ainda'
                              : 'Nenhuma anotação deste tipo',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Adicione anotações durante a palestra',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredNotes.length,
                    itemBuilder: (context, index) {
                      final note = filteredNotes[index];
                      return _buildNoteCard(note);
                    },
                  ),
          ),

          // Bottom Actions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(
                top: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _exportNotes,
                    icon: const Icon(Icons.share),
                    label: const Text('Compartilhar Anotações'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _clearAllNotes,
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Limpar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[600],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(Map<String, dynamic> note) {
    final type = note['type'] ?? 'quick';
    final timestamp = note['timestamp'] as Duration?;
    final createdAt = note['createdAt'] as DateTime?;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                // Type Icon
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: _getTypeColor(type).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    _getTypeIcon(type),
                    size: 16,
                    color: _getTypeColor(type),
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // Type Label
                Text(
                  _getTypeLabel(type),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _getTypeColor(type),
                  ),
                ),
                
                const Spacer(),
                
                // Timestamp
                if (timestamp != null) ...[
                  Icon(
                    Icons.access_time,
                    size: 12,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDuration(timestamp),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
                
                // Delete Button
                IconButton(
                  onPressed: () => widget.onNoteDeleted(note['id']),
                  icon: Icon(
                    Icons.delete_outline,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Note Content
            Text(
              note['text'] ?? '',
              style: const TextStyle(fontSize: 14),
            ),
            
            // Verse Reference (for verse notes)
            if (type == 'verse' && note['reference'] != null) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  note['reference'],
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            
            // Created At
            if (createdAt != null) ...[
              const SizedBox(height: 4),
              Text(
                'Adicionado às ${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredNotes() {
    if (_filterType == 'all') {
      return widget.notes;
    }
    
    return widget.notes.where((note) {
      return note['type'] == _filterType;
    }).toList();
  }

  String _getFilterLabel(String filter) {
    switch (filter) {
      case 'all':
        return 'Todas';
      case 'quick':
        return 'Rápidas';
      case 'verse':
        return 'Versículos';
      case 'bookmark':
        return 'Marcações';
      default:
        return filter;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'verse':
        return Colors.blue;
      case 'bookmark':
        return Colors.orange;
      case 'quick':
      default:
        return AppTheme.primaryColor;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'verse':
        return Icons.menu_book;
      case 'bookmark':
        return Icons.bookmark;
      case 'quick':
      default:
        return Icons.note;
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'verse':
        return 'VERSÍCULO';
      case 'bookmark':
        return 'MARCAÇÃO';
      case 'quick':
      default:
        return 'ANOTAÇÃO';
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
  
  void _addQuickNote() {
    final text = _quickNoteController.text.trim();
    if (text.isNotEmpty) {
      widget.onNoteAdded(text);
      _quickNoteController.clear();
      
      // Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anotação adicionada!'),
          duration: Duration(seconds: 1),
          backgroundColor: AppTheme.secondaryColor,
        ),
      );
    }
  }

  void _exportNotes() {
    // TODO: Implement export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidade de exportação em desenvolvimento'),
        backgroundColor: AppTheme.secondaryColor,
      ),
    );
  }

  void _clearAllNotes() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar Anotações'),
        content: const Text('Tem certeza que deseja remover todas as anotações?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Clear all notes
              for (final note in widget.notes) {
                widget.onNoteDeleted(note['id']);
              }
            },
            child: const Text('Limpar'),
          ),
        ],
      ),
    );
  }
}

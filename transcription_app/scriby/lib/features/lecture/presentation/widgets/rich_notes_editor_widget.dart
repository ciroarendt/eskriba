import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill/quill_delta.dart';

import '../../../../shared/themes/app_theme.dart';
import '../../../../services/audio_recording_service.dart';

/// Rich Notes Editor Widget
/// Provides a rich text editor with formatting options (Bold, Italic, Underline)
/// and displays previous notes below the editor
class RichNotesEditorWidget extends StatefulWidget {
  final List<Map<String, dynamic>> notes;
  // onNoteAdded now receives the full note map for richer metadata
  final Function(Map<String, dynamic>) onNoteAdded;
  // Optional callback when a note is edited
  final Function(Map<String, dynamic>)? onNoteUpdated;
  final Function(String) onNoteDeleted;
  final VoidCallback onClose;
  // Optional: current recording position and audio path to create snippet
  final Duration? currentPosition;
  final String? audioPath;

  const RichNotesEditorWidget({
    super.key,
    required this.notes,
    required this.onNoteAdded,
    this.onNoteUpdated,
    required this.onNoteDeleted,
    required this.onClose,
    this.currentPosition,
    this.audioPath,
  });

  @override
  State<RichNotesEditorWidget> createState() => _RichNotesEditorWidgetState();
}

class _RichNotesEditorWidgetState extends State<RichNotesEditorWidget> {
  // Quill rich text editor
  late quill.QuillController _quillController;
  final FocusNode _focusNode = FocusNode();
  
  // Editing state
  String? _editingNoteId;
  
  // Audio playback
  final AudioRecordingService _audio = AudioRecordingService();

  @override
  void initState() {
    super.initState();
    _quillController = quill.QuillController.basic();
    // Initialize audio service for playback (safe to call once)
    _audio.initialize();
  }

  @override
  void dispose() {
    try {
      _quillController.dispose();
    } catch (_) {}
    _focusNode.dispose();
    _audio.dispose();
    super.dispose();
  }

  void _loadNoteIntoEditor(Map<String, dynamic> note) {
    try {
      if (note['delta'] != null) {
        // Load from stored Delta JSON
        final deltaJson = List<Map<String, dynamic>>.from(note['delta'] as List);
        final delta = Delta.fromJson(deltaJson);
        final doc = quill.Document.fromDelta(delta);
        try { _quillController.dispose(); } catch (_) {}
        _quillController = quill.QuillController(
          document: doc,
          selection: const TextSelection.collapsed(offset: 0),
        );
      } else {
        final text = (note['text'] ?? '').toString();
        try { _quillController.dispose(); } catch (_) {}
        _quillController = quill.QuillController(
          document: quill.Document()..insert(0, text),
          selection: const TextSelection.collapsed(offset: 0),
        );
      }
      setState(() {});
      _focusNode.requestFocus();
    } catch (_) {
      // Fallback to plain text if any issue
      final text = (note['text'] ?? '').toString();
      try { _quillController.dispose(); } catch (_) {}
      _quillController = quill.QuillController(
        document: quill.Document()..insert(0, text),
        selection: const TextSelection.collapsed(offset: 0),
      );
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
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
                  Icons.edit_note,
                  color: AppTheme.primaryColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Anotações da Aula',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
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

          // Rich Text Editor
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                // Formatting Toolbar (Quill)
                quill.QuillSimpleToolbar(controller: _quillController),

                // Rich editor area
                Container(
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(minHeight: 140, maxHeight: 260),
                  child: quill.QuillEditor(
                    controller: _quillController,
                    scrollController: ScrollController(),
                    focusNode: FocusNode(),
                  ),
                ),
                
                // Add Button
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (_editingNoteId != null)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _editingNoteId = null;
                              _quillController = quill.QuillController.basic();
                            });
                          },
                          child: const Text('Cancelar'),
                        ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _saveNote,
                        icon: Icon(_editingNoteId != null ? Icons.save : Icons.add),
                        label: Text(_editingNoteId != null ? 'Salvar alterações' : 'Adicionar anotação'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Previous Notes Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.notes.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Anotações Anteriores',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                
                Expanded(
                  child: widget.notes.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.note_outlined,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Nenhuma anotação ainda',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Comece digitando acima',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: widget.notes.length,
                          itemBuilder: (context, index) {
                            final note = widget.notes[widget.notes.length - 1 - index]; // Reverse order
                            return _buildNoteCard(note);
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primaryColor.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: isActive ? Border.all(color: AppTheme.primaryColor) : null,
          ),
          child: Icon(
            icon,
            size: 20,
            color: isActive ? AppTheme.primaryColor : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildNoteCard(Map<String, dynamic> note) {
    final createdAt = DateTime.tryParse((note['createdAt'] ?? '').toString()) ?? DateTime.now();
    final type = (note['type'] ?? 'note').toString();
    final snippet = note['snippet'] as Map<String, dynamic>?;
    final recordingPositionMs = note['recordingPositionMs'] as int?;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Note header
            Row(
              children: [
                Icon(
                  Icons.note,
                  size: 16,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  type == 'verse' ? 'Verso' : 'Anotação',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const Spacer(),
                if (recordingPositionMs != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Text(
                      _formatDuration(Duration(milliseconds: recordingPositionMs)),
                      style: const TextStyle(fontSize: 10, color: Colors.green),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    _editingNoteId = note['id']?.toString();
                    _loadNoteIntoEditor(note);
                  },
                  child: Icon(
                    Icons.edit_outlined,
                    size: 16,
                    color: Colors.blue[400],
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => widget.onNoteDeleted(note['id']),
                  child: Icon(
                    Icons.delete_outline,
                    size: 16,
                    color: Colors.red[400],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Note content
            Text(
              (note['text'] ?? '').toString(),
              style: const TextStyle(fontSize: 14),
            ),

            if (snippet != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.play_arrow),
                    tooltip: 'Reproduzir trecho',
                    color: AppTheme.secondaryColor,
                    onPressed: (snippet['audioPath'] != null && (snippet['audioPath'] as String).isNotEmpty)
                        ? () {
                            _audio.playSnippet(
                              (snippet['audioPath'] as String),
                              from: Duration(milliseconds: (snippet['startMs'] ?? 0) as int),
                              duration: Duration(milliseconds: (snippet['durationMs'] ?? 10000) as int),
                            );
                          }
                        : null,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Trecho: ${_formatDuration(Duration(milliseconds: (snippet['startMs'] ?? 0) as int))} • ${(snippet['durationMs'] ?? 10000) ~/ 1000}s',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _saveNote() {
    final plainText = _quillController.document.toPlainText().trim();
    if (plainText.isEmpty) return;
    final deltaJson = _quillController.document.toDelta().toJson();

    // Build snippet metadata if position available
    Map<String, dynamic>? snippet;
    int? recordingPositionMs;
    if (widget.currentPosition != null) {
      final pos = widget.currentPosition!;
      final start = pos - const Duration(seconds: 10);
      final startSafe = start.isNegative ? Duration.zero : start;
      snippet = {
        'startMs': startSafe.inMilliseconds,
        'durationMs': 10000,
        'audioPath': widget.audioPath ?? '',
      };
      recordingPositionMs = pos.inMilliseconds;
    }

    if (_editingNoteId != null) {
      final updated = {
        'id': _editingNoteId,
        'text': plainText,
        'delta': deltaJson,
        'updatedAt': DateTime.now().toIso8601String(),
        if (snippet != null) 'snippet': snippet,
        if (recordingPositionMs != null) 'recordingPositionMs': recordingPositionMs,
      };
      widget.onNoteUpdated?.call(updated);
      // feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anotação atualizada!'),
          duration: Duration(seconds: 1),
          backgroundColor: AppTheme.secondaryColor,
        ),
      );
    } else {
      final newNote = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'text': plainText,
        'delta': deltaJson,
        'type': 'note',
        'createdAt': DateTime.now().toIso8601String(),
        if (snippet != null) 'snippet': snippet,
        if (recordingPositionMs != null) 'recordingPositionMs': recordingPositionMs,
      };
      widget.onNoteAdded(newNote);
      // feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anotação adicionada!'),
          duration: Duration(seconds: 1),
          backgroundColor: AppTheme.secondaryColor,
        ),
      );
    }

    // Reset editor state
    setState(() {
      _editingNoteId = null;
      try { _quillController.dispose(); } catch (_) {}
      _quillController = quill.QuillController.basic();
    });
    _focusNode.requestFocus();
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(d.inHours)}:${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}';
  }
}

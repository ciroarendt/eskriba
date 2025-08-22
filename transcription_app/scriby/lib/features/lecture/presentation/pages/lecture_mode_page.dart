import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

import '../../../../core/config/api_config.dart';
import '../../../../shared/themes/app_theme.dart';
import '../widgets/bible_reader_widget.dart';
import '../widgets/pdf_viewer_widget.dart';
import '../widgets/notes_overlay_widget.dart';
import '../widgets/rich_notes_editor_widget.dart';
import '../widgets/recording_controls_widget.dart';
import '../../data/services/pdf_service.dart';
import '../widgets/compact_recording_controls_widget.dart';
import '../../data/services/youversion_service.dart';
import '../../../../services/audio_recording_service.dart';

/// Lecture Mode Page - Enhanced learning experience for sermons/lectures
/// Integrates audio recording, Bible reading, and note-taking
class LectureModeePage extends ConsumerStatefulWidget {
  const LectureModeePage({super.key});

  @override
  ConsumerState<LectureModeePage> createState() => _LectureModeePageState();
}

class _LectureModeePageState extends ConsumerState<LectureModeePage>
    with TickerProviderStateMixin {
  bool _isRecording = false;
  bool _showNotes = false;
  bool _showBible = true;
  Duration _recordingDuration = Duration.zero;
  List<Map<String, dynamic>> _notes = [];
  final ApiBibleService _bibleService = ApiBibleService();
  final AudioRecordingService _audio = AudioRecordingService();
  Timer? _durationTimer;
  
  // PDF Mode State (Premium Feature)
  bool _isPdfMode = false;
  String? _selectedPdfPath;
  final PdfService _pdfService = PdfService();
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _audio.initialize();
  }

  @override
  void dispose() {
    _noteController.dispose();
    _audio.dispose();
    _durationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768; // iPad threshold
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Modo Aula'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Source Selection Menu - Simplified
          PopupMenuButton<String>(
            icon: Icon(
              Icons.menu_book,
              color: AppTheme.primaryColor,
              size: 28,
            ),
            tooltip: 'Selecionar fonte de leitura',
            onSelected: (value) async {
              if (value == 'bible') {
                setState(() {
                  _isPdfMode = false;
                  _showBible = true;
                  _selectedPdfPath = null;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Bíblia selecionada'),
                    duration: Duration(seconds: 1),
                    backgroundColor: AppTheme.secondaryColor,
                  ),
                );
              } else if (value == 'pdf_upload') {
                await _handlePdfUpload();
              } else if (value.startsWith('pdf_')) {
                final pdfId = value.substring(4);
                final pdfPath = await _pdfService.getPdfPath(pdfId);
                if (pdfPath != null) {
                  setState(() {
                    _isPdfMode = true;
                    _showBible = false;
                    _selectedPdfPath = pdfPath;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('PDF selecionado'),
                      duration: Duration(seconds: 1),
                      backgroundColor: AppTheme.secondaryColor,
                    ),
                  );
                }
              }
            },
            itemBuilder: (context) => [
              // Bible option
              PopupMenuItem(
                value: 'bible',
                child: Row(
                  children: [
                    Icon(
                      Icons.menu_book,
                      color: !_isPdfMode ? AppTheme.primaryColor : Colors.grey[600],
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Bíblia',
                      style: TextStyle(
                        color: !_isPdfMode ? AppTheme.primaryColor : Colors.grey[600],
                        fontWeight: !_isPdfMode ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    const Spacer(),
                    if (!_isPdfMode)
                      Icon(Icons.check, color: AppTheme.primaryColor, size: 18),
                  ],
                ),
              ),
              
              // Divider
              const PopupMenuDivider(),
              
              // Upload PDF option
              PopupMenuItem(
                value: 'pdf_upload',
                child: Row(
                  children: [
                    Icon(
                      Icons.upload_file,
                      color: Colors.orange[600],
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Fazer Upload de PDF',
                      style: TextStyle(
                        color: Colors.orange[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'PREMIUM',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Dynamic PDF list will be added here
            ],
          ),
        ],
      ),
      body: isTablet ? _buildTabletLayout(context) : _buildPhoneLayout(context),
      
      // Floating Action Buttons - Clean layout without overlap
      floatingActionButton: _buildFloatingActionButtons(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      
      // Rich Notes Editor Bottom Sheet
      bottomSheet: _showNotes
          ? RichNotesEditorWidget(
              notes: _notes,
              onClose: () {
                setState(() {
                  _showNotes = false;
                });
              },
              onNoteDeleted: _deleteNote,
              onNoteAdded: _onRichNoteAdded,
              onNoteUpdated: _onRichNoteUpdated,
              currentPosition: _recordingDuration,
              audioPath: _audio.currentRecordingPath,
            )
          : null,
    );
  }

  // Tablet Layout - Split Screen
  Widget _buildTabletLayout(BuildContext context) {
    return Column(
      children: [
        // Status Bar
        _buildStatusBar(context),
        
        // Main Split Content
        Expanded(
          child: Row(
            children: [
              // Left side - Recording Controls
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color: Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                  ),
                  child: RecordingControlsWidget(
                    isRecording: _isRecording,
                    onRecordingChanged: (recording) async {
                      if (recording) {
                        await _audio.startRecording();
                      } else {
                        await _audio.stopRecording();
                      }
                      setState(() {
                        _isRecording = recording;
                      });
                    },
                    onDurationChanged: (duration) {
                      setState(() {
                        _recordingDuration = duration;
                      });
                    },
                  ),
                ),
              ),
              
              // Right side - Bible Reader
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: BibleReaderWidget(
                    onVerseSelected: _addVerseNote,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Quick notes input removed — using RichNotesEditorWidget via FAB bottomSheet
      ],
    );
  }
  
  // Phone Layout - Vertical with Expandable Controls
  Widget _buildPhoneLayout(BuildContext context) {
    return Column(
      children: [
        // Compact Recording Controls
        CompactRecordingControlsWidget(
          isRecording: _isRecording,
          duration: _recordingDuration,
          onRecordingChanged: (recording) async {
            if (recording) {
              await _audio.startRecording();
              // Reset and start local duration timer for phone layout
              _durationTimer?.cancel();
              setState(() {
                _isRecording = true;
                _recordingDuration = Duration.zero;
              });
              _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
                if (!mounted || !_isRecording) return;
                setState(() {
                  _recordingDuration += const Duration(seconds: 1);
                });
              });
            } else {
              await _audio.stopRecording();
              _durationTimer?.cancel();
              setState(() {
                _isRecording = false;
              });
            }
          },
          onDurationChanged: (duration) {
            setState(() {
              _recordingDuration = duration;
            });
          },
        ),
        
        // Main Content Area
        Expanded(
          child: _isPdfMode && _selectedPdfPath != null
              ? Container(
                  padding: const EdgeInsets.all(16),
                  child: PdfViewerWidget(
                    pdfPath: _selectedPdfPath,
                    onTextSelected: (text, reference) {
                      _addNote('PDF: $reference - $text');
                    },
                    onUploadPdf: _handlePdfUpload,
                  ),
                )
              : _showBible 
                  ? Container(
                      padding: const EdgeInsets.all(16),
                      child: BibleReaderWidget(
                        onVerseSelected: _addVerseNote,
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.menu_book_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Toque no ícone e selecione uma\nfonte de dados para leitura',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
        
        // Quick notes input removed — using RichNotesEditorWidget via FAB bottomSheet
      ],
    );
  }
  
  // Status Bar Widget
  Widget _buildStatusBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _isRecording 
            ? AppTheme.recordingColor.withOpacity(0.1)
            : Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Recording indicator
          if (_isRecording) ...[
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: AppTheme.recordingColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
          ],
          
          // Timer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _isRecording ? Colors.red[50] : Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isRecording ? Colors.red : Colors.grey,
                width: 1,
              ),
            ),
            child: Text(
              _formatDuration(_recordingDuration),
              style: TextStyle(
                color: _isRecording ? Colors.red : Colors.grey[600],
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          
          const Spacer(),
          
          // Notes count
          if (_notes.isNotEmpty) ...[
            Icon(
              Icons.note,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              '${_notes.length}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Quick Note Input Widget
  Widget _buildQuickNoteInput(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _noteController,
              decoration: InputDecoration(
                hintText: 'Adicionar anotação rápida...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              onSubmitted: _addQuickNote,
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _addQuickNote(_noteController.text),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addQuickNote(String text) {
    if (text.trim().isEmpty) return;
    
    setState(() {
      _notes.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'text': text.trim(),
        'timestamp': _recordingDuration,
        'type': 'quick',
        'createdAt': DateTime.now(),
      });
    });
    
    _noteController.clear();
    
    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Anotação adicionada'),
        duration: const Duration(seconds: 1),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _addVerseNote(String verse, String reference) {
    setState(() {
      _notes.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'text': verse,
        'reference': reference,
        'timestamp': _recordingDuration,
        'type': 'verse',
        'createdAt': DateTime.now(),
      });
    });
    
    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Versículo adicionado: $reference'),
        duration: const Duration(seconds: 2),
        backgroundColor: AppTheme.secondaryColor,
      ),
    );
  }

  void _addNote(String text) {
    setState(() {
      _notes.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'text': text,
        'timestamp': DateTime.now(),
        'type': 'quick',
      });
    });
  }

  // Handle notes added from RichNotesEditorWidget (rich content + snippet)
  void _onRichNoteAdded(Map<String, dynamic> note) {
    setState(() {
      final enriched = {
        ...note,
        // Keep original timestamp model for backward compatibility
        'timestamp': _recordingDuration,
        // Ensure createdAt exists
        'createdAt': note['createdAt'] ?? DateTime.now().toIso8601String(),
      };
      _notes.add(enriched);
    });
  }

  // Handle note updates (edit existing)
  void _onRichNoteUpdated(Map<String, dynamic> updated) {
    setState(() {
      final idx = _notes.indexWhere((n) => n['id'] == updated['id']);
      if (idx != -1) {
        _notes[idx] = {
          ..._notes[idx],
          ...updated,
        };
      } else {
        _notes.add(updated);
      }
    });
  }
  
  void _deleteNote(String noteId) {
    setState(() {
      _notes.removeWhere((note) => note['id'] == noteId);
    });
  }
  
  Future<void> _handlePdfUpload() async {
    try {
      final pdfInfo = await _pdfService.uploadPdf();
      if (pdfInfo != null) {
        setState(() {
          _isPdfMode = true;
          _showBible = false;
          _selectedPdfPath = pdfInfo['path'];
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF "${pdfInfo['name']}" carregado com sucesso!'),
            duration: const Duration(seconds: 2),
            backgroundColor: AppTheme.secondaryColor,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar PDF: $e'),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  /// Format duration for display
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  /// Build floating action button - single green button for quick notes
  Widget _buildFloatingActionButtons() {
    return FloatingActionButton(
      onPressed: () {
        setState(() {
          _showNotes = true;
        });
      },
      backgroundColor: AppTheme.secondaryColor, // Green color
      heroTag: "quick_note",
      tooltip: 'Anotações',
      child: const Icon(Icons.note_add, color: Colors.white),
    );
  }
  

}

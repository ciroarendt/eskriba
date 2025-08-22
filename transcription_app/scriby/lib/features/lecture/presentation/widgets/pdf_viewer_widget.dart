import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'dart:io';

import '../../../../shared/themes/app_theme.dart';
import '../../../lecture/data/services/pdf_service.dart';

/// PDF Viewer Widget for Premium Feature
/// Displays PDF documents with annotation capabilities during lectures
class PdfViewerWidget extends StatefulWidget {
  final String? pdfPath;
  final Function(String, String) onTextSelected; // (selectedText, pageReference)
  final VoidCallback onUploadPdf;

  const PdfViewerWidget({
    super.key,
    this.pdfPath,
    required this.onTextSelected,
    required this.onUploadPdf,
  });

  @override
  State<PdfViewerWidget> createState() => _PdfViewerWidgetState();
}

class _PdfViewerWidgetState extends State<PdfViewerWidget> {
  PDFViewController? _pdfController;
  int _currentPage = 0;
  int _totalPages = 0;
  bool _isLoading = true;
  final PdfService _pdfService = PdfService();
  List<Map<String, dynamic>> _uploadedPdfs = [];

  @override
  void initState() {
    super.initState();
    _loadUploadedPdfs();
  }

  Future<void> _loadUploadedPdfs() async {
    final pdfs = await _pdfService.getUploadedPdfs();
    if (mounted) {
      setState(() {
        _uploadedPdfs = pdfs;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.pdfPath == null || !File(widget.pdfPath!).existsSync()) {
      return _buildNoPdfView();
    }

    return Column(
      children: [
        // PDF Controls
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            border: Border(
              bottom: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.picture_as_pdf,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Documento PDF',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              if (_totalPages > 0) ...[
                Text(
                  'Página ${_currentPage + 1} de $_totalPages',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 8),
              ],
              IconButton(
                onPressed: _showPdfOptions,
                icon: const Icon(Icons.more_vert),
                color: AppTheme.primaryColor,
              ),
            ],
          ),
        ),

        // PDF Viewer
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : PDFView(
                  filePath: widget.pdfPath!,
                  enableSwipe: true,
                  swipeHorizontal: false,
                  autoSpacing: false,
                  pageFling: true,
                  pageSnap: true,
                  defaultPage: _currentPage,
                  fitPolicy: FitPolicy.BOTH,
                  preventLinkNavigation: false,
                  onRender: (pages) {
                    setState(() {
                      _totalPages = pages ?? 0;
                      _isLoading = false;
                    });
                  },
                  onViewCreated: (PDFViewController pdfViewController) {
                    _pdfController = pdfViewController;
                  },
                  onLinkHandler: (uri) {
                    // Handle PDF links if needed
                  },
                  onPageChanged: (page, total) {
                    setState(() {
                      _currentPage = page ?? 0;
                      _totalPages = total ?? 0;
                    });
                  },
                  onPageError: (page, error) {
                    print('Erro na página $page: $error');
                  },
                ),
        ),

        // Page Navigation
        if (_totalPages > 1)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(
                top: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: _currentPage > 0 ? _previousPage : null,
                  icon: const Icon(Icons.chevron_left),
                  color: _currentPage > 0 ? AppTheme.primaryColor : Colors.grey,
                ),
                TextButton(
                  onPressed: _showPageSelector,
                  child: Text(
                    'Página ${_currentPage + 1}',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _currentPage < _totalPages - 1 ? _nextPage : null,
                  icon: const Icon(Icons.chevron_right),
                  color: _currentPage < _totalPages - 1 ? AppTheme.primaryColor : Colors.grey,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildNoPdfView() {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            border: Border(
              bottom: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.picture_as_pdf,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Documentos PDF',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'PREMIUM',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Content
        Expanded(
          child: _uploadedPdfs.isEmpty
              ? _buildEmptyState()
              : _buildPdfList(),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.upload_file,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum PDF carregado',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Faça upload de um documento PDF\npara acompanhar durante a aula',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: widget.onUploadPdf,
            icon: const Icon(Icons.upload_file),
            label: const Text('Fazer Upload de PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPdfList() {
    return Column(
      children: [
        // Upload button
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: widget.onUploadPdf,
              icon: const Icon(Icons.upload_file),
              label: const Text('Fazer Upload de PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ),

        // PDF list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _uploadedPdfs.length,
            itemBuilder: (context, index) {
              final pdf = _uploadedPdfs[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(
                    Icons.picture_as_pdf,
                    color: Colors.red[600],
                  ),
                  title: Text(
                    pdf['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${_pdfService.formatFileSize(pdf['size'])} • ${_formatDate(pdf['uploadedAt'])}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => _selectPdf(pdf['path']),
                        icon: const Icon(Icons.open_in_new),
                        color: AppTheme.primaryColor,
                      ),
                      IconButton(
                        onPressed: () => _deletePdf(pdf['id']),
                        icon: const Icon(Icons.delete),
                        color: Colors.red[600],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _selectPdf(String path) {
    // This would trigger a rebuild with the selected PDF
    // Implementation depends on parent widget state management
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('PDF selecionado: ${path.split('/').last}'),
        backgroundColor: AppTheme.secondaryColor,
      ),
    );
  }

  Future<void> _deletePdf(String pdfId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir PDF'),
        content: const Text('Tem certeza que deseja excluir este documento?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _pdfService.deletePdf(pdfId);
      if (success) {
        await _loadUploadedPdfs();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PDF excluído com sucesso'),
              backgroundColor: AppTheme.secondaryColor,
            ),
          );
        }
      }
    }
  }

  void _previousPage() {
    if (_pdfController != null && _currentPage > 0) {
      _pdfController!.setPage(_currentPage - 1);
    }
  }

  void _nextPage() {
    if (_pdfController != null && _currentPage < _totalPages - 1) {
      _pdfController!.setPage(_currentPage + 1);
    }
  }

  void _showPageSelector() {
    showDialog(
      context: context,
      builder: (context) {
        int selectedPage = _currentPage + 1;
        return AlertDialog(
          title: const Text('Ir para Página'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Número da página (1-$_totalPages)',
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) {
                  selectedPage = int.tryParse(value) ?? _currentPage + 1;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedPage >= 1 && selectedPage <= _totalPages) {
                  _pdfController?.setPage(selectedPage - 1);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Ir'),
            ),
          ],
        );
      },
    );
  }

  void _showPdfOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Fazer Upload de PDF'),
            onTap: () {
              Navigator.of(context).pop();
              widget.onUploadPdf();
            },
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('Ver Todos os PDFs'),
            onTap: () {
              Navigator.of(context).pop();
              // Navigate to PDF list
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Sobre o Modo PDF'),
            onTap: () {
              Navigator.of(context).pop();
              _showPdfInfo();
            },
          ),
        ],
      ),
    );
  }

  void _showPdfInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.picture_as_pdf, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            const Text('Modo PDF Premium'),
          ],
        ),
        content: const Text(
          'O Modo PDF permite que você:\n\n'
          '• Faça upload de documentos PDF\n'
          '• Acompanhe materiais durante aulas\n'
          '• Adicione anotações por página\n'
          '• Navegue facilmente pelo documento\n\n'
          'Esta é uma funcionalidade premium do Eskriba.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Data inválida';
    }
  }
}

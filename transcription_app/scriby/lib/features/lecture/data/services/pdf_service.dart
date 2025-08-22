import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// PDF Service for Premium Feature
/// Handles PDF upload, storage, and management for lecture mode
class PdfService {
  static const String _pdfStorageFolder = 'lecture_pdfs';
  
  /// Upload and store a PDF file for lecture use
  Future<Map<String, dynamic>?> uploadPdf() async {
    try {
      // Pick PDF file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileName = result.files.single.name;
        
        // Get app documents directory
        final appDir = await getApplicationDocumentsDirectory();
        final pdfDir = Directory(path.join(appDir.path, _pdfStorageFolder));
        
        // Create directory if it doesn't exist
        if (!await pdfDir.exists()) {
          await pdfDir.create(recursive: true);
        }
        
        // Generate unique filename
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileExtension = path.extension(fileName);
        final baseName = path.basenameWithoutExtension(fileName);
        final uniqueFileName = '${baseName}_$timestamp$fileExtension';
        
        // Copy file to app directory
        final destinationPath = path.join(pdfDir.path, uniqueFileName);
        final savedFile = await file.copy(destinationPath);
        
        // Return PDF info
        return {
          'id': timestamp.toString(),
          'name': baseName,
          'originalName': fileName,
          'path': savedFile.path,
          'size': await savedFile.length(),
          'uploadedAt': DateTime.now().toIso8601String(),
        };
      }
    } catch (e) {
      print('Erro ao fazer upload do PDF: $e');
    }
    
    return null;
  }
  
  /// Get list of uploaded PDFs
  Future<List<Map<String, dynamic>>> getUploadedPdfs() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final pdfDir = Directory(path.join(appDir.path, _pdfStorageFolder));
      
      if (!await pdfDir.exists()) {
        return [];
      }
      
      final files = await pdfDir.list().toList();
      final pdfFiles = files.whereType<File>()
          .where((file) => path.extension(file.path).toLowerCase() == '.pdf')
          .toList();
      
      List<Map<String, dynamic>> pdfs = [];
      
      for (final file in pdfFiles) {
        final fileName = path.basenameWithoutExtension(file.path);
        final parts = fileName.split('_');
        final timestamp = parts.isNotEmpty ? parts.last : '';
        final originalName = parts.length > 1 
            ? parts.sublist(0, parts.length - 1).join('_')
            : fileName;
        
        final stat = await file.stat();
        
        pdfs.add({
          'id': timestamp,
          'name': originalName,
          'originalName': path.basename(file.path),
          'path': file.path,
          'size': stat.size,
          'uploadedAt': stat.modified.toIso8601String(),
        });
      }
      
      // Sort by upload date (newest first)
      pdfs.sort((a, b) => b['uploadedAt'].compareTo(a['uploadedAt']));
      
      return pdfs;
    } catch (e) {
      print('Erro ao listar PDFs: $e');
      return [];
    }
  }
  
  /// Delete a PDF file
  Future<bool> deletePdf(String pdfId) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final pdfDir = Directory(path.join(appDir.path, _pdfStorageFolder));
      
      if (!await pdfDir.exists()) {
        return false;
      }
      
      final files = await pdfDir.list().toList();
      final targetFile = files.whereType<File>()
          .firstWhere(
            (file) => path.basenameWithoutExtension(file.path).endsWith('_$pdfId'),
            orElse: () => throw Exception('PDF não encontrado'),
          );
      
      await targetFile.delete();
      return true;
    } catch (e) {
      print('Erro ao deletar PDF: $e');
      return false;
    }
  }
  
  /// Get PDF file path by ID
  Future<String?> getPdfPath(String pdfId) async {
    try {
      final pdfs = await getUploadedPdfs();
      final pdf = pdfs.firstWhere(
        (pdf) => pdf['id'] == pdfId,
        orElse: () => {},
      );
      
      return pdf['path'];
    } catch (e) {
      print('Erro ao obter caminho do PDF: $e');
      return null;
    }
  }
  
  /// Format file size for display
  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

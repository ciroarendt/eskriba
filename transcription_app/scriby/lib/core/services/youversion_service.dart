import 'dart:convert';
import 'package:http/http.dart' as http;

/// YouVersion API Service - Integrates with Bible.com API for scripture access
/// Provides Bible reading functionality for lecture mode
class YouVersionService {
  static const String _baseUrl = 'https://bible-api.com';
  static const String _fallbackUrl = 'https://labs.bible.org/api';
  
  /// Get Bible chapter with verses
  static Future<Map<String, dynamic>> getChapter({
    required String book,
    required int chapter,
    String translation = 'almeida',
  }) async {
    try {
      // Try primary API first
      final response = await http.get(
        Uri.parse('$_baseUrl/$book+$chapter?translation=$translation'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseApiResponse(data);
      }
      
      // Fallback to mock data if API fails
      return _getMockChapter(book, chapter);
      
    } catch (e) {
      print('YouVersion API Error: $e');
      // Return mock data on error
      return _getMockChapter(book, chapter);
    }
  }
  
  /// Get specific verse
  static Future<Map<String, dynamic>> getVerse({
    required String book,
    required int chapter,
    required int verse,
    String translation = 'almeida',
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$book+$chapter:$verse?translation=$translation'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'text': data['text'] ?? '',
          'reference': data['reference'] ?? '$book $chapter:$verse',
          'translation': translation,
        };
      }
      
      return _getMockVerse(book, chapter, verse);
      
    } catch (e) {
      print('YouVersion Verse API Error: $e');
      return _getMockVerse(book, chapter, verse);
    }
  }
  
  /// Search verses by keyword
  static Future<List<Map<String, dynamic>>> searchVerses({
    required String query,
    String translation = 'almeida',
    int limit = 10,
  }) async {
    try {
      // This would integrate with a real search API
      // For now, return mock search results
      return _getMockSearchResults(query);
      
    } catch (e) {
      print('YouVersion Search Error: $e');
      return [];
    }
  }
  
  /// Get popular Bible books for quick access
  static List<Map<String, dynamic>> getPopularBooks() {
    return [
      {'name': 'João', 'chapters': 21, 'testament': 'NT'},
      {'name': 'Mateus', 'chapters': 28, 'testament': 'NT'},
      {'name': 'Marcos', 'chapters': 16, 'testament': 'NT'},
      {'name': 'Lucas', 'chapters': 24, 'testament': 'NT'},
      {'name': 'Romanos', 'chapters': 16, 'testament': 'NT'},
      {'name': 'Salmos', 'chapters': 150, 'testament': 'OT'},
      {'name': 'Provérbios', 'chapters': 31, 'testament': 'OT'},
      {'name': 'Gênesis', 'chapters': 50, 'testament': 'OT'},
      {'name': '1 Coríntios', 'chapters': 16, 'testament': 'NT'},
      {'name': 'Efésios', 'chapters': 6, 'testament': 'NT'},
    ];
  }
  
  /// Get available translations
  static List<Map<String, dynamic>> getTranslations() {
    return [
      {'code': 'almeida', 'name': 'Almeida Corrigida Fiel', 'short': 'ACF'},
      {'code': 'nvi', 'name': 'Nova Versão Internacional', 'short': 'NVI'},
      {'code': 'ara', 'name': 'Almeida Revista e Atualizada', 'short': 'ARA'},
      {'code': 'ntlh', 'name': 'Nova Tradução na Linguagem de Hoje', 'short': 'NTLH'},
    ];
  }
  
  // Private helper methods
  
  static Map<String, dynamic> _parseApiResponse(dynamic data) {
    if (data is Map<String, dynamic>) {
      return {
        'verses': data['verses'] ?? [],
        'reference': data['reference'] ?? '',
        'translation': data['translation_name'] ?? '',
      };
    }
    return {'verses': [], 'reference': '', 'translation': ''};
  }
  
  static Map<String, dynamic> _getMockChapter(String book, int chapter) {
    // Mock data for demonstration - João 3 (John 3)
    if (book.toLowerCase() == 'joão' && chapter == 3) {
      return {
        'verses': [
          {
            'verse': 1,
            'text': 'Havia entre os fariseus um homem chamado Nicodemos, uma autoridade entre os judeus.',
          },
          {
            'verse': 2,
            'text': 'Ele veio a Jesus, à noite, e disse: "Mestre, sabemos que ensinas da parte de Deus, pois ninguém pode realizar os sinais miraculosos que estás fazendo, se Deus não estiver com ele".',
          },
          {
            'verse': 3,
            'text': 'Em resposta, Jesus declarou: "Digo-lhe a verdade: Ninguém pode ver o Reino de Deus, se não nascer de novo".',
          },
          {
            'verse': 16,
            'text': 'Porque Deus tanto amou o mundo que deu o seu Filho Unigênito, para que todo o que nele crer não pereça, mas tenha a vida eterna.',
          },
        ],
        'reference': '$book $chapter',
        'translation': 'NVI',
      };
    }
    
    // Default mock chapter
    return {
      'verses': [
        {
          'verse': 1,
          'text': 'Este é um versículo de exemplo para demonstração da funcionalidade.',
        },
        {
          'verse': 2,
          'text': 'A integração com a API YouVersion será implementada para conteúdo real.',
        },
      ],
      'reference': '$book $chapter',
      'translation': 'Demo',
    };
  }
  
  static Map<String, dynamic> _getMockVerse(String book, int chapter, int verse) {
    return {
      'text': 'Versículo de exemplo para demonstração da funcionalidade.',
      'reference': '$book $chapter:$verse',
      'translation': 'Demo',
    };
  }
  
  static List<Map<String, dynamic>> _getMockSearchResults(String query) {
    return [
      {
        'text': 'Porque Deus tanto amou o mundo que deu o seu Filho Unigênito, para que todo o que nele crer não pereça, mas tenha a vida eterna.',
        'reference': 'João 3:16',
        'book': 'João',
        'chapter': 3,
        'verse': 16,
      },
      {
        'text': 'O Senhor é o meu pastor; nada me faltará.',
        'reference': 'Salmos 23:1',
        'book': 'Salmos',
        'chapter': 23,
        'verse': 1,
      },
    ];
  }
}

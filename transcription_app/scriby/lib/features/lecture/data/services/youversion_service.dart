import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';

/// API.Bible Service
/// Provides access to Bible verses, books, and translations via API.Bible
/// Documentation: https://api.scripture.api.bible
class ApiBibleService {
  /// Make HTTP GET request to API.Bible
  static Future<Map<String, dynamic>> _makeRequest(String endpoint) async {
    // Check if we have a valid API key first
    if (!ApiConfig.hasValidApiKey) {
      ApiConfig.logRequest('$endpoint (usando dados mock - sem chave API)');
      return _getMockData(endpoint);
    }
    
    ApiConfig.logRequest(endpoint);
    
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.apiBibleBaseUrl}$endpoint'),
        headers: ApiConfig.apiBibleHeaders,
      ).timeout(Duration(seconds: ApiConfig.requestTimeoutSeconds));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        final error = 'API Key inválida. Configure sua chave da API.Bible';
        ApiConfig.logError('$error (Status: ${response.statusCode})');
        // Fallback to mock data instead of throwing
        return _getMockData(endpoint);
      } else if (response.statusCode == 429) {
        final error = 'Limite de requisições excedido. Tente novamente em alguns minutos.';
        ApiConfig.logError('$error (Status: ${response.statusCode})');
        // Fallback to mock data instead of throwing
        return _getMockData(endpoint);
      } else {
        final error = 'Erro na API: ${response.statusCode}';
        ApiConfig.logError('$error - ${response.body}');
        // Fallback to mock data instead of throwing
        return _getMockData(endpoint);
      }
    } catch (e) {
      ApiConfig.logError('Erro na requisição: $e');
      // Fallback to mock data if API fails
      return _getMockData(endpoint);
    }
  }
  

  
  /// Fallback mock data for when API is unavailable
  static Map<String, dynamic> _getMockData(String endpoint) {
    // Return mock data based on endpoint
    if (endpoint.contains('/books')) {
      return {
        'data': [
          {'id': 'JHN', 'name': 'João', 'nameLong': 'Evangelho de João'},
          {'id': 'MAT', 'name': 'Mateus', 'nameLong': 'Evangelho de Mateus'},
          {'id': 'PSA', 'name': 'Salmos', 'nameLong': 'Livro dos Salmos'},
          {'id': 'ROM', 'name': 'Romanos', 'nameLong': 'Carta aos Romanos'},
          {'id': 'GEN', 'name': 'Gênesis', 'nameLong': 'Livro de Gênesis'},
          {'id': 'PRO', 'name': 'Provérbios', 'nameLong': 'Livro de Provérbios'},
        ]
      };
    } else if (endpoint.contains('/chapters')) {
      if (endpoint.contains('JHN')) {
        return {
          'data': [
            {'id': 'JHN.1', 'number': '1', 'reference': 'João 1'},
            {'id': 'JHN.3', 'number': '3', 'reference': 'João 3'},
            {'id': 'JHN.14', 'number': '14', 'reference': 'João 14'},
          ]
        };
      } else if (endpoint.contains('ROM')) {
        return {
          'data': [
            {'id': 'ROM.8', 'number': '8', 'reference': 'Romanos 8'},
            {'id': 'ROM.12', 'number': '12', 'reference': 'Romanos 12'},
          ]
        };
      }
    } else if (endpoint.contains('JHN.3?') || endpoint.contains('JHN.3/')) {
      return {
        'data': {
          'content': '''1 Havia entre os fariseus um homem chamado Nicodemos, uma autoridade entre os judeus.
2 Ele veio a Jesus, à noite, e disse: "Mestre, sabemos que ensinas da parte de Deus, pois ninguém pode realizar os sinais que fazes, se Deus não estiver com ele".
3 Em resposta, Jesus declarou: "Digo-lhe a verdade: Ninguém pode ver o Reino de Deus, se não nascer de novo".
16 Porque Deus tanto amou o mundo que deu o seu Filho Unigênito, para que todo o que nele crer não pereça, mas tenha a vida eterna.'''
        }
      };
    } else if (endpoint.contains('ROM.8?') || endpoint.contains('ROM.8/')) {
      return {
        'data': {
          'content': '''28 Sabemos que Deus age em todas as coisas para o bem daqueles que o amam, dos que foram chamados de acordo com o seu propósito.
31 Que diremos, pois, diante dessas coisas? Se Deus é por nós, quem será contra nós?
38 Pois estou convencido de que nem morte nem vida, nem anjos nem demônios, nem o presente nem o futuro, nem quaisquer poderes,
39 nem altura nem profundidade, nem qualquer outra coisa na criação será capaz de nos separar do amor de Deus que está em Cristo Jesus, nosso Senhor.'''
        }
      };
    }
    return {'data': []};
  }
  
  /// Get available Bibles
  Future<List<Map<String, dynamic>>> getBibles({String language = 'por'}) async {
    final response = await _makeRequest('/bibles?language=$language');
    return List<Map<String, dynamic>>.from(response['data'] ?? []);
  }
  
  /// Get available Bible books for a specific Bible
  Future<List<Map<String, dynamic>>> getBooks({String? bibleId}) async {
    final id = bibleId ?? ApiConfig.defaultBibleId;
    final response = await _makeRequest('/bibles/$id/books');
    return List<Map<String, dynamic>>.from(response['data'] ?? []);
  }
  
  /// Get chapters for a specific book
  Future<List<Map<String, dynamic>>> getChapters(String bookId, {String? bibleId}) async {
    final id = bibleId ?? ApiConfig.defaultBibleId;
    final response = await _makeRequest('/bibles/$id/books/$bookId/chapters');
    return List<Map<String, dynamic>>.from(response['data'] ?? []);
  }
  
  /// Get verses for a specific chapter
  Future<List<Map<String, dynamic>>> getVerses(String chapterId, {String? bibleId}) async {
    final id = bibleId ?? ApiConfig.defaultBibleId;
    final response = await _makeRequest('/bibles/$id/chapters/$chapterId/verses');
    return List<Map<String, dynamic>>.from(response['data'] ?? []);
  }
  
  /// Get a specific chapter with all verses
  Future<Map<String, dynamic>> getChapter(String chapterId, {String? bibleId}) async {
    final id = bibleId ?? ApiConfig.defaultBibleId;
    final response = await _makeRequest('/bibles/$id/chapters/$chapterId?content-type=text&include-verse-numbers=true');
    return response['data'] ?? {};
  }
  
  /// Get a specific verse
  Future<Map<String, dynamic>> getVerse(String verseId, {String? bibleId}) async {
    final id = bibleId ?? ApiConfig.defaultBibleId;
    final response = await _makeRequest('/bibles/$id/verses/$verseId?content-type=text');
    return response['data'] ?? {};
  }
  
  /// Get a passage (can be multiple verses)
  Future<Map<String, dynamic>> getPassage(String passageId, {String? bibleId}) async {
    final id = bibleId ?? ApiConfig.defaultBibleId;
    final response = await _makeRequest('/bibles/$id/passages/$passageId?content-type=text&include-verse-numbers=true');
    return response['data'] ?? {};
  }
  
  /// Search for verses containing specific text
  Future<Map<String, dynamic>> searchVerses(String query, {String? bibleId, int limit = 10, int offset = 0}) async {
    final id = bibleId ?? ApiConfig.defaultBibleId;
    final encodedQuery = Uri.encodeComponent(query);
    final response = await _makeRequest('/bibles/$id/search?query=$encodedQuery&limit=$limit&offset=$offset');
    return response['data'] ?? {};
  }
  
  /// Get popular Bible passages (hardcoded list of well-known verses)
  Future<List<Map<String, dynamic>>> getPopularVerses({String? bibleId}) async {
    final id = bibleId ?? ApiConfig.defaultBibleId;
    
    // Popular verse references
    final popularRefs = [
      'JHN.3.16', // João 3:16
      'PSA.23.1', // Salmos 23:1
      'MAT.5.3',  // Mateus 5:3
      'ROM.8.28', // Romanos 8:28
      'PHI.4.13', // Filipenses 4:13
      'JER.29.11', // Jeremias 29:11
      'PSA.119.105', // Salmos 119:105
      'ISA.40.31', // Isaías 40:31
    ];
    
    final results = <Map<String, dynamic>>[];
    
    for (final ref in popularRefs) {
      try {
        final verse = await getVerse(ref, bibleId: id);
        if (verse.isNotEmpty) {
          results.add({
            ...verse,
            'isPopular': true,
          });
        }
      } catch (e) {
        // Skip verses that fail to load
        continue;
      }
    }
    
    return results;
  }
  
  /// Get verse of the day (rotates through popular verses)
  Future<Map<String, dynamic>> getVerseOfTheDay({String? bibleId}) async {
    final popular = await getPopularVerses(bibleId: bibleId);
    
    if (popular.isEmpty) {
      return {};
    }
    
    // Use day of year to rotate through verses
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    final selectedVerse = popular[dayOfYear % popular.length];
    
    return {
      ...selectedVerse,
      'isVerseOfTheDay': true,
      'date': DateTime.now().toIso8601String(),
    };
  }
  
  /// Helper method to get book name in Portuguese
  String getBookNameInPortuguese(String bookId) {
    final bookNames = {
      'GEN': 'Gênesis',
      'EXO': 'Êxodo',
      'LEV': 'Levítico',
      'NUM': 'Números',
      'DEU': 'Deuteronômio',
      'JOS': 'Josué',
      'JDG': 'Juízes',
      'RUT': 'Rute',
      '1SA': '1 Samuel',
      '2SA': '2 Samuel',
      '1KI': '1 Reis',
      '2KI': '2 Reis',
      '1CH': '1 Crônicas',
      '2CH': '2 Crônicas',
      'EZR': 'Esdras',
      'NEH': 'Neemias',
      'EST': 'Ester',
      'JOB': 'Jó',
      'PSA': 'Salmos',
      'PRO': 'Provérbios',
      'ECC': 'Eclesiastes',
      'SNG': 'Cantares',
      'ISA': 'Isaías',
      'JER': 'Jeremias',
      'LAM': 'Lamentações',
      'EZK': 'Ezequiel',
      'DAN': 'Daniel',
      'HOS': 'Oséias',
      'JOL': 'Joel',
      'AMO': 'Amós',
      'OBA': 'Obadias',
      'JON': 'Jonas',
      'MIC': 'Miquéias',
      'NAM': 'Naum',
      'HAB': 'Habacuque',
      'ZEP': 'Sofonias',
      'HAG': 'Ageu',
      'ZEC': 'Zacarias',
      'MAL': 'Malaquias',
      'MAT': 'Mateus',
      'MRK': 'Marcos',
      'LUK': 'Lucas',
      'JHN': 'João',
      'ACT': 'Atos',
      'ROM': 'Romanos',
      '1CO': '1 Coríntios',
      '2CO': '2 Coríntios',
      'GAL': 'Gálatas',
      'EPH': 'Efésios',
      'PHI': 'Filipenses',
      'COL': 'Colossenses',
      '1TH': '1 Tessalonicenses',
      '2TH': '2 Tessalonicenses',
      '1TI': '1 Timóteo',
      '2TI': '2 Timóteo',
      'TIT': 'Tito',
      'PHM': 'Filemom',
      'HEB': 'Hebreus',
      'JAS': 'Tiago',
      '1PE': '1 Pedro',
      '2PE': '2 Pedro',
      '1JN': '1 João',
      '2JN': '2 João',
      '3JN': '3 João',
      'JUD': 'Judas',
      'REV': 'Apocalipse',
    };
    
    return bookNames[bookId] ?? bookId;
  }
  
  /// Clean HTML content from API responses
  String cleanContent(String content) {
    // Remove HTML tags and clean up text
    return content
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .trim();
  }
}

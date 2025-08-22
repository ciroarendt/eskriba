import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/youversion_service.dart';
import '../../../../shared/themes/app_theme.dart';

/// Bible Reader Widget - Integrates with YouVersion API for scripture reading
/// Allows users to read Bible during sermons/lectures with verse selection
class BibleReaderWidget extends ConsumerStatefulWidget {
  final Function(String verse, String reference) onVerseSelected;

  const BibleReaderWidget({
    super.key,
    required this.onVerseSelected,
  });

  @override
  ConsumerState<BibleReaderWidget> createState() => _BibleReaderWidgetState();
}

class _BibleReaderWidgetState extends ConsumerState<BibleReaderWidget> {
  String _selectedBook = 'João';
  int _selectedChapter = 3;
  List<Map<String, dynamic>> _verses = [];
  bool _isLoading = false;
  String _selectedTranslation = 'NVI';
  
  final List<String> _popularBooks = [
    'João', 'Mateus', 'Marcos', 'Lucas', 'Romanos', 
    'Salmos', 'Provérbios', 'Gênesis', '1 Coríntios', 'Efésios'
  ];
  
  final List<String> _translations = ['NVI', 'ARA', 'ACF', 'NTLH'];

  @override
  void initState() {
    super.initState();
    _loadChapter();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header with book/chapter selector
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            border: Border(
              bottom: BorderSide(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              // Book and Chapter Row
              Row(
                children: [
                  // Book Selector
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: _selectedBook,
                      decoration: InputDecoration(
                        labelText: 'Livro',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: _popularBooks.map((book) {
                        return DropdownMenuItem(
                          value: book,
                          child: Text(book),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedBook = value;
                            _selectedChapter = 1;
                          });
                          _loadChapter();
                        }
                      },
                    ),
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // Chapter Selector
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      initialValue: _selectedChapter.toString(),
                      decoration: InputDecoration(
                        labelText: 'Cap.',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onFieldSubmitted: (value) {
                        final chapter = int.tryParse(value);
                        if (chapter != null && chapter > 0) {
                          setState(() {
                            _selectedChapter = chapter;
                          });
                          _loadChapter();
                        }
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Translation and Navigation Row
              Row(
                children: [
                  // Translation Selector
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedTranslation,
                      decoration: InputDecoration(
                        labelText: 'Versão',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: _translations.map((translation) {
                        return DropdownMenuItem(
                          value: translation,
                          child: Text(translation),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedTranslation = value;
                          });
                          _loadChapter();
                        }
                      },
                    ),
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // Navigation Buttons
                  IconButton(
                    onPressed: _selectedChapter > 1 ? _previousChapter : null,
                    icon: const Icon(Icons.chevron_left),
                    tooltip: 'Capítulo anterior',
                  ),
                  IconButton(
                    onPressed: _nextChapter,
                    icon: const Icon(Icons.chevron_right),
                    tooltip: 'Próximo capítulo',
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Verses Content
        Expanded(
          child: _isLoading
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Carregando capítulo...'),
                    ],
                  ),
                )
              : _verses.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.menu_book_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Capítulo não encontrado',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _verses.length,
                      itemBuilder: (context, index) {
                        final verse = _verses[index];
                        return _buildVerseCard(verse, index + 1);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildVerseCard(Map<String, dynamic> verse, int verseNumber) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      child: InkWell(
        onTap: () => _selectVerse(verse, verseNumber),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Verse Number
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    verseNumber.toString(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Verse Text
              Expanded(
                child: Text(
                  verse['text'] ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ),
              
              // Add Note Icon
              Icon(
                Icons.add_circle_outline,
                color: Colors.grey[400],
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _loadChapter() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final apiBibleService = ApiBibleService();
      
      // Get books to find the correct book ID
      final books = await apiBibleService.getBooks();
      
      // Find the book ID that matches our selected book
      String? bookId;
      for (final book in books) {
        final bookName = apiBibleService.getBookNameInPortuguese(book['id'] ?? '');
        if (bookName == _selectedBook) {
          bookId = book['id'];
          break;
        }
      }
      
      if (bookId != null) {
        // Get chapters for the book
        final chapters = await apiBibleService.getChapters(bookId);
        
        // Find the chapter ID
        String? chapterId;
        for (final chapter in chapters) {
          if (chapter['number'] == _selectedChapter.toString()) {
            chapterId = chapter['id'];
            break;
          }
        }
        
        if (chapterId != null) {
          // Get the chapter content
          final chapterData = await apiBibleService.getChapter(chapterId);
          
          // Parse the content into verses
          final content = chapterData['content'] ?? '';
          final cleanContent = apiBibleService.cleanContent(content);
          
          // Split content into verses (simple approach)
          final verseLines = cleanContent.split('\n').where((line) => line.trim().isNotEmpty).toList();
          
          final verses = <Map<String, dynamic>>[];
          for (int i = 0; i < verseLines.length; i++) {
            if (verseLines[i].trim().isNotEmpty) {
              verses.add({
                'text': verseLines[i].trim(),
                'number': i + 1,
              });
            }
          }
          
          if (mounted) {
            setState(() {
              _verses = verses.isNotEmpty ? verses : _getMockVerses();
              _isLoading = false;
            });
          }
        } else {
          // Fallback to mock data
          if (mounted) {
            setState(() {
              _verses = _getMockVerses();
              _isLoading = false;
            });
          }
        }
      } else {
        // Fallback to mock data
        if (mounted) {
          setState(() {
            _verses = _getMockVerses();
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Erro ao carregar capítulo: $e');
      // Fallback to mock data on error
      if (mounted) {
        setState(() {
          _verses = _getMockVerses();
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _getMockVerses() {
    // Mock verses for João 3 (John 3)
    if (_selectedBook == 'João' && _selectedChapter == 3) {
      return [
        {
          'text': 'Havia entre os fariseus um homem chamado Nicodemos, uma autoridade entre os judeus.',
        },
        {
          'text': 'Ele veio a Jesus, à noite, e disse: "Mestre, sabemos que ensinas da parte de Deus, pois ninguém pode realizar os sinais miraculosos que estás fazendo, se Deus não estiver com ele".',
        },
        {
          'text': 'Em resposta, Jesus declarou: "Digo-lhe a verdade: Ninguém pode ver o Reino de Deus, se não nascer de novo".',
        },
        {
          'text': 'Perguntou Nicodemos: "Como alguém pode nascer, sendo velho? É claro que não pode entrar pela segunda vez no ventre de sua mãe e renascer!"',
        },
        {
          'text': 'Respondeu Jesus: "Digo-lhe a verdade: Ninguém pode entrar no Reino de Deus, se não nascer da água e do Espírito.',
        },
        {
          'text': 'O que nasce da carne é carne, mas o que nasce do Espírito é espírito.',
        },
        {
          'text': 'Não se surpreenda pelo fato de eu ter dito: É necessário que vocês nasçam de novo.',
        },
        {
          'text': 'O vento sopra onde quer. Você o escuta, mas não pode dizer de onde vem nem para onde vai. Assim acontece com todos os nascidos do Espírito".',
        },
        {
          'text': 'Perguntou Nicodemos: "Como pode ser isso?"',
        },
        {
          'text': 'Disse Jesus: "Você é mestre em Israel e não entende essas coisas?',
        },
        {
          'text': 'Digo-lhe a verdade: Nós falamos do que conhecemos e testemunhamos do que vimos, mas vocês não aceitam o nosso testemunho.',
        },
        {
          'text': 'Eu lhes falei de coisas terrenas e vocês não creram; como crerão se lhes falar de coisas celestiais?',
        },
        {
          'text': 'Ninguém subiu ao céu, a não ser aquele que de lá desceu: o Filho do homem.',
        },
        {
          'text': 'Da mesma forma como Moisés levantou a serpente no deserto, assim também é necessário que o Filho do homem seja levantado,',
        },
        {
          'text': 'para que todo o que nele crer tenha a vida eterna.',
        },
        {
          'text': 'Porque Deus tanto amou o mundo que deu o seu Filho Unigênito, para que todo o que nele crer não pereça, mas tenha a vida eterna.',
        },
      ];
    }
    
    // Default mock verses
    return [
      {
        'text': 'Este é um versículo de exemplo para demonstração da funcionalidade.',
      },
      {
        'text': 'A integração com a API YouVersion será implementada para conteúdo real.',
      },
    ];
  }

  void _selectVerse(Map<String, dynamic> verse, int verseNumber) {
    final reference = '$_selectedBook $_selectedChapter:$verseNumber';
    widget.onVerseSelected(verse['text'] ?? '', reference);
    
    // Visual feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Versículo selecionado: $reference'),
        duration: const Duration(seconds: 1),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _previousChapter() {
    if (_selectedChapter > 1) {
      setState(() {
        _selectedChapter--;
      });
      _loadChapter();
    }
  }

  void _nextChapter() {
    setState(() {
      _selectedChapter++;
    });
    _loadChapter();
  }
}

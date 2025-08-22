/// Mock Data Service - Provides sample transcription data for development
class MockDataService {
  /// Generate sample transcription data for testing navigation and UI
  static Map<String, dynamic> getSampleTranscriptionData() {
    return {
      'transcription': {
        'id': 'mock_001',
        'content': '''Bom dia pessoal, vamos começar nossa reunião de planejamento do projeto Eskriba. 

Primeiro ponto da agenda: revisão do progresso da semana passada. O João terminou a implementação do backend Django com todas as APIs de transcrição funcionando. A Maria avançou bastante no design da interface mobile.

Segundo ponto: próximos passos. Precisamos focar na integração entre o mobile e o backend, especialmente na parte de upload de áudio e polling dos resultados.

Terceiro ponto: cronograma. Nossa meta é ter uma versão beta funcionando até o final do mês. Isso significa que precisamos acelerar os testes e a documentação.

Quarto ponto: action items. João vai trabalhar na otimização das APIs, Maria vai finalizar as telas de resultados, e Pedro vai começar os testes automatizados.

Alguma dúvida sobre os próximos passos? Perfeito, então vamos encerrar por aqui. Obrigado pessoal!''',
        'confidence': 0.92,
        'duration': 180.5,
        'language': 'pt-BR',
        'segments': [
          {
            'start': 0.0,
            'end': 8.2,
            'text': 'Bom dia pessoal, vamos começar nossa reunião de planejamento do projeto Eskriba.',
            'confidence': 0.95
          },
          {
            'start': 8.5,
            'end': 22.1,
            'text': 'Primeiro ponto da agenda: revisão do progresso da semana passada.',
            'confidence': 0.89
          },
          {
            'start': 22.4,
            'end': 35.8,
            'text': 'O João terminou a implementação do backend Django com todas as APIs de transcrição funcionando.',
            'confidence': 0.93
          },
          {
            'start': 36.1,
            'end': 45.3,
            'text': 'A Maria avançou bastante no design da interface mobile.',
            'confidence': 0.91
          },
          {
            'start': 46.0,
            'end': 58.7,
            'text': 'Segundo ponto: próximos passos. Precisamos focar na integração entre o mobile e o backend.',
            'confidence': 0.88
          },
          {
            'start': 59.0,
            'end': 72.4,
            'text': 'Especialmente na parte de upload de áudio e polling dos resultados.',
            'confidence': 0.94
          }
        ]
      },
      'analysis': {
        'summary': '''Esta foi uma reunião de planejamento do projeto Eskriba focada em revisar o progresso e definir próximos passos. 

Principais conquistas: Backend Django implementado com APIs funcionando, design mobile em progresso avançado.

Próximas prioridades: Integração mobile-backend, upload de áudio, polling de resultados, testes automatizados.

Meta: Versão beta até final do mês.''',
        'key_points': [
          'Backend Django completamente implementado com APIs funcionais',
          'Design da interface mobile em estágio avançado',
          'Foco na integração entre mobile e backend como prioridade',
          'Meta de versão beta até o final do mês estabelecida',
          'Necessidade de acelerar testes e documentação identificada'
        ],
        'topics': [
          {
            'name': 'Desenvolvimento Backend',
            'relevance': 0.95,
            'description': 'Implementação e otimização das APIs Django para transcrição'
          },
          {
            'name': 'Interface Mobile',
            'relevance': 0.88,
            'description': 'Design e desenvolvimento da aplicação Flutter'
          },
          {
            'name': 'Integração de Sistemas',
            'relevance': 0.82,
            'description': 'Conexão entre mobile e backend, upload de áudio'
          },
          {
            'name': 'Planejamento e Cronograma',
            'relevance': 0.75,
            'description': 'Definição de metas e prazos para entrega'
          },
          {
            'name': 'Testes e Qualidade',
            'relevance': 0.68,
            'description': 'Implementação de testes automatizados e documentação'
          }
        ],
        'action_items': [
          {
            'task': 'Otimizar performance das APIs de transcrição no backend Django',
            'assignee': 'João',
            'priority': 'high',
            'category': 'Backend',
            'due_date': '2024-01-25'
          },
          {
            'task': 'Finalizar implementação das telas de resultados no mobile',
            'assignee': 'Maria',
            'priority': 'high',
            'category': 'Mobile',
            'due_date': '2024-01-23'
          },
          {
            'task': 'Implementar upload de áudio e polling de resultados',
            'assignee': 'Maria',
            'priority': 'medium',
            'category': 'Integração',
            'due_date': '2024-01-28'
          },
          {
            'task': 'Desenvolver suite de testes automatizados',
            'assignee': 'Pedro',
            'priority': 'medium',
            'category': 'QA',
            'due_date': '2024-01-30'
          },
          {
            'task': 'Atualizar documentação técnica do projeto',
            'assignee': 'Pedro',
            'priority': 'low',
            'category': 'Documentação',
            'due_date': '2024-02-01'
          }
        ],
        'sentiment': {
          'overall': 'positive',
          'confidence': 0.87,
          'emotions': ['motivated', 'focused', 'collaborative']
        },
        'meeting_type': 'planning',
        'participants': ['João', 'Maria', 'Pedro'],
        'duration_minutes': 3
      },
      'metadata': {
        'created_at': '2024-01-20T14:30:00Z',
        'file_name': 'reuniao_planejamento_eskriba.wav',
        'file_size': 2048576,
        'processing_time': 12.3
      }
    };
  }

  /// Generate another sample for variety
  static Map<String, dynamic> getSampleLectureData() {
    return {
      'transcription': {
        'id': 'mock_002',
        'content': '''Hoje vamos falar sobre inteligência artificial e processamento de linguagem natural. 

A IA tem revolucionado a forma como interagimos com a tecnologia. Especificamente, o processamento de linguagem natural permite que máquinas compreendam e gerem texto humano.

Aplicações práticas incluem assistentes virtuais, tradução automática, análise de sentimentos e, claro, transcrição de áudio como estamos fazendo aqui no Eskriba.

Os modelos mais avançados, como GPT e Whisper, utilizam arquiteturas transformer que processam sequências de texto de forma muito eficiente.

Para o próximo encontro, quero que vocês pesquisem sobre fine-tuning de modelos de linguagem. Isso será fundamental para nosso projeto final.''',
        'confidence': 0.88,
        'duration': 145.2,
        'language': 'pt-BR',
        'segments': [
          {
            'start': 0.0,
            'end': 12.1,
            'text': 'Hoje vamos falar sobre inteligência artificial e processamento de linguagem natural.',
            'confidence': 0.92
          },
          {
            'start': 12.5,
            'end': 25.8,
            'text': 'A IA tem revolucionado a forma como interagimos com a tecnologia.',
            'confidence': 0.89
          }
        ]
      },
      'analysis': {
        'summary': 'Aula sobre inteligência artificial focada em processamento de linguagem natural, suas aplicações e tecnologias como GPT e Whisper.',
        'key_points': [
          'IA revoluciona interação com tecnologia',
          'NLP permite compreensão de texto por máquinas',
          'Aplicações: assistentes, tradução, análise de sentimentos',
          'Modelos transformer são muito eficientes',
          'Tarefa: pesquisar fine-tuning para projeto final'
        ],
        'topics': [
          {
            'name': 'Inteligência Artificial',
            'relevance': 0.98,
            'description': 'Conceitos fundamentais de IA e suas aplicações'
          },
          {
            'name': 'Processamento de Linguagem Natural',
            'relevance': 0.95,
            'description': 'Técnicas para compreensão de texto por máquinas'
          }
        ],
        'action_items': [
          {
            'task': 'Pesquisar sobre fine-tuning de modelos de linguagem',
            'assignee': 'Estudantes',
            'priority': 'medium',
            'category': 'Estudo',
            'due_date': 'Próximo encontro'
          }
        ],
        'sentiment': {
          'overall': 'educational',
          'confidence': 0.91,
          'emotions': ['informative', 'engaging']
        },
        'meeting_type': 'lecture',
        'participants': ['Professor', 'Estudantes'],
        'duration_minutes': 2
      }
    };
  }
}

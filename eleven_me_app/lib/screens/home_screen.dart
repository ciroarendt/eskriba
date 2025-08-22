import 'dart:io';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/audio_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isRecording = false;
  bool _isConnected = false;
  bool _isLoading = false;
  String? _currentRecordingPath;
  List<dynamic> _recordings = [];
  List<dynamic> _transcriptions = [];
  final TextEditingController _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _testConnection();
    _loadData();
  }

  Future<void> _testConnection() async {
    setState(() => _isLoading = true);
    try {
      final connected = await ApiService.testConnection();
      setState(() => _isConnected = connected);
      if (connected) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Conectado ao backend Eskriba!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Erro de conexão com o backend'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => _isConnected = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erro: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadData() async {
    try {
      final recordings = await ApiService.getRecordings();
      final transcriptions = await ApiService.getTranscriptions();
      setState(() {
        _recordings = recordings;
        _transcriptions = transcriptions;
      });
    } catch (e) {
      print('Error loading data: $e');
    }
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      // Stop recording
      final recordingPath = await AudioService.stopRecording();
      setState(() {
        _isRecording = false;
        _currentRecordingPath = recordingPath;
      });
      
      if (recordingPath != null) {
        _showUploadDialog();
      }
    } else {
      // Start recording
      final success = await AudioService.startRecording();
      if (success) {
        setState(() => _isRecording = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎤 Gravação iniciada'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Erro ao iniciar gravação'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showUploadDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gravação Concluída'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Digite um título para sua gravação:'),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: _uploadRecording,
            child: const Text('Upload'),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadRecording() async {
    if (_currentRecordingPath == null || _titleController.text.isEmpty) {
      return;
    }

    Navigator.pop(context);
    setState(() => _isLoading = true);

    try {
      final file = File(_currentRecordingPath!);
      final result = await ApiService.uploadRecording(file, _titleController.text);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Gravação enviada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      
      _titleController.clear();
      _loadData();
      
      // Start transcription automatically
      if (result['id'] != null) {
        _startTranscription(result['id'].toString());
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erro no upload: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _startTranscription(String recordingId) async {
    try {
      await ApiService.transcribeRecording(recordingId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔄 Transcrição iniciada'),
          backgroundColor: Colors.blue,
        ),
      );
      
      // Reload data after a delay to see transcription
      Future.delayed(const Duration(seconds: 3), _loadData);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erro na transcrição: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eskriba'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(
              _isConnected ? Icons.cloud_done : Icons.cloud_off,
              color: _isConnected ? Colors.green : Colors.red,
            ),
            onPressed: _testConnection,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Connection Status
                    Card(
                      child: ListTile(
                        leading: Icon(
                          _isConnected ? Icons.check_circle : Icons.error,
                          color: _isConnected ? Colors.green : Colors.red,
                        ),
                        title: Text(_isConnected ? 'Backend Conectado' : 'Backend Desconectado'),
                        subtitle: Text(_isConnected 
                            ? 'api.eskriba.app' 
                            : 'Verifique sua conexão'),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Recording Section
                    const Text(
                      'Gravação',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    
                    Center(
                      child: GestureDetector(
                        onTap: _toggleRecording,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isRecording ? Colors.red : Colors.blue,
                            boxShadow: [
                              BoxShadow(
                                color: (_isRecording ? Colors.red : Colors.blue).withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Icon(
                            _isRecording ? Icons.stop : Icons.mic,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Center(
                      child: Text(
                        _isRecording ? 'Gravando...' : 'Toque para gravar',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Recordings List
                    const Text(
                      'Gravações',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    
                    if (_recordings.isEmpty)
                      const Card(
                        child: ListTile(
                          leading: Icon(Icons.info),
                          title: Text('Nenhuma gravação encontrada'),
                          subtitle: Text('Faça sua primeira gravação!'),
                        ),
                      )
                    else
                      ..._recordings.map((recording) => Card(
                        child: ListTile(
                          leading: const Icon(Icons.audiotrack),
                          title: Text(recording['title'] ?? 'Sem título'),
                          subtitle: Text('Status: ${recording['status'] ?? 'unknown'}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.transcribe),
                            onPressed: () => _startTranscription(recording['id'].toString()),
                          ),
                        ),
                      )),
                    
                    const SizedBox(height: 32),
                    
                    // Transcriptions List
                    const Text(
                      'Transcrições',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    
                    if (_transcriptions.isEmpty)
                      const Card(
                        child: ListTile(
                          leading: Icon(Icons.info),
                          title: Text('Nenhuma transcrição encontrada'),
                          subtitle: Text('Transcrições aparecerão aqui'),
                        ),
                      )
                    else
                      ..._transcriptions.map((transcription) => Card(
                        child: ListTile(
                          leading: const Icon(Icons.text_snippet),
                          title: Text('Transcrição ${transcription['id'].toString().substring(0, 8)}...'),
                          subtitle: Text(transcription['text'] ?? 'Processando...'),
                        ),
                      )),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    AudioService.dispose();
    super.dispose();
  }
}

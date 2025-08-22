import 'package:flutter/material.dart';

import '../../features/recording/presentation/pages/home_page.dart';
import '../../features/transcription/presentation/pages/transcription_results_page.dart';

/// App Router - Simple navigation system for Eskriba
class AppRouter {
  static const String home = '/';
  static const String transcriptionResults = '/transcription-results';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
          settings: settings,
        );
        
      case transcriptionResults:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null) {
          return _errorRoute('Missing transcription data');
        }
        return MaterialPageRoute(
          builder: (_) => TranscriptionResultsPage(
            transcriptionData: args,
          ),
          settings: settings,
        );
        
      default:
        return _errorRoute('Route not found: ${settings.name}');
    }
  }

  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('Erro')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Erro de Navegação',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                  home,
                  (route) => false,
                ),
                child: const Text('Voltar ao Início'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Navigate to transcription results with data
  static void goToTranscriptionResults(
    BuildContext context,
    Map<String, dynamic> transcriptionData,
  ) {
    Navigator.pushNamed(
      context,
      transcriptionResults,
      arguments: transcriptionData,
    );
  }

  /// Navigate back to home
  static void goToHome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      home,
      (route) => false,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'shared/themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🚀 Iniciando Eskriba...');
  
  runApp(
    const ProviderScope(
      child: EskribaApp(),
    ),
  );
}



class EskribaApp extends StatelessWidget {
  const EskribaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eskriba - Intelligent Transcription',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: AppRouter.home,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}

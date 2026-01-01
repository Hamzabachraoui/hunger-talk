import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/config/app_config.dart';
import 'data/services/ollama_service.dart';
import 'data/services/api_service.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/stock_provider.dart';
import 'presentation/providers/chat_provider.dart';
import 'presentation/providers/recipe_provider.dart';
import 'core/routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser la configuration (charge l'URL depuis SharedPreferences)
  await AppConfig.initialize();
  
  // Découverte automatique de l'IP Ollama (en arrière-plan, ne bloque pas le démarrage)
  _initializeOllamaDiscovery();
  
  runApp(const HungerTalkApp());
}

// Variable globale pour stocker l'AuthProvider (sera initialisée dans HungerTalkApp)
AuthProvider? _globalAuthProvider;

// Fonction callback pour notifier AuthProvider lors d'une erreur 401
void _handleUnauthorized() {
  _globalAuthProvider?.forceLogout();
}

/// Initialise la découverte automatique de l'IP Ollama
/// S'exécute en arrière-plan pour ne pas bloquer le démarrage de l'application
void _initializeOllamaDiscovery() {
  final ollamaService = OllamaService();
  // Lancer la découverte en arrière-plan (non bloquant)
  ollamaService.autoDiscoverAndSetUrl().then((success) {
    if (success) {
      debugPrint('✅ [Main] Découverte Ollama initialisée avec succès');
    } else {
      debugPrint('⚠️ [Main] Découverte Ollama non disponible, utilisation des valeurs par défaut');
    }
  }).catchError((error) {
    debugPrint('❌ [Main] Erreur lors de l\'initialisation de la découverte Ollama: $error');
  });
}

class HungerTalkApp extends StatelessWidget {
  const HungerTalkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final authProvider = AuthProvider();
            // Enregistrer le provider globalement pour le callback
            _globalAuthProvider = authProvider;
            // Configurer le callback ApiService pour notifier AuthProvider lors d'une erreur 401
            ApiService.setOnUnauthorizedCallback(_handleUnauthorized);
            return authProvider;
          },
        ),
        ChangeNotifierProvider(create: (_) => StockProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => RecipeProvider()),
      ],
      child: MaterialApp.router(
        title: 'Hunger-Talk',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}


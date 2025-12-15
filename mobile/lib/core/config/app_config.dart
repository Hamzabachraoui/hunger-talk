import 'package:flutter/foundation.dart';
import 'config_service.dart';
import 'server_discovery_service.dart';

/// Configuration de l'application
/// L'URL du serveur peut être configurée depuis les paramètres de l'application
class AppConfig {
  // Détection automatique de l'environnement
  static bool get isProduction => const bool.fromEnvironment('dart.vm.product');
  static bool get isDevelopment => !isProduction;

  // URL du backend - peut être modifiée depuis les paramètres
  // Par défaut, utilise la valeur depuis l'environnement ou SharedPreferences
  static String _baseUrl = '';
  
  /// Récupère l'URL de base du serveur (synchrone)
  /// Assurez-vous d'appeler initialize() au démarrage de l'application
  static String get baseUrl {
    // Si pas encore initialisé, utiliser la valeur par défaut
    if (_baseUrl.isEmpty) {
      _baseUrl = const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'https://hunger-talk-production.up.railway.app', // Railway par défaut même en dev
      );
    }
    return _baseUrl;
  }

  /// Définit l'URL de base du serveur (et la sauvegarde)
  static Future<bool> setBaseUrl(String url) async {
    final success = await ConfigService.setServerUrl(url);
    if (success) {
      _baseUrl = url;
      printConfig();
    }
    return success;
  }

  /// Réinitialise l'URL à la valeur par défaut
  static Future<void> resetBaseUrl() async {
    await ConfigService.resetServerUrl();
    _baseUrl = await ConfigService.getServerUrl();
    printConfig();
  }

  /// Récupère l'URL de l'API (baseUrl + /api)
  static String get apiBaseUrl => '$baseUrl/api';

  /// Initialise la configuration au démarrage de l'application
  /// En production : utilise l'URL fixe (ne change jamais)
  /// En développement : peut utiliser la découverte automatique
  /// Doit être appelé avant d'utiliser baseUrl
  static Future<void> initialize({bool autoDiscover = false}) async {
    // En production, utiliser directement l'URL fixe (pas de découverte)
    if (isProduction) {
      // URL fixe pour production (Railway)
      _baseUrl = const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'https://hunger-talk-production.up.railway.app',
      );
      debugPrint('🚀 [Config] Mode PRODUCTION - URL fixe: $_baseUrl');
    } else {
      // En développement : utiliser la découverte automatique si activée
      _baseUrl = await ConfigService.getServerUrl();
      if (_baseUrl.isEmpty) {
        _baseUrl = ConfigService.defaultServerUrl;
      }
      
      if (autoDiscover) {
        final isWorking = await ConfigService.testConnection(_baseUrl);
        
        if (!isWorking) {
          debugPrint('⚠️ [Config] L\'URL sauvegardée ne fonctionne pas, découverte automatique...');
          final discoveredUrl = await ServerDiscoveryService.discoverServer();
          if (discoveredUrl != null) {
            _baseUrl = discoveredUrl;
            debugPrint('✅ [Config] Serveur découvert automatiquement: $_baseUrl');
          } else {
            debugPrint('⚠️ [Config] Aucun serveur trouvé, utilisation de l\'URL par défaut');
          }
        }
      }
    }
    
    printConfig();
  }

  // Afficher l'URL actuelle (pour debug)
  static void printConfig() {
    // ignore: avoid_print
    debugPrint('🔧 Configuration:');
    // ignore: avoid_print
    debugPrint('   Environment: ${isProduction ? "Production" : "Development"}');
    // ignore: avoid_print
    debugPrint('   Base URL: $_baseUrl');
    // ignore: avoid_print
    debugPrint('   API URL: $apiBaseUrl');
  }

  /// Permet d'injecter une URL en tests sans toucher au stockage sécurisé
  @visibleForTesting
  static void setBaseUrlForTesting(String url) {
    _baseUrl = url;
  }
}


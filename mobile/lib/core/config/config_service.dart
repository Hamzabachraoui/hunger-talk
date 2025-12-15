import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Service de gestion de la configuration de l'application
/// Permet de stocker et récupérer l'adresse IP du serveur
class ConfigService {
  static const String _serverUrlKey = 'server_base_url';

  // URL par défaut : privilégie la prod, tout en restant surchargable au build
  static const String _defaultServerUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://hunger-talk-production.up.railway.app',
  );
  
  /// Récupère l'URL par défaut (accessible depuis d'autres services)
  static String get defaultServerUrl => _defaultServerUrl;

  /// Récupère l'URL du serveur depuis le stockage local
  /// Retourne la valeur par défaut si aucune n'est sauvegardée
  static Future<String> getServerUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUrl = prefs.getString(_serverUrlKey);
      
      if (savedUrl != null && savedUrl.isNotEmpty) {
        debugPrint('🔧 [Config] URL serveur chargée depuis le stockage: $savedUrl');
        return savedUrl;
      }
      
      debugPrint('🔧 [Config] Utilisation de l\'URL par défaut: $_defaultServerUrl');
      return _defaultServerUrl;
    } catch (e) {
      debugPrint('❌ [Config] Erreur lors de la récupération de l\'URL: $e');
      return _defaultServerUrl;
    }
  }

  /// Sauvegarde l'URL du serveur dans le stockage local
  static Future<bool> setServerUrl(String url) async {
    try {
      // Valider l'URL
      if (!_isValidUrl(url)) {
        debugPrint('❌ [Config] URL invalide: $url');
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.setString(_serverUrlKey, url);
      
      if (success) {
        debugPrint('✅ [Config] URL serveur sauvegardée: $url');
      } else {
        debugPrint('❌ [Config] Échec de la sauvegarde de l\'URL');
      }
      
      return success;
    } catch (e) {
      debugPrint('❌ [Config] Erreur lors de la sauvegarde de l\'URL: $e');
      return false;
    }
  }

  /// Réinitialise l'URL du serveur à la valeur par défaut
  static Future<bool> resetServerUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.remove(_serverUrlKey);
      
      if (success) {
        debugPrint('✅ [Config] URL serveur réinitialisée à la valeur par défaut');
      }
      
      return success;
    } catch (e) {
      debugPrint('❌ [Config] Erreur lors de la réinitialisation: $e');
      return false;
    }
  }

  /// Vérifie si l'URL est valide
  static bool _isValidUrl(String url) {
    if (url.isEmpty) return false;
    
    // Vérifier le format de base (http:// ou https:// suivi d'une adresse)
    final uriRegex = RegExp(r'^https?://[\w\.-]+(:\d+)?/?$');
    return uriRegex.hasMatch(url);
  }

  /// Teste la connexion au serveur
  static Future<bool> testConnection(String url) async {
    try {
      final testUrl = url.endsWith('/') ? '${url}health' : '$url/health';
      
      final response = await http.get(
        Uri.parse(testUrl),
      ).timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          throw TimeoutException('La connexion a expiré');
        },
      );
      
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('❌ [Config] Erreur lors du test de connexion: $e');
      return false;
    }
  }
}

// Classe d'exception pour le timeout
class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
  
  @override
  String toString() => message;
}

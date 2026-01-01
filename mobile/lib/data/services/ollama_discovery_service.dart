import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import '../../core/config/app_config.dart';

/// Service de découverte automatique de l'IP Ollama sur le réseau local
/// 
/// Stratégie de découverte (par ordre de priorité) :
/// 1. Récupère l'IP depuis Railway (backend) - le plus rapide et fiable
/// 2. Essaie de récupérer l'IP depuis le serveur PC local (port 8001)
/// 3. Si échec, scanne le réseau local pour trouver Ollama (port 11434)
/// 4. Sauvegarde l'IP trouvée pour les prochaines utilisations
class OllamaDiscoveryService {
  static const int _ollamaPort = 11434;
  static const int _ipServerPort = 8001;
  static const Duration _timeout = Duration(seconds: 2);
  static const String _ipServerEndpoint = '/ollama-ip';
  static const String _ollamaHealthEndpoint = '/api/tags';

  /// Découvre automatiquement l'IP Ollama
  /// Retourne l'URL Ollama trouvée (ex: "http://192.168.1.100:11434"), ou null si aucune n'est trouvée
  static Future<String?> discoverOllamaIp() async {
    debugPrint('🔍 [OllamaDiscovery] Début de la découverte automatique d\'Ollama...');

    // Stratégie 1: Récupérer l'IP depuis Railway (backend) - le plus rapide et fiable
    try {
      final ipFromRailway = await _getIpFromRailway()
          .timeout(const Duration(seconds: 5));
      if (ipFromRailway != null && ipFromRailway.isNotEmpty) {
        // Vérifier que l'URL fonctionne réellement
        if (await _testOllamaConnection(ipFromRailway)) {
          debugPrint('✅ [OllamaDiscovery] IP Ollama récupérée depuis Railway: $ipFromRailway');
          return ipFromRailway;
        } else {
          debugPrint('⚠️ [OllamaDiscovery] IP depuis Railway ne fonctionne pas, continuation...');
        }
      }
    } catch (e) {
      debugPrint('⚠️ [OllamaDiscovery] Impossible de récupérer l\'IP depuis Railway: $e');
    }

    // Stratégie 2: Essayer de récupérer l'IP depuis le serveur PC local (port 8001)
    // Timeout plus court pour cette méthode (rapide si disponible)
    try {
      final ipFromServer = await _getIpFromPcServer()
          .timeout(const Duration(seconds: 5));
      if (ipFromServer != null) {
        debugPrint('✅ [OllamaDiscovery] IP Ollama récupérée depuis le serveur PC: $ipFromServer');
        return ipFromServer;
      }
    } catch (e) {
      debugPrint('⚠️ [OllamaDiscovery] Le serveur PC n\'est pas accessible: $e');
    }

    debugPrint('🔍 [OllamaDiscovery] Scan réseau direct pour trouver Ollama...');

    // Stratégie 3: Scanner le réseau local pour trouver Ollama directement
    // Timeout plus long pour le scan réseau
    try {
      final discoveredUrl = await _scanNetworkForOllama()
          .timeout(const Duration(seconds: 10));
      
      if (discoveredUrl != null) {
        debugPrint('✅ [OllamaDiscovery] Ollama découvert automatiquement: $discoveredUrl');
        return discoveredUrl;
      }
    } catch (e) {
      debugPrint('⚠️ [OllamaDiscovery] Erreur lors du scan réseau: $e');
    }

    debugPrint('❌ [OllamaDiscovery] Aucun serveur Ollama trouvé');
    return null;
  }

  /// Récupère l'IP Ollama depuis Railway (backend)
  /// Retourne l'URL Ollama complète si réussie, null sinon
  static Future<String?> _getIpFromRailway() async {
    try {
      final url = Uri.parse('${AppConfig.apiBaseUrl}/system-config/ollama');
      final response = await http
          .get(url)
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final ollamaUrl = data['ollama_base_url'] as String?;
        
        if (ollamaUrl != null && ollamaUrl.isNotEmpty) {
          // Vérifier que ce n'est pas localhost (qui ne fonctionnera pas sur téléphone)
          if (ollamaUrl.contains('localhost') || ollamaUrl.contains('127.0.0.1')) {
            debugPrint('⚠️ [OllamaDiscovery] URL Railway pointe vers localhost, ignorée');
            return null;
          }
          return ollamaUrl;
        }
      }
    } catch (e) {
      // Erreur silencieuse, on continuera avec les autres stratégies
      return null;
    }
    return null;
  }

  /// Récupère l'IP Ollama depuis le serveur PC (port 8001)
  /// Retourne l'URL Ollama complète si réussie, null sinon
  static Future<String?> _getIpFromPcServer() async {
    // Liste des préfixes réseau courants à essayer
    // Prioriser 192.168.11.x car c'est le réseau du PC détecté
    final commonPrefixes = [
      '192.168.11',  // Prioriser ce réseau (réseau du PC)
      '192.168.1',
      '192.168.0',
      '192.168.2',
      '10.0.0',
      '172.16.0',
    ];

    // Tester les adresses communes pour chaque préfixe
    // Prioriser 101 qui correspond souvent au PC (192.168.11.101 détecté)
    final commonIps = [101, 100, 1, 102, 103, 104, 105, 106, 107, 108, 109, 110];

    for (final prefix in commonPrefixes) {
      for (final ip in commonIps) {
        final serverUrl = 'http://$prefix.$ip:$_ipServerPort';
        try {
          final response = await http
              .get(
                Uri.parse('$serverUrl$_ipServerEndpoint'),
              )
              .timeout(_timeout);

          if (response.statusCode == 200) {
            final data = response.body;
            // Parser le JSON : {"ip":"192.168.1.100","url":"http://192.168.1.100:11434","port":11434}
            try {
              final jsonMatch = RegExp(r'"url"\s*:\s*"([^"]+)"').firstMatch(data);
              if (jsonMatch != null) {
                final ollamaUrl = jsonMatch.group(1);
                if (ollamaUrl != null && ollamaUrl.isNotEmpty) {
                  // Vérifier que l'URL Ollama fonctionne réellement
                  if (await _testOllamaConnection(ollamaUrl)) {
                    debugPrint('✅ [OllamaDiscovery] Serveur PC trouvé à $serverUrl');
                    return ollamaUrl;
                  }
                }
              }
            } catch (e) {
              debugPrint('⚠️ [OllamaDiscovery] Erreur lors du parsing de la réponse: $e');
            }
          }
        } catch (e) {
          // Ignorer les erreurs et continuer
        }
      }
    }

    return null;
  }

  /// Scanne le réseau local pour trouver Ollama directement
  /// Retourne l'URL Ollama trouvée, ou null si aucune n'est trouvée
  static Future<String?> _scanNetworkForOllama() async {
    // Liste des préfixes réseau courants à scanner
    // Prioriser 192.168.11.x car c'est souvent utilisé (réseau du PC détecté)
    final commonPrefixes = [
      '192.168.11',  // Prioriser ce réseau (souvent le réseau du PC)
      '192.168.1',
      '192.168.0',
      '192.168.2',
      '10.0.0',
      '172.16.0',
    ];

    for (final prefix in commonPrefixes) {
      final found = await _scanNetworkPrefix(prefix);
      if (found != null) {
        return found;
      }
    }

    return null;
  }

  /// Scanne un préfixe réseau spécifique pour trouver Ollama
  /// Optimisé: teste d'abord les adresses les plus probables avec timeout réduit
  static Future<String?> _scanNetworkPrefix(String networkPrefix) async {
    debugPrint('🔍 [OllamaDiscovery] Scan du réseau $networkPrefix.0/24 pour Ollama...');

    // 1. Tester d'abord les adresses les plus probables (avec timeout court)
    // Prioriser 101 qui correspond souvent au PC (192.168.11.101 détecté)
    final commonIps = [101, 100, 1, 102, 103, 104, 105, 106, 107, 108, 109, 110];
    
    // Tester en parallèle mais avec timeout court pour chaque IP
    for (final ip in commonIps) {
      final url = 'http://$networkPrefix.$ip:$_ollamaPort';
      final result = await _testOllamaAndReturn(url);
      if (result != null) {
        return result;
      }
    }

    // 2. Si aucune adresse commune ne fonctionne, ne pas faire de scan étendu
    // pour éviter les timeouts - le serveur IP devrait être utilisé à la place
    return null;
  }

  /// Teste une connexion à Ollama et retourne l'URL si elle réussit
  static Future<String?> _testOllamaAndReturn(String url) async {
    if (await _testOllamaConnection(url)) {
      return url;
    }
    return null;
  }

  /// Teste une connexion à Ollama (endpoint /api/tags)
  static Future<bool> _testOllamaConnection(String url) async {
    try {
      final testUrl = url.endsWith('/') 
          ? '${url.substring(0, url.length - 1)}$_ollamaHealthEndpoint'
          : '$url$_ollamaHealthEndpoint';
      
      final response = await http
          .get(Uri.parse(testUrl))
          .timeout(_timeout);

      // Ollama retourne 200 avec un JSON contenant "models" si disponible
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}


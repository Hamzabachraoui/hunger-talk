import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'config_service.dart';

/// Service de découverte automatique du serveur sur le réseau local
class ServerDiscoveryService {
  static const int _port = 8000;
  static const Duration _timeout = Duration(seconds: 2);
  static const String _healthEndpoint = '/health';

  /// Découvre automatiquement le serveur sur le réseau local
  /// Retourne l'URL du serveur trouvé, ou null si aucun serveur n'est trouvé
  static Future<String?> discoverServer() async {
    debugPrint('🔍 [Discovery] Début de la découverte automatique du serveur...');

    // 1. Essayer d'abord l'adresse sauvegardée (si elle existe)
    final savedUrl = await ConfigService.getServerUrl();
    if (savedUrl != ConfigService.defaultServerUrl) {
      debugPrint('🔍 [Discovery] Test de l\'adresse sauvegardée: $savedUrl');
      if (await _testConnection(savedUrl)) {
        debugPrint('✅ [Discovery] Serveur trouvé à l\'adresse sauvegardée: $savedUrl');
        return savedUrl;
      }
    }

    // 2. Obtenir l'adresse IP locale du téléphone
    final localIp = await _getLocalIpAddress();
    if (localIp == null) {
      debugPrint('❌ [Discovery] Impossible de déterminer l\'adresse IP locale');
      return null;
    }

    debugPrint('🔍 [Discovery] Adresse IP locale du téléphone: $localIp');

    // 3. Extraire le préfixe réseau (ex: 192.168.1)
    final networkPrefix = _extractNetworkPrefix(localIp);
    if (networkPrefix == null) {
      debugPrint('❌ [Discovery] Impossible d\'extraire le préfixe réseau');
      return null;
    }

    debugPrint('🔍 [Discovery] Préfixe réseau détecté: $networkPrefix.x');

    // 4. Scanner les adresses IP du réseau local
    final foundUrl = await _scanNetwork(networkPrefix);
    
    if (foundUrl != null) {
      debugPrint('✅ [Discovery] Serveur découvert automatiquement: $foundUrl');
      // Sauvegarder l'adresse trouvée pour les prochaines fois
      await ConfigService.setServerUrl(foundUrl);
      return foundUrl;
    }

    debugPrint('❌ [Discovery] Aucun serveur trouvé sur le réseau local');
    return null;
  }

  /// Teste une connexion à une URL donnée
  static Future<bool> _testConnection(String url) async {
    try {
      final testUrl = url.endsWith('/') 
          ? '${url.substring(0, url.length - 1)}$_healthEndpoint'
          : '$url$_healthEndpoint';
      
      final response = await http
          .get(Uri.parse(testUrl))
          .timeout(_timeout);

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Scanne le réseau local pour trouver le serveur
  /// Optimisé: teste d'abord les adresses les plus probables
  static Future<String?> _scanNetwork(String networkPrefix) async {
    debugPrint('🔍 [Discovery] Scan du réseau $networkPrefix.0/24...');

    // 1. Tester d'abord les adresses les plus probables (souvent utilisées)
    final commonIps = [1, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110];
    debugPrint('🔍 [Discovery] Test des adresses communes...');
    
    final commonFutures = commonIps.map((i) {
      final url = 'http://$networkPrefix.$i:$_port';
      return _testAndReturn(url);
    }).toList();
    
    final commonResults = await Future.wait(commonFutures);
    for (final result in commonResults) {
      if (result != null) {
        return result;
      }
    }

    // 2. Si aucune adresse commune ne fonctionne, scanner le reste
    debugPrint('🔍 [Discovery] Scan complet du réseau...');
    final allIps = List.generate(254, (i) => i + 1)
        .where((i) => !commonIps.contains(i))
        .toList();
    
    // Scanner par groupes de 30 en parallèle
    const int groupSize = 30;
    
    for (int i = 0; i < allIps.length; i += groupSize) {
      final group = allIps.skip(i).take(groupSize).toList();
      final futures = group.map((ip) {
        final url = 'http://$networkPrefix.$ip:$_port';
        return _testAndReturn(url);
      }).toList();

      final results = await Future.wait(futures);
      
      for (final result in results) {
        if (result != null) {
          return result;
        }
      }
    }

    return null;
  }

  /// Teste une URL et la retourne si la connexion réussit
  static Future<String?> _testAndReturn(String url) async {
    if (await _testConnection(url)) {
      return url;
    }
    return null;
  }

  /// Extrait le préfixe réseau depuis une adresse IP
  /// Ex: "192.168.1.100" -> "192.168.1"
  static String? _extractNetworkPrefix(String ip) {
    final parts = ip.split('.');
    if (parts.length >= 3) {
      return '${parts[0]}.${parts[1]}.${parts[2]}';
    }
    return null;
  }

  /// Obtient l'adresse IP locale du téléphone
  /// Scanne les réseaux courants pour trouver le serveur
  static Future<String?> _getLocalIpAddress() async {
    // Liste des préfixes réseau courants à scanner
    final commonPrefixes = [
      '192.168.0',
      '192.168.1',
      '192.168.11',
      '192.168.2',
      '10.0.0',
      '172.16.0',
    ];

    // Tester chaque préfixe
    for (final prefix in commonPrefixes) {
      final found = await _scanNetwork(prefix);
      if (found != null) {
        return found.replaceAll('http://', '').replaceAll(':$_port', '');
      }
    }

    return null;
  }
}

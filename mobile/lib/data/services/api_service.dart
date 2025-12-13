import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/app_constants.dart';
import '../../core/config/app_config.dart';

class ApiService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Liste des endpoints POST qui nécessitent un trailing slash (routes racine FastAPI)
  static const List<String> _postRootEndpoints = [
    '/stock',
    '/chat',
    '/recipes',
    '/shopping-list',
    '/recommendations',
  ];

  // Normaliser l'URL pour gérer les trailing slashes
  // FastAPI redirige automatiquement /api/stock vers /api/stock/ avec 307
  // Pour éviter cela, on ajoute le trailing slash directement pour les routes racine POST
  String _normalizeUrl(String endpoint, {bool isPostOnRoot = false}) {
    // Si l'endpoint commence par /, on le garde
    if (!endpoint.startsWith('/')) {
      endpoint = '/$endpoint';
    }
    
    // Pour POST sur routes racine, ajouter trailing slash
    if (isPostOnRoot && !endpoint.endsWith('/')) {
      // Enlever les query params pour l'analyse
      final endpointWithoutQuery = endpoint.split('?').first;
      
      // Vérifier si c'est une route racine connue OU si c'est 1 seul segment
      final segments = endpointWithoutQuery.split('/').where((s) => s.isNotEmpty).toList();
      final isKnownRootRoute = _postRootEndpoints.contains(endpointWithoutQuery);
      final isSingleSegment = segments.length == 1;
      
      debugPrint('   🔧 Analyse: $endpointWithoutQuery');
      debugPrint('   🔧 Segments: $segments (count: ${segments.length})');
      debugPrint('   🔧 Is known root: $isKnownRootRoute');
      debugPrint('   🔧 Is single segment: $isSingleSegment');
      
      if (isKnownRootRoute || isSingleSegment) {
        // Reconstruire avec le trailing slash et les query params si présents
        final queryPart = endpoint.contains('?') ? endpoint.substring(endpoint.indexOf('?')) : '';
        endpoint = '$endpointWithoutQuery/$queryPart';
        debugPrint('   ✅ Trailing slash ajouté: $endpoint');
      } else {
        debugPrint('   ⚠️ Pas une route racine, trailing slash non ajouté');
      }
    }
    
    final fullUrl = '${AppConfig.apiBaseUrl}$endpoint';
    debugPrint('   🔧 URL finale: $fullUrl');
    return fullUrl;
  }

  Future<String?> _getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<Map<String, String>> _getHeaders({bool requiresAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (requiresAuth) {
      final token = await _getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
        debugPrint('🔑 [API] Token présent dans headers (${token.substring(0, 20)}...)');
      } else {
        debugPrint('⚠️ [API] Token manquant ! L\'utilisateur n\'est pas authentifié.');
      }
    }

    return headers;
  }

  Future<dynamic> get(String endpoint, {bool requiresAuth = true}) async {
    try {
      // Pour GET, normaliser l'URL (sans trailing slash sauf si nécessaire)
      final normalizedUrl = _normalizeUrl(endpoint);
      final url = Uri.parse(normalizedUrl);
      final headers = await _getHeaders(requiresAuth: requiresAuth);

      debugPrint('🌐 [API] GET $url');
      debugPrint('   Headers: ${headers.keys.join(", ")}');
      if (headers.containsKey('Authorization')) {
        final authHeader = headers['Authorization']!;
        debugPrint('   🔑 Authorization: ${authHeader.substring(0, authHeader.length > 30 ? 30 : authHeader.length)}...');
      } else {
        debugPrint('   ⚠️ Authorization header manquant !');
      }

      final response = await http
          .get(url, headers: headers)
          .timeout(AppConstants.apiTimeout);

      debugPrint('📥 [API] Response: ${response.statusCode}');
      if (kDebugMode && response.statusCode >= 400) {
        debugPrint('   Body: ${response.body}');
      }

      return _handleResponse(response);
    } catch (e, stackTrace) {
      debugPrint('❌ [API] GET Error: $e');
      debugPrint('   Stack: $stackTrace');
      throw Exception('Erreur réseau: $e');
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data, {bool requiresAuth = true, Duration? timeout}) async {
    try {
      // Pour POST, détecter si c'est une route racine (1 seul segment)
      // Nettoyer l'endpoint pour l'analyse
      final cleanEndpoint = endpoint.split('?').first; // Enlever les query params
      final segments = cleanEndpoint.split('/').where((s) => s.isNotEmpty).toList();
      final isRootRoute = segments.length == 1;
      
      debugPrint('🔧 [API] POST Normalisation:');
      debugPrint('   Endpoint original: $endpoint');
      debugPrint('   Segments: $segments');
      debugPrint('   Is root route: $isRootRoute');
      
      final normalizedUrl = _normalizeUrl(endpoint, isPostOnRoot: isRootRoute);
      
      debugPrint('   URL normalisée (string): $normalizedUrl');
      
      // IMPORTANT: Uri.parse() peut modifier l'URL, vérifier après parsing
      var url = Uri.parse(normalizedUrl);
      final finalPath = url.path;
      final shouldHaveTrailing = isRootRoute && _postRootEndpoints.contains(endpoint.split('?').first);
      
      debugPrint('   URL après Uri.parse(): ${url.toString()}');
      debugPrint('   Path après parsing: $finalPath');
      debugPrint('   Path se termine par /: ${finalPath.endsWith('/')}');
      debugPrint('   Devrait avoir trailing: $shouldHaveTrailing');
      
      // Si le trailing slash a été perdu, le réajouter
      if (shouldHaveTrailing && !finalPath.endsWith('/')) {
        debugPrint('   ⚠️ Trailing slash perdu après Uri.parse(), correction...');
        final correctedPath = '$finalPath/';
        url = url.replace(path: correctedPath);
        debugPrint('   ✅ URL corrigée: ${url.toString()}');
      }
      final headers = await _getHeaders(requiresAuth: requiresAuth);

      debugPrint('🌐 [API] POST $url');
      debugPrint('   Endpoint: $endpoint');
      debugPrint('   Full URL: $url');
      debugPrint('   Requires Auth: $requiresAuth');
      if (kDebugMode) {
        debugPrint('   Data: ${jsonEncode(data)}');
        debugPrint('   Headers: $headers');
      }

      final timeoutDuration = timeout ?? AppConstants.apiTimeout;
      debugPrint('   ⏱️ Timeout: ${timeoutDuration.inSeconds}s');
      
      final response = await http
          .post(
            url,
            headers: headers,
            body: jsonEncode(data),
          )
          .timeout(timeoutDuration);

      debugPrint('📥 [API] POST Response: ${response.statusCode}');
      debugPrint('   Request URL: ${response.request?.url}');
      debugPrint('   Body: ${response.body}');
      if (kDebugMode) {
        debugPrint('   Headers: ${response.headers}');
      }
      
      // Détecter et gérer les redirections 307/308
      if (response.statusCode == 307 || response.statusCode == 308) {
        final location = response.headers['location'] ?? response.headers['Location'] ?? '';
        debugPrint('⚠️ [API] Redirection ${response.statusCode} détectée!');
        debugPrint('   URL demandée: ${response.request?.url}');
        debugPrint('   Location: $location');
        debugPrint('   ⚠️ Le client HTTP ne suit pas les redirections pour POST');
        throw Exception('Erreur 307: Redirection détectée. L\'URL devrait être: $location');
      }
      
      // Pour les erreurs, afficher toujours le body
      if (response.statusCode >= 400) {
        debugPrint('   ⚠️ Erreur détectée, body complet: ${response.body}');
      }

      final result = _handleResponse(response);
      debugPrint('📦 [API] POST Parsed result type: ${result.runtimeType}');
      debugPrint('📦 [API] POST Parsed result: $result');
      return result;
    } catch (e, stackTrace) {
      debugPrint('❌ [API] POST Error: $e');
      debugPrint('   Stack: $stackTrace');
      throw Exception('Erreur réseau: $e');
    }
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> data, {bool requiresAuth = true}) async {
    try {
      // Pour PUT, normaliser l'URL
      final normalizedUrl = _normalizeUrl(endpoint);
      final url = Uri.parse(normalizedUrl);
      final headers = await _getHeaders(requiresAuth: requiresAuth);

      final response = await http
          .put(
            url,
            headers: headers,
            body: jsonEncode(data),
          )
          .timeout(AppConstants.apiTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  Future<dynamic> delete(String endpoint, {bool requiresAuth = true}) async {
    try {
      // Pour DELETE, normaliser l'URL
      final normalizedUrl = _normalizeUrl(endpoint);
      final url = Uri.parse(normalizedUrl);
      final headers = await _getHeaders(requiresAuth: requiresAuth);

      final response = await http
          .delete(url, headers: headers)
          .timeout(AppConstants.apiTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        debugPrint('⚠️ [API] Réponse vide (status ${response.statusCode})');
        // Pour les méthodes DELETE, une réponse vide est normale
        if (response.request?.method == 'DELETE') {
          return {'success': true};
        }
        return null;
      }
      try {
        final decoded = jsonDecode(response.body);
        return decoded;
      } catch (e) {
        debugPrint('❌ [API] JSON Parse Error: $e');
        debugPrint('   Status: ${response.statusCode}');
        debugPrint('   Body: ${response.body}');
        throw Exception('Erreur de parsing JSON: $e');
      }
    } else if (response.statusCode == 401) {
      debugPrint('🔒 [API] Unauthorized (401)');
      debugPrint('   Body: ${response.body}');
      try {
        final error = jsonDecode(response.body);
        final detail = error['detail'] ?? 'Non authentifié. Veuillez vous reconnecter.';
        debugPrint('   Detail: $detail');
        throw Exception(detail);
      } catch (e) {
        // Si le parsing échoue, utiliser le message générique
        if (e is Exception && e.toString().contains('detail')) {
          rethrow;
        }
        throw Exception('Non authentifié. Veuillez vous reconnecter. (${response.body})');
      }
    } else if (response.statusCode == 404) {
      debugPrint('🔍 [API] Not Found (404)');
      throw Exception('Ressource non trouvée');
    } else if (response.statusCode >= 500) {
      debugPrint('💥 [API] Server Error (${response.statusCode})');
      debugPrint('   Body: ${response.body}');
      throw Exception('Erreur serveur. Veuillez réessayer plus tard.');
    } else {
      try {
        final error = jsonDecode(response.body);
        debugPrint('⚠️ [API] Error ${response.statusCode}: ${error['detail']}');
        throw Exception(error['detail'] ?? 'Une erreur est survenue');
      } catch (e) {
        debugPrint('⚠️ [API] Error ${response.statusCode}: ${response.body}');
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    }
  }
}


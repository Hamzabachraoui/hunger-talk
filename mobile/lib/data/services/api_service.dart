import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/app_constants.dart';
import '../../core/config/app_config.dart';

class ApiService {
  final FlutterSecureStorage _storage;
  final http.Client _client;
  static Function()? _onUnauthorizedCallback;

  ApiService({
    FlutterSecureStorage? storage,
    http.Client? client,
  })  : _storage = storage ?? const FlutterSecureStorage(),
        _client = client ?? http.Client();

  // Méthode statique pour enregistrer un callback appelé lors d'une erreur 401
  static void setOnUnauthorizedCallback(Function() callback) {
    _onUnauthorizedCallback = callback;
  }

  // Liste des endpoints qui nécessitent un trailing slash (routes racine FastAPI)
  static const List<String> _rootEndpoints = [
    '/stock',
    '/chat',
    '/recipes',
    '/shopping-list',
    '/recommendations',
  ];

  // Normaliser l'URL pour gérer les trailing slashes
  // FastAPI redirige automatiquement /api/stock vers /api/stock/ avec 307
  // Pour éviter cela, on ajoute le trailing slash directement pour les routes racine
  String _normalizeUrl(String endpoint, {bool isPostOnRoot = false}) {
    // Si l'endpoint commence par /, on le garde
    if (!endpoint.startsWith('/')) {
      endpoint = '/$endpoint';
    }
    
    // Enlever les query params pour l'analyse
    final endpointWithoutQuery = endpoint.split('?').first;
    final queryPart = endpoint.contains('?') ? endpoint.substring(endpoint.indexOf('?')) : '';
    
    // Vérifier si c'est une route racine connue
    final isKnownRootRoute = _rootEndpoints.contains(endpointWithoutQuery);
    
    // Ajouter trailing slash si:
    // 1. C'est une requête POST sur route racine (isPostOnRoot), OU
    // 2. C'est une route racine connue (GET ou POST) et on n'a pas déjà un trailing slash
    final shouldAddTrailingSlash = (isPostOnRoot || isKnownRootRoute) && 
                                    !endpointWithoutQuery.endsWith('/');
    
    if (shouldAddTrailingSlash) {
      endpoint = '$endpointWithoutQuery/$queryPart';
      if (kDebugMode) {
        debugPrint('   ✅ Trailing slash ajouté: $endpoint');
      }
    }
    
    final fullUrl = '${AppConfig.apiBaseUrl}$endpoint';
    debugPrint('   🔧 URL finale: $fullUrl');
    return fullUrl;
  }

  Future<String?> _getToken() async {
    final token = await _storage.read(key: 'auth_token');
    if (token == null) {
      debugPrint('⚠️ [API] Token non trouvé dans le storage');
    } else {
      debugPrint('✅ [API] Token lu depuis le storage (${token.substring(0, 20)}...)');
    }
    return token;
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
      // Pour GET, normaliser l'URL (ajouter trailing slash uniquement pour routes racine connues)
      final normalizedUrl = _normalizeUrl(endpoint);
      final url = Uri.parse(normalizedUrl);
      
      // Récupérer le token AVANT de construire les headers pour éviter les problèmes de timing
      String? token;
      if (requiresAuth) {
        token = await _getToken();
        if (token == null) {
          debugPrint('❌❌❌ [API] GET $url - TOKEN MANQUANT !');
        } else {
          debugPrint('✅✅✅ [API] GET $url - Token trouvé (${token.substring(0, 20)}...)');
        }
      }
      
      final headers = await _getHeaders(requiresAuth: requiresAuth);

      debugPrint('🌐 [API] GET $url');
      debugPrint('   Requires Auth: $requiresAuth');
      debugPrint('   Headers: ${headers.keys.join(", ")}');
      if (headers.containsKey('Authorization')) {
        final authHeader = headers['Authorization']!;
        debugPrint('   🔑 Authorization: ${authHeader.substring(0, authHeader.length > 30 ? 30 : authHeader.length)}...');
      } else {
        debugPrint('   ⚠️⚠️⚠️ Authorization header MANQUANT !');
      }

      final response = await _client.get(url, headers: headers).timeout(
            AppConstants.apiTimeout,
          );

      debugPrint('📥 [API] Response: ${response.statusCode}');
      if (kDebugMode && response.statusCode >= 400) {
        debugPrint('   Body: ${response.body}');
      }

      return await _handleResponse(response);
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
      final shouldHaveTrailing = isRootRoute && _rootEndpoints.contains(endpoint.split('?').first);
      
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
      
      final response = await _client
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

      final result = await _handleResponse(response);
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

      final response = await _client
          .put(
            url,
            headers: headers,
            body: jsonEncode(data),
          )
          .timeout(AppConstants.apiTimeout);

      return await _handleResponse(response);
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

      final response = await _client
          .delete(url, headers: headers)
          .timeout(AppConstants.apiTimeout);

      return await _handleResponse(response);
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  Future<dynamic> _handleResponse(http.Response response) async {
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
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      debugPrint('🔒 [API] Unauthorized/Forbidden (${response.statusCode})');
      debugPrint('   Body: ${response.body}');
      
      // Vérifier si le token existe encore (pour éviter de supprimer plusieurs fois)
      final existingToken = await _storage.read(key: 'auth_token');
      if (existingToken != null) {
        // Supprimer le token invalide du storage
        await _storage.delete(key: 'auth_token');
        debugPrint('🗑️ [API] Token supprimé du storage (erreur ${response.statusCode})');
        
        // Notifier le callback si défini (pour synchroniser avec AuthProvider)
        if (_onUnauthorizedCallback != null) {
          debugPrint('📢 [API] Notification de déconnexion à AuthProvider');
          _onUnauthorizedCallback!();
        }
      } else {
        debugPrint('⚠️ [API] Token déjà supprimé du storage');
      }
      
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


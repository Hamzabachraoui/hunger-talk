import 'package:flutter/foundation.dart';
import 'api_service.dart';
import '../../core/constants/app_constants.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final data = {
      'email': email,
      'password': password,
    };

    debugPrint('🔐 [AUTH] Tentative de connexion pour: $email');
    
    final response = await _apiService.post(
      AppConstants.authLogin,
      data,
      requiresAuth: false,
    );

    debugPrint('📦 [AUTH] Type de réponse: ${response.runtimeType}');
    debugPrint('📦 [AUTH] Réponse: $response');

    // Vérifier que la réponse n'est pas null et est un Map
    if (response == null) {
      debugPrint('❌ [AUTH] Réponse null');
      throw Exception('Réponse vide du serveur');
    }
    
    if (response is! Map) {
      debugPrint('❌ [AUTH] Réponse n\'est pas un Map: ${response.runtimeType}');
      throw Exception('Format de réponse invalide: ${response.runtimeType}. Réponse: $response');
    }

    // Convertir en Map<String, dynamic> si nécessaire
    final Map<String, dynamic> responseMap = Map<String, dynamic>.from(response);
    debugPrint('✅ [AUTH] Réponse valide: $responseMap');
    
    return responseMap;
  }

  Future<Map<String, dynamic>> register(
    String email,
    String password,
    String firstName,
    String lastName,
  ) async {
    final data = {
      'email': email,
      'password': password,
      'first_name': firstName,
      'last_name': lastName,
    };

    debugPrint('📝 [AUTH] Tentative d\'inscription pour: $email');
    
    final response = await _apiService.post(
      AppConstants.authRegister,
      data,
      requiresAuth: false,
    );

    debugPrint('📦 [AUTH] Type de réponse: ${response.runtimeType}');
    debugPrint('📦 [AUTH] Réponse: $response');

    // Vérifier que la réponse n'est pas null et est un Map
    if (response == null) {
      debugPrint('❌ [AUTH] Réponse null');
      throw Exception('Réponse vide du serveur');
    }
    
    if (response is! Map) {
      debugPrint('❌ [AUTH] Réponse n\'est pas un Map: ${response.runtimeType}');
      throw Exception('Format de réponse invalide: ${response.runtimeType}. Réponse: $response');
    }

    // Convertir en Map<String, dynamic> si nécessaire
    final Map<String, dynamic> responseMap = Map<String, dynamic>.from(response);
    debugPrint('✅ [AUTH] Réponse valide: $responseMap');
    
    return responseMap;
  }

  Future<void> logout(String token) async {
    await _apiService.post(AppConstants.authLogout, {}, requiresAuth: true);
  }
}


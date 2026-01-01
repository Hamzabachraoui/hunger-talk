import 'package:flutter/foundation.dart';
import 'api_service.dart';
import '../../core/constants/app_constants.dart';
import '../models/user_model.dart';

class UserProfileService {
  final ApiService _apiService = ApiService();

  Future<UserModel> getProfile() async {
    debugPrint('👤 [PROFILE] Récupération du profil...');
    final response = await _apiService.get(AppConstants.userProfile);
    if (response == null || response is! Map<String, dynamic>) {
      throw Exception('Format de réponse invalide: attendu Map, reçu ${response?.runtimeType ?? "null"}');
    }
    debugPrint('✅ [PROFILE] Profil récupéré');
    return UserModel.fromJson(response);
  }

  Future<UserModel> updateProfile({
    String? firstName,
    String? lastName,
  }) async {
    debugPrint('👤 [PROFILE] Mise à jour du profil...');
    final data = <String, dynamic>{};
    if (firstName != null) {
      data['first_name'] = firstName;
    }
    if (lastName != null) {
      data['last_name'] = lastName;
    }
    
    final response = await _apiService.put(AppConstants.userProfile, data);
    if (response == null || response is! Map<String, dynamic>) {
      throw Exception('Format de réponse invalide: attendu Map, reçu ${response?.runtimeType ?? "null"}');
    }
    debugPrint('✅ [PROFILE] Profil mis à jour');
    return UserModel.fromJson(response);
  }
}


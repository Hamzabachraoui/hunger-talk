import 'api_service.dart';
import '../../core/constants/app_constants.dart';

class UserPreferencesService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> getPreferences() async {
    final response = await _apiService.get(AppConstants.userPreferences);
    if (response == null || response is! Map<String, dynamic>) {
      throw Exception('Format de réponse invalide: attendu Map, reçu ${response?.runtimeType ?? "null"}');
    }
    return response;
  }

  Future<Map<String, dynamic>> updatePreferences(Map<String, dynamic> preferences) async {
    final response = await _apiService.put(AppConstants.userPreferences, preferences);
    if (response == null || response is! Map<String, dynamic>) {
      throw Exception('Format de réponse invalide: attendu Map, reçu ${response?.runtimeType ?? "null"}');
    }
    return response;
  }
}


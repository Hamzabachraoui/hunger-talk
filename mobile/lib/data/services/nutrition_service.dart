import 'api_service.dart';
import '../../core/constants/app_constants.dart';

class NutritionService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> getDailyNutrition({String? targetDate}) async {
    final queryParams = <String, String>{};
    if (targetDate != null) queryParams['target_date'] = targetDate;

    final queryString = queryParams.isEmpty
        ? ''
        : '?${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}';

    final response = await _apiService.get('${AppConstants.nutritionDaily}$queryString');
    if (response == null || response is! Map<String, dynamic>) {
      throw Exception('Format de réponse invalide: attendu Map, reçu ${response?.runtimeType ?? "null"}');
    }
    return response;
  }

  Future<Map<String, dynamic>> getWeeklyNutrition() async {
    final response = await _apiService.get(AppConstants.nutritionWeekly);
    if (response == null || response is! Map<String, dynamic>) {
      throw Exception('Format de réponse invalide: attendu Map, reçu ${response?.runtimeType ?? "null"}');
    }
    return response;
  }
}


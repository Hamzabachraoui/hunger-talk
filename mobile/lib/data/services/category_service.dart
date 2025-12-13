import 'api_service.dart';
import '../../core/constants/app_constants.dart';

class CategoryService {
  final ApiService _apiService = ApiService();

  Future<List<dynamic>> getCategories() async {
    final response = await _apiService.get(AppConstants.stockCategories);
    if (response == null) {
      return [];
    }
    if (response is! List) {
      throw Exception('Format de réponse invalide: attendu List, reçu ${response.runtimeType}');
    }
    return response;
  }
}


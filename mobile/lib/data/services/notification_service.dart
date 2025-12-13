import 'api_service.dart';
import '../../core/constants/app_constants.dart';

class NotificationService {
  final ApiService _apiService = ApiService();

  Future<List<dynamic>> getNotifications({bool? unreadOnly}) async {
    final queryParams = <String, String>{};
    if (unreadOnly != null) queryParams['unread_only'] = unreadOnly.toString();

    final queryString = queryParams.isEmpty
        ? ''
        : '?${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}';

    final response = await _apiService.get('${AppConstants.notifications}$queryString');
    if (response == null) {
      return [];
    }
    if (response is! List) {
      throw Exception('Format de réponse invalide: attendu List, reçu ${response.runtimeType}');
    }
    return response;
  }

  Future<void> markAsRead(String id) async {
    await _apiService.post('${AppConstants.notifications}/$id/read', {});
  }

  Future<void> markAllAsRead() async {
    await _apiService.post('${AppConstants.notifications}/read-all', {});
  }
}


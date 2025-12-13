import 'package:flutter/foundation.dart';
import 'api_service.dart';
import '../models/chat_message_model.dart';
import '../../core/constants/app_constants.dart';

class ChatService {
  final ApiService _apiService = ApiService();

  Future<String> sendMessage(String message) async {
    final data = {'message': message};
    debugPrint('💬 [CHAT] Envoi de message: ${message.substring(0, message.length > 50 ? 50 : message.length)}...');
    // Le chat nécessite plus de temps car l'IA peut prendre du temps à répondre
    final response = await _apiService.post(
      AppConstants.chat,
      data,
      timeout: AppConstants.chatTimeout,
    );
    debugPrint('💬 [CHAT] Réponse reçue: ${response.runtimeType}');
    if (response == null || response is! Map<String, dynamic>) {
      debugPrint('❌ [CHAT] Format de réponse invalide: ${response?.runtimeType ?? "null"}');
      throw Exception('Format de réponse invalide: attendu Map, reçu ${response?.runtimeType ?? "null"}');
    }
    if (!response.containsKey('response')) {
      debugPrint('❌ [CHAT] Clé "response" manquante. Clés disponibles: ${response.keys.toList()}');
      throw Exception('Réponse invalide: clé "response" manquante. Réponse: $response');
    }
    final aiResponse = response['response'] as String? ?? '';
    debugPrint('✅ [CHAT] Réponse IA reçue (${aiResponse.length} caractères)');
    return aiResponse;
  }

  Future<List<ChatMessageModel>> getHistory() async {
    debugPrint('💬 [CHAT] Chargement de l\'historique...');
    final response = await _apiService.get(AppConstants.chatHistory);
    if (response == null) {
      debugPrint('⚠️ [CHAT] Historique vide');
      return [];
    }
    if (response is! List) {
      debugPrint('❌ [CHAT] Format de réponse invalide: ${response.runtimeType}');
      throw Exception('Format de réponse invalide: attendu List, reçu ${response.runtimeType}');
    }
    final List<dynamic> data = response;
    debugPrint('💬 [CHAT] ${data.length} message(s) dans l\'historique');
    return data.map((json) {
      if (json is! Map<String, dynamic>) {
        debugPrint('❌ [CHAT] Format d\'élément invalide: ${json.runtimeType}');
        throw Exception('Format d\'élément invalide: attendu Map, reçu ${json.runtimeType}');
      }
      return ChatMessageModel.fromJson(json);
    }).toList();
  }
}


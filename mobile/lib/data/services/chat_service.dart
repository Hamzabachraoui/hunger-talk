import 'package:flutter/foundation.dart';
import 'api_service.dart';
import 'ollama_service.dart';
import '../models/chat_message_model.dart';
import '../../core/constants/app_constants.dart';

class ChatService {
  final ApiService _apiService = ApiService();
  final OllamaService _ollamaService = OllamaService();

  /// Envoie un message via Ollama local (architecture hybride)
  /// 
  /// 1. Récupère le contexte RAG depuis Railway
  /// 2. Appelle Ollama localement avec le contexte et streaming
  /// 3. Retourne la réponse de l'IA
  /// [onChunk] est appelé à chaque chunk reçu pour mettre à jour l'UI en temps réel
  Future<String> sendMessage(String message, {Function(String)? onChunk}) async {
    try {
      debugPrint('💬 [CHAT] Envoi de message: ${message.substring(0, message.length > 50 ? 50 : message.length)}...');
      
      // 1. Récupérer le contexte RAG depuis Railway
      debugPrint('🔍 [CHAT] Récupération du contexte depuis Railway...');
      final contextData = {'message': message};
      final contextResponse = await _apiService.post(
        '/chat/context',
        contextData,
        timeout: AppConstants.apiTimeout,
      );
      
      String? context;
      String? systemPrompt;
      
      if (contextResponse != null && contextResponse is Map<String, dynamic>) {
        context = contextResponse['context'] as String?;
        systemPrompt = contextResponse['system_prompt'] as String?;
        debugPrint('✅ [CHAT] Contexte récupéré depuis Railway (${context?.length ?? 0} caractères)');
      } else {
        debugPrint('⚠️ [CHAT] Contexte non disponible, envoi sans contexte');
      }
      
      // 2. Appeler Ollama localement avec le contexte et streaming
      debugPrint('🤖 [CHAT] Appel à Ollama local avec streaming...');
      final aiResponse = await _ollamaService.sendMessage(
        message,
        context: context,
        systemPrompt: systemPrompt,
        onChunk: onChunk, // Passer le callback pour les mises à jour progressives
      );
      
      debugPrint('✅ [CHAT] Réponse IA reçue (${aiResponse.length} caractères)');
      return aiResponse;
      
    } catch (e) {
      debugPrint('❌ [CHAT] Erreur lors de l\'envoi: $e');
      rethrow;
    }
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


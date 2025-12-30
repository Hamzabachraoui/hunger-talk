import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'api_service.dart';

/// Service pour communiquer directement avec Ollama local
class OllamaService {
  final ApiService _apiService;
  String? _ollamaBaseUrl;

  OllamaService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  /// Récupère l'URL Ollama depuis Railway et la cache
  Future<String> _getOllamaUrl() async {
    if (_ollamaBaseUrl != null) {
      return _ollamaBaseUrl!;
    }

    try {
      debugPrint('🔍 [OLLAMA] Récupération de l\'URL Ollama depuis Railway...');
      final response = await _apiService.get('/system-config/ollama');
      
      if (response != null && response is Map<String, dynamic>) {
        final url = response['ollama_base_url'] as String?;
        if (url != null && url.isNotEmpty) {
          _ollamaBaseUrl = url;
          debugPrint('✅ [OLLAMA] URL Ollama récupérée: $url');
          return url;
        }
      }
      
      // Valeur par défaut si non configurée
      debugPrint('⚠️ [OLLAMA] URL non configurée, utilisation de localhost');
      _ollamaBaseUrl = 'http://192.168.11.101:11434';
      return _ollamaBaseUrl!;
    } catch (e) {
      debugPrint('❌ [OLLAMA] Erreur lors de la récupération de l\'URL: $e');
      // Valeur par défaut en cas d'erreur
      _ollamaBaseUrl = 'http://192.168.11.101:11434';
      return _ollamaBaseUrl!;
    }
  }

  /// Envoie un message à Ollama et récupère la réponse
  /// 
  /// [message] : Le message de l'utilisateur
  /// [context] : Contexte RAG (stock, recettes, etc.) - récupéré depuis Railway
  /// [systemPrompt] : Prompt système pour Ollama
  /// 
  /// Retourne la réponse de l'IA
  Future<String> sendMessage(
    String message, {
    String? context,
    String? systemPrompt,
  }) async {
    try {
      final ollamaUrl = await _getOllamaUrl();
      
      debugPrint('💬 [OLLAMA] Envoi du message à Ollama ($ollamaUrl)...');
      
      final url = Uri.parse('$ollamaUrl/api/chat');
      
      // Construire les messages avec le contexte
      final messages = <Map<String, String>>[];
      
      // Ajouter le prompt système
      if (systemPrompt != null && systemPrompt.isNotEmpty) {
        messages.add({
          'role': 'system',
          'content': systemPrompt,
        });
      } else {
        messages.add({
          'role': 'system',
          'content': 'Tu es un assistant nutritionnel intelligent qui aide les utilisateurs à gérer leur alimentation.',
        });
      }
      
      // Construire le prompt utilisateur avec le contexte
      String userContent = message;
      if (context != null && context.isNotEmpty) {
        userContent = '$context\n\nQuestion: $message';
      }
      
      messages.add({
        'role': 'user',
        'content': userContent,
      });
      
      final payload = {
        'model': 'llama3.1:8b',
        'messages': messages,
        'stream': false,
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 120));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final aiResponse = data['message']?['content'] as String? ?? '';
        debugPrint('✅ [OLLAMA] Réponse reçue (${aiResponse.length} caractères)');
        return aiResponse;
      } else {
        debugPrint('❌ [OLLAMA] Erreur HTTP: ${response.statusCode}');
        throw Exception('Erreur Ollama: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ [OLLAMA] Erreur lors de l\'appel: $e');
      rethrow;
    }
  }

  /// Récupère le contexte utilisateur depuis Railway
  /// (stock, recettes favorites, etc.)
  Future<String?> getContext() async {
    try {
      // Appeler Railway pour obtenir le contexte RAG
      // On pourrait créer un endpoint /api/chat/context qui retourne juste le contexte
      // Pour l'instant, on retourne null (pas de contexte)
      return null;
    } catch (e) {
      debugPrint('⚠️ [OLLAMA] Impossible de récupérer le contexte: $e');
      return null;
    }
  }
}


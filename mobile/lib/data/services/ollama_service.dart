import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'ollama_discovery_service.dart';

/// Service pour communiquer directement avec Ollama local
/// OLLAMA EST MAINTENANT TOUJOURS LOCAL - Plus de connexion Railway pour Ollama
class OllamaService {
  String? _ollamaBaseUrl;
  bool _isDiscovering = false;

  OllamaService();

  /// Découvre automatiquement l'IP Ollama et la sauvegarde
  /// Cette méthode est appelée au démarrage de l'application si aucune URL n'est sauvegardée
  Future<bool> autoDiscoverAndSetUrl() async {
    // Éviter les découvertes multiples simultanées
    if (_isDiscovering) {
      debugPrint('⚠️ [OLLAMA] Découverte déjà en cours, attente...');
      return false;
    }

    // Si une URL est déjà définie, ne pas refaire la découverte
    if (_ollamaBaseUrl != null && _ollamaBaseUrl!.isNotEmpty) {
      debugPrint('ℹ️ [OLLAMA] URL déjà définie, découverte non nécessaire');
      return true;
    }

    _isDiscovering = true;
    try {
      debugPrint('🔍 [OLLAMA] Lancement de la découverte automatique...');
      final discoveredUrl = await OllamaDiscoveryService.discoverOllamaIp();
      
      if (discoveredUrl != null && discoveredUrl.isNotEmpty) {
        await setOllamaUrl(discoveredUrl);
        debugPrint('✅ [OLLAMA] Découverte automatique réussie: $discoveredUrl');
        return true;
      } else {
        debugPrint('⚠️ [OLLAMA] Découverte automatique n\'a pas trouvé d\'URL');
        return false;
      }
    } catch (e) {
      debugPrint('❌ [OLLAMA] Erreur lors de la découverte automatique: $e');
      return false;
    } finally {
      _isDiscovering = false;
    }
  }

  /// Récupère l'URL Ollama locale (plus de Railway pour Ollama)
  /// 
  /// Pour Android émulateur : utilise 10.0.2.2 (pointe vers localhost du PC)
  /// Pour téléphone physique : utilise l'IP locale du PC (détectée automatiquement ou configurée manuellement)
  /// Pour iOS : utilise localhost directement
  Future<String> _getOllamaUrl() async {
    if (_ollamaBaseUrl != null) {
      return _ollamaBaseUrl!;
    }

    // Vérifier si une URL est sauvegardée dans les préférences
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUrl = prefs.getString('ollama_base_url');
      if (savedUrl != null && savedUrl.isNotEmpty) {
        _ollamaBaseUrl = savedUrl;
        debugPrint('✅ [OLLAMA] URL Ollama chargée depuis les préférences: $savedUrl');
        return _ollamaBaseUrl!;
      }
    } catch (e) {
      debugPrint('⚠️ [OLLAMA] Erreur lors de la lecture des préférences: $e');
    }

    // Si aucune URL sauvegardée, essayer la découverte automatique
    // Timeout plus long pour permettre au scan réseau de fonctionner
    if (!_isDiscovering) {
      debugPrint('🔍 [OLLAMA] Aucune URL sauvegardée, tentative de découverte automatique...');
      try {
        final discoveredUrl = await OllamaDiscoveryService.discoverOllamaIp()
            .timeout(const Duration(seconds: 15)); // Timeout plus long pour le scan réseau
        if (discoveredUrl != null && discoveredUrl.isNotEmpty) {
          await setOllamaUrl(discoveredUrl);
          debugPrint('✅ [OLLAMA] Découverte automatique réussie: $discoveredUrl');
          return _ollamaBaseUrl!;
        }
      } catch (e) {
        debugPrint('⚠️ [OLLAMA] Découverte automatique échouée ou timeout: $e');
        debugPrint('💡 [OLLAMA] Astuce: Assurez-vous que le serveur PC est démarré (demarrer_ollama_ip_server.ps1)');
        // Continuer avec les valeurs par défaut
      }
    }

    // URL par défaut selon la plateforme
    String defaultUrl;
    
    if (Platform.isAndroid) {
      // Android émulateur : 10.0.2.2 pointe vers localhost du PC hôte
      // Pour téléphone physique, 10.0.2.2 ne fonctionnera pas - la découverte automatique est nécessaire
      defaultUrl = 'http://10.0.2.2:11434';
      debugPrint('🤖 [OLLAMA] Android détecté - URL par défaut (émulateur): $defaultUrl');
      debugPrint('⚠️ [OLLAMA] Si vous utilisez un téléphone physique, la découverte automatique doit fonctionner');
      debugPrint('⚠️ [OLLAMA] Sinon, démarrez le serveur PC: .\\demarrer_ollama_ip_server.ps1');
    } else if (Platform.isIOS) {
      // iOS : localhost fonctionne directement
      defaultUrl = 'http://localhost:11434';
      debugPrint('🤖 [OLLAMA] iOS détecté - URL: $defaultUrl');
    } else {
      // Autres plateformes (web, desktop, etc.)
      defaultUrl = 'http://localhost:11434';
      debugPrint('🤖 [OLLAMA] Autre plateforme - URL: $defaultUrl');
    }

    _ollamaBaseUrl = defaultUrl;
    debugPrint('✅ [OLLAMA] URL Ollama locale configurée (par défaut): $_ollamaBaseUrl');
    return _ollamaBaseUrl!;
  }

  /// Permet de définir manuellement l'URL Ollama (utile pour téléphone physique)
  /// L'URL sera sauvegardée dans les préférences
  Future<void> setOllamaUrl(String url) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('ollama_base_url', url);
      _ollamaBaseUrl = url;
      debugPrint('🔧 [OLLAMA] URL Ollama mise à jour et sauvegardée: $url');
    } catch (e) {
      debugPrint('❌ [OLLAMA] Erreur lors de la sauvegarde de l\'URL: $e');
      // Mettre à jour quand même en mémoire
      _ollamaBaseUrl = url;
    }
  }

  /// Envoie un message à Ollama local et récupère la réponse
  /// 
  /// [message] : Le message de l'utilisateur
  /// [context] : Contexte RAG (stock, recettes, etc.) - récupéré depuis Railway
  /// [systemPrompt] : Prompt système pour Ollama
  /// 
  /// Retourne la réponse de l'IA avec streaming
  /// 
  /// NOTE: Ollama est maintenant TOUJOURS local, plus de connexion Railway
  /// [onChunk] est appelé à chaque chunk reçu pour mettre à jour l'UI en temps réel
  Future<String> sendMessage(
    String message, {
    String? context,
    String? systemPrompt,
    Function(String)? onChunk,
  }) async {
    try {
      final ollamaUrl = await _getOllamaUrl();
      
      debugPrint('💬 [OLLAMA] Envoi du message à Ollama LOCAL ($ollamaUrl)...');
      
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
        'model': 'llama3.2:3b', // Modèle plus léger pour des réponses plus rapides
        'messages': messages,
        'stream': true, // Activer le streaming pour des réponses plus rapides
        'options': {
          'num_predict': 300, // Limiter à ~300 tokens pour des réponses plus rapides
        },
      };

      final request = http.Request('POST', url);
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(payload);

      debugPrint('📤 [OLLAMA] Requête envoyée avec streaming (modèle: llama3.2:3b)');
      final streamedResponse = await request.send().timeout(const Duration(seconds: 300));
      
      debugPrint('📥 [OLLAMA] Réponse reçue, status: ${streamedResponse.statusCode}');
      
      if (streamedResponse.statusCode == 200) {
        final buffer = StringBuffer();
        String currentLine = '';
        int chunkCount = 0;
        
        await for (final chunk in streamedResponse.stream.transform(utf8.decoder)) {
          chunkCount++;
          if (chunkCount == 1) {
            debugPrint('📦 [OLLAMA] Premier chunk reçu: ${chunk.substring(0, chunk.length > 100 ? 100 : chunk.length)}');
          }
          
          // Accumuler les chunks car ils peuvent arriver partiels
          currentLine += chunk;
          
          // Traiter les lignes complètes (séparées par \n)
          final lines = currentLine.split('\n');
          // Garder la dernière ligne incomplète pour le prochain chunk
          currentLine = lines.removeLast();
          
          for (final line in lines) {
            if (line.trim().isEmpty) continue;
            
            // Ollama peut envoyer soit "data: {...}" soit directement du JSON
            String jsonStr = line;
            if (line.startsWith('data: ')) {
              jsonStr = line.substring(6); // Enlever "data: "
            }
            
            if (jsonStr.trim() == '[DONE]') {
              debugPrint('✅ [OLLAMA] Stream terminé avec [DONE]');
              continue;
            }
            
            try {
              final data = jsonDecode(jsonStr) as Map<String, dynamic>;
              
              // Ollama peut avoir différentes structures
              String? content;
              if (data['message'] != null && data['message'] is Map) {
                content = data['message']?['content'] as String?;
              } else if (data['content'] != null) {
                content = data['content'] as String?;
              }
              
              if (content != null && content.isNotEmpty) {
                buffer.write(content);
                debugPrint('📝 [OLLAMA] Chunk reçu: ${content.length} caractères (total: ${buffer.length})');
                // Notifier le callback avec le contenu accumulé
                if (onChunk != null) {
                  onChunk(buffer.toString());
                }
              } else {
                // Log pour déboguer les chunks vides
                if (data['done'] == true) {
                  debugPrint('✅ [OLLAMA] Stream terminé (done: true)');
                } else {
                  debugPrint('⚠️ [OLLAMA] Chunk sans contenu: ${data.keys.join(", ")}');
                }
              }
            } catch (e) {
              // Log plus détaillé pour les erreurs de parsing
              debugPrint('⚠️ [OLLAMA] Erreur parsing chunk: $e');
              debugPrint('   Ligne reçue: ${line.substring(0, line.length > 200 ? 200 : line.length)}');
            }
          }
        }
        
        debugPrint('🔚 [OLLAMA] Fin du stream ($chunkCount chunks reçus)');
        
        // Traiter la dernière ligne si elle existe
        if (currentLine.trim().isNotEmpty) {
          String jsonStr = currentLine;
          if (currentLine.startsWith('data: ')) {
            jsonStr = currentLine.substring(6);
          }
          
          if (jsonStr.trim() != '[DONE]') {
            try {
              final data = jsonDecode(jsonStr) as Map<String, dynamic>;
              String? content;
              if (data['message'] != null && data['message'] is Map) {
                content = data['message']?['content'] as String?;
              } else if (data['content'] != null) {
                content = data['content'] as String?;
              }
              if (content != null && content.isNotEmpty) {
                buffer.write(content);
                if (onChunk != null) {
                  onChunk(buffer.toString());
                }
              }
            } catch (e) {
              debugPrint('⚠️ [OLLAMA] Erreur parsing dernière ligne: $e');
            }
          }
        }
        
        final fullResponse = buffer.toString();
        debugPrint('✅ [OLLAMA] Réponse complète reçue (${fullResponse.length} caractères)');
        if (fullResponse.isEmpty) {
          debugPrint('⚠️ [OLLAMA] ATTENTION: Réponse vide, vérifiez les logs ci-dessus');
        }
        return fullResponse;
      } else {
        final errorBody = await streamedResponse.stream.transform(utf8.decoder).join();
        debugPrint('❌ [OLLAMA] Erreur HTTP: ${streamedResponse.statusCode}');
        debugPrint('   Body: $errorBody');
        throw Exception('Erreur Ollama: ${streamedResponse.statusCode}');
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


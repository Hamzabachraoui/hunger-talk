import 'package:flutter/foundation.dart';
import '../../data/models/chat_message_model.dart';
import '../../data/services/chat_service.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();

  List<ChatMessageModel> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;
  String? _error;

  List<ChatMessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get error => _error;

  Future<void> loadHistory() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('💬 [CHAT PROVIDER] Chargement de l\'historique...');
      final backendMessages = await _chatService.getHistory();
      
      // Convertir chaque message backend (qui contient message + response) en deux messages séparés
      _messages = [];
      for (final backendMsg in backendMessages) {
        // Ajouter le message utilisateur
        if (backendMsg.message.isNotEmpty) {
          _messages.add(ChatMessageModel(
            id: '${backendMsg.id}_user',
            message: backendMsg.message,
            isUser: true,
            timestamp: backendMsg.timestamp,
          ));
        }
        
        // Ajouter la réponse IA
        if (backendMsg.response != null && backendMsg.response!.isNotEmpty) {
          _messages.add(ChatMessageModel(
            id: '${backendMsg.id}_ai',
            message: backendMsg.response!,
            isUser: false,
            timestamp: backendMsg.timestamp,
          ));
        }
      }
      
      // Trier par timestamp pour avoir l'ordre chronologique (les plus anciens en premier)
      _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      
      debugPrint('✅ [CHAT PROVIDER] ${_messages.length} message(s) chargé(s) depuis ${backendMessages.length} conversation(s)');
      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('❌ [CHAT PROVIDER] Erreur lors du chargement: $e');
      debugPrint('   Stack: $stackTrace');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendMessage(String message) async {
    _isSending = true;
    _error = null;
    
    // Ajouter le message utilisateur immédiatement
    final userMessage = ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: message,
      isUser: true,
      timestamp: DateTime.now(),
    );
    _messages.add(userMessage);
    notifyListeners();

    // Créer le message IA vide qui sera mis à jour progressivement avec le streaming
    final aiMessageId = (DateTime.now().millisecondsSinceEpoch + 1).toString();
    final aiMessage = ChatMessageModel(
      id: aiMessageId,
      message: '',
      isUser: false,
      timestamp: DateTime.now(),
    );
    _messages.add(aiMessage);
    notifyListeners();

    try {
      debugPrint('💬 [CHAT PROVIDER] Envoi du message avec streaming...');
      
      final response = await _chatService.sendMessage(
        message,
        onChunk: (partialResponse) {
          // Mettre à jour le message IA progressivement
          final index = _messages.indexWhere((m) => m.id == aiMessageId);
          if (index != -1) {
            _messages[index] = ChatMessageModel(
              id: aiMessageId,
              message: partialResponse,
              isUser: false,
              timestamp: _messages[index].timestamp,
            );
            notifyListeners();
          }
        },
      );
      
      // Mettre à jour avec la réponse finale (au cas où il y aurait un dernier chunk)
      final finalIndex = _messages.indexWhere((m) => m.id == aiMessageId);
      if (finalIndex != -1 && _messages[finalIndex].message != response) {
        _messages[finalIndex] = ChatMessageModel(
          id: aiMessageId,
          message: response,
          isUser: false,
          timestamp: _messages[finalIndex].timestamp,
        );
        notifyListeners();
      }
      
      debugPrint('✅ [CHAT PROVIDER] Message envoyé avec succès');
      
      // Recharger l'historique pour obtenir les IDs du backend et s'assurer que tout est synchronisé
      // Cela remplace les messages temporaires par les messages sauvegardés du backend
      try {
        await loadHistory();
        debugPrint('✅ [CHAT PROVIDER] Historique rechargé après envoi');
      } catch (e) {
        debugPrint('⚠️ [CHAT PROVIDER] Erreur lors du rechargement de l\'historique: $e');
        // Ne pas faire échouer l'envoi si le rechargement échoue
      }
      
      _isSending = false;
      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ [CHAT PROVIDER] Erreur lors de l\'envoi: $e');
      debugPrint('   Stack: $stackTrace');
      
      // Supprimer le message IA vide en cas d'erreur
      _messages.removeWhere((m) => m.id == aiMessageId);
      
      _error = e.toString();
      _isSending = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}


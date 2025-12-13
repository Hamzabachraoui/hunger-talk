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
      _messages = await _chatService.getHistory();
      debugPrint('✅ [CHAT PROVIDER] ${_messages.length} message(s) chargé(s)');
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

    try {
      debugPrint('💬 [CHAT PROVIDER] Envoi du message...');
      final response = await _chatService.sendMessage(message);
      
      // Ajouter la réponse de l'IA
      final aiMessage = ChatMessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        message: response,
        isUser: false,
        timestamp: DateTime.now(),
      );
      _messages.add(aiMessage);
      
      debugPrint('✅ [CHAT PROVIDER] Message envoyé avec succès');
      _isSending = false;
      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ [CHAT PROVIDER] Erreur lors de l\'envoi: $e');
      debugPrint('   Stack: $stackTrace');
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


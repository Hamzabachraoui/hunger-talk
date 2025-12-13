import 'package:equatable/equatable.dart';

class ChatMessageModel extends Equatable {
  final String id;
  final String message;
  final bool isUser;
  final DateTime timestamp;
  final String? response;

  const ChatMessageModel({
    required this.id,
    required this.message,
    required this.isUser,
    required this.timestamp,
    this.response,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    // Gérer l'ID qui peut être String, int, ou UUID
    String id;
    if (json['id'] is String) {
      id = json['id'] as String;
    } else {
      id = json['id'].toString();
    }

    // Gérer is_user qui peut être bool ou int (0/1)
    bool isUser;
    if (json['is_user'] is bool) {
      isUser = json['is_user'] as bool;
    } else if (json['is_user'] is int) {
      isUser = (json['is_user'] as int) != 0;
    } else if (json['is_user'] is String) {
      isUser = (json['is_user'] as String).toLowerCase() == 'true' || (json['is_user'] as String) == '1';
    } else {
      // Par défaut, si pas de champ, c'est un message utilisateur
      isUser = json['message'] != null && json['response'] == null;
    }

    // Gérer le timestamp
    DateTime timestamp;
    if (json['timestamp'] is DateTime) {
      timestamp = json['timestamp'] as DateTime;
    } else if (json['timestamp'] is String) {
      timestamp = DateTime.parse(json['timestamp'] as String);
    } else {
      timestamp = DateTime.now();
    }

    return ChatMessageModel(
      id: id,
      message: json['message'] as String? ?? '',
      isUser: isUser,
      timestamp: timestamp,
      response: json['response'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
    };
  }

  @override
  List<Object?> get props => [id, message, isUser, timestamp];
}


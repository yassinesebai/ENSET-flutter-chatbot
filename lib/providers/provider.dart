import 'package:chat_bot_app/models/messages_mdel.dart';
import 'package:flutter/material.dart';
import 'package:chat_bot_app/services/chat_service.dart';


class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  List<Messages> _messages = [];

  List<String> get messages => _messages.map((m) => '${m.role}: ${m.content}').toList();

  Future<void> sendMessage(String message) async {
    _messages.add(Messages(role: 'user', content: message));
    notifyListeners();

    try {
      final response = await _chatService.sendMessage(_messages);
      _messages.add(Messages(role: 'bot', content: response));
    } catch (e) {
      print('Error sending message: $e');
      _messages.add(Messages(role: 'system', content: 'Failed to get response: $e'));
    } finally {
      notifyListeners();
    }
  }
}
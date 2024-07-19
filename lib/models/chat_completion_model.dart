


import 'package:chat_bot_app/models/messages_mdel.dart';

class ChatCompletionModel {
  String model;
  List<Messages> messages;
  bool stream;

  ChatCompletionModel({
    required this.model,
    required this.messages,
    required this.stream,
  });

  Map<String, dynamic> toJson() {
    return {
      'model': model,
      'messages': messages.map((message) => message.toJson()).toList(),
      'stream': stream,
    };
  }
}

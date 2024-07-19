import 'dart:convert';
import 'package:chat_bot_app/models/chat_completion_model.dart';
import 'package:chat_bot_app/models/messages_mdel.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class ChatService {
  final String apiUrl = 'https://api.openai.com/v1/chat/completions';
  final String apiKey = ''; // Replace with your actual API key

  Future<String> sendMessage(List<Messages> messages) async {
    final openAiModel = ChatCompletionModel(
      model: 'gpt-3.5-turbo',
      messages: messages,
      stream: false,
    );

    final url = Uri.https('api.openai.com', '/v1/chat/completions');
    int attempts = 0;
    const maxAttempts = 3;

    while (attempts < maxAttempts) {
      attempts++;
      try {
        final response = await http.post(
          url,
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(openAiModel.toJson()),
        );

        if (response.statusCode == 200) {
          final jsonData = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
          String content = jsonData['choices'][0]['message']['content'];
          return content.trim();
        } else if (response.statusCode == 429) {
          // Too Many Requests, retry after a delay
          await Future.delayed(Duration(seconds: attempts * 2)); // Exponential backoff
        } else {
          throw Exception('Failed to load response: ${response.statusCode}');
        }
      } catch (e) {
        print('Error sending message: $e');
        throw Exception('Failed to send message: $e');
      }
    }

    throw Exception('Maximum retry attempts reached.');
  }
}


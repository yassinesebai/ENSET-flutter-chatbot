
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const apiKey = '.....';
const endpoint = 'https://api.openai.com/v1/chat/completions';


class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _controller = TextEditingController();
  List<Map<String, String>> _messages = [];

  void _sendMessage(String message) async {
    setState(() {
      _messages.add({"role": "user", "content": message});
    });

    try {
      var prompt = {
        "model": "gpt-3.5-turbo",
        "messages": [
          {"role": "user", "content": message }
        ],
        "temperature": 0
      };

      var response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: json.encode(prompt),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          _messages.add({"role": "ChatGPT", "content": data['choices'][0]['text']});
        });
      } else {
        print('Error: ${response.statusCode}');
        print('Response body: ${response.body}');
        setState(() {
          _messages.add({"role": "error", "content": 'Error communicating with ChatGPT: ${response.statusCode}'});
        });
      }
    } catch (e) {
      print('Exception: $e');
      setState(() {
        _messages.add({"role": "error", "content": 'Error: $e'});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('myChat'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                var message = _messages[index];
                bool isUserMessage = message['role'] == 'user';

                return Align(
                  alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isUserMessage ? Colors.blue[200] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.all(12),
                      child: Text(message['content']!),
                    ),
                  ),
                );
              },
              // Reverse the list view to show newer messages at the bottom
              reverse: true,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Enter your message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      _sendMessage(_controller.text);
                      _controller.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
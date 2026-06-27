import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../core/constants/api_constants.dart';

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class ChatProvider extends ChangeNotifier {
  final ApiService _apiService;

  final List<ChatMessage> _messages = [];
  // Store the exact history format expected by Gemini
  final List<Map<String, dynamic>> _apiHistory = [];
  
  bool _isLoading = false;
  String? _error;

  ChatProvider(this._apiService);

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void addMessage(String text, {required bool isUser}) {
    _messages.add(ChatMessage(text: text, isUser: isUser));
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message to UI immediately
    addMessage(text, isUser: true);

    try {
      _setLoading(true);

      final response = await _apiService.client.post(
        ApiConstants.tipsChat,
        data: {
          'message': text,
          'history': _apiHistory,
        },
      );

      // Append to internal history for the next request
      _apiHistory.add({
        'role': 'user',
        'parts': [{'text': text}]
      });

      final aiResponse = response.data['data']['text'] as String;
      
      _apiHistory.add({
        'role': 'model',
        'parts': [{'text': aiResponse}]
      });

      // Add AI response to UI
      addMessage(aiResponse, isUser: false);

    } catch (e) {
      _setError(e.toString());
      addMessage('Sorry, I encountered an error. Please try again.', isUser: false);
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    _error = null;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }
}

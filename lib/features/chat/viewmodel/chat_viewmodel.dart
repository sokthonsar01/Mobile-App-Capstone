import 'package:flutter/foundation.dart';
import '../data/chat_repository.dart';

/// ViewModel managing chat conversation lifecycle and message dispatching.
class ChatViewModel extends ChangeNotifier {
  final ChatRepository _chatRepository = ChatRepository();

  String? _activeConversationId;
  bool _isLoadingConversation = false;
  final List<String> _localFallbackMessages = [];
  String? _errorMessage;

  String? get activeConversationId => _activeConversationId;
  bool get isLoadingConversation => _isLoadingConversation;
  List<String> get localFallbackMessages => List.unmodifiable(_localFallbackMessages);
  String? get errorMessage => _errorMessage;
  String get currentUserId => _chatRepository.currentUserId;

  void initConversation({String? conversationId, String? companyId}) {
    _activeConversationId = conversationId;
    if (_activeConversationId == null && companyId != null) {
      _fetchOrCreateConversation(companyId);
    }
  }

  Future<void> _fetchOrCreateConversation(String companyId) async {
    _isLoadingConversation = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _chatRepository.getOrCreateConversation(companyId);
      _activeConversationId = res['id'] as String?;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingConversation = false;
      notifyListeners();
    }
  }

  Stream<List<ChatMessage>> streamMessages(String conversationId) {
    return _chatRepository.streamMessages(conversationId);
  }

  Future<bool> sendMessage(String text) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return false;

    if (_activeConversationId != null) {
      try {
        await _chatRepository.sendMessage(_activeConversationId!, cleanText);
        return true;
      } catch (e) {
        _errorMessage = e.toString();
        notifyListeners();
        return false;
      }
    } else {
      _localFallbackMessages.add(cleanText);
      notifyListeners();
      return true;
    }
  }
}

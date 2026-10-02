import 'package:flutter/foundation.dart';
import '../data/chat_repository.dart';

/// ViewModel managing conversation threads for the MessagesScreen.
class MessagesViewModel extends ChangeNotifier {
  static final MessagesViewModel instance = MessagesViewModel._internal();

  MessagesViewModel._internal();

  factory MessagesViewModel() => instance;

  final ChatRepository _chatRepository = ChatRepository();

  List<Map<String, dynamic>> _conversations = [];
  bool _isLoading = false;
  bool _hasLoadedOnce = false;
  String _searchQuery = '';
  String? _errorMessage;

  List<Map<String, dynamic>> get conversations => _conversations;
  bool get isLoading => _isLoading;
  bool get hasLoadedOnce => _hasLoadedOnce;
  String get searchQuery => _searchQuery;
  String? get errorMessage => _errorMessage;

  /// Returns conversations filtered by search query
  List<Map<String, dynamic>> get filteredConversations {
    if (_searchQuery.trim().isEmpty) return _conversations;
    final query = _searchQuery.toLowerCase().trim();
    return _conversations.where((conv) {
      final company = conv['company'] as Map<String, dynamic>?;
      final name = ((company?['name'] as String?) ?? '').toLowerCase();
      final lastMsg = ((conv['lastMessage'] as String?) ?? '').toLowerCase();
      return name.contains(query) || lastMsg.contains(query);
    }).toList();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Load conversations from backend. If already loaded once, refreshes silently in background.
  Future<void> loadConversations({bool force = false}) async {
    final isBackground = _hasLoadedOnce && !force;
    if (!isBackground) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final remote = await _chatRepository.getConversations();
      _conversations = remote;
      _hasLoadedOnce = true;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    _conversations = [];
    _isLoading = false;
    _hasLoadedOnce = false;
    _searchQuery = '';
    _errorMessage = null;
    notifyListeners();
  }
}

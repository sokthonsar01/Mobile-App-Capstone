import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../config/app_env.dart';

class ChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      conversationId: json['conversationId'] as String,
      senderId: json['senderId'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class ChatRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  String get _jwt => _supabase.auth.currentSession?.accessToken ?? '';
  String get currentUserId => _supabase.auth.currentUser?.id ?? '';

  Future<Map<String, dynamic>> getOrCreateConversation(String companyId) async {
    final response = await http.post(
      Uri.parse('${AppEnv.apiBaseUrl}/conversations'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_jwt',
      },
      body: jsonEncode({'companyId': companyId}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to load conversation: ${response.body}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getConversations() async {
    final response = await http.get(
      Uri.parse('${AppEnv.apiBaseUrl}/conversations'),
      headers: {'Authorization': 'Bearer $_jwt'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load conversations');
    }
    final List list = jsonDecode(response.body);
    return list.cast<Map<String, dynamic>>();
  }

  Stream<List<ChatMessage>> streamMessages(String conversationId) {
    return _supabase
        .from('Message')
        .stream(primaryKey: ['id'])
        .eq('conversationId', conversationId)
        .order('createdAt', ascending: true)
        .map((data) => data.map((json) => ChatMessage.fromJson(json)).toList());
  }

  Future<void> sendMessage(String conversationId, String content) async {
    final response = await http.post(
      Uri.parse('${AppEnv.apiBaseUrl}/conversations/$conversationId/messages'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_jwt',
      },
      body: jsonEncode({'content': content}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to send message: ${response.body}');
    }
  }
}

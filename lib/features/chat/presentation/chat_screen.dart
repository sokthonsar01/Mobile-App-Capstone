import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../shared/app_colors.dart';
import '../../../shared/theme/app_theme_controller.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../data/chat_repository.dart';
import '../viewmodel/chat_viewmodel.dart';

/// Live chat screen backed by Supabase WebSocket realtime messages.
class ChatScreen extends StatefulWidget {
  final String contactName;
  final String? avatarAsset;
  final String? conversationId;
  final String? companyId;

  const ChatScreen({
    super.key,
    required this.contactName,
    this.avatarAsset,
    this.conversationId,
    this.companyId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  late final ChatViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = ChatViewModel();
    _vm.initConversation(
      conversationId: widget.conversationId,
      companyId: widget.companyId,
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppThemeController.instance.themeModeNotifier,
      builder: (context, currentMode, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                Divider(height: 1, color: AppColors.cardBorder),
                Expanded(
                  child: ListenableBuilder(
                    listenable: _vm,
                    builder: (context, _) {
                      if (_vm.isLoadingConversation) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (_vm.activeConversationId != null) {
                        return _buildLiveMessageStream(_vm.activeConversationId!);
                      }
                      return _buildFallbackList();
                    },
                  ),
                ),
                _buildInputBar(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.heading,
              size: 20,
            ),
          ),
          InitialsAvatar(
            name: widget.contactName,
            size: 36,
            imageAsset: widget.avatarAsset,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.contactName,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.heading,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: AppColors.online,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Online',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppColors.online,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: AppColors.heading, size: 22),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: AppColors.surface,
            onSelected: (value) {
              if (value == 'mute') {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Notifications muted for ${widget.contactName}',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'mute',
                child: Row(
                  children: [
                    Icon(Icons.notifications_off_outlined, size: 18, color: AppColors.hintText),
                    const SizedBox(width: 10),
                    Text(
                      'Mute notifications',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.heading,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLiveMessageStream(String conversationId) {
    return StreamBuilder<List<ChatMessage>>(
      stream: _vm.streamMessages(conversationId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final messages = snapshot.data!;
        if (messages.isEmpty) {
          return Center(
            child: Text(
              'No messages yet. Say hello!',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.hintText,
                fontSize: 13,
              ),
            ),
          );
        }

        return ListView.builder(
          reverse: true,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            // Reverse indexing so newest message is at bottom
            final msg = messages[messages.length - 1 - index];
            final isMe = msg.senderId == _vm.currentUserId;

            return Align(
              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                decoration: BoxDecoration(
                  color: isMe ? const Color(0xFF0D9488) : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  msg.content,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: isMe ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFallbackList() {
    final messages = _vm.localFallbackMessages;
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      itemCount: messages.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Today',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: AppColors.hintText,
                ),
              ),
            ),
          );
        }
        final text = messages[index - 1];
        return Align(
          alignment: Alignment.centerRight,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 14),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.cardBorder)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                onSubmitted: (_) => _handleSend(),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: AppColors.heading,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Write your message',
                  hintStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: AppColors.hintText,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: _handleSend,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D9488),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: softShadow,
                ),
                child: const Icon(Icons.send, color: Colors.white, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSend() async {
    final String text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    final ok = await _vm.sendMessage(text);
    if (!ok && mounted && _vm.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send: ${_vm.errorMessage}')),
      );
    }
  }
}

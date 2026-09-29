import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../shared/app_colors.dart';
import '../../../shared/demo_data.dart';
import '../../../shared/theme/app_theme_controller.dart';
import '../../../shared/widgets/shared_widgets.dart';

/// One conversation. Front end only, so the messages are the demo list.
class ChatScreen extends StatefulWidget {
  /// Whose chat we opened. Comes from the Messages list.
  final String contactName;
  final String? avatarAsset;

  const ChatScreen({
    super.key,
    required this.contactName,
    this.avatarAsset,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  /// We copy the demo list into a normal list so the send button
  /// can add new messages to it while we test the screen.
  late final List<ChatMessage> _messages = List<ChatMessage>.from(
    demoConversation,
  );

  @override
  void dispose() {
    _messageController.dispose();
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
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    itemCount: _messages.length + 1,
                    itemBuilder: (BuildContext context, int index) {
                      // The very first item is the gray "Today" label.
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
                      // index - 1 because item 0 was the "Today" label.
                      return _buildBubble(_messages[index - 1]);
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
              if (value == 'clear') {
                setState(() => _messages.clear());
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Chat cleared.',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else if (value == 'mute') {
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
              PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    const Icon(Icons.delete_sweep_outlined, size: 18, color: AppColors.danger),
                    const SizedBox(width: 10),
                    Text(
                      'Clear chat history',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.danger,
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

  Widget _buildBubble(ChatMessage message) {
    // My messages go on the right, the other person's on the left.
    final bool isMine = message.isMine;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment:
            isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // ConstrainedBox stops a long message from filling the whole width.
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.72,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color:
                    isMine ? AppColors.primaryBlue : AppColors.otherBubble,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  // The corner nearest the sender is square.
                  bottomLeft: Radius.circular(isMine ? 16 : 4),
                  bottomRight: Radius.circular(isMine ? 4 : 16),
                ),
              ),
              child: Text(
                message.text,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  height: 1.45,
                  color: isMine ? Colors.white : AppColors.heading,
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message.time,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: AppColors.hintText,
                ),
              ),
              // The green double check only shows on my own messages.
              if (isMine) ...[
                const SizedBox(width: 5),
                const Icon(Icons.done_all,
                    size: 15, color: AppColors.online),
              ],
            ],
          ),
        ],
      ),
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
            IconButton(
              tooltip: 'Attach Document',
              onPressed: _showAttachmentSheet,
              icon: Icon(Icons.attach_file,
                  color: AppColors.bodyText, size: 22),
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
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
                  color: AppColors.primaryBlue,
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

  void _showAttachmentSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.cardBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Attach Files',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.heading,
                  ),
                ),
                const SizedBox(height: 14),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.description_rounded, color: AppColors.primaryBlue),
                  ),
                  title: Text(
                    'Attach Resume / CV (PDF)',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  subtitle: Text(
                    'CADT_Internship_Resume.pdf',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.hintText),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() {
                      _messages.add(
                        ChatMessage(
                          text: '📄 Attached: CADT_Internship_Resume.pdf',
                          time: 'now',
                          isMine: true,
                        ),
                      );
                    });
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.link_rounded, color: Color(0xFF16A34A)),
                  ),
                  title: Text(
                    'Share Portfolio Link',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  subtitle: Text(
                    'https://github.com/sombo-dev',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.hintText),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() {
                      _messages.add(
                        ChatMessage(
                          text: '🔗 Portfolio: https://github.com/sombo-dev',
                          time: 'now',
                          isMine: true,
                        ),
                      );
                    });
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF5FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.photo_library_rounded, color: Color(0xFF9333EA)),
                  ),
                  title: Text(
                    'Send Photo / Screenshot',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  subtitle: Text(
                    'Certificate or document image',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.hintText),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() {
                      _messages.add(
                        ChatMessage(
                          text: '📷 [Attached Image: Certificate.png]',
                          time: 'now',
                          isMine: true,
                        ),
                      );
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// TODO(team): send the message to the server once a backend exists.
  /// For now it only adds the text to the list on screen.
  void _handleSend() {
    final String text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(text: text, time: 'now', isMine: true),
      );
      _messageController.clear();
    });
  }
}

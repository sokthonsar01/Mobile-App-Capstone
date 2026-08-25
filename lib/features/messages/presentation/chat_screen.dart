import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../shared/app_colors.dart';
import '../../../shared/demo_data.dart';
import '../../../shared/widgets/shared_widgets.dart';

/// One conversation. Front end only, so the messages are the demo list.
class ChatScreen extends StatefulWidget {
  /// Whose chat we opened. Comes from the Messages list.
  final String contactName;

  const ChatScreen({super.key, required this.contactName});

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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            const Divider(height: 1),
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
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new,
                color: Colors.black, size: 20),
          ),
          InitialsAvatar(name: widget.contactName, size: 34),
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
                    color: Colors.black,
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
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert, color: Colors.black, size: 22),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.attach_file,
                color: AppColors.bodyText, size: 22),
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              style: GoogleFonts.plusJakartaSans(fontSize: 14),
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

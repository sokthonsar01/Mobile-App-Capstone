import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../shared/app_colors.dart';
import '../../../shared/app_navigation.dart';
import '../../../shared/demo_data.dart';
import '../../../shared/theme/app_theme_controller.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../data/chat_repository.dart';
import 'chat_screen.dart';

/// The Messages list screen.
class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ChatRepository _chatRepository = ChatRepository();

  String _searchText = '';
  List<Map<String, dynamic>> _remoteConversations = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    setState(() => _isLoading = true);
    try {
      final list = await _chatRepository.getConversations();
      if (mounted) {
        setState(() {
          _remoteConversations = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Only the chats whose name contains the search text.
  List<ChatPreview> get _visibleChats {
    if (_searchText.isEmpty) return demoChats;
    return demoChats
        .where((chat) => chat.name.toLowerCase().contains(_searchText))
        .toList();
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
                _buildSearchBox(),
                const SizedBox(height: 8),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _remoteConversations.isNotEmpty
                          ? _buildRemoteList()
                          : _buildDemoList(),
                ),
              ],
            ),
          ),
          bottomNavigationBar: AppBottomNav(
            currentIndex: 3,
            onTap: (int index) => navigateToAppTab(context, 3, index),
          ),
        );
      },
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Row(
        children: [
          const SizedBox(width: 88),
          Expanded(
            child: Text(
              'Messages',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.heading,
              ),
            ),
          ),
          IconButton(
            tooltip: 'New Message',
            onPressed: _showNewChatDialog,
            icon: const Icon(
              Icons.edit_square,
              color: AppColors.primaryBlue,
              size: 24,
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: AppColors.heading, size: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: AppColors.surface,
            onSelected: (value) {
              if (value == 'mark_read') {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'All messages marked as read.',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else if (value == 'clear_search') {
                setState(() {
                  _searchController.clear();
                  _searchText = '';
                });
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'mark_read',
                child: Row(
                  children: [
                    const Icon(Icons.done_all_rounded, size: 18, color: AppColors.primaryBlue),
                    const SizedBox(width: 10),
                    Text(
                      'Mark all as read',
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
                value: 'clear_search',
                child: Row(
                  children: [
                    Icon(Icons.clear_all_rounded, size: 18, color: AppColors.hintText),
                    const SizedBox(width: 10),
                    Text(
                      'Clear search',
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

  Widget _buildSearchBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (String value) {
            setState(() => _searchText = value.toLowerCase());
          },
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: AppColors.heading,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
            prefixIcon: Icon(Icons.search, color: AppColors.hintText),
            hintText: 'Search message',
            hintStyle: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: AppColors.hintText,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRemoteList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: _remoteConversations.length,
      itemBuilder: (BuildContext context, int index) {
        final conv = _remoteConversations[index];
        final company = conv['company'] as Map<String, dynamic>?;
        final name = (company?['name'] as String?) ?? 'Recruiter';
        final convId = conv['id'] as String;

        return ListTile(
          leading: InitialsAvatar(name: name, size: 46),
          title: Text(
            name,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.heading,
            ),
          ),
          subtitle: Text(
            'Tap to open chat',
            style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.hintText),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  contactName: name,
                  conversationId: convId,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDemoList() {
    if (_visibleChats.isEmpty) {
      return Center(
        child: Text(
          'No message found.',
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.hintText,
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: _visibleChats.length,
      itemBuilder: (BuildContext context, int index) {
        return _buildChatRow(_visibleChats[index]);
      },
    );
  }

  Widget _buildChatRow(ChatPreview chat) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              contactName: chat.name,
              avatarAsset: chat.avatarAsset,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InitialsAvatar(
              name: chat.name,
              size: 46,
              imageAsset: chat.avatarAsset,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chat.name,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.heading,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    chat.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: AppColors.bodyText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  chat.timeAgo,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppColors.hintText,
                  ),
                ),
                const SizedBox(height: 6),
                if (chat.unreadCount > 0)
                  Container(
                    width: 18,
                    height: 18,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${chat.unreadCount}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showNewChatDialog() {
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
                  'Start New Message',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.heading,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Select a recruiter or company to chat with',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: AppColors.hintText,
                  ),
                ),
                const SizedBox(height: 14),
                ...demoChats.take(4).map((chat) {
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 4),
                    leading: InitialsAvatar(
                      name: chat.name,
                      size: 40,
                      imageAsset: chat.avatarAsset,
                    ),
                    title: Text(
                      chat.name,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.heading,
                      ),
                    ),
                    subtitle: Text(
                      'Verified Recruiter',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppColors.hintText,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chat_outlined,
                      color: AppColors.primaryBlue,
                      size: 20,
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            contactName: chat.name,
                            avatarAsset: chat.avatarAsset,
                          ),
                        ),
                      );
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}

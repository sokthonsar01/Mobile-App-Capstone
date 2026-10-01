import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../shared/app_colors.dart';
import '../../../shared/app_navigation.dart';
import '../../../shared/theme/app_theme_controller.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../viewmodel/messages_viewmodel.dart';
import 'chat_screen.dart';

/// The Messages list screen.
class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final TextEditingController _searchController = TextEditingController();
  late final MessagesViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = MessagesViewModel();
    _vm.loadConversations();
  }

  @override
  void dispose() {
    _searchController.dispose();
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
                _buildSearchBox(),
                const SizedBox(height: 8),
                Expanded(
                  child: ListenableBuilder(
                    listenable: _vm,
                    builder: (context, _) {
                      if (_vm.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (_vm.filteredConversations.isNotEmpty) {
                        return _buildRemoteList();
                      }
                      return _buildEmptyState();
                    },
                  ),
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
                _searchController.clear();
                _vm.updateSearchQuery('');
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
            _vm.updateSearchQuery(value);
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

  Widget _buildEmptyState() {
    final isSearching = _vm.searchQuery.isNotEmpty;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 36,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isSearching ? 'No conversations found' : 'No messages yet',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.heading,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isSearching
                  ? 'Try searching with a different recruiter or company name.'
                  : 'Connect with recruiters directly to discuss internship opportunities.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppColors.hintText,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemoteList() {
    final conversations = _vm.filteredConversations;
    return RefreshIndicator(
      onRefresh: _vm.loadConversations,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 4),
        itemCount: conversations.length,
        itemBuilder: (BuildContext context, int index) {
          final conv = conversations[index];
          final company = conv['company'] as Map<String, dynamic>?;
          final name = (company?['name'] as String?) ?? 'Recruiter';
          final convId = conv['id']?.toString() ?? '';
          final lastMessage = (conv['lastMessage'] as String?) ?? 'Tap to open chat';
          final timeAgo = conv['timeAgo']?.toString() ?? '';

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
              lastMessage,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppColors.hintText,
              ),
            ),
            trailing: timeAgo.isNotEmpty
                ? Text(
                    timeAgo,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppColors.hintText,
                    ),
                  )
                : null,
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
                if (_vm.conversations.isNotEmpty)
                  ..._vm.conversations.map((conv) {
                    final company = conv['company'] as Map<String, dynamic>?;
                    final name = (company?['name'] as String?) ?? 'Recruiter';
                    final convId = conv['id']?.toString() ?? '';
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 4),
                      leading: InitialsAvatar(name: name, size: 40),
                      title: Text(
                        name,
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
                              contactName: name,
                              conversationId: convId,
                            ),
                          ),
                        );
                      },
                    );
                  })
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'No recruiter contacts yet.\nApply or save internships to connect with recruiters.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: AppColors.hintText,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

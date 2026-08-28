import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../shared/app_colors.dart';
import '../../../shared/demo_data.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../../home/presentation/application_details_screen.dart';
import '../../profile/presentation/edit_profile_screen.dart';
import 'chat_screen.dart';

/// The Messages list screen.
class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final TextEditingController _searchController = TextEditingController();

  /// What the user typed in the search box, in small letters.
  String _searchText = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Only the chats whose name contains the search text.
  /// If the box is empty, this returns everything.
  List<ChatPreview> get _visibleChats {
    if (_searchText.isEmpty) return demoChats;
    return demoChats
        .where((chat) => chat.name.toLowerCase().contains(_searchText))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            _buildSearchBox(),
            const SizedBox(height: 8),
            Expanded(
              child: _visibleChats.isEmpty
                  ? Center(
                      child: Text(
                        'No message found.',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.hintText,
                        ),
                      ),
                    )
                  // ListView.builder only builds the rows you can see.
                  // That keeps a long list fast.
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      itemCount: _visibleChats.length,
                      itemBuilder: (BuildContext context, int index) {
                        return _buildChatRow(_visibleChats[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 3,
        onTap: (int index) {
          if (index == 3) return;
          if (index == 0 || index == 1) {
            Navigator.popUntil(context, (route) => route.isFirst);
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const ApplicationDetailsScreen(),
              ),
            );
          } else if (index == 4) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const EditProfileScreen(),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Row(
        children: [
          // Empty box on the left with the same width as the two icons,
          // so the title stays exactly in the middle.
          const SizedBox(width: 88),
          Expanded(
            child: Text(
              'Messages',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.edit_square,
              color: AppColors.primaryBlue,
              size: 24,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert, color: Colors.black, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      // Same rule as the profile header: no fixed height.
      // We control the size with contentPadding instead, so a bigger
      // system font can never make it overflow.
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF7F8FA),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: _searchController,
          // onChanged runs on every letter the user types.
          onChanged: (String value) {
            setState(() => _searchText = value.toLowerCase());
          },
          style: GoogleFonts.plusJakartaSans(fontSize: 14),
          decoration: InputDecoration(
            border: InputBorder.none,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
            prefixIcon: const Icon(Icons.search, color: AppColors.hintText),
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

  Widget _buildChatRow(ChatPreview chat) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(contactName: chat.name),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          // start = line the avatar up with the top of the text.
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InitialsAvatar(name: chat.name, size: 46),
            const SizedBox(width: 14),
            // Expanded gives the name and message all the space that is
            // left, so long text gets cut with "..." instead of
            // overflowing the screen.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chat.name,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
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
                // Show the blue badge only when there are unread messages.
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
}

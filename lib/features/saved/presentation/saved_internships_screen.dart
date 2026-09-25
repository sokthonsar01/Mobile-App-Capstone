import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../shared/app_colors.dart';
import '../../../shared/demo_data.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../../home/presentation/application_details_screen.dart';
import '../../messages/presentation/messages_screen.dart';
import '../../profile/presentation/edit_profile_screen.dart';

/// The list of internships the user saved.
class SavedInternshipsScreen extends StatefulWidget {
  const SavedInternshipsScreen({super.key});

  @override
  State<SavedInternshipsScreen> createState() =>
      _SavedInternshipsScreenState();
}

class _SavedInternshipsScreenState extends State<SavedInternshipsScreen> {
  /// A copy of the demo list, so the delete button can remove items
  /// while we test. The original const list cannot be changed.
  late final List<SavedInternship> _internships =
      List<SavedInternship>.from(demoSavedInternships);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: _internships.isEmpty
                  ? Center(
                      child: Text(
                        'You have no saved internships.',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.hintText,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      itemCount: _internships.length,
                      itemBuilder: (BuildContext context, int index) {
                        return _buildCard(_internships[index], index);
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 2,
        onTap: (int index) {
          if (index == 0 || index == 1) {
            Navigator.popUntil(context, (route) => route.isFirst);
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const ApplicationDetailsScreen(),
              ),
            );
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const MessagesScreen(),
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
          const SizedBox(width: 48),
          Expanded(
            child: Text(
              'Saved Internships',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.heading,
              ),
            ),
          ),
          IconButton(
            onPressed: _confirmClearAll,
            icon: const Icon(Icons.delete_outline,
                color: AppColors.danger, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(SavedInternship internship, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InitialsAvatar(name: internship.company, size: 40),
              const Spacer(),
              GestureDetector(
                onTap: () => _removeOne(index),
                child: const Icon(Icons.more_vert,
                    color: Colors.black54, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            internship.title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${internship.company} - ${internship.location}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: AppColors.bodyText,
            ),
          ),
          const SizedBox(height: 14),

          // Wrap puts the tags on a new line if they do not fit.
          // A Row would overflow on a small phone.
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: internship.tags.map(_buildTag).toList(),
          ),

          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                internship.postedAgo,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: AppColors.hintText,
                ),
              ),
              Text(
                internship.payType,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: AppColors.hintText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// One small gray pill with blue text.
  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.lightFill,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          color: AppColors.primaryBlue,
        ),
      ),
    );
  }

  void _removeOne(int index) {
    setState(() => _internships.removeAt(index));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Removed from saved.')),
    );
  }

  /// Deleting everything cannot be undone, so we ask first.
  void _confirmClearAll() {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Remove all?'),
          content: const Text(
            'This removes every saved internship from the list.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                setState(() => _internships.clear());
              },
              child: const Text(
                'Remove all',
                style: TextStyle(color: AppColors.danger),
              ),
            ),
          ],
        );
      },
    );
  }
}

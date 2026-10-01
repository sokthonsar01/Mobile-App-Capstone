import 'package:flutter/material.dart';

import '../../../shared/app_colors.dart';
import '../../../shared/widgets/app_skeleton.dart';

/// Reusable skeleton loader matching the visual structure of [InternshipCard].
/// Designed to be rendered during opening/initial load without blocking the rest of the UI.
class InternshipCardSkeleton extends StatelessWidget {
  const InternshipCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.cardBorder,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D0141).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header: Logo + Title/Role + Bookmark placeholder
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const AppSkeleton(
                width: 44,
                height: 44,
                borderRadius: 12,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AppSkeleton(
                          width: 110,
                          height: 15,
                          borderRadius: 4,
                        ),
                        SizedBox(width: 6),
                        AppSkeleton(
                          width: 46,
                          height: 16,
                          borderRadius: 6,
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    AppSkeleton(
                      width: 160,
                      height: 12,
                      borderRadius: 4,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const AppSkeleton(
                width: 34,
                height: 34,
                borderRadius: 10,
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 2. Short description lines
          const AppSkeleton(
            width: double.infinity,
            height: 12,
            borderRadius: 4,
          ),
          const SizedBox(height: 6),
          const AppSkeleton(
            width: 220,
            height: 12,
            borderRadius: 4,
          ),

          const SizedBox(height: 14),

          // 3. Poster placeholder (matches AspectRatio 750 / 350)
          AspectRatio(
            aspectRatio: 750 / 350,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.cardBorder,
                  width: 1,
                ),
              ),
              child: const ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(11)),
                child: AppSkeleton(
                  width: double.infinity,
                  height: double.infinity,
                  borderRadius: 0,
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // 4. Tags / Footer placeholder
          const Row(
            children: [
              AppSkeleton(
                width: 75,
                height: 24,
                borderRadius: 6,
              ),
              SizedBox(width: 8),
              AppSkeleton(
                width: 90,
                height: 24,
                borderRadius: 6,
              ),
              Spacer(),
              AppSkeleton(
                width: 80,
                height: 20,
                borderRadius: 4,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

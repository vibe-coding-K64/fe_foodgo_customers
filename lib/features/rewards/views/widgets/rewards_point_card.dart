import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/language_service.dart';

/// Card hien thi so diem hien tai va hang thanh vien cua nguoi dung.
class RewardsPointCard extends StatelessWidget {
  final int currentPoints;
  final String memberTier;
  final int nextTierPoints;

  const RewardsPointCard({
    super.key,
    required this.currentPoints,
    required this.memberTier,
    required this.nextTierPoints,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFF6B35),
            Color(0xFFFF8C00),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B35).withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tieu de "Diem cua ban".
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                LanguageService.translate('rewards_my_points'),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.workspace_premium,
                      color: Colors.amber[300],
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      memberTier,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // So diem lon.
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currentPoints.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  LanguageService.translate('rewards_points'),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Thanh tien do den hang tiep theo.
          _buildProgressBar(),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = currentPoints / nextTierPoints;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              LanguageService.translate('rewards_next_tier'),
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
            Text(
              '$currentPoints / $nextTierPoints',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

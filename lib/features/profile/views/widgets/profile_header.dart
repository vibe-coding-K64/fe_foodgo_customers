import 'package:flutter/material.dart';
import '../../../../core/localization/language_service.dart';

/// Widget hien thi phan header cua trang tai khoan.
/// Background gradient xanh, avatar tron o giua, ten va so dien thoai.
class ProfileHeader extends StatelessWidget {
  final String userName;
  final String phoneNumber;
  final String avatarUrl;
  final VoidCallback? onEditProfile;

  const ProfileHeader({
    super.key,
    required this.userName,
    required this.phoneNumber,
    required this.avatarUrl,
    this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Color(0xFF2E7D32),
            Color(0xFF4CAF50),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar hinh tron.
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white.withOpacity(0.2),
                backgroundImage: avatarUrl.isNotEmpty
                    ? NetworkImage(avatarUrl)
                    : null,
                onBackgroundImageError: (_, __) {},
                child: avatarUrl.isEmpty
                    ? const Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.white,
                      )
                    : null,
              ),
              const SizedBox(height: 16),
              // Ten nguoi dung.
              Text(
                userName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              // So dien thoai.
              if (phoneNumber.isNotEmpty)
                Text(
                  phoneNumber,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              const SizedBox(height: 12),
              // Nut chinh sua ho so.
              OutlinedButton.icon(
                onPressed: onEditProfile,
                icon: const Icon(Icons.edit, size: 16),
                label: Text(
                  context.t('profile_edit'),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

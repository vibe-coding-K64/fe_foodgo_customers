import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/language_service.dart';

/// Mot item trong danh sach menu tai khoan.
class ProfileMenuItem {
  final String titleKey;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;

  const ProfileMenuItem({
    required this.titleKey,
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
  });
}

/// Widget hien thi danh sach menu tai khoan.
class ProfileMenuList extends StatelessWidget {
  final List<ProfileMenuItem> items;

  const ProfileMenuList({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 1, indent: 56),
      itemBuilder: (context, index) {
        final item = items[index];
        return _MenuTile(item: item);
      },
    );
  }
}

class _MenuTile extends StatelessWidget {
  final ProfileMenuItem item;

  const _MenuTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final isLogout = item.isDestructive;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(
        item.icon,
        color: isLogout ? AppColors.error : AppColors.textSecondary,
        size: 24,
      ),
      title: Text(
        context.t(item.titleKey),
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: isLogout ? AppColors.error : AppColors.textPrimary,
        ),
      ),
      trailing: isLogout
          ? null
          : Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary.withOpacity(0.5),
              size: 20,
            ),
      onTap: () {
        debugPrint('Tu chon menu: ${item.titleKey}');
        item.onTap();
      },
    );
  }
}

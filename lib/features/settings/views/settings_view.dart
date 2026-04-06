import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/language_service.dart';
import 'change_password_view.dart';

/// Man hinh Cai dat.
///
/// Hien thi danh sach cac tuy chon cai dat:
///   - Bat/Tat thong bao day (SwitchListTile).
///   - Doi ngon ngu (ListTile).
///   - Doi mat khau (ListTile).
///
/// Duoc goi tu:
///   - ProfileView: bam "Cai dat"
class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  /// Trang thai thong bao day (bat/tat).
  bool _pushNotificationsEnabled = true;

  /// Ngon ngu hien tai (vi/en).
  String _currentLocale = 'vi';

  @override
  void initState() {
    super.initState();
    debugPrint('Settings: Man hinh cai dat da mo');
  }

  /// Xu ly khi doi trang thai thong bao day.
  void _onPushNotiChanged(bool value) {
    setState(() => _pushNotificationsEnabled = value);
    debugPrint(
        'Settings: Thong bao day ${value ? "BAT" : "TAT"}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value
              ? 'Thong bao da bat'
              : 'Thong bao da tat',
        ),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Xu ly bam muc "Doi ngon ngu".
  void _onLanguageTap() {
    debugPrint('Settings: Nguoi dung bam muc Doi ngon ngu');
    _showLanguageBottomSheet(context);
  }

  /// Xu ly bam muc "Doi mat khau".
  void _onChangePasswordTap() {
    debugPrint('Settings: Mo trang doi mat khau');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChangePasswordView(),
      ),
    );
  }

  /// Hien thi BottomSheet chon ngon ngu.
  void _showLanguageBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thanh keo.
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 10),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Tieu de.
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Text(
                  LanguageService.translate('settings_language'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              // Lua chon Tieng Viet.
              _buildLanguageOption(
                label: LanguageService.translate('settings_language_vi'),
                locale: 'vi',
              ),
              // Lua chon English.
              _buildLanguageOption(
                label: LanguageService.translate('settings_language_en'),
                locale: 'en',
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  /// Mot tuy chon ngon ngu trong BottomSheet.
  Widget _buildLanguageOption({
    required String label,
    required String locale,
  }) {
    final isSelected = _currentLocale == locale;

    return InkWell(
      onTap: () {
        debugPrint('Settings: Chon ngon ngu [$locale]');
        setState(() => _currentLocale = locale);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Da chon: $label'),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            // Ngon ngu hien tai (o day la tieng Viet / English).
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textPrimary,
                ),
              ),
            ),
            // Chi hieu khi duoc chon.
            if (isSelected)
              const Icon(
                Icons.check,
                color: AppColors.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  /// Tao label hien thi ngon ngu hien tai o day cuoi ListTile.
  String get _languageLabel {
    if (_currentLocale == 'vi') {
      return LanguageService.translate('settings_language_vi');
    } else {
      return LanguageService.translate('settings_language_en');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            debugPrint('Settings: Nguoi dung bam nut back');
            Navigator.pop(context);
          },
        ),
        title: Text(
          LanguageService.translate('settings_title'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // Nhom "Chung" (tieu de nhom).
          _buildSectionTitle(LanguageService.translate('settings_section_general')),
          // Thong bao day.
          _buildSwitchTile(),
          const Divider(height: 1, indent: 16, endIndent: 16),
          // Doi ngon ngu.
          _buildLanguageTile(),
          const Divider(height: 1, indent: 16, endIndent: 16),
          // Doi mat khau.
          _buildChangePasswordTile(),
          const SizedBox(height: 16),
          // Nhom "Khac".
          _buildSectionTitle(LanguageService.translate('settings_section_other')),
          // Ve chung toi.
          _buildAboutTile(),
          const Divider(height: 1, indent: 16, endIndent: 16),
          // Phien ban.
          _buildVersionTile(),
        ],
      ),
    );
  }

  /// Tieu de nhom (VD: "Chung", "Khac").
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// SwitchListTile: Bat/Tat thong bao day.
  Widget _buildSwitchTile() {
    return Container(
      color: AppColors.surface,
      child: SwitchListTile(
        title: Text(
          LanguageService.translate('settings_push_noti'),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            LanguageService.translate('settings_push_noti_desc'),
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        value: _pushNotificationsEnabled,
        onChanged: _onPushNotiChanged,
        activeColor: AppColors.primary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
      ),
    );
  }

  /// ListTile: Doi ngon ngu.
  Widget _buildLanguageTile() {
    return Container(
      color: AppColors.surface,
      child: ListTile(
        title: Text(
          LanguageService.translate('settings_language'),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _languageLabel,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textHint,
              size: 22,
            ),
          ],
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
        onTap: _onLanguageTap,
      ),
    );
  }

  /// ListTile: Doi mat khau.
  Widget _buildChangePasswordTile() {
    return Container(
      color: AppColors.surface,
      child: ListTile(
        title: Text(
          LanguageService.translate('settings_change_password'),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.textHint,
          size: 22,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
        onTap: _onChangePasswordTap,
      ),
    );
  }

  /// ListTile: Ve chung toi.
  Widget _buildAboutTile() {
    return Container(
      color: AppColors.surface,
      child: ListTile(
        title: Text(
          LanguageService.translate('settings_about'),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.textHint,
          size: 22,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
        onTap: () {
          debugPrint('Settings: Nguoi dung bam Ve chung toi');
        },
      ),
    );
  }

  /// ListTile: Phien ban.
  Widget _buildVersionTile() {
    return Container(
      color: AppColors.surface,
      child: ListTile(
        title: Text(
          LanguageService.translate('settings_version'),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        trailing: const Text(
          '1.0.0',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
      ),
    );
  }
}

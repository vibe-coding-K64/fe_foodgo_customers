import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/language_service.dart';
import '../../../core/state/locale_provider.dart';
import '../../../core/utils/snackbar_helper.dart';
import 'change_password_view.dart';

/// Man hinh Cai dat.
///
/// Hien thi danh sach cac tuy chon cai dat:
///   - Doi ngon ngu (SwitchListTile).
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

  @override
  void initState() {
    super.initState();
    debugPrint('Settings: Man hinh cai dat da mo');
  }

  /// Xu ly khi nguoi dung chuyen doi ngon ngu qua Switch.
  ///
  /// Switch ON = Tieng Viet, Switch OFF = English.
  void _onLanguageSwitchChanged(bool isVietnamese, LocaleProvider provider) {
    provider.setLocale(isVietnamese);
    debugPrint('Settings: Doi ngon ngu thanh ${isVietnamese ? "Tieng Viet" : "English"}');
    showAppToast(
      context,
      message: isVietnamese
          ? context.t('settings_lang_switched_vi')
          : context.t('settings_lang_switched_en'),
      type: AppToastType.success,
      duration: const Duration(seconds: 1),
    );
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

  @override
  Widget build(BuildContext context) {
    final localeProvider = LocaleProvider.of(context);

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
          context.t('settings_title'),
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
          _buildSectionTitle(context.t('settings_section_general')),
          // Doi ngon ngu (Switch).
          _buildLanguageTile(localeProvider),
          const Divider(height: 1, indent: 16, endIndent: 16),
          // Doi mat khau.
          _buildChangePasswordTile(),
          const SizedBox(height: 16),
          // Nhom "Khac".
          _buildSectionTitle(context.t('settings_section_other')),
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

  /// SwitchListTile: Doi ngon ngu.
  ///
  /// Switch ON = Tieng Viet, OFF = English.
  /// Mau xanh la chu dao (AppColors.primary) khi bat.
  Widget _buildLanguageTile(LocaleProvider localeProvider) {
    return Container(
      color: AppColors.surface,
      child: SwitchListTile(
        title: Text(
          context.t('settings_language'),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            localeProvider.isVietnamese
                ? context.t('settings_language_vi')
                : context.t('settings_language_en'),
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        value: localeProvider.isVietnamese,
        onChanged: (value) => _onLanguageSwitchChanged(value, localeProvider),
        activeColor: AppColors.primary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
      ),
    );
  }

  /// ListTile: Doi mat khau.
  Widget _buildChangePasswordTile() {
    return Container(
      color: AppColors.surface,
      child: ListTile(
        title: Text(
          context.t('settings_change_password'),
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

  /// ListTile: Phien ban.
  Widget _buildVersionTile() {
    return Container(
      color: AppColors.surface,
      child: ListTile(
        title: Text(
          context.t('settings_version'),
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

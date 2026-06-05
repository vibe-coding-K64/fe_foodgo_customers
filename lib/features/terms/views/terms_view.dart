import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/language_service.dart';

/// Model mot muc trong dieu khoan.
class TermsSection {
  final String titleKey;
  final String contentKey;

  const TermsSection({
    required this.titleKey,
    required this.contentKey,
  });
}

/// Man hinh Dieu khoan va Chinh sach.
///
/// Hien thi noi dung van ban cac dieu khoan su dung:
///   - AppBar voi tieu de.
///   - SingleChildScrollView chua cac muc van ban.
///   - Tieu de muc in dam, noi dung mau xam.
///
/// Duoc goi tu:
///   - ProfileView: bam "Dieu khoan va chinh sach"
class TermsView extends StatelessWidget {
  const TermsView({super.key});

  /// Danh sach cac muc (section) trong dieu khoan.
  static const List<TermsSection> _sections = [
    TermsSection(
      titleKey: 'terms_section_1_title',
      contentKey: 'terms_section_1_content',
    ),
    TermsSection(
      titleKey: 'terms_section_2_title',
      contentKey: 'terms_section_2_content',
    ),
    TermsSection(
      titleKey: 'terms_section_3_title',
      contentKey: 'terms_section_3_content',
    ),
    TermsSection(
      titleKey: 'terms_section_4_title',
      contentKey: 'terms_section_4_content',
    ),
  ];

  /// Tao widget tieu de muc (in dam, co margin).
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          height: 1.4,
        ),
      ),
    );
  }

  /// Tao widget noi dung muc (mau xam, co margin).
  Widget _buildSectionContent(String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        content,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
          height: 1.6,
        ),
      ),
    );
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
            debugPrint('Terms: Nguoi dung bam nut back');
            Navigator.pop(context);
          },
        ),
        title: Text(
          context.t('terms_title'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Khong co padding top o day dau tien vi AppBar da co spacing.
            for (int i = 0; i < _sections.length; i++) ...[
              if (i == 0) const SizedBox(height: 8),
              _buildSectionTitle(context.t(_sections[i].titleKey)),
              _buildSectionContent(context.t(_sections[i].contentKey)),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

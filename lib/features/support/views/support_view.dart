import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/language_service.dart';
import 'support_chat_view.dart';

/// Model mot cau hoi FAQ.
class FaqItem {
  final String questionKey;
  final String answerKey;

  const FaqItem({
    required this.questionKey,
    required this.answerKey,
  });
}

/// Man hinh Tro giup / Trung tam tro giup.
///
/// Hien thi:
///   - Thanh tim kiem o dau trang.
///   - Danh sach FAQ (ExpansionTile - hieu ung accordion).
///   - Sticky bottom bar voi nut Chat va nut Goi tong dai.
///
/// Duoc goi tu:
///   - Tab Tai khoan (ProfileView): bam "Ho tro"
class SupportView extends StatefulWidget {
  const SupportView({super.key});

  @override
  State<SupportView> createState() => _SupportViewState();
}

class _SupportViewState extends State<SupportView> {
  /// Controller thanh tim kiem.
  final _searchController = TextEditingController();

  /// Tu khoa loc FAQ.
  String _searchQuery = '';

  /// Danh sach FAQ mock.
  static const List<FaqItem> _faqItems = [
    FaqItem(
      questionKey: 'support_faq_cancel_order',
      answerKey: 'support_faq_cancel_order_answer',
    ),
    FaqItem(
      questionKey: 'support_faq_promotion',
      answerKey: 'support_faq_promotion_answer',
    ),
    FaqItem(
      questionKey: 'support_faq_change_address',
      answerKey: 'support_faq_change_address_answer',
    ),
    FaqItem(
      questionKey: 'support_faq_payment',
      answerKey: 'support_faq_payment_answer',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Loc danh sach FAQ theo tu khoa tim kiem.
  List<FaqItem> get _filteredFaqs {
    if (_searchQuery.isEmpty) return _faqItems;
    final query = _searchQuery.toLowerCase();
    return _faqItems.where((faq) {
      final question = LanguageService.translate(faq.questionKey).toLowerCase();
      final answer = LanguageService.translate(faq.answerKey).toLowerCase();
      return question.contains(query) || answer.contains(query);
    }).toList();
  }

  /// Xu ly bam nut Chat.
  void _onChatTap() {
    debugPrint('SupportView: Mo man hinh chat voi nhan vien');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SupportChatView(),
      ),
    );
  }

  /// Xu ly bam nut Goi tong dai.
  void _onCallTap() {
    debugPrint('SupportView: Nguoi dung bam nut Goi tong dai');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(LanguageService.translate('support_call_btn')),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
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
            debugPrint('SupportView: Nguoi dung bam nut back');
            Navigator.pop(context);
          },
        ),
        title: Text(
          LanguageService.translate('support_title'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Thanh tim kiem.
          _buildSearchBar(),
          // Danh sach FAQ.
          Expanded(
            child: _buildFaqList(),
          ),
          // Sticky bottom bar.
          _buildStickyBottomBar(context),
        ],
      ),
    );
  }

  /// Thanh tim kiem o dau trang.
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      color: AppColors.surface,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
        ),
        child: TextField(
          controller: _searchController,
          textInputAction: TextInputAction.search,
          onChanged: (value) {
            setState(() => _searchQuery = value);
            debugPrint('SupportView: Tu khoa tim kiem = [$value]');
          },
          decoration: InputDecoration(
            hintText: LanguageService.translate('support_search_hint'),
            hintStyle: const TextStyle(
              fontSize: 14,
              color: AppColors.textHint,
            ),
            prefixIcon: const Icon(
              Icons.search,
              color: AppColors.textHint,
              size: 22,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                      debugPrint('SupportView: Xoa tu khoa tim kiem');
                    },
                    child: const Icon(
                      Icons.clear,
                      color: AppColors.textHint,
                      size: 20,
                    ),
                  )
                : null,
            filled: true,
            fillColor: AppColors.surfaceVariant,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Danh sach FAQ su dung ExpansionTile.
  Widget _buildFaqList() {
    final filtered = _filteredFaqs;

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.help_outline,
                size: 36,
                color: AppColors.textHint,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              LanguageService.translate('search_no_results'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              LanguageService.translate('support_search_hint'),
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            LanguageService.translate('support_faq_title'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              return _buildFaqTile(filtered[index], index);
            },
          ),
        ),
      ],
    );
  }

  /// Mot item FAQ su dung ExpansionTile.
  Widget _buildFaqTile(FaqItem faq, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: ExpansionTile(
        key: PageStorageKey('faq_$index'),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        onExpansionChanged: (expanded) {
          debugPrint(
              'SupportView: FAQ [${faq.questionKey}] ${expanded ? "mo" : "dong"}');
        },
        iconColor: AppColors.textHint,
        collapsedIconColor: AppColors.textHint,
        title: Text(
          LanguageService.translate(faq.questionKey),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            height: 1.3,
          ),
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              LanguageService.translate(faq.answerKey),
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Sticky Bottom Bar voi 2 nut.
  Widget _buildStickyBottomBar(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dong chu "Can ho tro them?"
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              LanguageService.translate('support_need_help'),
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          // 2 nut.
          Row(
            children: [
              // Nut Chat (Outline).
              Expanded(
                child: GestureDetector(
                  onTap: _onChatTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.chat_bubble_outline,
                          color: AppColors.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          LanguageService.translate('support_chat_btn'),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Nut Goi (Elevated).
              Expanded(
                child: GestureDetector(
                  onTap: _onCallTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.phone_outlined,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          LanguageService.translate('support_call_btn'),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

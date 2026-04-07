import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/language_service.dart';
import '../../cart/views/cart_view.dart';
import 'search_result_view.dart';

/// Man hinh tim kiem chinh.
///
/// Hien thi thanh tim kiem de nguoi dung nhap tu khoa va nhan tim.
/// Khi nguoi dung nhan tim (nut enter hoac icon), chuyen sang
/// SearchResultView voi tu khoa da nhap.
///
/// Su dung trong 2 truong hop:
///   1. Tu trang chu: bam vao thanh tim kiem HomeSearchBar.
///   2. Tu tab Tim kiem o BottomNavigation (neu co).
class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  /// Controller cho o tim kiem.
  final TextEditingController _searchController = TextEditingController();

  /// FocusNode de tu dong focus vao o tim kiem khi vao man hinh.
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Tu dong focus sau khi widget duoc build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Xu ly khi nguoi dung nhan nut tim kiem.
  void _onSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      return;
    }
    _navigateToResult(query);
  }

  /// Chuyen sang man hinh ket qua tim kiem.
  void _navigateToResult(String query) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultView(query: query),
      ),
    ).then((_) {
      // Khi quay lai, clear thanh tim kiem.
      _searchController.clear();
      _focusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: _buildSearchField(),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              debugPrint('SearchView: Nguoi dung bam icon gio hang');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CartView(),
                ),
              );
            },
          ),
        ],
      ),
      body: _buildRecentSearches(),
    );
  }

  /// Thanh tim kiem trong AppBar.
  Widget _buildSearchField() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              onSubmitted: (_) => _onSearch(),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: context.t('search_hint'),
                hintStyle: TextStyle(
                  color: AppColors.textHint,
                  fontSize: 15,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                isDense: true,
              ),
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          // Nut xoa text (hien thi khi co noi dung).
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _searchController,
            builder: (context, value, child) {
              if (value.text.isEmpty) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: Icon(
                  Icons.close,
                  color: AppColors.textHint,
                  size: 18,
                ),
                onPressed: () {
                  _searchController.clear();
                  _focusNode.requestFocus();
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36),
              );
            },
          ),
          // Nut tim kiem.
          GestureDetector(
            onTap: _onSearch,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Icon(
                Icons.search,
                color: AppColors.primary,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget hien thi lich su tim kiem gan day.
  Widget _buildRecentSearches() {
    // TODO: Thay bang lich su tu local storage hoac API khi co.
    final recentSearches = <String>[
      'Tra sua',
      'Gia rán',
      'Cơm tấm',
      'Bún bò',
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tieu de lich su tim kiem gan day.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.t('search_recent'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () {
                  debugPrint('Xoa lich su tim kiem');
                },
                child: Text(
                  context.t('search_clear_history'),
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Danh sach lich su.
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: recentSearches.map((keyword) {
              return _RecentSearchChip(
                keyword: keyword,
                onTap: () => _navigateToResult(keyword),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          // Tieu de tim kiem pho bien.
          Text(
            context.t('search_popular'),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          // Danh sach tim kiem pho bien.
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _PopularSearchChip(
                keyword: 'Phở',
                icon: Icons.local_fire_department,
                onTap: () => _navigateToResult('Phở'),
              ),
              _PopularSearchChip(
                keyword: 'Bánh mì',
                icon: Icons.bakery_dining,
                onTap: () => _navigateToResult('Bánh mì'),
              ),
              _PopularSearchChip(
                keyword: 'Cà phê',
                icon: Icons.coffee,
                onTap: () => _navigateToResult('Cà phê'),
              ),
              _PopularSearchChip(
                keyword: 'Gỏi',
                icon: Icons.eco,
                onTap: () => _navigateToResult('Gỏi'),
              ),
              _PopularSearchChip(
                keyword: 'Lẩu',
                icon: Icons.soup_kitchen,
                onTap: () => _navigateToResult('Lẩu'),
              ),
              _PopularSearchChip(
                keyword: 'Nước ép',
                icon: Icons.local_bar,
                onTap: () => _navigateToResult('Nước ép'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Chip lich su tim kiem gan day.
class _RecentSearchChip extends StatelessWidget {
  final String keyword;
  final VoidCallback? onTap;

  const _RecentSearchChip({
    required this.keyword,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history,
              size: 16,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              keyword,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Chip tim kiem pho bien voi icon.
class _PopularSearchChip extends StatelessWidget {
  final String keyword;
  final IconData icon;
  final VoidCallback? onTap;

  const _PopularSearchChip({
    required this.keyword,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: AppColors.primary,
            ),
            const SizedBox(width: 6),
            Text(
              keyword,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
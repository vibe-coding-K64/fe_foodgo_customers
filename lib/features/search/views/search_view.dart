import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/language_service.dart';
import '../../cart/views/cart_view.dart';
import '../models/search_history_model.dart';
import '../services/services.dart';
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

  /// Service quan ly lich su tim kiem.
  final SearchService _searchService = const SearchService();

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
  Future<void> _onSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      return;
    }

    // Luu tu khoa vao lich su truoc khi chuyen sang man hinh ket qua.
    try {
      await _searchService.addSearchKeyword(query);
    } catch (e) {
      debugPrint('SearchView: Loi khi luu lich su tim kiem - $e');
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
      body: _buildSearchHistorySection(),
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

  /// Widget hien thi phan lich su tim kiem (lang nghe tu Stream).
  ///
  /// Hien thi:
  /// - Loading indicator khi dang tai.
  /// - Empty state neu khong co lich su.
  /// - Danh sach lich su voi tieu de va nut xoa tat ca.
  Widget _buildSearchHistorySection() {
    return StreamBuilder<List<SearchHistoryModel>>(
      stream: _searchService.getSearchHistoryStream(),
      builder: (context, snapshot) {
        // Dang tai.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        // Co loi.
        if (snapshot.hasError) {
          debugPrint('SearchView: Loi Stream lich su - ${snapshot.error}');
          return const SizedBox.shrink();
        }

        final histories = snapshot.data ?? [];

        // Rong -> khong hien gi.
        if (histories.isEmpty) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hien thi tracuu rong.
                _buildEmptyHistoryHint(),
                const SizedBox(height: 24),
                // Tieu de tim kiem pho bien.
                _buildPopularSearchTitle(),
                const SizedBox(height: 12),
                _buildPopularSearchChips(),
              ],
            ),
          );
        }

        // Co du lieu -> hien thi lich su + pho bien.
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tieu de + nut xoa tat ca.
              _buildHistoryHeader(histories.length),
              const SizedBox(height: 12),
              // Danh sach lich su.
              _buildHistoryList(histories),
              const SizedBox(height: 24),
              // Tieu de tim kiem pho bien.
              _buildPopularSearchTitle(),
              const SizedBox(height: 12),
              _buildPopularSearchChips(),
            ],
          ),
        );
      },
    );
  }

  /// Hien thi goi y khi chua co lich su.
  Widget _buildEmptyHistoryHint() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        'Chua co lich su tim kiem',
        style: TextStyle(
          fontSize: 14,
          color: AppColors.textHint,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  /// Tieu de lich su tim kiem voi nut xoa tat ca.
  Widget _buildHistoryHeader(int itemCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Lich su tim kiem',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        TextButton(
          onPressed: _onClearAllHistory,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Xoa tat ca',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.error.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  /// Danh sach lich su tim kiem.
  Widget _buildHistoryList(List<SearchHistoryModel> histories) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: histories.map((item) {
        return _HistorySearchChip(
          keyword: item.keyword,
          onTap: () => _onHistoryItemTap(item.keyword),
          onDelete: () => _onDeleteHistoryItem(item.id),
        );
      }).toList(),
    );
  }

  /// Xu ly khi bam vao item lich su.
  void _onHistoryItemTap(String keyword) {
    // Dien tu khoa vao thanh tim kiem.
    _searchController.text = keyword;
    _searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: keyword.length),
    );

    // Tu dong kich hoat tim kiem.
    _onSearch();
  }

  /// Xu ly xoa 1 item lich su.
  void _onDeleteHistoryItem(String id) {
    _searchService.deleteSearchHistory(id).catchError((e) {
      debugPrint('SearchView: Loi xoa item lich su - $e');
    });
  }

  /// Xu ly xoa tat ca lich su.
  Future<void> _onClearAllHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xac nhan xoa'),
        content: const Text('Ban co chac chan muon xoa tat ca lich su tim kiem?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Huy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Xoa'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _searchService.clearAllHistory();
      } catch (e) {
        debugPrint('SearchView: Loi xoa tat ca lich su - $e');
      }
    }
  }

  /// Tieu de tim kiem pho bien.
  Widget _buildPopularSearchTitle() {
    return Text(
      context.t('search_popular'),
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  /// Cac chip tim kiem pho bien.
  Widget _buildPopularSearchChips() {
    return Wrap(
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
    );
  }
}

/// Chip lich su tim kiem voi icon history va nut xoa.
class _HistorySearchChip extends StatelessWidget {
  final String keyword;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const _HistorySearchChip({
    required this.keyword,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(left: 14, right: 6, top: 8, bottom: 8),
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
            const SizedBox(width: 2),
            // Nut xoa item.
            GestureDetector(
              onTap: onDelete,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: AppColors.textHint,
                ),
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
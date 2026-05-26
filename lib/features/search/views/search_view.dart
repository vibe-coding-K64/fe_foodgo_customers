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
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final SearchService _searchService = const SearchService();
  final ApiSearchService _apiSearchService = const ApiSearchService();

  late final Future<List<String>> _popularKeywordsFuture;

  @override
  void initState() {
    super.initState();
    _popularKeywordsFuture = _apiSearchService.getPopularKeywords();
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

  Future<void> _onSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      return;
    }

    try {
      await _searchService.addSearchKeyword(query);
    } catch (e) {
      debugPrint('SearchView: Loi khi luu lich su tim kiem - $e');
    }

    _navigateToResult(query);
  }

  void _navigateToResult(String query) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SearchResultView(query: query)),
    ).then((_) {
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
                MaterialPageRoute(builder: (context) => const CartView()),
              );
            },
          ),
        ],
      ),
      body: _buildSearchHistorySection(),
    );
  }

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
                hintStyle: TextStyle(color: AppColors.textHint, fontSize: 15),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                isDense: true,
              ),
              style: TextStyle(fontSize: 15, color: AppColors.textPrimary),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _searchController,
            builder: (context, value, child) {
              if (value.text.isEmpty) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: Icon(Icons.close, color: AppColors.textHint, size: 18),
                onPressed: () {
                  _searchController.clear();
                  _focusNode.requestFocus();
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36),
              );
            },
          ),
          GestureDetector(
            onTap: _onSearch,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Icon(Icons.search, color: AppColors.primary, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHistorySection() {
    return StreamBuilder<List<SearchHistoryModel>>(
      stream: _searchService.getSearchHistoryStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        if (snapshot.hasError) {
          debugPrint('SearchView: Loi Stream lich su - ${snapshot.error}');
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEmptyHistoryHint(),
                const SizedBox(height: 24),
                _buildPopularSearchTitle(),
                const SizedBox(height: 12),
                _buildPopularSearchChipsFromApi(),
              ],
            ),
          );
        }

        final histories = snapshot.data ?? [];

        if (histories.isEmpty) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEmptyHistoryHint(),
                const SizedBox(height: 24),
                _buildPopularSearchTitle(),
                const SizedBox(height: 12),
                _buildPopularSearchChipsFromApi(),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHistoryHeader(histories.length),
              const SizedBox(height: 12),
              _buildHistoryList(histories),
              const SizedBox(height: 24),
              _buildPopularSearchTitle(),
              const SizedBox(height: 12),
              _buildPopularSearchChipsFromApi(),
            ],
          ),
        );
      },
    );
  }

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

  void _onHistoryItemTap(String keyword) {
    _searchController.text = keyword;
    _searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: keyword.length),
    );
    _onSearch();
  }

  void _onDeleteHistoryItem(String id) {
    _searchService.deleteSearchHistory(id).catchError((e) {
      debugPrint('SearchView: Loi xoa item lich su - $e');
    });
  }

  Future<void> _onClearAllHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xac nhan xoa'),
        content: const Text(
          'Ban co chac chan muon xoa tat ca lich su tim kiem?',
        ),
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

  /// Hien thi cac chip tu khoa pho bien tu API (FutureBuilder).
  Widget _buildPopularSearchChipsFromApi() {
    return FutureBuilder<List<String>>(
      future: _popularKeywordsFuture,
      builder: (context, snapshot) {
        // Dang tai.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(
              6,
              (index) => _PopularChipSkeleton(),
            ),
          );
        }

        // Co loi -> hien thi mac dinh.
        if (snapshot.hasError) {
          debugPrint(
              'SearchView: Loi tai tu khoa pho bien - ${snapshot.error}');
          return _buildPopularSearchChipsFallback();
        }

        final keywords = snapshot.data ?? [];

        if (keywords.isEmpty) {
          return _buildPopularSearchChipsFallback();
        }

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: keywords.map((keyword) {
            return _PopularSearchChip(
              keyword: keyword,
              onTap: () => _navigateToResult(keyword),
            );
          }).toList(),
        );
      },
    );
  }

  /// Fallback chip pho bien khi API loi hoac khong co du lieu.
  Widget _buildPopularSearchChipsFallback() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _PopularSearchChip(
          keyword: 'Pho',
          onTap: () => _navigateToResult('Pho'),
        ),
        _PopularSearchChip(
          keyword: 'Banh mi',
          onTap: () => _navigateToResult('Banh mi'),
        ),
        _PopularSearchChip(
          keyword: 'Ca phe',
          onTap: () => _navigateToResult('Ca phe'),
        ),
        _PopularSearchChip(
          keyword: 'Tra sua',
          onTap: () => _navigateToResult('Tra sua'),
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

  const _HistorySearchChip({required this.keyword, this.onTap, this.onDelete});

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
            Icon(Icons.history, size: 16, color: AppColors.textSecondary),
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
            GestureDetector(
              onTap: onDelete,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(Icons.close, size: 16, color: AppColors.textHint),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Chip tu khoa pho bien (khong co icon, lay tu API).
class _PopularSearchChip extends StatelessWidget {
  final String keyword;
  final VoidCallback? onTap;

  const _PopularSearchChip({required this.keyword, this.onTap});

  IconData _getIconForKeyword(String keyword) {
    final lower = keyword.toLowerCase();
    if (lower.contains('pho')) return Icons.ramen_dining;
    if (lower.contains('banh')) return Icons.bakery_dining;
    if (lower.contains('ca phe') || lower.contains('cafe') || lower.contains('cappuccino')) {
      return Icons.coffee;
    }
    if (lower.contains('tra sua') || lower.contains('tra') || lower.contains('tra sua')) {
      return Icons.local_cafe;
    }
    if (lower.contains('com') || lower.contains('bun')) return Icons.rice_bowl;
    if (lower.contains('lau')) return Icons.soup_kitchen;
    if (lower.contains('trai cay') || lower.contains('nuoc ep')) {
      return Icons.local_bar;
    }
    if (lower.contains('my') || lower.contains('mi')) return Icons.dinner_dining;
    if (lower.contains('chao') || lower.contains('sup')) return Icons.soup_kitchen;
    if (lower.contains('kem') || lower.contains('dessert')) return Icons.icecream;
    return Icons.search;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_getIconForKeyword(keyword), size: 16, color: AppColors.primary),
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

/// Skeleton chip placeholder khi dang tai popular keywords.
class _PopularChipSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            width: 60,
            height: 13,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/language_service.dart';

/// Loai sap xep / loc.
enum SearchSortType {
  /// Gia tang dan.
  priceAsc,
  /// Gia giam dan.
  priceDesc,
  /// Danh gia cao nhat.
  ratingDesc,
  /// Mac dinh (khong sap xep).
  none,
}

/// Widget thanh loc va sap xep cho man hinh ket qua tim kiem.
///
/// Hien thi cac FilterChip ngang, cuon duoc khi nhieu.
///
/// Cac tuy chon: Gia, Danh gia, Sap xep (Gia tang/giam, Danh gia).
class SearchFilterBar extends StatelessWidget {
  /// Lua chon loc hien tai.
  final SearchSortType selectedSort;
  /// Lua chon loc theo gia.
  final double? minPrice;
  final double? maxPrice;
  /// Lua chon loc theo danh gia.
  final double? minRating;
  /// Ham goi khi nguoi dung thay doi loc.
  final ValueChanged<SearchSortType>? onSortChanged;

  const SearchFilterBar({
    super.key,
    this.selectedSort = SearchSortType.none,
    this.minPrice,
    this.maxPrice,
    this.minRating,
    this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      color: AppColors.surface,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          // Nut Gia: mo cua so loc gia.
          _FilterChipButton(
            label: LanguageService.translate('search_filter_price'),
            icon: Icons.tune,
            isSelected: minPrice != null || maxPrice != null,
            onTap: () => _showPriceFilterDialog(context),
          ),
          const SizedBox(width: 8),
          // Nut Danh gia: mo cua so loc danh gia.
          _FilterChipButton(
            label: LanguageService.translate('search_filter_rating'),
            icon: Icons.star_outline,
            isSelected: minRating != null,
            onTap: () => _showRatingFilterDialog(context),
          ),
          const SizedBox(width: 8),
          // Nut Sap xep gia tang.
          _FilterChipButton(
            label: LanguageService.translate('search_sort_price_asc'),
            icon: Icons.arrow_upward,
            isSelected: selectedSort == SearchSortType.priceAsc,
            onTap: () => onSortChanged?.call(SearchSortType.priceAsc),
          ),
          const SizedBox(width: 8),
          // Nut Sap xep gia giam.
          _FilterChipButton(
            label: LanguageService.translate('search_sort_price_desc'),
            icon: Icons.arrow_downward,
            isSelected: selectedSort == SearchSortType.priceDesc,
            onTap: () => onSortChanged?.call(SearchSortType.priceDesc),
          ),
          const SizedBox(width: 8),
          // Nut Sap xep danh gia cao.
          _FilterChipButton(
            label: LanguageService.translate('search_sort_rating'),
            icon: Icons.star,
            isSelected: selectedSort == SearchSortType.ratingDesc,
            onTap: () => onSortChanged?.call(SearchSortType.ratingDesc),
          ),
        ],
      ),
    );
  }

  void _showPriceFilterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _PriceFilterSheet(
        currentMin: minPrice,
        currentMax: maxPrice,
      ),
    );
  }

  void _showRatingFilterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _RatingFilterSheet(currentMin: minRating),
    );
  }
}

/// Nut bam filter nho (FilterChip style).
class _FilterChipButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback? onTap;

  const _FilterChipButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet loc theo khoang gia.
class _PriceFilterSheet extends StatefulWidget {
  final double? currentMin;
  final double? currentMax;

  const _PriceFilterSheet({
    this.currentMin,
    this.currentMax,
  });

  @override
  State<_PriceFilterSheet> createState() => _PriceFilterSheetState();
}

class _PriceFilterSheetState extends State<_PriceFilterSheet> {
  late TextEditingController _minController;
  late TextEditingController _maxController;

  @override
  void initState() {
    super.initState();
    _minController = TextEditingController(
      text: widget.currentMin?.toStringAsFixed(0) ?? '',
    );
    _maxController = TextEditingController(
      text: widget.currentMax?.toStringAsFixed(0) ?? '',
    );
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LanguageService.translate('search_filter_price'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minController,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: LanguageService.translate('search_price_from'),
                    hintText: LanguageService.translate('search_price_hint_min'),
                    fillColor: AppColors.surfaceVariant,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('-', style: TextStyle(fontSize: 20)),
              ),
              Expanded(
                child: TextField(
                  controller: _maxController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: LanguageService.translate('search_price_to'),
                    hintText: LanguageService.translate('search_price_hint_max'),
                    fillColor: AppColors.surfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                debugPrint('Loc gia: tu ${_minController.text} den ${_maxController.text}');
                Navigator.pop(context);
              },
              child: Text(LanguageService.translate('common_apply')),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: () {
                _minController.clear();
                _maxController.clear();
                Navigator.pop(context);
              },
              child: Text(LanguageService.translate('common_clear')),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet loc theo so sao danh gia.
class _RatingFilterSheet extends StatefulWidget {
  final double? currentMin;

  const _RatingFilterSheet({this.currentMin});

  @override
  State<_RatingFilterSheet> createState() => _RatingFilterSheetState();
}

class _RatingFilterSheetState extends State<_RatingFilterSheet> {
  double? _selectedRating;

  @override
  void initState() {
    super.initState();
    _selectedRating = widget.currentMin;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LanguageService.translate('search_filter_rating'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          // Cac o chon so sao: 4+, 3+, 2+.
          ...List.generate(3, (index) {
            final starCount = 4 - index;
            final isSelected = _selectedRating == starCount.toDouble();
            return ListTile(
              leading: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  starCount,
                  (i) => Icon(
                    Icons.star,
                    color: AppColors.warning,
                    size: 20,
                  ),
                ),
              ),
              title: Text('${starCount}+ ${LanguageService.translate('unit_rating')}'),
              trailing: isSelected
                  ? Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                setState(() {
                  _selectedRating = isSelected ? null : starCount.toDouble();
                });
              },
            );
          }),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                debugPrint('Loc danh gia: $_selectedRating+');
                Navigator.pop(context);
              },
              child: Text(LanguageService.translate('common_apply')),
            ),
          ),
        ],
      ),
    );
  }
}

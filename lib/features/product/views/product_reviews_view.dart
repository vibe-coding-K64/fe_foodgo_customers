import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/language_service.dart';
import '../models/product_review_model.dart';
import '../services/product_review_service.dart';

/// Trang danh gia cua mot mon an.
///
/// Duoc goi khi nguoi dung bam vao khoi danh gia o trang chi tiet mon.
///
/// Man hinh gom:
///   1. AppBar: Tieu de "Danh gia mon an", nut Back.
///   2. Thong ke tong quan: So sao trung binh + Bieu do phan bo.
///   3. Bo loc: Loc theo so sao, binh luan, hinh anh.
///   4. Danh sach danh gia: Avatar, ten, thoi gian, sao, noi dung, hinh anh.
class ProductReviewsView extends StatefulWidget {
  final String productId;
  final String productName;
  final String storeId;

  const ProductReviewsView({
    super.key,
    required this.productId,
    required this.productName,
    required this.storeId,
  });

  @override
  State<ProductReviewsView> createState() => _ProductReviewsViewState();
}

class _ProductReviewsViewState extends State<ProductReviewsView> {
  List<ProductReviewModel> _allReviews = [];
  bool _isLoading = false;
  String? _errorMessage;

  int? _selectedStarFilter;
  bool _filterWithComment = false;
  bool _filterWithImage = false;

  @override
  void initState() {
    super.initState();
    _fetchReviews();
    debugPrint(
        'ProductReviewsView: Khoi tao trang danh gia cua mon [${widget.productId}]');
    debugPrint('>>> [ProductReviewsView] productId = ${widget.productId}');
    debugPrint('>>> [ProductReviewsView] storeId   = ${widget.storeId}');
  }

  Future<void> _fetchReviews() async {
    debugPrint('>>> [ProductReviewsView._fetchReviews] goi API voi productId=${widget.productId}, storeId=${widget.storeId}');
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final reviews = await ProductReviewService.getReviewsByProduct(
        productId: widget.productId,
        storeId: widget.storeId,
      );

      debugPrint('>>> [ProductReviewsView] Nhan duoc ${reviews.length} reviews tu service');
      if (mounted) {
        setState(() {
          _allReviews = reviews;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('!!! [ProductReviewsView._fetchReviews] CATCH: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Da xay ra loi khong xac dinh.';
        });
      }
    }
  }

  List<ProductReviewModel> get _filteredReviews {
    return _allReviews.where((review) {
      if (_selectedStarFilter != null && review.starRating != _selectedStarFilter) {
        return false;
      }
      if (_filterWithComment && (review.comment == null || review.comment!.isEmpty)) {
        return false;
      }
      if (_filterWithImage && review.imageUrls.isEmpty) {
        return false;
      }
      return true;
    }).toList();
  }

  void _showStarFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _StarFilterBottomSheet(
        selectedStar: _selectedStarFilter,
        onSelect: (star) {
          setState(() => _selectedStarFilter = star);
          Navigator.pop(context);
          debugPrint('ProductReviewsView: Loc danh gia theo $star sao');
        },
      ),
    );
  }

  double get _averageRating {
    if (_allReviews.isEmpty) return 0;
    final total = _allReviews.fold<int>(0, (sum, r) => sum + r.starRating);
    return total / _allReviews.length;
  }

  ProductReviewStarDistribution get _distribution {
    int star5 = 0, star4 = 0, star3 = 0, star2 = 0, star1 = 0;
    for (final r in _allReviews) {
      switch (r.starRating) {
        case 5: star5++; break;
        case 4: star4++; break;
        case 3: star3++; break;
        case 2: star2++; break;
        case 1: star1++; break;
      }
    }
    return ProductReviewStarDistribution(
      star5: star5,
      star4: star4,
      star3: star3,
      star2: star2,
      star1: star1,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          context.t('product_review_title'),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.textHint,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchReviews,
                child: const Text('Thu lai'),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _ReviewOverviewSection(
            averageRating: _averageRating,
            distribution: _distribution,
          ),
          Divider(height: 1, color: AppColors.divider),
          _ReviewFilterBar(
            selectedStar: _selectedStarFilter,
            filterWithComment: _filterWithComment,
            filterWithImage: _filterWithImage,
            onStarFilterTap: _showStarFilterSheet,
            onCommentFilterChanged: (value) {
              setState(() => _filterWithComment = value ?? false);
            },
            onImageFilterChanged: (value) {
              setState(() => _filterWithImage = value ?? false);
            },
          ),
          Divider(height: 1, color: AppColors.divider),
          _ReviewListSection(
            reviews: _filteredReviews,
            totalReviews: _allReviews.length,
          ),
        ],
      ),
    );
  }
}

// ================================================================
// WIDGET: THONG KE TONG QUAN
// Hien thi so sao trung binh + Bieu do phan bo so sao (Pie Chart).
// ================================================================

class _ReviewOverviewSection extends StatelessWidget {
  final double averageRating;
  final ProductReviewStarDistribution distribution;

  const _ReviewOverviewSection({
    required this.averageRating,
    required this.distribution,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ========== BEN TRAI: SO SAO TRUNG BINH ==========
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  averageRating.toStringAsFixed(1),
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      context.t('review_star_label'),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${context.t('review_total_count').replaceFirst('\$1', distribution.total.toString())}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),

          // ========== BEN PHAI: BIEU DO PIE ==========
          Expanded(
            child: _ReviewPieChart(distribution: distribution),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// WIDGET: BIEU DO TRON (PIE CHART)
// Ve bieu do phan bo so sao bang CustomPaint.
// ================================================================

class _ReviewPieChart extends StatelessWidget {
  final ProductReviewStarDistribution distribution;

  const _ReviewPieChart({required this.distribution});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = [
      const Color(0xFF4CAF50), // 5 sao - xanh la
      const Color(0xFF8BC34A), // 4 sao - xanh nhat
      const Color(0xFFFFC107), // 3 sao - vang
      const Color(0xFFFF9800), // 2 sao - cam
      const Color(0xFFE53935), // 1 sao - do
    ];

    return Row(
      children: [
        // Bieu do tron.
        SizedBox(
          width: 100,
          height: 100,
          child: CustomPaint(
            painter: _PieChartPainter(
              percents: [
                distribution.getPercent(5),
                distribution.getPercent(4),
                distribution.getPercent(3),
                distribution.getPercent(2),
                distribution.getPercent(1),
              ],
              colors: colors,
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Chu thich tung cot.
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(5, (index) {
              final star = 5 - index;
              final percent = (distribution.getPercent(star) * 100).round();
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 1.5),
                child: Row(
                  children: [
                    Text(
                      '$star',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(Icons.star, color: Colors.amber, size: 10),
                    const SizedBox(width: 4),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: distribution.getPercent(star),
                          backgroundColor: AppColors.divider,
                          valueColor: AlwaysStoppedAnimation(colors[5 - star]),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$percent%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

/// Painter ve bieu do tron.
class _PieChartPainter extends CustomPainter {
  final List<double> percents;
  final List<Color> colors;

  _PieChartPainter({required this.percents, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    double startAngle = -math.pi / 2;

    for (int i = 0; i < percents.length; i++) {
      final sweepAngle = percents[i] * 2 * math.pi;
      if (sweepAngle > 0) {
        final paint = Paint()
          ..color = colors[i]
          ..style = PaintingStyle.fill;
        canvas.drawArc(rect, startAngle, sweepAngle, true, paint);
        startAngle += sweepAngle;
      }
    }

    final centerPaint = Paint()
      ..color = AppColors.surface
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.5, centerPaint);
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) {
    return oldDelegate.percents != percents;
  }
}

// ================================================================
// WIDGET: BO LOC DANH GIA
// Cuon ngang, chua cac nut loc theo so sao, binh luan, hinh anh.
// ================================================================

class _ReviewFilterBar extends StatelessWidget {
  final int? selectedStar;
  final bool filterWithComment;
  final bool filterWithImage;
  final VoidCallback onStarFilterTap;
  final ValueChanged<bool?> onCommentFilterChanged;
  final ValueChanged<bool?> onImageFilterChanged;

  const _ReviewFilterBar({
    required this.selectedStar,
    required this.filterWithComment,
    required this.filterWithImage,
    required this.onStarFilterTap,
    required this.onCommentFilterChanged,
    required this.onImageFilterChanged,
  });

  String _getStarLabel(int? star) {
    if (star == null) return LanguageService.translate('filter_all');
    return '$star ${LanguageService.translate('review_star_label')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _FilterChipButton(
              label: _getStarLabel(selectedStar),
              icon: Icons.arrow_drop_down,
              isSelected: selectedStar != null,
              onTap: onStarFilterTap,
            ),

            const SizedBox(width: 8),

            _FilterChipButton(
              label: context.t('filter_with_comment'),
              icon: Icons.comment_outlined,
              isSelected: filterWithComment,
              onTap: () => onCommentFilterChanged(!filterWithComment),
            ),

            const SizedBox(width: 8),

            _FilterChipButton(
              label: context.t('filter_with_image'),
              icon: Icons.image_outlined,
              isSelected: filterWithImage,
              onTap: () => onImageFilterChanged(!filterWithImage),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChipButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================================================================
// WIDGET: DANH SACH DANH GIA
// ================================================================

class _ReviewListSection extends StatelessWidget {
  final List<ProductReviewModel> reviews;
  final int totalReviews;

  const _ReviewListSection({
    required this.reviews,
    required this.totalReviews,
  });

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return _EmptyReviewsWidget();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            context.t('review_total_count').replaceFirst('\$1', totalReviews.toString()),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reviews.length,
          separatorBuilder: (context, index) => Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: AppColors.divider,
          ),
          itemBuilder: (context, index) => _ReviewItemWidget(review: reviews[index]),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ================================================================
// WIDGET: MOT ITEM DANH GIA
// ================================================================

class _ReviewItemWidget extends StatelessWidget {
  final ProductReviewModel review;

  const _ReviewItemWidget({required this.review});

  String _formatDate(BuildContext context, DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    final timePart = '$hour:$minute';
    final datePart = '$day/$month/$year';
    final template = context.t('review_time_format');
    return template.replaceFirst('\$1', timePart).replaceFirst('\$2', datePart);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              review.userAvatarUrl.isNotEmpty
                  ? CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.surfaceVariant,
                      backgroundImage: NetworkImage(review.userAvatarUrl),
                      onBackgroundImageError: (_, __) {},
                    )
                  : CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.surfaceVariant,
                      child: Icon(Icons.person, size: 20, color: AppColors.textHint),
                    ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(context, review.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textHint,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              _StarRatingDisplay(rating: review.starRating),
            ],
          ),

          const SizedBox(height: 10),

          if (review.comment != null && review.comment!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 50),
              child: Text(
                review.comment!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(left: 50),
              child: Text(
                context.t('review_no_content'),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textHint,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

          if (review.imageUrls.isNotEmpty) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 50),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: review.imageUrls.map((url) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      url,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 80,
                          color: AppColors.surfaceVariant,
                          child: Icon(Icons.broken_image, color: AppColors.textHint, size: 24),
                        );
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ],

          // ===== PHAN HOI TU CUA HANG =====
          if (review.replyComment != null && review.replyComment!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 50, top: 10),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.store,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          context.t('review_seller_reply_label'),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (review.repliedAt != null) ...[
                          const Spacer(),
                          Text(
                            _formatDate(context, review.repliedAt!),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textHint,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      review.replyComment!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ================================================================
// WIDGET: HIEN THI SAO (5 ICON)
// ================================================================

class _StarRatingDisplay extends StatelessWidget {
  final int rating;

  const _StarRatingDisplay({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final isFilled = index < rating;
        return Icon(
          isFilled ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 16,
        );
      }),
    );
  }
}

// ================================================================
// WIDGET: TRANG THAI EMPTY
// ================================================================

class _EmptyReviewsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.rate_review_outlined,
            size: 64,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 16),
          Text(
            context.t('empty_reviews'),
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// BOTTOM SHEET: CHON SO SAO LOC
// ================================================================

class _StarFilterBottomSheet extends StatelessWidget {
  final int? selectedStar;
  final ValueChanged<int?> onSelect;

  const _StarFilterBottomSheet({
    required this.selectedStar,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final options = [null, 5, 4, 3, 2, 1];

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text(
              context.t('filter_by_star'),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          ...options.map((star) {
            final isSelected = star == selectedStar;
            return ListTile(
              leading: star == null
                  ? null
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        star,
                        (i) => const Icon(Icons.star, color: Colors.amber, size: 18),
                      ),
                    ),
              title: Text(
                star == null
                    ? context.t('filter_all')
                    : '$star ${context.t('review_star_label')}',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              trailing: isSelected
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () => onSelect(star),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

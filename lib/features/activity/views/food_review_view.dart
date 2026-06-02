import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/localization/language_service.dart';
import '../../../core/utils/auth_storage.dart';
import '../../order/models/order_model.dart';
import '../../order/services/food_review_service.dart';

class FoodReviewView extends StatefulWidget {
  final OrderModel order;

  const FoodReviewView({
    super.key,
    required this.order,
  });

  @override
  State<FoodReviewView> createState() => _FoodReviewViewState();
}

class _FoodReviewViewState extends State<FoodReviewView> {
  late List<FoodReviewItemModel> _reviewItems;
  bool _isSubmitting = false;

  String get _userId => AuthStorage.getUserId() ?? '';
  String get _userName {
    final user = AuthStorage.getUser();
    return user?['fullName'] as String? ?? 'Khách hàng';
  }

  String? get _userAvatarUrl {
    final user = AuthStorage.getUser();
    return user?['photoUrl'] as String?;
  }

  @override
  void initState() {
    super.initState();
    _reviewItems = FoodReviewService.getReviewItemsFromOrder(widget.order);
    debugPrint(
        'FoodReviewView: Khởi tạo ${_reviewItems.length} dòng đánh giá cho đơn [${widget.order.id}]');
  }

  bool get _hasAnyRating => _reviewItems.any((item) => item.starRating > 0);

  Future<void> _submitReviews() async {
    if (!_hasAnyRating) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.t('food_review_error_no_rating')),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await FoodReviewService.submitFoodReviews(
        orderId: widget.order.id,
        storeId: widget.order.storeId,
        userId: _userId,
        userName: _userName,
        userAvatarUrl: _userAvatarUrl,
        items: _reviewItems,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.t('food_review_success')),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } on FoodReviewException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.t('error_unknown')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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
          context.t('food_review_title'),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  _OrderInfoBanner(
                    orderCode: widget.order.orderCode,
                    storeName: widget.order.storeName,
                    storeAvatar: widget.order.storeAvatar,
                    createdAt: widget.order.createdAt,
                  ),

                  Divider(height: 1, color: AppColors.divider),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      context.t('food_review_section_title'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _reviewItems.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: AppColors.divider,
                    ),
                    itemBuilder: (context, index) {
                      final item = _reviewItems[index];
                      return _ReviewItemCard(
                        key: ValueKey(item.productId),
                        item: item,
                        onRatingChanged: (r) => setState(() => item.starRating = r),
                        onCommentChanged: (c) => item.comment = c,
                        onPickImages: () async {
                          await FoodReviewService.pickImagesForItem(item);
                          setState(() {});
                        },
                        onTakePhoto: () async {
                          await FoodReviewService.takePhotoForItem(item);
                          setState(() {});
                        },
                        onRemoveImage: (i) {
                          FoodReviewService.removeImage(item, i);
                          setState(() {});
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting || !_hasAnyRating ? null : _submitReviews,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.surfaceVariant,
                    disabledForegroundColor: AppColors.textHint,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : Text(
                          context.t('food_review_submit'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// WIDGET: THÔNG TIN ĐƠN HÀNG (BANNER)
// ================================================================

class _OrderInfoBanner extends StatelessWidget {
  final String? orderCode;
  final String storeName;
  final String? storeAvatar;
  final DateTime createdAt;

  const _OrderInfoBanner({
    this.orderCode,
    required this.storeName,
    this.storeAvatar,
    required this.createdAt,
  });

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          storeAvatar != null && storeAvatar!.isNotEmpty
              ? CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.surfaceVariant,
                  backgroundImage: NetworkImage(storeAvatar!),
                  onBackgroundImageError: (_, __) {},
                )
              : CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.surfaceVariant,
                  child: const Icon(Icons.store, color: AppColors.textHint),
                ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  storeName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${context.t('food_review_order_date')}: ${_formatDate(createdAt)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (orderCode != null && orderCode!.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '#$orderCode',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ================================================================
// WIDGET: MỘT DÒNG ĐÁNH GIÁ (theo productId đã gom)
// ================================================================

class _ReviewItemCard extends StatefulWidget {
  final FoodReviewItemModel item;
  final ValueChanged<int> onRatingChanged;
  final ValueChanged<String> onCommentChanged;
  final VoidCallback onPickImages;
  final VoidCallback onTakePhoto;
  final ValueChanged<int> onRemoveImage;

  const _ReviewItemCard({
    super.key,
    required this.item,
    required this.onRatingChanged,
    required this.onCommentChanged,
    required this.onPickImages,
    required this.onTakePhoto,
    required this.onRemoveImage,
  });

  @override
  State<_ReviewItemCard> createState() => _ReviewItemCardState();
}

class _ReviewItemCardState extends State<_ReviewItemCard> {
  late TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController(text: widget.item.comment);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.camera_alt, color: Colors.white),
                ),
                title: const Text('Chụp ảnh'),
                onTap: () {
                  Navigator.pop(context);
                  widget.onTakePhoto();
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.secondary,
                  child: Icon(Icons.photo_library, color: Colors.white),
                ),
                title: const Text('Chọn từ thư viện'),
                onTap: () {
                  Navigator.pop(context);
                  widget.onPickImages();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== Header: Hình + Tên + SL =====
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: widget.item.foodImageUrl != null &&
                        widget.item.foodImageUrl!.isNotEmpty
                    ? Image.network(
                        widget.item.foodImageUrl!,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _buildPlaceholderImage(),
                      )
                    : _buildPlaceholderImage(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.foodName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          _formatPrice(widget.item.price),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '×${widget.item.totalQuantity}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ===== Chọn sao =====
          Row(
            children: [
              Text(
                context.t('food_review_rating_label'),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              _StarRatingInput(
                rating: widget.item.starRating,
                onRatingChanged: widget.onRatingChanged,
                size: 32,
              ),
              const Spacer(),
              if (widget.item.starRating > 0)
                Text(
                  _getStarLabel(widget.item.starRating),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _getStarColor(widget.item.starRating),
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 14),

          // ===== Nhập bình luận =====
          TextField(
            controller: _commentController,
            maxLines: 3,
            maxLength: 500,
            decoration: InputDecoration(
              hintText: context.t('food_review_comment_hint'),
              hintStyle: const TextStyle(color: AppColors.textHint),
              filled: true,
              fillColor: AppColors.surfaceVariant,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.5),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              counterStyle: const TextStyle(color: AppColors.textHint),
            ),
            onChanged: widget.onCommentChanged,
          ),

          const SizedBox(height: 12),

          // ===== Nút chọn ảnh =====
          _ImagePickerSection(
            item: widget.item,
            onAddPhoto: _showImageSourceSheet,
            onRemoveImage: widget.onRemoveImage,
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.restaurant,
          color: AppColors.textHint, size: 28),
    );
  }

  String _formatPrice(double price) {
    if (price >= 1000) {
      final formatted =
          (price / 1000).toStringAsFixed(price % 1000 == 0 ? 0 : 1);
      return '${formatted}000đ';
    }
    return '${price.toStringAsFixed(0)}đ';
  }

  String _getStarLabel(int rating) {
    switch (rating) {
      case 1:
        return context.t('food_review_star_1');
      case 2:
        return context.t('food_review_star_2');
      case 3:
        return context.t('food_review_star_3');
      case 4:
        return context.t('food_review_star_4');
      case 5:
        return context.t('food_review_star_5');
      default:
        return '';
    }
  }

  Color _getStarColor(int rating) {
    switch (rating) {
      case 1:
        return const Color(0xFFE53935);
      case 2:
        return const Color(0xFFFF9800);
      case 3:
        return const Color(0xFFFFC107);
      case 4:
        return const Color(0xFF8BC34A);
      case 5:
        return const Color(0xFF4CAF50);
      default:
        return AppColors.textSecondary;
    }
  }
}

// ================================================================
// WIDGET: CHỌN ẢNH (thumbs + nút thêm)
// ================================================================

class _ImagePickerSection extends StatelessWidget {
  final FoodReviewItemModel item;
  final VoidCallback onAddPhoto;
  final ValueChanged<int> onRemoveImage;

  const _ImagePickerSection({
    required this.item,
    required this.onAddPhoto,
    required this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    final allImages = item.pickedImages;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.photo_library_outlined,
                size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              'Ảnh minh hoạ (${allImages.length}/5)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 80,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // Nút thêm ảnh
              if (allImages.length < 5)
                GestureDetector(
                  onTap: onAddPhoto,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.border,
                        width: 1.5,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo,
                            color: AppColors.textSecondary, size: 24),
                        SizedBox(height: 4),
                        Text(
                          'Thêm ảnh',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Các ảnh đã chọn
              ...allImages.asMap().entries.map((entry) {
                final index = entry.key;
                final file = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          File(file.path),
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 80,
                            height: 80,
                            color: AppColors.surfaceVariant,
                            child: const Icon(Icons.broken_image,
                                color: AppColors.textHint),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: GestureDetector(
                          onTap: () => onRemoveImage(index),
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close,
                                color: Colors.white, size: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

// ================================================================
// WIDGET: SAO CHỌN (local, không phụ thuộc service)
// ================================================================

class _StarRatingInput extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onRatingChanged;
  final double size;

  const _StarRatingInput({
    required this.rating,
    required this.onRatingChanged,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        final isFilled = starValue <= rating;
        return GestureDetector(
          onTap: () {
            debugPrint('StarRating: Chọn $starValue sao');
            onRatingChanged(starValue);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Icon(
              isFilled ? Icons.star : Icons.star_border,
              color: Colors.amber,
              size: size,
            ),
          ),
        );
      }),
    );
  }
}

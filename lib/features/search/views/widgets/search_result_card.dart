import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/language_service.dart';
import '../../models/search_result_item.dart';

/// Widget hien thi mot item san pham trong danh sach ket qua tim kiem.
///
/// Bo cuc: [Hinh anh] [Ten mon] [Ten cua hang] [Gia | Sao] [Icon gio hang]
class SearchResultCard extends StatelessWidget {
  final SearchResultItem item;
  final int cartQuantity;
  final bool isAddingToCart;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;

  const SearchResultCard({
    super.key,
    required this.item,
    this.cartQuantity = 0,
    this.isAddingToCart = false,
    this.onTap,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.divider.withOpacity(0.5),
                width: 1,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hinh anh san pham ben trai.
              _buildProductImage(context),
              const SizedBox(width: 12),
              // Noi dung chinh: ten mon, ten cua hang, gia, danh gia.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProductName(),
                    const SizedBox(height: 2),
                    _buildStoreName(),
                    const SizedBox(height: 6),
                    _buildPriceAndRating(),
                  ],
                ),
              ),
              // Nut them vao gio hang ben phai.
              _buildAddButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        children: [
          Image.network(
            item.imageUrl,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: AppColors.textHint,
                  size: 28,
                ),
              );
            },
          ),
          if (item.isOutOfStock)
            Positioned.fill(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    context.t('home_out_of_stock'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductName() {
    return Text(
      item.productName,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildStoreName() {
    return Text(
      item.storeName,
      style: TextStyle(
        fontSize: 13,
        color: AppColors.textSecondary,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildPriceAndRating() {
    return Row(
      children: [
        // Gia tien.
        Text(
          _formatPrice(item.price),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        const Spacer(),
        // Danh gia sao.
        Icon(
          Icons.star,
          size: 14,
          color: AppColors.warning,
        ),
        const SizedBox(width: 2),
        Text(
          item.rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          '(${item.reviewCount})',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildAddButton() {
    if (item.isOutOfStock) {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.textHint.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.remove_shopping_cart_outlined,
          color: Colors.white,
          size: 20,
        ),
      );
    }

    if (isAddingToCart) {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    if (cartQuantity > 0) {
      // Da co trong gio -> hien thi icon gio + badge so luong.
      return Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            onTap: onAddToCart,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          Positioned(
            top: -6,
            right: -6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(minWidth: 18),
              child: Text(
                '$cartQuantity',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      );
    }

    // Chua co trong gio -> hien thi nut +.
    return GestureDetector(
      onTap: onAddToCart,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }

  /// Format gia thanh chuoi VND (VD: "45.000 đ").
  String _formatPrice(double price) {
    if (price >= 1000) {
      final formatted = price.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}.',
          );
      return '$formatted đ';
    }
    return '${price.toStringAsFixed(0)} đ';
  }
}

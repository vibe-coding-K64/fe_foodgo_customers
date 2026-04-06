import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/language_service.dart';
import '../models/product_item_model.dart';
import '../models/rewards_model.dart';

/// Man hinh hien thi danh sach san pham co the ap dung voucher.
///
/// Khi nguoi dung bam nut "Dung ngay" tren voucher, he thong se chuyen
/// huong sang trang nay de hien thi danh sach san pham duoc phep su dung
/// voucher do.
///
/// Thiet ke:
///   - AppBar voi tieu de dong lay tu voucher.
///   - Banner thong bao nho phia duoi AppBar.
///   - ListView danh sach san pham (1 cot, moi hang 1 san pham).
///   - FAB nut gio hang o goc phai duoi man hinh.
class VoucherApplicableProductsView extends StatefulWidget {
  /// Voucher duoc truyen vao de lay tieu de va hien thi thong tin.
  final MyVoucherModel voucher;

  const VoucherApplicableProductsView({
    super.key,
    required this.voucher,
  });

  @override
  State<VoucherApplicableProductsView> createState() =>
      _VoucherApplicableProductsViewState();
}

class _VoucherApplicableProductsViewState
    extends State<VoucherApplicableProductsView> {
  /// Mock data danh sach san pham co the ap dung voucher.
  /// Se duoc thay the boi API call thuc te.
  final List<ProductItemModel> _mockProducts = [
    const ProductItemModel(
      id: 'p1',
      name: 'Com ga xoi mem',
      imageUrl:
          'https://images.unsplash.com/photo-1562967914-608f82629710?w=200&q=80',
      price: 35000,
      storeName: 'Quan Com Van Phong',
    ),
    const ProductItemModel(
      id: 'p2',
      name: 'Bun bo hue',
      imageUrl:
          'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=200&q=80',
      price: 45000,
      storeName: 'Bun Bo Hue Ba Hoa',
    ),
    const ProductItemModel(
      id: 'p3',
      name: 'My tom ham',
      imageUrl:
          'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=200&q=80',
      price: 55000,
      storeName: 'My Quang Oc Hoa',
    ),
    const ProductItemModel(
      id: 'p4',
      name: 'Ca fee sua da',
      imageUrl:
          'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=200&q=80',
      price: 28000,
      storeName: 'Highland Coffee',
    ),
    const ProductItemModel(
      id: 'p5',
      name: 'Tra sua tran chau',
      imageUrl:
          'https://images.unsplash.com/photo-1558857563-b371033873b8?w=200&q=80',
      price: 30000,
      storeName: 'TraSua Oc Que',
    ),
    const ProductItemModel(
      id: 'p6',
      name: 'Banh mi thit',
      imageUrl:
          'https://images.unsplash.com/photo-1600688640154-9619e0020423?w=200&q=80',
      price: 25000,
      storeName: 'Banh Mi Phuong Nam',
    ),
    const ProductItemModel(
      id: 'p7',
      name: 'Com tam suon bi cha',
      imageUrl:
          'https://images.unsplash.com/photo-1568667256549-094345857637?w=200&q=80',
      price: 48000,
      storeName: 'Com Tam Gia Dinh',
    ),
    const ProductItemModel(
      id: 'p8',
      name: 'Xoi ga lam dong',
      imageUrl:
          'https://images.unsplash.com/photo-1604329760661-e71dc83f8f26?w=200&q=80',
      price: 32000,
      storeName: 'Xoi Ga Ba Xuan',
    ),
  ];

  int _cartItemCount = 0;

  /// Tao tieu de dong cho AppBar.
  String get _titleText {
    final discountText = widget.voucher.isPercentage
        ? 'Giam ${widget.voucher.discountValue.toInt()}%'
        : 'Giam ${widget.voucher.discountValue.toInt()}K';
    final titleTemplate =
        LanguageService.translate('voucher_apply_title').replaceAll('\$1', discountText);
    return titleTemplate;
  }

  /// Format gia thanh chuoi VND (VD: "35.000 đ").
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

  /// Xu ly khi nguoi dung them san pham vao gio hang.
  void _onAddToCart(ProductItemModel product) {
    setState(() {
      _cartItemCount++;
    });
    debugPrint('VoucherApplicableProductsView: Da them san pham [${product.name}] vao gio hang');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          LanguageService.translate('success_add_to_cart'),
        ),
        duration: const Duration(seconds: 1),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _titleText,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Banner thong bao nho phia duoi AppBar.
          _buildInfoBanner(),
          // Danh sach san pham.
          Expanded(
            child: ListView.builder(
              itemCount: _mockProducts.length,
              itemBuilder: (context, index) {
                return _buildProductItem(_mockProducts[index]);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _buildCartFAB(),
    );
  }

  /// Banner thong bao nho phia duoi AppBar.
  Widget _buildInfoBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.primary,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              LanguageService.translate('voucher_auto_apply_note'),
              style: TextStyle(
                fontSize: 13,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget hien thi mot item san pham trong danh sach.
  Widget _buildProductItem(ProductItemModel product) {
    return Material(
      color: AppColors.surface,
      child: InkWell(
        onTap: () {
          debugPrint('VoucherApplicableProductsView: Nguoi dung bam san pham [${product.name}]');
        },
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
              _buildProductImage(product),
              const SizedBox(width: 12),
              // Noi dung chinh: ten mon, ten cua hang, gia.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProductName(product),
                    const SizedBox(height: 2),
                    _buildStoreName(product),
                    const SizedBox(height: 6),
                    _buildPrice(product),
                  ],
                ),
              ),
              // Nut them vao gio hang ben phai.
              _buildAddButton(product),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage(ProductItemModel product) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        product.imageUrl,
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
    );
  }

  Widget _buildProductName(ProductItemModel product) {
    return Text(
      product.name,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildStoreName(ProductItemModel product) {
    return Text(
      product.storeName,
      style: TextStyle(
        fontSize: 13,
        color: AppColors.textSecondary,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildPrice(ProductItemModel product) {
    return Text(
      _formatPrice(product.price),
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildAddButton(ProductItemModel product) {
    return GestureDetector(
      onTap: () => _onAddToCart(product),
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

  /// FAB nut gio hang o goc phai duoi man hinh.
  Widget _buildCartFAB() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        FloatingActionButton(
          onPressed: () {
            debugPrint('VoucherApplicableProductsView: Nguoi dung bam FAB gio hang, so mon: $_cartItemCount');
          },
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          child: const Icon(
            Icons.shopping_cart_outlined,
            size: 24,
          ),
        ),
        // Badge hien thi so luong mon trong gio (neu co).
        if (_cartItemCount > 0)
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              child: Text(
                _cartItemCount.toString(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

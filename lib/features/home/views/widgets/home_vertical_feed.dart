import 'package:flutter/material.dart';
import '../../models/store_model.dart';
import '../../models/product_model.dart';
import '../../../../core/localization/language_service.dart';

/// Widget feed danh sach san pham/quan an cuon doc.
/// Nhan Stream thay vi List, tu dong xu ly 3 trang thai:
/// - Dang tai: CircularProgressIndicator
/// - Loi: Hien thi thong bao loi
/// - Co du lieu: Hien thi danh sach
class HomeVerticalFeed extends StatelessWidget {
  final Stream<List<StoreModel>>? storesStream;
  final Stream<List<ProductModel>>? productsStream;
  final void Function(StoreModel store)? onStoreTap;
  final void Function(ProductModel product)? onProductTap;
  final VoidCallback? onLoadMore;

  const HomeVerticalFeed({
    super.key,
    this.storesStream,
    this.productsStream,
    this.onStoreTap,
    this.onProductTap,
    this.onLoadMore,
  }) : assert(storesStream != null || productsStream != null);

  @override
  Widget build(BuildContext context) {
    if (storesStream != null) {
      return _StoresVerticalStreamBuilder(
        storesStream: storesStream!,
        onStoreTap: onStoreTap,
        onLoadMore: onLoadMore,
      );
    } else {
      return _ProductsVerticalStreamBuilder(
        productsStream: productsStream!,
        onProductTap: onProductTap,
        onLoadMore: onLoadMore,
      );
    }
  }
}

class _StoresVerticalStreamBuilder extends StatelessWidget {
  final Stream<List<StoreModel>> storesStream;
  final void Function(StoreModel store)? onStoreTap;
  final VoidCallback? onLoadMore;

  const _StoresVerticalStreamBuilder({
    required this.storesStream,
    this.onStoreTap,
    this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<StoreModel>>(
      stream: storesStream,
      builder: (context, snapshot) {
        // Hien thi loading khi chua co du lieu.
        if (!snapshot.hasData) {
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 5,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, __) => const _VerticalStoreItemSkeleton(),
          );
        }

        if (snapshot.hasError) {
          debugPrint(
              'HomeVerticalFeed: loi khi load danh sach quan: ${snapshot.error}');
          return _ErrorWidget(
            message: LanguageService.translate('error_load_stores'),
          );
        }

        final stores = snapshot.data!;
        if (stores.isEmpty) {
          return _EmptyWidget(
            message: LanguageService.translate('empty_stores'),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: stores.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return _VerticalStoreItem(
              store: stores[index],
              onTap: () => onStoreTap?.call(stores[index]),
            );
          },
        );
      },
    );
  }
}

class _ProductsVerticalStreamBuilder extends StatelessWidget {
  final Stream<List<ProductModel>> productsStream;
  final void Function(ProductModel product)? onProductTap;
  final VoidCallback? onLoadMore;

  const _ProductsVerticalStreamBuilder({
    required this.productsStream,
    this.onProductTap,
    this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ProductModel>>(
      stream: productsStream,
      builder: (context, snapshot) {
        // Hien thi loading khi chua co du lieu.
        if (!snapshot.hasData) {
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 5,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, __) => const _VerticalProductItemSkeleton(),
          );
        }

        if (snapshot.hasError) {
          debugPrint(
              'HomeVerticalFeed: loi khi load danh sach san pham: ${snapshot.error}');
          return _ErrorWidget(
            message: LanguageService.translate('error_load_products'),
          );
        }

        final products = snapshot.data!;
        if (products.isEmpty) {
          return _EmptyWidget(
            message: LanguageService.translate('empty_products'),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: products.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return _VerticalProductItem(
              product: products[index],
              onTap: () => onProductTap?.call(products[index]),
            );
          },
        );
      },
    );
  }
}

class _VerticalStoreItem extends StatelessWidget {
  final StoreModel store;
  final VoidCallback? onTap;

  const _VerticalStoreItem({required this.store, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                store.avtUrl,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 90,
                  height: 90,
                  color: Colors.grey[200],
                  child: const Icon(Icons.store),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    store.address,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 2),
                      Text(
                        store.rating.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${store.reviewCount} ${LanguageService.translate('unit_rating')})',
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color:
                              store.isOpen ? Colors.green[50] : Colors.red[50],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          store.isOpen
                              ? LanguageService.translate('home_open')
                              : LanguageService.translate('home_closed'),
                          style: TextStyle(
                            fontSize: 11,
                            color: store.isOpen ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        store.deliveryTime,
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerticalProductItem extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;

  const _VerticalProductItem({required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                children: [
                  Image.network(
                    product.imageUrl,
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 90,
                      height: 90,
                      color: Colors.grey[200],
                      child: const Icon(Icons.fastfood),
                    ),
                  ),
                  if (product.isOutOfStock)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            LanguageService.translate('home_out_of_stock'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.categoryName,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.description,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${product.basePrice.toStringAsFixed(0)} ${LanguageService.translate('unit_currency')}',
                    style: const TextStyle(
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerticalStoreItemSkeleton extends StatelessWidget {
  const _VerticalStoreItemSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120,
                  height: 15,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 160,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 80,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalProductItemSkeleton extends StatelessWidget {
  const _VerticalProductItemSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120,
                  height: 15,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 80,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 150,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 70,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  final String message;

  const _ErrorWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red[300]),
            const SizedBox(height: 4),
            Text(
              message,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyWidget extends StatelessWidget {
  final String message;

  const _EmptyWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Center(
        child: Text(
          message,
          style: TextStyle(fontSize: 14, color: Colors.grey[500]),
        ),
      ),
    );
  }
}

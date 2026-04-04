import 'package:flutter/material.dart';
import '../../models/category_model.dart';
import '../../../../core/localization/language_service.dart';

/// Widget hien thi danh muc mon an duoi dang cuon ngang.
/// Nhan Stream<List<CategoryModel>> va tu dong xu ly 3 trang thai:
/// - Dang tai: CircularProgressIndicator
/// - Loi: Hien thi thong bao loi
/// - Co du lieu: Hien thi danh sach danh muc
class HomeCategories extends StatelessWidget {
  final Stream<List<CategoryModel>> categoriesStream;
  final void Function(CategoryModel category)? onCategoryTap;

  const HomeCategories({
    super.key,
    required this.categoriesStream,
    this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            LanguageService.translate('home_categories'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<CategoryModel>>(
          stream: categoriesStream,
          builder: (context, snapshot) {
            // Hien thi loading khi chua co du lieu.
            if (!snapshot.hasData) {
              return SizedBox(
                height: 110,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: 6,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, __) => const _CategoryItemSkeleton(),
                ),
              );
            }

            if (snapshot.hasError) {
              debugPrint(
                  'HomeCategories: Loi khi load danh muc: ${snapshot.error}');
              return _ErrorWidget(
                message: LanguageService.translate('error_load_categories'),
              );
            }

            final categories = snapshot.data!;
            if (categories.isEmpty) {
              return _EmptyWidget(
                message: LanguageService.translate('empty_categories'),
              );
            }

            return SizedBox(
              height: 110,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return _CategoryItem(
                    category: category,
                    onTap: () => onCategoryTap?.call(category),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback? onTap;

  const _CategoryItem({required this.category, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: NetworkImage(category.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 70,
            child: Text(
              category.name,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton loading cho item danh muc.
class _CategoryItemSkeleton extends StatelessWidget {
  const _CategoryItemSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.grey[200],
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 50,
          height: 12,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Colors.grey[200],
          ),
        ),
      ],
    );
  }
}

/// Widget hien thi khi co loi.
class _ErrorWidget extends StatelessWidget {
  final String message;

  const _ErrorWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
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

/// Widget hien thi khi khong co du lieu.
class _EmptyWidget extends StatelessWidget {
  final String message;

  const _EmptyWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: Center(
        child: Text(
          message,
          style: TextStyle(fontSize: 14, color: Colors.grey[500]),
        ),
      ),
    );
  }
}

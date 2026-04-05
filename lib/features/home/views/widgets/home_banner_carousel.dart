import 'package:flutter/material.dart';
import '../../models/banner_model.dart';
import '../../../../core/constants/app_colors.dart';

/// Widget hien thi banner quang cao duoi dang carousel.
/// Nhan Stream<List<BannerModel>> va tu dong xu ly 3 trang thai.
class HomeBannerCarousel extends StatelessWidget {
  final Stream<List<BannerModel>> bannersStream;
  final void Function(BannerModel banner)? onBannerTap;

  const HomeBannerCarousel({
    super.key,
    required this.bannersStream,
    this.onBannerTap,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BannerModel>>(
      stream: bannersStream,
      builder: (context, snapshot) {
        // Hien thi loading khi chua co du lieu.
        if (!snapshot.hasData) {
          return _BannerSkeleton();
        }

        if (snapshot.hasError) {
          debugPrint(
              'HomeBannerCarousel: loi khi load banner: ${snapshot.error}');
          return const SizedBox.shrink();
        }

        final banners = snapshot.data!;
        if (banners.isEmpty) {
          return const SizedBox.shrink();
        }

        return _BannerCarouselContent(
          banners: banners,
          onBannerTap: onBannerTap,
        );
      },
    );
  }
}

class _BannerCarouselContent extends StatefulWidget {
  final List<BannerModel> banners;
  final void Function(BannerModel banner)? onBannerTap;

  const _BannerCarouselContent({
    required this.banners,
    this.onBannerTap,
  });

  @override
  State<_BannerCarouselContent> createState() => _BannerCarouselContentState();
}

class _BannerCarouselContentState extends State<_BannerCarouselContent> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: widget.banners.length,
            itemBuilder: (context, index) {
              final banner = widget.banners[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GestureDetector(
                  onTap: () => widget.onBannerTap?.call(banner),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          banner.imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.image, size: 40),
                          ),
                        ),
                      ),
                      if (banner.storeName != null && banner.storeName!.isNotEmpty)
                        Positioned(
                          bottom: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              banner.storeName!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.banners.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentPage == index ? 20 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? AppColors.primaryDark
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BannerSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[200],
        ),
      ),
    );
  }
}

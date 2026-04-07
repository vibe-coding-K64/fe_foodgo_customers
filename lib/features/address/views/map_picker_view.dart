import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/language_service.dart';

///=============================================================================
/// SECTION: MODELS
///=============================================================================

/// Model mot dia diem duoc goi y (mock).
class SuggestedLocationModel {
  final String name;
  final String address;
  final double latitude;
  final double longitude;

  const SuggestedLocationModel({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });
}

///=============================================================================
/// SECTION: VIEW
///=============================================================================

/// Man hinh chon dia chi tren ban do.
///
/// Duoc goi ra tu trang Them dia chi moi, cho phep nguoi dung:
///
/// Lop 1 (day)    : Container toan man hinh - nen xam nhat hoac anh tu Unsplash.
/// Lop 2 (giua)   : Icon ghim dia diem nam chinh giua man hinh.
/// Lop 3 (tren)   : Cac cong cu tuong tac (Back, Tim kiem, Bottom Card).
///
/// Giao dien chi la Mock UI, chua tich hop Google Maps API.
class MapPickerView extends StatelessWidget {
  /// Dia chi mac dinh de hien thi (neu co).
  final String? initialAddress;

  /// Callback khi nguoi dung xac nhan vi tri.
  final void Function(double latitude, double longitude, String address)?
      onLocationConfirmed;

  const MapPickerView({
    super.key,
    this.initialAddress,
    this.onLocationConfirmed,
  });

  /// Vi tri mac dinh (mock) - tam thoi dung TP.HCM.
  static const double _defaultLat = 10.7769;
  static const double _defaultLng = 106.7009;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ================================================================
          // LOP 1: NEN BAN DO (Tren cung)
          // ================================================================
          _buildMapBackground(),

          // ================================================================
          // LOP 2: DIEM GHIM (Giua Stack)
          // ================================================================
          _buildPinMarker(),

          // ================================================================
          // LOP 3: CAC CONG CU TUONG TAC (Tren cung)
          // ================================================================
          SafeArea(
            child: Column(
              children: [
                // Nut Back o goc trai tren.
                _buildBackButton(context),
                const Spacer(),
                // Noi dung Bottom Card.
                _buildBottomCard(context),
              ],
            ),
          ),

          // Thanh tim kiem nam giua man hinh (nam tren Bottom Card).
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _buildSearchBar(context),
            ),
          ),
        ],
      ),
    );
  }

  /// Lop 1: Container toan man hinh, nen xam nhat.
  Widget _buildMapBackground() {
    return SizedBox.expand(
      child: Container(
        color: AppColors.surfaceVariant,
        child: Image.network(
          // Anh ban do gia tu Unsplash lam nen (TP.HCM).
          'https://images.unsplash.com/photo-1528183429752-'
          'cf0b7de6dce9?w=1200&q=80',
          fit: BoxFit.cover,
          // Neu anh that bai thi hien thi Container mau xam.
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: AppColors.surfaceVariant,
            );
          },
          // Hien thi loading neu anh dang tai.
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: AppColors.surfaceVariant,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.textSecondary,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Lop 2: Icon ghim dia diem nam chinh giua man hinh.
  Widget _buildPinMarker() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Bong mo duoi chan ghim.
          Container(
            width: 20,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 2),
          // Icon ghim mau xanh la.
          Icon(
            Icons.location_on,
            size: 56,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  /// Nut Back o goc trai tren.
  Widget _buildBackButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 16, top: 16),
        child: GestureDetector(
          onTap: () {
            debugPrint('MapPickerView: Nguoi dung bam nut Back');
            Navigator.pop(context);
          },
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_back,
              size: 22,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  /// Thanh tim kiem giua man hinh.
  ///
  /// Su dung TextField lam khoi duy nhat de dam bao border bao toan bo
  /// (icon trai, text, icon phai deu nam trong cung 1 border).
  Widget _buildSearchBar(BuildContext context) {
    return TextField(
      readOnly: true,
      onTap: () {
        debugPrint('MapPickerView: Nguoi dung bam thanh tim kiem');
        // TODO: Mo trang tim kiem dia chi (tich hop Google Places).
      },
      style: const TextStyle(
        fontSize: 15,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: LanguageService.translate('map_search_hint'),
        hintStyle: TextStyle(
          fontSize: 15,
          color: AppColors.textHint,
        ),
        // Icon trai nam trong border.
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 16, right: 8),
          child: Icon(
            Icons.search,
            size: 20,
            color: AppColors.textSecondary,
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        // Icon phai nam trong border.
        suffixIcon: GestureDetector(
          onTap: () {
            debugPrint('MapPickerView: Nguoi dung bam nut xoa tim kiem');
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 8, right: 16),
            child: Icon(
              Icons.close,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        // Border mac dinh (chua focus).
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
        // Border khi focus - cung radius, mau xanh nhat.
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(
            color: AppColors.primary.withAlpha(160),
            width: 1.5,
          ),
        ),
        // Khong co border giua (InputBorder.none lam tat ca).
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(
            color: AppColors.primary.withAlpha(160),
            width: 1.5,
          ),
        ),
        // Nen trang cho toan khoi.
        filled: true,
        fillColor: Colors.white,
        // Noi dung can giua theo chieu cao.
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
        ),
      ),
    );
  }

  /// Bottom Card: Hien thi dia chi da ghim va nut xac nhan.
  Widget _buildBottomCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, 16, 20,
          MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tam ke giua de keo Card (decorative).
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Tieu de.
          Text(
            LanguageService.translate('map_pinned_address'),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          // Dia chi (mock).
          Text(
            initialAddress ?? 'So 1, Vo Van Ngan, TP. Thu Duc, TP.HCM',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // Mo ta them (mock).
          Text(
            '10.7769, 106.7009',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textHint,
            ),
          ),
          const SizedBox(height: 16),
          // Nut Xac nhan vi tri.
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                debugPrint(
                    'MapPickerView: Nguoi dung xac nhan vi tri tai [$_defaultLat, $_defaultLng]');
                onLocationConfirmed?.call(
                  _defaultLat,
                  _defaultLng,
                  initialAddress ?? 'So 1, Vo Van Ngan, TP. Thu Duc, TP.HCM',
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                LanguageService.translate('map_confirm_btn'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

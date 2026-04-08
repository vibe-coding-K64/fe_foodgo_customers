import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/language_service.dart';
import 'driver_chat_view.dart';
import 'order_detail_view.dart';

///=============================================================================
/// SECTION: MODELS
///=============================================================================

/// Model vi tri Marker tren ban do.
class MapMarkerModel {
  /// Vi tri (0.0 - 1.0) theo ti le so voi kich thuoc man hinh.
  final double xRatio;
  final double yRatio;
  final IconData icon;
  final Color color;
  final String labelKey;

  const MapMarkerModel({
    required this.xRatio,
    required this.yRatio,
    required this.icon,
    required this.color,
    required this.labelKey,
  });
}

///=============================================================================
/// SECTION: VIEW
///=============================================================================

/// Man hinh theo doi don hang tren ban do.
///
/// Hien thi cho cac don hang o trang thai "Dang giao".
///
/// Lop 1 (day)    : Container toan man hinh - nen xam nhat hoac anh tu Unsplash.
/// Lop 2 (giua)   : 3 Marker gia (Quan an, Khach hang, Tai xe).
/// Lop 3 (tren)   : Cac overlay (Back, ETA Card, Bottom Card).
///
/// Giao dien chi la Mock UI, chua tich hop Google Maps API.
class OrderTrackingMapView extends StatelessWidget {
  /// Thong tin don hang (bat buoc).
  final OrderDetailModel order;

  /// Thoi gian du kien con lai (phut).
  final int etaMinutes;

  const OrderTrackingMapView({
    super.key,
    required this.order,
    this.etaMinutes = 15,
  });

  /// Danh sach 3 Marker mock.
  List<MapMarkerModel> get _markers => [
        MapMarkerModel(
          xRatio: 0.25,
          yRatio: 0.25,
          icon: Icons.store_outlined,
          color: AppColors.primary,
          labelKey: 'track_map_marker_shop',
        ),
        MapMarkerModel(
          xRatio: 0.75,
          yRatio: 0.75,
          icon: Icons.home_outlined,
          color: AppColors.primaryDark,
          labelKey: 'track_map_marker_customer',
        ),
        MapMarkerModel(
          xRatio: 0.50,
          yRatio: 0.45,
          icon: Icons.two_wheeler,
          color: AppColors.info,
          labelKey: 'track_map_marker_driver',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ================================================================
          // LOP 1: NEN BAN DO
          // ================================================================
          _buildMapBackground(),

          // ================================================================
          // LOP 2: CAC MARKER
          // ================================================================
          ..._buildMarkers(context),

          // ================================================================
          // LOP 3: CAC OVERLAY
          // ================================================================
          SafeArea(
            child: Column(
              children: [
                // Nut Back o goc trai tren.
                _buildBackButton(context),
                const Spacer(),
                // Bottom Card thong tin tai xe.
                _buildBottomCard(context),
              ],
            ),
          ),

          // ETA Card o giua phia tren.
          _buildEtaCard(context),
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
          'https://images.unsplash.com/photo-1528183429752-'
          'cf0b7de6dce9?w=1200&q=80',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(color: AppColors.surfaceVariant);
          },
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

  /// Lop 2: Render danh sach Marker.
  List<Widget> _buildMarkers(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return _markers.map((marker) {
      return Positioned(
        left: size.width * marker.xRatio - 24,
        top: size.height * marker.yRatio - 24,
        child: _buildMarkerIcon(context, marker),
      );
    }).toList();
  }

  /// Icon Marker don le.
  Widget _buildMarkerIcon(BuildContext context, MapMarkerModel marker) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Bang hieu Marker.
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              marker.icon,
              size: 26,
              color: marker.color,
            ),
          ),
        ),
        const SizedBox(height: 4),
        // Nhan Marker.
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            context.t(marker.labelKey),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
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
            debugPrint('OrderTrackingMapView: Nguoi dung bam nut Back');
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

  /// Card hien thi thoi gian du kien (ETA).
  Widget _buildEtaCard(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 60,
      left: 16,
      right: 16,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.access_time,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '${context.t('track_map_eta_label')} '
                '${context.t('track_map_eta_minutes').replaceFirst('\$1', etaMinutes.toString())}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Bottom Card: Thong tin tai xe va nut hanh dong.
  Widget _buildBottomCard(BuildContext context) {
    final driver = order.driverInfo;
    // Neu khong co thong tin tai xe, hien thi gia tri mac dinh.
    final driverName = driver?.name ?? context.t('track_map_driver_name');
    final vehiclePlate = driver?.vehiclePlate ?? context.t('track_map_vehicle_plate');
    final driverPhone = driver?.phone ?? '';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
          // Tam ke giua (decorative).
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
          const SizedBox(height: 14),
          // Trang thai don hang.
          Text(
            context.t('track_map_status_delivering'),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          // Thong tin tai xe.
          Row(
            children: [
              // Avatar.
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.surfaceVariant,
                backgroundImage: (driver?.avatarUrl.isNotEmpty ?? false)
                    ? NetworkImage(driver!.avatarUrl)
                    : null,
                child: (driver?.avatarUrl.isEmpty ?? true)
                    ? Icon(
                        Icons.person,
                        size: 26,
                        color: AppColors.textSecondary,
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              // Ten va bien so.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driverName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.two_wheeler,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          vehiclePlate,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Nut goi dien.
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () {
                    debugPrint(
                        'OrderTrackingMapView: Nguoi dung goi tai xe [$driverPhone]');
                    // TODO: Mo url tel hoac app goi dien.
                  },
                  icon: const Icon(
                    Icons.phone,
                    size: 22,
                    color: Colors.white,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Nut nhan tin.
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                debugPrint(
                    'OrderTrackingMapView: Nguoi dung bam nut nhan tin voi tai xe');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DriverChatView(
                      chat: DriverChatModel(
                        driverName: driverName,
                        vehiclePlate: vehiclePlate,
                        driverPhone: driverPhone,
                        driverAvatarUrl: driver?.avatarUrl ?? '',
                        messages: const [],
                      ),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.chat_bubble_outline, size: 20),
              label: Text(context.t('track_map_message_btn')),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
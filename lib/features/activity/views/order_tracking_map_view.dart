import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:fe_foodgo_customers/core/constants/app_colors.dart';
import 'package:fe_foodgo_customers/core/localization/language_service.dart';
import 'package:fe_foodgo_customers/core/services/osrm_service.dart';

/// Man hinh theo doi vi tri don hang tren ban do that.
///
/// Hien thi cac marker tren OpenStreetMap:
///   - Vi tri GPS hien tai cua thiet bi (vong tron xanh duong)
///   - Vi tri khach hang dat hang (icon nguoi)
///   - Vi tri nha hang (icon cua hang)
///   - Vi tri tai xe (icon xe may) — cap nhat realtime tu Firestore
///
/// Su dung `flutter_map` + OpenStreetMap tiles.
class OrderTrackingMapView extends StatefulWidget {
  /// ID don hang (de doc realtime tu Firestore).
  final String orderId;

  /// ID tai xe (de doc toa do tu driver_profiles/{driverId}).
  final String driverId;

  /// Ten tai xe.
  final String driverName;

  /// So dien thoai tai xe.
  final String driverPhone;

  /// Bien so xe.
  final String vehiclePlate;

  /// Toa do cua tai xe (khoi tao, cap nhat realtime).
  final double? driverLat;
  final double? driverLng;

  /// Toa do cua hang (quán an).
  final double? storeLat;
  final double? storeLng;
  final String? storeName;

  /// Toa do dia chi giao hang (noi khach dat).
  final double? addressLat;
  final double? addressLng;
  final String? receiverName;

  const OrderTrackingMapView({
    super.key,
    required this.orderId,
    required this.driverId,
    required this.driverName,
    required this.driverPhone,
    required this.vehiclePlate,
    this.driverLat,
    this.driverLng,
    this.storeLat,
    this.storeLng,
    this.storeName,
    this.addressLat,
    this.addressLng,
    this.receiverName,
  });

  @override
  State<OrderTrackingMapView> createState() => _OrderTrackingMapViewState();
}

class _OrderTrackingMapViewState extends State<OrderTrackingMapView> {
  late final MapController _mapController;

  /// Vi tri GPS thiet bi.
  LatLng? _deviceLocation;

  /// Vi tri tai xe (tu Firestore realtime).
  LatLng? _driverLocation;

  /// Subscription doc realtime driver location tu Firestore.
  StreamSubscription<DocumentSnapshot>? _driverLocationSub;

  /// Khoang cach giua driver va khach (m).
  double? _distanceToCustomer;

  /// Thoi gian du kien (phut), tinh tu toc do ~30km/h.
  int? _etaMinutes;

  /// Tuyen duong tu tai xe den khach hang (OSRM polyline).
  List<LatLng>? _routePoints;

  /// Co dang goi OSRM lay route khong.
  bool _isRouteLoading = false;

  /// Timestamp (ms) lan cuoi goi OSRM, de debounce.
  int _lastRouteFetchMs = 0;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _driverLocation = (widget.driverLat != null && widget.driverLng != null)
        ? LatLng(widget.driverLat!, widget.driverLng!)
        : null;
    debugPrint('OrderTrackingMapView initState: driverLat=${widget.driverLat}, driverLng=${widget.driverLng}, _driverLocation=$_driverLocation');
    _initDeviceLocation();
    _subscribeDriverLocation();
  }

  @override
  void dispose() {
    _driverLocationSub?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  /// Lay vi tri GPS hien tai cua thiet bi.
  Future<void> _initDeviceLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      if (mounted) {
        setState(() {
          _deviceLocation = LatLng(position.latitude, position.longitude);
        });
        _fitBounds();
      }
    } catch (e) {
      debugPrint('OrderTrackingMapView: Khong lay duoc GPS: $e');
    }
  }

  /// Doc realtime driver location tu Firestore.
  void _subscribeDriverLocation() {
    debugPrint('OrderTrackingMapView: subscribing to driver location for driverId=${widget.driverId}');
    _driverLocationSub = FirebaseFirestore.instance
        .collection('driver_profiles')
        .doc(widget.driverId)
        .snapshots()
        .listen((doc) {
      if (!doc.exists || !mounted) return;
      final data = doc.data()!;
      debugPrint('OrderTrackingMapView driver_profiles: $data');
      final lat = (data['lat'] as num?)?.toDouble();
      final lng = (data['lng'] as num?)?.toDouble();
      debugPrint('OrderTrackingMapView: driver lat=$lat, lng=$lng');
      if (lat != null && lng != null) {
        setState(() {
          _driverLocation = LatLng(lat, lng);
        });
        _updateEta();
        _fitBounds();
        _fetchRoute();
      }
    });
  }

  /// Tinh khoang cach va ETA khi driver location thay doi.
  void _updateEta() {
    if (_driverLocation == null) return;
    LatLng? dest;

    // Neu co dia chi khach -> tinh theo no, nguoc lai dung store
    if (widget.addressLat != null && widget.addressLng != null) {
      dest = LatLng(widget.addressLat!, widget.addressLng!);
    } else if (widget.storeLat != null && widget.storeLng != null) {
      dest = LatLng(widget.storeLat!, widget.storeLng!);
    }

    if (dest != null) {
      const Distance dist = Distance();
      final meters = dist.as(
        LengthUnit.Meter,
        _driverLocation!,
        dest,
      );
      _distanceToCustomer = meters;
      // Ước tính: 30km/h ≈ 8.33m/s → ETA phút
      _etaMinutes = (meters / 500).ceil().clamp(1, 99);
    }
  }

  /// Lay tuyen duong OSRM tu tai xe den khach.
  /// Co debounce: chi goi lai neu da qua 10 giay.
  Future<void> _fetchRoute() async {
    if (_driverLocation == null) return;

    final dest = (widget.addressLat != null && widget.addressLng != null)
        ? LatLng(widget.addressLat!, widget.addressLng!)
        : (widget.storeLat != null && widget.storeLng != null)
            ? LatLng(widget.storeLat!, widget.storeLng!)
            : null;
    if (dest == null) return;

    // Debounce: chi goi lai sau 10 giay
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    if (nowMs - _lastRouteFetchMs < 10000 && _routePoints != null) return;
    _lastRouteFetchMs = nowMs;

    if (mounted) setState(() => _isRouteLoading = true);

    final points = await OSRMService.getRoute(
      origin: _driverLocation!,
      destination: dest,
    );

    if (mounted) {
      setState(() {
        _routePoints = points;
        _isRouteLoading = false;
      });
    }
  }

  /// Fit ban do de hien thi tat ca cac marker.
  void _fitBounds() {
    final points = <LatLng>[];

    if (_deviceLocation != null) points.add(_deviceLocation!);
    if (_driverLocation != null) points.add(_driverLocation!);
    if (widget.storeLat != null && widget.storeLng != null) {
      points.add(LatLng(widget.storeLat!, widget.storeLng!));
    }
    if (widget.addressLat != null && widget.addressLng != null) {
      points.add(LatLng(widget.addressLat!, widget.addressLng!));
    }

    if (points.isEmpty) return;

    if (points.length == 1) {
      _mapController.move(points.first, 15);
      return;
    }

    final bounds = LatLngBounds.fromPoints(points);
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(60),
      ),
    );
  }

  /// Danh sach tat ca marker can hien thi.
  List<Marker> get _markers {
    final result = <Marker>[];

    // 1. Vi tri GPS thiet bi — vong tron xanh duong
    if (_deviceLocation != null) {
      result.add(
        Marker(
          point: _deviceLocation!,
          width: 36,
          height: 36,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue.shade600,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.4),
                  blurRadius: 8,
                  spreadRadius: 3,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 2. Vi tri khach dat hang — icon nguoi
    if (widget.addressLat != null && widget.addressLng != null) {
      result.add(
          Marker(
          point: LatLng(widget.addressLat!, widget.addressLng!),
          width: 44,
          height: 80,
          child: _buildLabeledMarker(
            icon: Icons.person_pin_circle,
            color: AppColors.primaryDark,
            label: widget.receiverName ?? context.t('track_map_marker_customer'),
          ),
        ),
      );
    }

    // 3. Vi tri nha hang — icon cua hang
    if (widget.storeLat != null && widget.storeLng != null) {
      final storeName = widget.storeName ?? context.t('track_map_marker_shop');
      result.add(
        Marker(
          point: LatLng(widget.storeLat!, widget.storeLng!),
          width: 44,
          height: 80,
          child: _buildLabeledMarker(
            icon: Icons.storefront,
            color: AppColors.primary,
            label: storeName,
          ),
        ),
      );
    }

    // 4. Vi tri tai xe — icon xe may
    if (_driverLocation != null) {
      result.add(
        Marker(
          point: _driverLocation!,
          width: 44,
          height: 80,
          child: _buildLabeledMarker(
            icon: Icons.two_wheeler,
            color: AppColors.info,
            label: widget.driverName.isNotEmpty
                ? widget.driverName
                : context.t('track_map_marker_driver'),
          ),
        ),
      );
    }

    return result;
  }

  /// Tao marker co icon + nhan.
  Widget _buildLabeledMarker({
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return ClipRect(
      child: Column(
        mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Icon(icon, size: 24, color: color),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ================================================================
          // LOP 1: BAN DO
          // ================================================================
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _getInitialCenter(),
              initialZoom: 14,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.fe_foodgo_customers',
              ),
              if (_routePoints != null && _routePoints!.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints!,
                      strokeWidth: 5,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              MarkerLayer(markers: _markers),
            ],
          ),

          // ================================================================
          // LOP 2: CAC OVERLAY
          // ================================================================
          SafeArea(
            child: Column(
              children: [
                _buildBackButton(context),
                const Spacer(),
                SingleChildScrollView(
                  child: _buildBottomCard(context),
                ),
              ],
            ),
          ),

          // ETA Card o giua phia tren.
          _buildEtaCard(context),
        ],
      ),
    );
  }

  LatLng _getInitialCenter() {
    if (_driverLocation != null) return _driverLocation!;
    if (widget.storeLat != null && widget.storeLng != null) {
      return LatLng(widget.storeLat!, widget.storeLng!);
    }
    if (widget.addressLat != null && widget.addressLng != null) {
      return LatLng(widget.addressLat!, widget.addressLng!);
    }
    if (_deviceLocation != null) return _deviceLocation!;
    // Mac dinh: TP.HCM
    return const LatLng(10.8231, 106.6297);
  }

  /// Nut Back o goc trai tren.
  Widget _buildBackButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 16, top: 12),
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
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
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
    if (_etaMinutes == null) return const SizedBox.shrink();

    return Positioned(
      top: MediaQuery.of(context).padding.top + 56,
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
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.access_time, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                context.t('track_map_eta_min').replaceFirst('\$1', _etaMinutes.toString()),
                style: const TextStyle(
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
    final displayDriverName = widget.driverName.isNotEmpty
        ? widget.driverName
        : context.t('track_map_driver_name');
    final displayVehiclePlate = widget.vehiclePlate.isNotEmpty
        ? widget.vehiclePlate
        : context.t('track_map_vehicle_plate');

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
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tam ke giua.
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
          // Trang thai.
          Text(
            context.t('track_map_status_delivering'),
            style: const TextStyle(
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
                child: const Icon(
                  Icons.person,
                  size: 26,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 14),
              // Ten va bien so.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayDriverName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.two_wheeler,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            displayVehiclePlate,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        if (_distanceToCustomer != null) ...[
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.straighten,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${_distanceToCustomer!.toInt()} m',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
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
                    final uri = Uri(scheme: 'tel', path: widget.driverPhone);
                    launchUrl(uri);
                  },
                  icon: const Icon(Icons.phone, size: 22, color: Colors.white),
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

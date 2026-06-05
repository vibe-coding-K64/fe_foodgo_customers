import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/language_service.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../../core/services/nominatim_service.dart';

///Man hinh chon vi tri tren ban do.
///
///Stack gom:
///  - AppBar (back + tieu de)
///  - Search bar (Photon autocomplete)
///  - FlutterMap (OSM/CartoDB tiles + marker o giua)
///  - Bottom sheet (dia chi preview + nut xac nhan)
///
///Tra ve `Map<String, dynamic>` khi nguoi dung bam "Xac nhan":
///  - `lat`: double
///  - `lng`: double
///  - `address`: String (dia chi day du)
class MapPickerPage extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;
  final String? initialAddress;

  const MapPickerPage({
    super.key,
    this.initialLat,
    this.initialLng,
    this.initialAddress,
  });

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  late final MapController _mapController;

  ///Vi tri marker (luc dau = vi tri mac dinh TP.HCM, hoac initial)
  late LatLng _currentPosition;

  ///Dia chi duoc geocode tu vi tri hien tai
  String _formattedAddress = '';

  ///Dang tai khi lay dia chi
  bool _isFetchingAddress = false;

  ///Ket qua search Nominatim
  List<NominatimResult> _searchResults = [];
  bool _isSearching = false;

  ///Debounce reverse geocoding (1 giay)
  Timer? _debounceGeocode;

  ///Debounce search API (400ms)
  Timer? _debounceSearch;

  ///Controller cho o tim kiem
  final TextEditingController _searchController = TextEditingController();

  ///FocusNode de dieu khien keyboard
  final FocusNode _searchFocus = FocusNode();

  ///Co dang scroll map khong (de tranh goi geocode khi setState)
  bool _isProgrammaticMove = false;

  ///Dang lay vi tri GPS
  bool _isLocating = false;

  ///Map dang di chuyen (de xu ly onMapEventMoveEnd)
  bool _isMoving = false;

  ///Tranh race condition: chi update address khi response ve dung vi tri dang request
  LatLng? _requestedLatLng;

  ///Da lay dia chi cho vi tri khoi dau chua (de tranh goi API thua voi vi tri TP.HCM)
  bool _didInitialFetch = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _currentPosition = (widget.initialLat != null && widget.initialLng != null)
        ? LatLng(widget.initialLat!, widget.initialLng!)
        : const LatLng(10.7769, 106.7009);

    if (widget.initialAddress != null && widget.initialAddress!.isNotEmpty) {
      _formattedAddress = widget.initialAddress!;
      _searchController.text = widget.initialAddress!;
      _onPositionChanged(_currentPosition);
    } else {
      _getInitialLocation();
    }
  }

  ///Lay vi tri GPS khi man hinh khoi dau.
  Future<void> _getInitialLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      _currentPosition = LatLng(position.latitude, position.longitude);
      _mapController.move(_currentPosition, 16);
      _onPositionChanged(_currentPosition);
    } catch (e) {
      _onPositionChanged(_currentPosition);
    }
  }

  @override
  void dispose() {
    _debounceGeocode?.cancel();
    _debounceSearch?.cancel();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  ///Go API reverse geocoding cho vi tri hien tai.
  Future<void> _onPositionChanged(LatLng position) async {
    _requestedLatLng = position;
    setState(() => _isFetchingAddress = true);
    try {
      final address = await NominatimService.reverse(position);
      if (mounted && _requestedLatLng == position) {
        setState(() {
          _formattedAddress = address;
          _isFetchingAddress = false;
          _didInitialFetch = true;
        });
        if (_searchController.text.isEmpty && address.isNotEmpty) {
          _searchController.text = address;
        }
      }
    } catch (e) {
      if (mounted && _requestedLatLng == position) {
        setState(() {
          _formattedAddress = '';
          _isFetchingAddress = false;
          _didInitialFetch = true;
        });
      }
    }
  }

  ///Lay vi tri GPS hien tai cua may.
  Future<void> _getCurrentLocation() async {
    setState(() => _isLocating = true);
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      final latLng = LatLng(position.latitude, position.longitude);
      _isProgrammaticMove = true;
      _mapController.move(latLng, 16);
      _onPositionChanged(latLng);
      _isProgrammaticMove = false;
    } catch (e) {
      if (mounted) {
        showAppToast(
          context,
          message: context.t('address_form_location_error'),
          type: AppToastType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  ///Khi nguoi dung go vao o tim kiem.
  void _onSearchChanged(String query) {
    _debounceSearch?.cancel();

    if (query.trim().length < 3) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isSearching = true);
    _debounceSearch = Timer(const Duration(milliseconds: 400), () async {
      try {
        final results = await NominatimService.search(query);
        if (mounted) {
          setState(() {
            _searchResults = results;
            _isSearching = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isSearching = false);
        }
      }
    });
  }

  ///Khi nguoi dung bam mot ket qua search.
  void _onSelectSearchResult(NominatimResult result) {
    _searchFocus.unfocus();
    _debounceSearch?.cancel();
    _debounceGeocode?.cancel();

    _searchController.text = result.displayName;
    final target = LatLng(result.lat, result.lng);

    _isProgrammaticMove = true;
    _currentPosition = target;
    setState(() => _searchResults = []);

    _mapController.move(target, 16);

    Timer(const Duration(milliseconds: 600), () {
      _isProgrammaticMove = false;
      _onPositionChanged(target);
    });
  }

  ///Khi nguoi dung bam "Xac nhan".
  void _onConfirm() {
    debugPrint('MapPicker: Xac nhan lat=${_currentPosition.latitude}, '
        'lng=${_currentPosition.longitude}, address=$_formattedAddress');
    Navigator.pop(context, {
      'lat': _currentPosition.latitude,
      'lng': _currentPosition.longitude,
      'address': _formattedAddress,
    });
  }

  ///Dong ho tro hien thi dia chi.
  Widget _buildAddressPreview() {
    if (_isFetchingAddress) {
      return Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Text(
            context.t('address_form_fetching_address'),
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      );
    }
    if (_formattedAddress.isEmpty) {
      return Text(
        context.t('address_form_no_results'),
        style: const TextStyle(fontSize: 13, color: AppColors.textHint),
      );
    }
    return Row(
      children: [
        const Icon(Icons.location_on, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            _formattedAddress,
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: Stack(
        children: [
          // === FlutterMap ===
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition,
              initialZoom: 16,
              minZoom: 4,
              maxZoom: 19,
              onMapEvent: (event) {
                if (event is MapEventMoveStart) {
                  _isMoving = true;
                } else if (event is MapEventMoveEnd) {
                  if (_isMoving && !_isProgrammaticMove && _didInitialFetch) {
                    _isMoving = false;
                    _onPositionChanged(event.camera.center);
                  }
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.example.foodgo',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _currentPosition,
                    width: 50,
                    height: 50,
                    child: const Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 50,
                      semanticLabel: 'Selected location',
                    ),
                  ),
                ],
              ),
            ],
          ),

          // === Crosshair icon ghim co dinh giua man hinh ===
          Center(
            child: IgnorePointer(
              child: Icon(
                Icons.add_circle,
                color: Colors.red.shade400,
                size: 36,
              ),
            ),
          ),

          // === AppBar tu ho (back) ===
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      context.t('map_picker_title'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),

          // === Search bar ===
          Positioned(
            top: MediaQuery.of(context).padding.top + 60,
            left: 16,
            right: 16,
            child: _buildSearchSection(),
          ),

          // === Nut GPS ===
          Positioned(
            right: 16,
            bottom: 180 + bottomPadding,
            child: FloatingActionButton.small(
              heroTag: 'gps',
              backgroundColor: Colors.white,
              onPressed: _isLocating ? null : _getCurrentLocation,
              child: _isLocating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                    )
                  : Icon(Icons.my_location, color: Colors.blue.shade700),
            ),
          ),

          // === Bottom sheet ===
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(16, 14, 16, 14 + bottomPadding),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(25),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Address preview
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _buildAddressPreview(),
                  ),
                  const SizedBox(height: 14),
                  // Confirm button
                  GestureDetector(
                    onTap: _onConfirm,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        context.t('address_form_confirm_location'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
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

  Widget _buildSearchSection() {
    return Column(
      children: [
        // Search text field
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(20),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocus,
            textInputAction: TextInputAction.search,
            textCapitalization: TextCapitalization.words,
            onChanged: _onSearchChanged,
            onSubmitted: (_) {
              if (_searchResults.isNotEmpty) {
                _onSelectSearchResult(_searchResults.first);
              } else {
                _searchFocus.unfocus();
              }
            },
            decoration: InputDecoration(
              hintText: context.t('address_form_search_location'),
              prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
              suffixIcon: _isSearching
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchResults = []);
                          },
                        )
                      : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),

        // Search results dropdown
        if (_searchResults.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(20),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 6),
              itemCount: _searchResults.length,
              separatorBuilder: (_, __) => const Divider(height: 1, indent: 16, endIndent: 16),
              itemBuilder: (context, index) {
                final result = _searchResults[index];
                return InkWell(
                  onTap: () => _onSelectSearchResult(result),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.place, size: 20, color: AppColors.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                result.street ?? result.displayName.split(',').first,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (result.city != null && result.city!.isNotEmpty)
                                Text(
                                  result.city!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

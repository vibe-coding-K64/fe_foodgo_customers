import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// Dịch vụ gọi OSRM (Open Source Routing Machine) để lấy tuyến đường.
/// Miễn phí, không cần API key.
/// Endpoint: https://router.project-osrm.org
class OSRMService {
  static const String _baseUrl = 'https://router.project-osrm.org';

  /// Lấy tuyến đường từ origin đến destination.
  /// Trả về List<LatLng> là các điểm trên tuyến đường.
  /// Trả về null nếu không lấy được route.
  static Future<List<LatLng>?> getRoute({
    required LatLng origin,
    required LatLng destination,
    int timeoutSeconds = 10,
  }) async {
    // OSRM yêu cầu format: lng,lat (thứ tự ngược)
    final url = Uri.parse(
      '$_baseUrl/route/v1/driving/'
      '${origin.longitude},${origin.latitude};'
      '${destination.longitude},${destination.latitude}'
      '?overview=full&geometries=polyline',
    );

    try {
      final resp = await http
          .get(
            url,
            headers: {
              'Accept': 'application/json',
            },
          )
          .timeout(Duration(seconds: timeoutSeconds));

      if (resp.statusCode != 200) {
        debugPrint('OSRMService: HTTP ${resp.statusCode}');
        return null;
      }

      final json = jsonDecode(resp.body) as Map<String, dynamic>;

      // Kiểm tra mã lỗi của OSRM
      final code = json['code'] as String?;
      if (code == null || code != 'Ok') {
        debugPrint('OSRMService: Response code = $code');
        return null;
      }

      // Lấy geometry (encoded polyline)
      final routes = json['routes'] as List?;
      if (routes == null || routes.isEmpty) {
        debugPrint('OSRMService: No routes found');
        return null;
      }

      final geometry = routes[0]['geometry'] as String?;
      if (geometry == null || geometry.isEmpty) {
        debugPrint('OSRMService: No geometry in response');
        return null;
      }

      return _decodePolyline(geometry);
    } catch (e) {
      debugPrint('OSRMService.getRoute error: $e');
      return null;
    }
  }

  /// Decode polyline string từ OSRM thành List<LatLng>.
  /// OSRM dùng Google Polyline Algorithm (5-bit groups).
  static List<LatLng> _decodePolyline(String encoded) {
    final points = <LatLng>[];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < encoded.length) {
      int shift = 0;
      int result = 0;
      int byte;

      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20);

      final dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;

      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20);

      final dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      // Chuyển từ int (1e-5 degree) sang double
      points.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return points;
  }
}


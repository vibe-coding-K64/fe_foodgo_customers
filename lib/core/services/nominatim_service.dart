import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

///Ket noi Nominatim (OSM) de reverse geocoding: lat/lng -> dia chi text.
class NominatimService {
  static const String _baseUrl = 'https://nominatim.openstreetmap.org/reverse';
  static const String _userAgent = 'FoodGoApp/1.0 (flutter)';

  ///Tra ve dia chi day du tu toa do (lat, lng).
  static Future<String> reverse(LatLng position) async {
    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'lat': position.latitude.toString(),
      'lon': position.longitude.toString(),
      'format': 'json',
      'addressdetails': '1',
    });

    try {
      final resp = await http.get(
        uri,
        headers: {'User-Agent': _userAgent},
      );
      if (resp.statusCode != 200) return '';

      final json = jsonDecode(resp.body) as Map<String, dynamic>;
      return _formatAddress(json['address'] as Map<String, dynamic>? ?? {});
    } catch (e) {
      debugPrint('NominatimService.reverse error: $e');
      return '';
    }
  }

  ///Gom cac thanh phan dia chi thanh chuoi theo format VN.
  static String _formatAddress(Map<String, dynamic> addr) {
    final road      = addr['road']            as String? ?? '';
    final houseNum  = addr['house_number']    as String? ?? '';
    final suburb    = addr['suburb']          as String? ?? '';
    final neighbourhood = addr['neighbourhood'] as String? ?? '';
    final village   = addr['village']         as String? ?? '';
    final town      = addr['town']            as String? ?? '';
    final cityDist  = addr['city_district']   as String? ?? '';
    final county    = addr['county']          as String? ?? '';
    final city      = addr['city']            as String? ?? addr['state'] as String? ?? '';
    final postcode  = addr['postcode']        as String? ?? '';

    final streetParts = <String>[];
    if (houseNum.isNotEmpty) streetParts.add(houseNum);
    if (road.isNotEmpty)     streetParts.add(road);
    final street = streetParts.join(' ');

    final wardPart = village.isNotEmpty
        ? village
        : town.isNotEmpty
            ? town
            : suburb.isNotEmpty
                ? suburb
                : neighbourhood.isNotEmpty
                    ? neighbourhood
                    : cityDist;

    final districtPart = county;

    final cityPart = city;

    final parts = <String>[];
    if (street.isNotEmpty)        parts.add(street);
    if (wardPart.isNotEmpty)      parts.add(wardPart);
    if (districtPart.isNotEmpty)  parts.add(districtPart);
    if (cityPart.isNotEmpty)      parts.add(cityPart);
    if (postcode.isNotEmpty)      parts.add(postcode);

    if (parts.isEmpty) return '';
    return parts.join(', ');
  }
}

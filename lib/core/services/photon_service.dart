import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

///Ket noi Photon API (komoot) de search dia chi OSM.
class PhotonService {
  static const String _baseUrl = 'https://photon.komoot.io/api/';

  ///Tim kiem dia chi, tra ve danh sach ket qua.
  static Future<List<PhotonResult>> search(String query) async {
    if (query.trim().length < 2) return [];

    final uri = Uri.parse('$_baseUrl?q=${Uri.encodeComponent(query)}&lang=vi&limit=6');
    try {
      final resp = await http.get(
        uri,
        headers: {'User-Agent': 'FoodGoApp/1.0 (flutter)'},
      );
      if (resp.statusCode != 200) return [];

      final json = jsonDecode(resp.body) as Map<String, dynamic>;
      final features = json['features'] as List? ?? [];
      return features.map((f) => PhotonResult.fromJson(f as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('PhotonService.search error: $e');
      return [];
    }
  }
}

///Ket qua tra ve tu Photon API.
class PhotonResult {
  final String name;
  final String? street;
  final String? city;
  final String? state;
  final double lat;
  final double lng;

  PhotonResult({
    required this.name,
    this.street,
    this.city,
    this.state,
    required this.lat,
    required this.lng,
  });

  factory PhotonResult.fromJson(Map<String, dynamic> json) {
    final props = json['properties'] as Map<String, dynamic>? ?? {};
    final geom = json['geometry'] as Map<String, dynamic>? ?? {};
    final coords = geom['coordinates'] as List? ?? [];

    return PhotonResult(
      name: props['name'] as String? ?? '',
      street: props['street'] as String?,
      city: props['city'] as String? ?? props['town'] as String? ?? props['village'] as String?,
      state: props['state'] as String?,
      lng: coords.isNotEmpty ? (coords[0] as num).toDouble() : 0,
      lat: coords.isNotEmpty ? (coords[1] as num).toDouble() : 0,
    );
  }

  ///Hien thi dia chi ngan gon de hien thi trong dropdown.
  String get displayName {
    final parts = <String>[];
    if (street != null && street!.isNotEmpty) parts.add(street!);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (parts.isEmpty && name.isNotEmpty) parts.add(name);
    if (state != null && state!.isNotEmpty) parts.add(state!);
    return parts.isNotEmpty ? parts.join(', ') : name;
  }

  @override
  String toString() => 'PhotonResult($displayName, lat=$lat, lng=$lng)';
}

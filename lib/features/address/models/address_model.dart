import 'package:cloud_firestore/cloud_firestore.dart';

/// Model dia chi nguoi dung, dong bo tu Firebase Firestore.
///
/// Cac truong cua Firestore:
/// - id           : ID document tu Firestore
/// - name         : Ten/nhan dia chi (VD: "Nha rieng", "Cong ty")
/// - address      : Dia chi chi tiet (VD: "123 Nguyen Hue, Quan 1, TP.HCM")
/// - receiverName : Ho ten nguoi nhan (bat buoc)
/// - receiverPhone: So dien thoai nguoi nhan (bat buoc)
/// - lat          : Vi do (co the null)
/// - lng          : Kinh do (co the null)
/// - isDefault    : La dia chi mac dinh hay khong
class AddressModel {
  final String id;
  final String label;
  final String addressText;
  final String receiverName;
  final String receiverPhone;
  final double? lat;
  final double? lng;
  final bool isDefault;

  AddressModel({
    required this.id,
    required this.label,
    required this.addressText,
    required this.receiverName,
    required this.receiverPhone,
    this.lat,
    this.lng,
    required this.isDefault,
  });

  /// Tao AddressModel tu DocumentSnapshot cua Firestore.
  /// Neu Firebase thieu truong receiverName/receiverPhone thi fallback chuoi rong.
  factory AddressModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AddressModel(
      id: doc.id,
      label: (data['name'] as String?) ?? '',
      addressText: (data['address'] as String?) ?? '',
      receiverName: (data['receiverName'] as String?) ?? '',
      receiverPhone: (data['receiverPhone'] as String?) ?? '',
      lat: (data['lat'] as num?)?.toDouble(),
      lng: (data['lng'] as num?)?.toDouble(),
      isDefault: (data['isDefault'] as bool?) ?? false,
    );
  }

  /// Chuyen AddressModel thanh Map de ghi xuong Firestore.
  Map<String, dynamic> toMap() {
    return {
      'name': label,
      'address': addressText,
      'receiverName': receiverName,
      'receiverPhone': receiverPhone,
      'lat': lat,
      'lng': lng,
      'isDefault': isDefault,
    };
  }

  AddressModel copyWith({
    String? id,
    String? label,
    String? addressText,
    String? receiverName,
    String? receiverPhone,
    double? lat,
    double? lng,
    bool? isDefault,
  }) {
    return AddressModel(
      id: id ?? this.id,
      label: label ?? this.label,
      addressText: addressText ?? this.addressText,
      receiverName: receiverName ?? this.receiverName,
      receiverPhone: receiverPhone ?? this.receiverPhone,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  /// Tao AddressModel (model moi) tu AddressModel cua profile.
  /// Dung de dam bao dong nhat khi AddressFormView tra ve model cu.
  factory AddressModel.fromOldModel(old) {
    return AddressModel(
      id: old.id as String,
      label: old.name as String,
      addressText: old.address as String,
      receiverName: '',
      receiverPhone: '',
      lat: (old.lat as num?)?.toDouble(),
      lng: (old.lng as num?)?.toDouble(),
      isDefault: old.isDefault as bool,
    );
  }
}

/// Class co so cho viec bom du lieu mau (seed data).
/// Su dung de tao du lieu mau khi phat trien hoac kiem thu.
class DataSeeder {
  DataSeeder._();

  /// Danh sach cac cua hang mau.
  static List<Map<String, dynamic>> getSampleStores() {
    return [
      {
        'id': 'store_001',
        'name': 'Bun Bo Hue Ba Hoa',
        'address': '123 Duong Ba Trieu, Quan 1, TP.HCM',
        'rating': 4.5,
        'reviewCount': 120,
        'imageUrl': 'https://example.com/store1.jpg',
        'isOpen': true,
        'deliveryTime': '15-25 phut',
        'deliveryFee': 15000,
        'minOrder': 50000,
      },
      {
        'id': 'store_002',
        'name': 'Com Tam Suon Bi Cha',
        'address': '456 Duong Nguyen Trai, Quan 5, TP.HCM',
        'rating': 4.2,
        'reviewCount': 85,
        'imageUrl': 'https://example.com/store2.jpg',
        'isOpen': true,
        'deliveryTime': '20-30 phut',
        'deliveryFee': 20000,
        'minOrder': 30000,
      },
    ];
  }

  /// Danh sach cac mon an mau.
  static List<Map<String, dynamic>> getSampleFoods() {
    return [
      {
        'id': 'food_001',
        'storeId': 'store_001',
        'name': 'Bun Bo Hue Lon',
        'description': 'Bun bo hue lon that, nau chin, hu nuong gio',
        'price': 45000,
        'imageUrl': 'https://example.com/food1.jpg',
        'category': 'Bun',
        'isAvailable': true,
      },
      {
        'id': 'food_002',
        'storeId': 'store_001',
        'name': 'Bun Bo Ga',
        'description': 'Bun bo ga nau chua ngot, thom muoi',
        'price': 40000,
        'imageUrl': 'https://example.com/food2.jpg',
        'category': 'Bun',
        'isAvailable': true,
      },
      {
        'id': 'food_003',
        'storeId': 'store_002',
        'name': 'Com Tam Suon Bi Cha',
        'description': 'Com tam suon nuong, bi cha hanh nem',
        'price': 35000,
        'imageUrl': 'https://example.com/food3.jpg',
        'category': 'Com',
        'isAvailable': true,
      },
    ];
  }

  /// Danh sach danh muc mau.
  static List<Map<String, dynamic>> getSampleCategories() {
    return [
      {'id': 'cat_001', 'name': 'Bun', 'icon': 'noodle', 'imageUrl': 'https://example.com/cat1.jpg'},
      {'id': 'cat_002', 'name': 'Com', 'icon': 'rice', 'imageUrl': 'https://example.com/cat2.jpg'},
      {'id': 'cat_003', 'name': 'My', 'icon': 'noodle', 'imageUrl': 'https://example.com/cat3.jpg'},
      {'id': 'cat_004', 'name': 'Banh', 'icon': 'cake', 'imageUrl': 'https://example.com/cat4.jpg'},
      {'id': 'cat_005', 'name': 'Tra Sua', 'icon': 'drink', 'imageUrl': 'https://example.com/cat5.jpg'},
      {'id': 'cat_006', 'name': 'An Vat', 'icon': 'snack', 'imageUrl': 'https://example.com/cat6.jpg'},
    ];
  }

  /// Tao dia chi nguoi dung mau.
  static Map<String, dynamic> getSampleAddress() {
    return {
      'id': 'addr_001',
      'name': 'Nha rieng',
      'address': '78 Duong Nguyen Hue, Quan 1, TP.HCM',
      'lat': 10.7769,
      'lng': 106.7009,
      'isDefault': true,
    };
  }
}

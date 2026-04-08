import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class DataSeeder {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Seed toan bo du lieu mau.
  /// Tra ve true neu tat ca deu thanh cong, false neu co loi.
  static Future<bool> seedAll() async {
    try {
      debugPrint('=== Bat dau seed du lieu ===');

      final result = await _seedAllInternal();

      if (result) {
        debugPrint('=== Seed du lieu hoan tat (thanh cong) ===');
      } else {
        debugPrint('=== Seed du lieu hoan tat (co loi chi tiet o tren) ===');
      }
      return result;
    } catch (e, stackTrace) {
      debugPrint('Loi ngoai le khi seed: $e');
      debugPrint('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Thuc hien seed noi bo, tra ve true neu thanh cong.
  static Future<bool> _seedAllInternal() async {
    bool allSuccess = true;

    allSuccess &= await _seedWithLog('system_categories', _buildCategories());
    allSuccess &= await _seedWithLog('stores', _buildStores());
    allSuccess &= await _seedWithLog('products', _buildProducts());
    allSuccess &= await _seedWithLog('banners', _buildBanners());
    allSuccess &= await _seedWithLog('vouchers', _buildVouchers());
    allSuccess &= await _seedWithLog('reviews', _buildReviews());
    allSuccess &= await _seedWithLog('orders', _buildOrders());
    allSuccess &= await _seedUsersCustom();

    return allSuccess;
  }

  /// Seed rieng voucher (goi duoc tu ben ngoai).
  static Future<bool> seedVouchers() async {
    return await _seedWithLog('vouchers', _buildVouchers());
  }

  /// Seed mot collection voi log chi tiet.
  static Future<bool> _seedWithLog(
    String collectionName,
    List<Map<String, dynamic>> documents,
  ) async {
    debugPrint('--- Dang seed collection: $collectionName ---');
    int successCount = 0;
    int failCount = 0;

    for (int i = 0; i < documents.length; i++) {
      final doc = documents[i];
      final docId = doc['id'] as String;

      try {
        await _firestore
            .collection(collectionName)
            .doc(docId)
            .set(doc, SetOptions(merge: true));
        successCount++;
        debugPrint('  [$i] OK - $docId');
      } catch (e) {
        failCount++;
        debugPrint('  [$i] LOI - $docId: $e');
      }
    }

    debugPrint(
      '--- $collectionName: $successCount thanh cong, $failCount that bai ---',
    );
    return failCount == 0;
  }

  // ============================================================
  // DANH SACH DU LIEU
  // ============================================================

  static List<Map<String, dynamic>> _buildCategories() => [
    {
      'id': 'cate_001',
      'name': 'Com',
      'icon': 'restaurant',
      'order': 1,
      'imageUrl': 'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=400&q=80',
      'createdAt': Timestamp.fromDate(DateTime.parse('2026-01-01T00:00:00Z')),
      'updatedAt': Timestamp.fromDate(DateTime.parse('2026-01-01T00:00:00Z')),
      'deletedAt': null,
    },
    {
      'id': 'cate_002',
      'name': 'Pho/Bun',
      'icon': 'soup_kitchen',
      'order': 2,
      'imageUrl': 'https://images.unsplash.com/photo-1583224964978-2257b960c3f3?w=400&q=80',
      'createdAt': Timestamp.fromDate(DateTime.parse('2026-01-01T00:00:00Z')),
      'updatedAt': Timestamp.fromDate(DateTime.parse('2026-01-01T00:00:00Z')),
      'deletedAt': null,
    },
    {
      'id': 'cate_003',
      'name': 'Tra sua',
      'icon': 'local_cafe',
      'order': 3,
      'imageUrl': 'https://images.unsplash.com/photo-1558857563-b371033873b8?w=400&q=80',
      'createdAt': Timestamp.fromDate(DateTime.parse('2026-01-01T00:00:00Z')),
      'updatedAt': Timestamp.fromDate(DateTime.parse('2026-01-01T00:00:00Z')),
      'deletedAt': null,
    },
    {
      'id': 'cate_004',
      'name': 'An vat',
      'icon': 'fastfood',
      'order': 4,
      'imageUrl': 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400&q=80',
      'createdAt': Timestamp.fromDate(DateTime.parse('2026-01-01T00:00:00Z')),
      'updatedAt': Timestamp.fromDate(DateTime.parse('2026-01-01T00:00:00Z')),
      'deletedAt': null,
    },
    {
      'id': 'cate_005',
      'name': 'Ga ran',
      'icon': 'kebab_dining',
      'order': 5,
      'imageUrl': 'https://images.unsplash.com/photo-1626645738196-c2a7c87a8f58?w=400&q=80',
      'createdAt': Timestamp.fromDate(DateTime.parse('2026-01-01T00:00:00Z')),
      'updatedAt': Timestamp.fromDate(DateTime.parse('2026-01-01T00:00:00Z')),
      'deletedAt': null,
    },
    {
      'id': 'cate_006',
      'name': 'Mon Han',
      'icon': 'ramen_dining',
      'order': 6,
      'imageUrl': 'https://images.unsplash.com/photo-1559314809-0d155014e29e?w=400&q=80',
      'createdAt': Timestamp.fromDate(DateTime.parse('2026-01-01T00:00:00Z')),
      'updatedAt': Timestamp.fromDate(DateTime.parse('2026-01-01T00:00:00Z')),
      'deletedAt': null,
    },
    {
      'id': 'cate_007',
      'name': 'Mon Nhat',
      'icon': 'dinner_dining',
      'order': 7,
      'imageUrl': 'https://images.unsplash.com/photo-1611143669185-af224c5e3252?w=400&q=80',
      'createdAt': Timestamp.fromDate(DateTime.parse('2026-01-01T00:00:00Z')),
      'updatedAt': Timestamp.fromDate(DateTime.parse('2026-01-01T00:00:00Z')),
      'deletedAt': null,
    },
    {
      'id': 'cate_008',
      'name': 'Banh mi',
      'icon': 'bakery_dining',
      'order': 8,
      'imageUrl': 'https://images.unsplash.com/photo-1605478371045-0d14b28f8f55?w=400&q=80',
      'createdAt': Timestamp.fromDate(DateTime.parse('2026-01-01T00:00:00Z')),
      'updatedAt': Timestamp.fromDate(DateTime.parse('2026-01-01T00:00:00Z')),
      'deletedAt': null,
    },
    {
      'id': 'cate_009',
      'name': 'Lau/Buffet',
      'icon': 'soup_kitchen',
      'order': 9,
      'imageUrl': 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=400&q=80',
      'createdAt': Timestamp.fromDate(DateTime.parse('2026-01-01T00:00:00Z')),
      'updatedAt': Timestamp.fromDate(DateTime.parse('2026-01-01T00:00:00Z')),
      'deletedAt': null,
    },
    {
      'id': 'cate_010',
      'name': 'Tra cay',
      'icon': 'local_drink',
      'order': 10,
      'imageUrl': 'https://images.unsplash.com/photo-1544787219-7f47ccb76574?w=400&q=80',
      'createdAt': Timestamp.fromDate(DateTime.parse('2026-01-01T00:00:00Z')),
      'updatedAt': Timestamp.fromDate(DateTime.parse('2026-01-01T00:00:00Z')),
      'deletedAt': null,
    },
  ];

  static List<Map<String, dynamic>> _buildStores() => [
    // Quán Cơm Tấm Phúc Lộc Thọ
    {
      'id': 'store_001',
      'name': 'Com tam Phuc Loc Tho',
      'address': '123 Le Van Viet, TP. Thu Duc',
      'rating': 4.8,
      'reviewCount': 500,
      'avtUrl': 'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=400&q=80',
      'backUrl': 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800&q=80',
      'isOpen': true,
      'deliveryTime': '20-30 phut',
      'deliveryFee': 15000.0,
      'categoryIds': ['cate_001', 'cate_004'],
      'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
      'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
      'restaurant_categories': {
        'rest_cate_001': {
          'name': 'Mon chinh',
          'order': 1,
          'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
          'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
        },
        'rest_cate_002': {
          'name': 'Mon phu',
          'order': 2,
          'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
          'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
        },
        'rest_cate_003': {
          'name': 'Nuoc uong',
          'order': 3,
          'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
          'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
        },
      },
    },

    // Quan Tra Sua Tocotoco
    {
      'id': 'store_002',
      'name': 'Tra sua Tocotoco',
      'address': '456 Nguyen Thai Son, Go Vap',
      'rating': 4.6,
      'reviewCount': 800,
      'avtUrl': 'https://images.unsplash.com/photo-1558857563-b371033873b8?w=400&q=80',
      'backUrl': 'https://images.unsplash.com/photo-1554744512-d6c603f27c54?w=800&q=80',
      'isOpen': true,
      'deliveryTime': '15-25 phut',
      'deliveryFee': 12000.0,
      'categoryIds': ['cate_003', 'cate_010'],
      'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
      'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
      'restaurant_categories': {
        'rest_cate_001': {
          'name': 'Tra sua',
          'order': 1,
          'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
          'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
        },
        'rest_cate_002': {
          'name': 'Tra cay',
          'order': 2,
          'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
          'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
        },
        'rest_cate_003': {
          'name': 'Topping',
          'order': 3,
          'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
          'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
        },
      },
    },

    // Quan Ga Ran KFC
    {
      'id': 'store_003',
      'name': 'Ga ran KFC Nguyen Cuu',
      'address': '789 Nguyen Cuu, Binh Thanh',
      'rating': 4.5,
      'reviewCount': 1200,
      'avtUrl': 'https://images.unsplash.com/photo-1626645738196-c2a7c87a8f58?w=400&q=80',
      'backUrl': 'https://images.unsplash.com/photo-1561758033-d89a9ad46330?w=800&q=80',
      'isOpen': true,
      'deliveryTime': '25-35 phut',
      'deliveryFee': 18000.0,
      'categoryIds': ['cate_005', 'cate_004'],
      'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
      'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
      'restaurant_categories': {
        'rest_cate_001': {
          'name': 'Ga chinh',
          'order': 1,
          'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
          'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
        },
        'rest_cate_002': {
          'name': 'Mon an kem',
          'order': 2,
          'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
          'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
        },
        'rest_cate_003': {
          'name': 'Nuoc uong',
          'order': 3,
          'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
          'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
        },
      },
    },

    // Quan Bun Bo Hue Ba Le
    {
      'id': 'store_004',
      'name': 'Bun bo Hue Ba Le',
      'address': '321 Vo Thi Sau, Quan 3',
      'rating': 4.7,
      'reviewCount': 650,
      'avtUrl': 'https://images.unsplash.com/photo-1583224964978-2257b960c3f3?w=400&q=80',
      'backUrl': 'https://images.unsplash.com/photo-1569058242567-93de6f36f8eb?w=800&q=80',
      'isOpen': true,
      'deliveryTime': '20-30 phut',
      'deliveryFee': 14000.0,
      'categoryIds': ['cate_002', 'cate_001'],
      'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
      'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
      'restaurant_categories': {
        'rest_cate_001': {
          'name': 'Bun bo',
          'order': 1,
          'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
          'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
        },
        'rest_cate_002': {
          'name': 'Hu tieu',
          'order': 2,
          'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
          'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
        },
        'rest_cate_003': {
          'name': 'Mon them',
          'order': 3,
          'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
          'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
        },
      },
    },
  ];

  static List<Map<String, dynamic>> _buildProducts() => [
    // === San pham cua store_001 - Com tam Phuc Loc Tho ===

    {
      'id': 'prod_001',
      'storeId': 'store_001',
      'categoryId': 'cate_001',
      'categoryName': 'Com',
      'name': 'Com tam suon bi cha',
      'description': 'Com tam ngon chuan vi Sai Gon voi suon nuong thom phuc',
      'basePrice': 45000.0,
      'imageUrl': 'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=400&q=80',
      'isOutOfStock': false,
      'isFeatured': true,
      'optionGroups': [
        {
          'name': 'Kich thuoc',
          'options': [
            {'name': 'Vua', 'price': 0.0},
            {'name': 'Lon', 'price': 10000.0},
          ],
        },
      ],
      'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
      'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
    },

    {
      'id': 'prod_002',
      'storeId': 'store_001',
      'categoryId': 'cate_001',
      'categoryName': 'Com',
      'name': 'Com tam ga xot',
      'description': 'Com tam voi ga ran giòn, chan phuot xot bong cai',
      'basePrice': 50000.0,
      'imageUrl': 'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=400&q=80',
      'isOutOfStock': false,
      'isFeatured': false,
      'optionGroups': [],
      'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
      'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
    },

    {
      'id': 'prod_003',
      'storeId': 'store_001',
      'categoryId': 'cate_001',
      'categoryName': 'Com',
      'name': 'Com tam ca ke',
      'description': 'Ca ke cham mam tom, com tam dot tet huu amph',
      'basePrice': 55000.0,
      'imageUrl': 'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=400&q=80',
      'isOutOfStock': false,
      'isFeatured': true,
      'optionGroups': [],
      'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
      'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
    },

    // === San pham cua store_002 - Tra sua Tocotoco ===

    {
      'id': 'prod_004',
      'storeId': 'store_002',
      'categoryId': 'cate_003',
      'categoryName': 'Tra sua',
      'name': 'Tra sua trach tang',
      'description': 'Tra sua thom ngon kem trach tang dai duong',
      'basePrice': 29000.0,
      'imageUrl': 'https://images.unsplash.com/photo-1558857563-b371033873b8?w=400&q=80',
      'isOutOfStock': false,
      'isFeatured': true,
      'optionGroups': [
        {
          'name': 'Kich thuoc',
          'options': [
            {'name': 'M', 'price': 0.0},
            {'name': 'L', 'price': 5000.0},
          ],
        },
        {
          'name': 'Luong duong',
          'options': [
            {'name': '0%', 'price': 0.0},
            {'name': '30%', 'price': 0.0},
            {'name': '50%', 'price': 0.0},
            {'name': '100%', 'price': 0.0},
          ],
        },
        {
          'name': 'Luong da',
          'options': [
            {'name': '0%', 'price': 0.0},
            {'name': '30%', 'price': 0.0},
            {'name': '50%', 'price': 0.0},
            {'name': '100%', 'price': 0.0},
          ],
        },
      ],
      'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
      'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
    },

    {
      'id': 'prod_005',
      'storeId': 'store_002',
      'categoryId': 'cate_003',
      'categoryName': 'Tra sua',
      'name': 'Tra sua matcha',
      'description': 'Tra sua matcha Nhat Ban chat luong cao',
      'basePrice': 35000.0,
      'imageUrl': 'https://images.unsplash.com/photo-1558857563-b371033873b8?w=400&q=80',
      'isOutOfStock': false,
      'isFeatured': false,
      'optionGroups': [
        {
          'name': 'Kich thuoc',
          'options': [
            {'name': 'M', 'price': 0.0},
            {'name': 'L', 'price': 5000.0},
          ],
        },
      ],
      'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
      'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
    },

    {
      'id': 'prod_006',
      'storeId': 'store_002',
      'categoryId': 'cate_010',
      'categoryName': 'Tra cay',
      'name': 'Nuoc ep cam',
      'description': 'Nuoc ep cam tuoi nguyen chat 100%',
      'basePrice': 25000.0,
      'imageUrl': 'https://images.unsplash.com/photo-1544787219-7f47ccb76574?w=400&q=80',
      'isOutOfStock': false,
      'isFeatured': false,
      'optionGroups': [],
      'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
      'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
    },

    {
      'id': 'prod_007',
      'storeId': 'store_002',
      'categoryId': 'cate_003',
      'categoryName': 'Tra sua',
      'name': 'Tra sua chocolate',
      'description': 'Tra sua chocolate Belgia thom ngot',
      'basePrice': 33000.0,
      'imageUrl': 'https://images.unsplash.com/photo-1558857563-b371033873b8?w=400&q=80',
      'isOutOfStock': true,
      'isFeatured': false,
      'optionGroups': [
        {
          'name': 'Kich thuoc',
          'options': [
            {'name': 'M', 'price': 0.0},
            {'name': 'L', 'price': 5000.0},
          ],
        },
      ],
      'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
      'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
    },

    // === San pham cua store_003 - Ga ran KFC ===

    {
      'id': 'prod_008',
      'storeId': 'store_003',
      'categoryId': 'cate_005',
      'categoryName': 'Ga ran',
      'name': 'Ga ran lon 1',
      'description': 'Ga ran lon giòn rum cay thom',
      'basePrice': 75000.0,
      'imageUrl': 'https://images.unsplash.com/photo-1626645738196-c2a7c87a8f58?w=400&q=80',
      'isOutOfStock': false,
      'isFeatured': true,
      'optionGroups': [],
      'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
      'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
    },

    {
      'id': 'prod_009',
      'storeId': 'store_003',
      'categoryId': 'cate_005',
      'categoryName': 'Ga ran',
      'name': 'Ga man hieu',
      'description': 'Ga man hieu oc bap giòn tanh',
      'basePrice': 55000.0,
      'imageUrl': 'https://images.unsplash.com/photo-1626645738196-c2a7c87a8f58?w=400&q=80',
      'isOutOfStock': false,
      'isFeatured': false,
      'optionGroups': [],
      'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
      'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
    },

    {
      'id': 'prod_010',
      'storeId': 'store_003',
      'categoryId': 'cate_004',
      'categoryName': 'An vat',
      'name': 'Khoai tay chien',
      'description': 'Khoai tay chien vai rum giòn',
      'basePrice': 25000.0,
      'imageUrl': 'https://images.unsplash.com/photo-1630384060421-cb20d0e0649d?w=400&q=80',
      'isOutOfStock': false,
      'isFeatured': false,
      'optionGroups': [
        {
          'name': 'Kich thuoc',
          'options': [
            {'name': 'Nho', 'price': 0.0},
            {'name': 'Lon', 'price': 10000.0},
          ],
        },
      ],
      'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
      'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
    },

    {
      'id': 'prod_011',
      'storeId': 'store_003',
      'categoryId': 'cate_005',
      'categoryName': 'Ga ran',
      'name': 'Combo KFC 1 nguoi',
      'description': 'Ga ran + khoai tay + nuoc ngot',
      'basePrice': 95000.0,
      'imageUrl': 'https://images.unsplash.com/photo-1626645738196-c2a7c87a8f58?w=400&q=80',
      'isOutOfStock': false,
      'isFeatured': true,
      'optionGroups': [],
      'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
      'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
    },

    // === San pham cua store_004 - Bun bo Hue Ba Le ===

    {
      'id': 'prod_012',
      'storeId': 'store_004',
      'categoryId': 'cate_002',
      'categoryName': 'Pho/Bun',
      'name': 'Bun bo Hue lon',
      'description': 'Bun bo Hue chinh goc, nuoc duong dam da, them bot',
      'basePrice': 50000.0,
      'imageUrl': 'https://images.unsplash.com/photo-1583224964978-2257b960c3f3?w=400&q=80',
      'isOutOfStock': false,
      'isFeatured': true,
      'optionGroups': [
        {
          'name': 'Muc do cay',
          'options': [
            {'name': 'Khong cay', 'price': 0.0},
            {'name': 'Cay vua', 'price': 0.0},
            {'name': 'Cay nhieu', 'price': 0.0},
          ],
        },
      ],
      'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
      'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
    },

    {
      'id': 'prod_013',
      'storeId': 'store_004',
      'categoryId': 'cate_002',
      'categoryName': 'Pho/Bun',
      'name': 'Bun bo Hue dao',
      'description': 'Bun bo Hue voi dao bo, ngon tuyet voi',
      'basePrice': 55000.0,
      'imageUrl': 'https://images.unsplash.com/photo-1583224964978-2257b960c3f3?w=400&q=80',
      'isOutOfStock': false,
      'isFeatured': false,
      'optionGroups': [],
      'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
      'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
    },

    {
      'id': 'prod_014',
      'storeId': 'store_004',
      'categoryId': 'cate_002',
      'categoryName': 'Pho/Bun',
      'name': 'Hu tieu sa te',
      'description': 'Hu tieu sa te Tom Truc Xanh, nuoc le dam ngot',
      'basePrice': 45000.0,
      'imageUrl': 'https://images.unsplash.com/photo-1569058242567-93de6f36f8eb?w=400&q=80',
      'isOutOfStock': true,
      'isFeatured': false,
      'optionGroups': [],
      'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
      'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
    },

    {
      'id': 'prod_015',
      'storeId': 'store_004',
      'categoryId': 'cate_001',
      'categoryName': 'Com',
      'name': 'Com rang dua bo',
      'description': 'Com rang dua bo duoc nau chinh tuoi, huu amph',
      'basePrice': 40000.0,
      'imageUrl': 'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=400&q=80',
      'isOutOfStock': false,
      'isFeatured': false,
      'optionGroups': [],
      'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
      'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
    },
  ];

  static List<Map<String, dynamic>> _buildBanners() => [
    {
      'id': 'banner_001',
      'title': 'Sieu sale giua thang',
      'imageUrl': 'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=800&q=80',
      'storeId': null,
      'storeName': null,
      'isActive': true,
      'order': 1,
      'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
      'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
    },
    {
      'id': 'banner_002',
      'title': 'Freeship 0 dong',
      'imageUrl': 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=800&q=80',
      'storeId': null,
      'storeName': null,
      'isActive': true,
      'order': 2,
      'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
      'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
    },
    {
      'id': 'banner_003',
      'title': 'Le hoi am thuc',
      'imageUrl': 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=800&q=80',
      'storeId': null,
      'storeName': null,
      'isActive': true,
      'order': 3,
      'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
      'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
    },
    {
      'id': 'banner_004',
      'title': 'Uong tra van chiu',
      'imageUrl': 'https://images.unsplash.com/photo-1558857563-b371033873b8?w=800&q=80',
      'storeId': null,
      'storeName': null,
      'isActive': true,
      'order': 4,
      'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
      'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
    },
  ];

  /// Ham seed User voi Sub-collections.
  /// Tao khoang 2-3 user, moi user co 7 Sub-collections: addresses, payment_methods,
  /// notifications, search_history, expenses, my_vouchers, cart.
  static Future<bool> _seedUsersCustom() async {
    debugPrint('--- Dang seed users voi Sub-collections ---');

    int userSuccessCount = 0;
    int userFailCount = 0;

    // Dinh nghia 2-3 user khac nhau
    final List<Map<String, dynamic>> users = [
      // User 1 - Khach hang tieu bieu
      {
        'id': 'user_001',
        'email': 'khachhang@gmail.com',
        'fullName': 'Khoi',
        'phoneNumber': '0123456789',
        'password': 'password123',
        'refreshToken': 'dummy_refresh_token_string_for_testing',
        'loyaltyPoints': 1500,
        'membershipTier': 1,  // 0: Dong, 1: Bac, 2: Vang, 3: Kim Cuong
        'photoUrl': 'https://example.com/avatar/user001.jpg',
        'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
        'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),

        // addresses
        'addresses': [
          {
            'id': 'addr_001',
            'name': 'Nha rieng',
            'address': 'Ky tuc xa UTC2, Quan 9, TP.HCM',
            'receiverName': 'Khoi',
            'receiverPhone': '0123456789',
            'lat': 10.8455,
            'lng': 106.7939,
            'isDefault': true,
            'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
            'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
            'deletedAt': null,
          },
          {
            'id': 'addr_002',
            'name': 'Truong hoc',
            'address': 'Truong Dai hoc Giao thong Van tai, Quan 9, TP.HCM',
            'receiverName': 'Khoi',
            'receiverPhone': '0123456789',
            'lat': 10.8512,
            'lng': 106.7890,
            'isDefault': false,
            'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
            'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
            'deletedAt': null,
          },
        ],

        // payment_methods
        'payment_methods': [
          {
            'id': 'pm_001',
            'type': 2,  // 1: Tien mat, 2: Vi dien tu, 3: The ngan hang
            'isDefault': true,
            'cardBrand': null,
            'last4Digits': null,
            'walletBrand': 'momo',
            'isLinked': true,
            'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
            'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
          },
          {
            'id': 'pm_002',
            'type': 3,  // 1: Tien mat, 2: Vi dien tu, 3: The ngan hang
            'isDefault': false,
            'cardBrand': 'Visa',
            'last4Digits': '1234',
            'walletBrand': null,
            'isLinked': true,
            'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
            'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
          },
        ],

        // notifications
        'notifications': [
          {
            'id': 'notif_001',
            'type': 2,  // 0: He thong, 1: Khuyen mai, 2: Don hang
            'referenceId': 'order_001',
            'isRead': false,
            'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
            'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
          },
          {
            'id': 'notif_002',
            'type': 1,  // 0: He thong, 1: Khuyen mai, 2: Don hang
            'referenceId': 'voucher_001',
            'isRead': true,
            'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-06T00:00:00Z')),
            'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-06T00:00:00Z')),
          },
          {
            'id': 'notif_003',
            'type': 0,  // 0: He thong, 1: Khuyen mai, 2: Don hang
            'referenceId': 'voucher_002',
            'isRead': false,
            'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-05T00:00:00Z')),
            'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-05T00:00:00Z')),
          },
        ],

        // search_history
        'search_history': [
          {
            'id': 'sh_001',
            'keyword': 'Com tam',
            'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
            'deletedAt': null,
          },
          {
            'id': 'sh_002',
            'keyword': 'Tra sua',
            'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-06T00:00:00Z')),
            'deletedAt': null,
          },
          {
            'id': 'sh_003',
            'keyword': 'Ga ran',
            'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-05T00:00:00Z')),
            'deletedAt': Timestamp.fromDate(DateTime.parse('2026-04-06T00:00:00Z')),
          },
        ],

        // expenses
        'expenses': [
          {
            'id': 'exp_001',
            'storeName': 'Com tam Phuc Loc Tho',
            'iconName': 'food',
            'categoryKey': 'food_drink',
            'date': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
            'amount': 55000.0,
            'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
            'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
          },
          {
            'id': 'exp_002',
            'storeName': 'Tra sua Tocotoco',
            'iconName': 'drink',
            'categoryKey': 'food_drink',
            'date': Timestamp.fromDate(DateTime.parse('2026-04-06T00:00:00Z')),
            'amount': 29000.0,
            'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-06T00:00:00Z')),
            'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-06T00:00:00Z')),
          },
          {
            'id': 'exp_003',
            'storeName': 'Ga ran KFC Nguyen Cuu',
            'iconName': 'food',
            'categoryKey': 'food_drink',
            'date': Timestamp.fromDate(DateTime.parse('2026-04-05T00:00:00Z')),
            'amount': 125000.0,
            'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-05T00:00:00Z')),
            'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-05T00:00:00Z')),
          },
        ],

        // my_vouchers
        'my_vouchers': [
          {
            'id': 'mv_001',
            'name': 'Giam 20K phi giao hang',
            'code': 'FREESHIP20',
            'description': 'Ap dung cho don tu 100K',
            'expiryDate': Timestamp.fromDate(DateTime.parse('2026-04-30T23:59:59Z')),
            'discountValue': 20000.0,
            'isPercentage': false,
            'minOrderValue': 100000.0,
            'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
            'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
          },
          {
            'id': 'mv_002',
            'name': 'Giam 10% cho don hang',
            'code': 'SAVE10',
            'description': 'Giam toi da 30K, ap dung cho tat ca quan an',
            'expiryDate': Timestamp.fromDate(DateTime.parse('2026-04-20T23:59:59Z')),
            'discountValue': 10.0,
            'isPercentage': true,
            'minOrderValue': 150000.0,
            'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-05T00:00:00Z')),
            'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-05T00:00:00Z')),
          },
        ],

        // cart
        'cart': [
          {
            'id': 'cart_item_001',
            'storeId': 'store_001',
            'foodId': 'prod_001',
            'name': 'Com tam suon bi cha',
            'price': 45000.0,
            'quantity': 2,
            'imageUrl': 'https://example.com/comtam.jpg',
            'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
            'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
          },
          {
            'id': 'cart_item_002',
            'storeId': 'store_002',
            'foodId': 'prod_004',
            'name': 'Tra sua trach tang',
            'price': 29000.0,
            'quantity': 1,
            'imageUrl': 'https://example.com/trasua.jpg',
            'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
            'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
          },
        ],
      },

      // User 2 - Khach hang nhieu hoat dong
      {
        'id': 'user_002',
        'email': 'nguyenvana@yahoo.com',
        'fullName': 'Nguyen Van A',
        'phoneNumber': '0987654321',
        'password': 'password123',
        'refreshToken': 'dummy_refresh_token_string_for_testing',
        'loyaltyPoints': 3200,
        'membershipTier': 2,  // 0: Dong, 1: Bac, 2: Vang, 3: Kim Cuong
        'photoUrl': 'https://example.com/avatar/user002.jpg',
        'createdAt': Timestamp.fromDate(DateTime.parse('2026-03-01T00:00:00Z')),
        'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),

        // addresses
        'addresses': [
          {
            'id': 'addr_003',
            'name': 'Nha rieng',
            'address': '123 Duong Nguyen Trai, Quan 1, TP.HCM',
            'receiverName': 'Nguyen Van A',
            'receiverPhone': '0987654321',
            'lat': 10.7781,
            'lng': 106.6935,
            'isDefault': true,
            'createdAt': Timestamp.fromDate(DateTime.parse('2026-03-01T00:00:00Z')),
            'updatedAt': Timestamp.fromDate(DateTime.parse('2026-03-01T00:00:00Z')),
            'deletedAt': null,
          },
          {
            'id': 'addr_004',
            'name': 'Cong ty',
            'address': 'Tao Dan Tower, Quan 1, TP.HCM',
            'receiverName': 'Nguyen Van A',
            'receiverPhone': '0987654321',
            'lat': 10.7795,
            'lng': 106.6991,
            'isDefault': false,
            'createdAt': Timestamp.fromDate(DateTime.parse('2026-03-10T00:00:00Z')),
            'updatedAt': Timestamp.fromDate(DateTime.parse('2026-03-10T00:00:00Z')),
            'deletedAt': null,
          },
          {
            'id': 'addr_005',
            'name': 'Nha ban',
            'address': '456 Bui Vien, Quan 1, TP.HCM',
            'receiverName': 'Nguyen Van A',
            'receiverPhone': '0987654321',
            'lat': 10.7675,
            'lng': 106.6890,
            'isDefault': false,
            'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-01T00:00:00Z')),
            'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-01T00:00:00Z')),
            'deletedAt': null,
          },
        ],

        // payment_methods
        'payment_methods': [
          {
            'id': 'pm_003',
            'type': 3,  // 1: Tien mat, 2: Vi dien tu, 3: The ngan hang
            'isDefault': true,
            'cardBrand': 'MasterCard',
            'last4Digits': '5678',
            'walletBrand': null,
            'isLinked': true,
            'createdAt': Timestamp.fromDate(DateTime.parse('2026-03-01T00:00:00Z')),
            'updatedAt': Timestamp.fromDate(DateTime.parse('2026-03-01T00:00:00Z')),
          },
          {
            'id': 'pm_004',
            'type': 2,  // 1: Tien mat, 2: Vi dien tu, 3: The ngan hang
            'isDefault': false,
            'cardBrand': null,
            'last4Digits': null,
            'walletBrand': 'zalo',
            'isLinked': true,
            'createdAt': Timestamp.fromDate(DateTime.parse('2026-03-15T00:00:00Z')),
            'updatedAt': Timestamp.fromDate(DateTime.parse('2026-03-15T00:00:00Z')),
          },
          {
            'id': 'pm_005',
            'type': 1,  // 1: Tien mat, 2: Vi dien tu, 3: The ngan hang
            'isDefault': false,
            'cardBrand': null,
            'last4Digits': null,
            'walletBrand': null,
            'isLinked': false,
            'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-01T00:00:00Z')),
            'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-01T00:00:00Z')),
          },
        ],

        // notifications
        'notifications': [
          {
            'id': 'notif_004',
            'type': 2,  // 0: He thong, 1: Khuyen mai, 2: Don hang
            'referenceId': 'order_002',
            'isRead': true,
            'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
            'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
          },
          {
            'id': 'notif_005',
            'type': 0,  // 0: He thong, 1: Khuyen mai, 2: Don hang
            'referenceId': 'user_002',
            'isRead': true,
            'createdAt': Timestamp.fromDate(DateTime.parse('2026-03-02T00:00:00Z')),
            'updatedAt': Timestamp.fromDate(DateTime.parse('2026-03-02T00:00:00Z')),
          },
          {
            'id': 'notif_006',
            'type': 0,  // 0: He thong, 1: Khuyen mai, 2: Don hang
            'referenceId': 'reward_001',
            'isRead': false,
            'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-06T00:00:00Z')),
            'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-06T00:00:00Z')),
          },
          {
            'id': 'notif_007',
            'type': 1,  // 0: He thong, 1: Khuyen mai, 2: Don hang
            'referenceId': 'voucher_003',
            'isRead': false,
            'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-05T00:00:00Z')),
            'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-05T00:00:00Z')),
          },
        ],

        // search_history
        'search_history': [
          {
            'id': 'sh_004',
            'keyword': 'Bun bo Hue',
            'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
            'deletedAt': null,
          },
          {
            'id': 'sh_005',
            'keyword': 'Banh mi',
            'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-06T00:00:00Z')),
            'deletedAt': null,
          },
          {
            'id': 'sh_006',
            'keyword': 'Lau',
            'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-05T00:00:00Z')),
            'deletedAt': null,
          },
          {
            'id': 'sh_007',
            'keyword': 'Mon Han Quoc',
            'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-04T00:00:00Z')),
            'deletedAt': null,
          },
        ],

        // expenses
        'expenses': [
          {
            'id': 'exp_004',
            'storeName': 'Bun bo Hue Ba Le',
            'iconName': 'food',
            'categoryKey': 'food_drink',
            'date': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
            'amount': 50000.0,
            'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
            'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
          },
          {
            'id': 'exp_005',
            'storeName': 'Ga ran KFC Nguyen Cuu',
            'iconName': 'food',
            'categoryKey': 'food_drink',
            'date': Timestamp.fromDate(DateTime.parse('2026-04-05T00:00:00Z')),
            'amount': 95000.0,
            'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-05T00:00:00Z')),
            'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-05T00:00:00Z')),
          },
          {
            'id': 'exp_006',
            'storeName': 'Com tam Phuc Loc Tho',
            'iconName': 'food',
            'categoryKey': 'food_drink',
            'date': Timestamp.fromDate(DateTime.parse('2026-04-03T00:00:00Z')),
            'amount': 45000.0,
            'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-03T00:00:00Z')),
            'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-03T00:00:00Z')),
          },
          {
            'id': 'exp_007',
            'storeName': 'Tra sua Tocotoco',
            'iconName': 'drink',
            'categoryKey': 'food_drink',
            'date': Timestamp.fromDate(DateTime.parse('2026-04-02T00:00:00Z')),
            'amount': 35000.0,
            'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-02T00:00:00Z')),
            'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-02T00:00:00Z')),
          },
        ],

        // my_vouchers
        'my_vouchers': [
          {
            'id': 'mv_003',
            'name': 'Giam 50K cho don tu 200K',
            'code': 'VIP50',
            'description': 'Danh cho khach hang than thiet',
            'expiryDate': Timestamp.fromDate(DateTime.parse('2026-05-31T23:59:59Z')),
            'discountValue': 50000.0,
            'isPercentage': false,
            'minOrderValue': 200000.0,
            'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-01T00:00:00Z')),
            'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-01T00:00:00Z')),
          },
          {
            'id': 'mv_004',
            'name': 'Freeship cho moi don',
            'code': 'FREESHIP50',
            'description': 'Mien phi van chuyen toi da 30K',
            'expiryDate': Timestamp.fromDate(DateTime.parse('2026-04-15T23:59:59Z')),
            'discountValue': 30000.0,
            'isPercentage': false,
            'minOrderValue': 50000.0,
            'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-05T00:00:00Z')),
            'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-05T00:00:00Z')),
          },
        ],

        // cart
        'cart': [
          {
            'id': 'cart_item_003',
            'storeId': 'store_004',
            'foodId': 'prod_012',
            'name': 'Bun bo Hue lon',
            'price': 50000.0,
            'quantity': 1,
            'imageUrl': 'https://example.com/bunbohue.jpg',
            'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
            'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
          },
          {
            'id': 'cart_item_004',
            'storeId': 'store_001',
            'foodId': 'prod_003',
            'name': 'Com tam ca ke',
            'price': 55000.0,
            'quantity': 1,
            'imageUrl': 'https://example.com/comtam_cake.jpg',
            'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-06T00:00:00Z')),
            'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-06T00:00:00Z')),
          },
          {
            'id': 'cart_item_005',
            'storeId': 'store_003',
            'foodId': 'prod_011',
            'name': 'Combo KFC 1 nguoi',
            'price': 95000.0,
            'quantity': 1,
            'imageUrl': 'https://example.com/kfc_combo.jpg',
            'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-05T00:00:00Z')),
            'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-05T00:00:00Z')),
          },
        ],
      },

      // User 3 - Khach hang moi tao
      {
        'id': 'user_003',
        'email': 'newuser@example.com',
        'fullName': 'Tran Thi B',
        'phoneNumber': '0369258147',
        'password': 'password123',
        'refreshToken': 'dummy_refresh_token_string_for_testing',
        'loyaltyPoints': 800,
        'membershipTier': 0,  // 0: Dong, 1: Bac, 2: Vang, 3: Kim Cuong
        'photoUrl': 'https://example.com/avatar/user003.jpg',
        'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-06T00:00:00Z')),
        'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),

        // addresses
        'addresses': [
          {
            'id': 'addr_006',
            'name': 'Nha rieng',
            'address': '78 Le Lai, Quan Tan Binh, TP.HCM',
            'receiverName': 'Tran Thi B',
            'receiverPhone': '0369258147',
            'lat': 10.7868,
            'lng': 106.6573,
            'isDefault': true,
            'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-06T00:00:00Z')),
            'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-06T00:00:00Z')),
            'deletedAt': null,
          },
        ],

        // payment_methods
        'payment_methods': [
          {
            'id': 'pm_006',
            'type': 2,  // 1: Tien mat, 2: Vi dien tu, 3: The ngan hang
            'isDefault': true,
            'cardBrand': null,
            'last4Digits': null,
            'walletBrand': 'vnpay',
            'isLinked': true,
            'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-06T00:00:00Z')),
            'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-06T00:00:00Z')),
          },
        ],

        // notifications
        'notifications': [
          {
            'id': 'notif_008',
            'type': 0,  // 0: He thong, 1: Khuyen mai, 2: Don hang
            'referenceId': 'user_003',
            'isRead': false,
            'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-06T00:00:00Z')),
            'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-06T00:00:00Z')),
          },
          {
            'id': 'notif_009',
            'type': 1,  // 0: He thong, 1: Khuyen mai, 2: Don hang
            'referenceId': 'voucher_005',
            'isRead': false,
            'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-06T00:00:00Z')),
            'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-06T00:00:00Z')),
          },
        ],

        // search_history
        'search_history': [
          {
            'id': 'sh_008',
            'keyword': 'Tra sua',
            'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
            'deletedAt': null,
          },
          {
            'id': 'sh_009',
            'keyword': 'Cafe',
            'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-06T00:00:00Z')),
            'deletedAt': null,
          },
        ],

        // expenses
        'expenses': [
          {
            'id': 'exp_008',
            'storeName': 'Tra sua Tocotoco',
            'iconName': 'drink',
            'categoryKey': 'food_drink',
            'date': Timestamp.fromDate(DateTime.parse('2026-04-06T00:00:00Z')),
            'amount': 35000.0,
            'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-06T00:00:00Z')),
            'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-06T00:00:00Z')),
          },
        ],

        // my_vouchers
        'my_vouchers': [
          {
            'id': 'mv_005',
            'name': 'Giam 20K phi giao hang',
            'code': 'WELCOME20',
            'description': 'Danh cho khach hang moi, ap dung cho don tu 100K',
            'expiryDate': Timestamp.fromDate(DateTime.parse('2026-04-30T23:59:59Z')),
            'discountValue': 20000.0,
            'isPercentage': false,
            'minOrderValue': 100000.0,
            'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-06T00:00:00Z')),
            'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-06T00:00:00Z')),
          },
        ],

        // cart
        'cart': [
          {
            'id': 'cart_item_006',
            'storeId': 'store_002',
            'foodId': 'prod_005',
            'name': 'Tra sua matcha',
            'price': 35000.0,
            'quantity': 2,
            'imageUrl': 'https://example.com/matcha.jpg',
            'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
            'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
          },
        ],
      },
    ];

    // Cac sub-collection fields can xu ly rieng
    const subCollectionKeys = [
      'addresses',
      'payment_methods',
      'notifications',
      'search_history',
      'expenses',
      'my_vouchers',
      'cart',
    ];

    for (int i = 0; i < users.length; i++) {
      final user = users[i];
      final userId = user['id'] as String;

      // Loc ra cac sub-collection data
      final Map<String, dynamic> subCollectionsData = {};
      for (final key in subCollectionKeys) {
        if (user.containsKey(key) && user[key] != null) {
          subCollectionsData[key] = user[key];
        }
      }

      // Tao ban sao user data chi chua thong tin goc (khong co sub-collection fields)
      final Map<String, dynamic> userBaseData = Map<String, dynamic>.from(user);
      for (final key in subCollectionKeys) {
        userBaseData.remove(key);
      }

      try {
        // Buoc 1: Ghi document goc cua User
        await _firestore
            .collection('users')
            .doc(userId)
            .set(userBaseData, SetOptions(merge: true));
        debugPrint('  [$i] OK - User goc: $userId');

        // Buoc 2: Duyet va ghi tung Sub-collection
        int subSuccessCount = 0;
        int subFailCount = 0;

        for (final entry in subCollectionsData.entries) {
          final subCollName = entry.key;
          final items = entry.value as List<dynamic>;

          for (int j = 0; j < items.length; j++) {
            final item = items[j] as Map<String, dynamic>;
            final itemId = item['id'] as String;

            try {
              await _firestore
                  .collection('users')
                  .doc(userId)
                  .collection(subCollName)
                  .doc(itemId)
                  .set(item, SetOptions(merge: true));
              subSuccessCount++;
            } catch (e) {
              subFailCount++;
              debugPrint('    [$i][$subCollName] LOI - $itemId: $e');
            }
          }
        }

        debugPrint(
          '  [$i] $userId: ${subSuccessCount} sub-doc OK, ${subFailCount} sub-doc LOI',
        );
        if (subFailCount == 0) {
          userSuccessCount++;
        } else {
          userFailCount++;
        }
      } catch (e) {
        userFailCount++;
        debugPrint('  [$i] LOI - $userId: $e');
      }
    }

    debugPrint(
      '--- users: $userSuccessCount user OK, $userFailCount user LOI ---',
    );
    return userFailCount == 0;
  }

  // ============================================================
  // DU LIEU REVIEWS
  // ============================================================

  static List<Map<String, dynamic>> _buildReviews() => [
    // Danh gia 1 - user_001 danh gia store_001
    {
      'id': 'rev_001',
      'storeId': 'store_001',
      'userId': 'user_001',
      'userName': 'Khoi',
      'userAvatarUrl': 'https://example.com/avatar/user001.jpg',
      'starRating': 5,
      'comment': 'Do an rat ngon, giao hang nhanh, dong goi ky luong.',
      'imageUrls': [
        'https://example.com/review/rev001_1.jpg',
        'https://example.com/review/rev001_2.jpg',
      ],
      'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
      'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
      'deletedAt': null,
    },

    // Danh gia 2 - user_002 danh gia store_002
    {
      'id': 'rev_002',
      'storeId': 'store_002',
      'userId': 'user_002',
      'userName': 'Nguyen Van A',
      'userAvatarUrl': 'https://example.com/avatar/user002.jpg',
      'starRating': 4,
      'comment': 'Tra sua thom, nhan manh, uong rat ngon. Se quay lai.',
      'imageUrls': [
        'https://example.com/review/rev002_1.jpg',
      ],
      'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-06T00:00:00Z')),
      'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-06T00:00:00Z')),
      'deletedAt': null,
    },

    // Danh gia 3 - user_001 danh gia store_003
    {
      'id': 'rev_003',
      'storeId': 'store_003',
      'userId': 'user_001',
      'userName': 'Khoi',
      'userAvatarUrl': 'https://example.com/avatar/user001.jpg',
      'starRating': 4,
      'comment': 'Ga ran gion, beo ngay, duoc hang dung gio.',
      'imageUrls': [],
      'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-05T00:00:00Z')),
      'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-05T00:00:00Z')),
      'deletedAt': null,
    },

    // Danh gia 4 - user_003 danh gia store_004
    {
      'id': 'rev_004',
      'storeId': 'store_004',
      'userId': 'user_003',
      'userName': 'Tran Thi B',
      'userAvatarUrl': 'https://example.com/avatar/user003.jpg',
      'starRating': 5,
      'comment': 'Bun bo ngon chuan vi Hue, nuoc dung thoi, that tuyet.',
      'imageUrls': [
        'https://example.com/review/rev004_1.jpg',
        'https://example.com/review/rev004_2.jpg',
        'https://example.com/review/rev004_3.jpg',
      ],
      'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-04T00:00:00Z')),
      'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-04T00:00:00Z')),
      'deletedAt': null,
    },

    // Danh gia 5 - user_002 danh gia store_001
    {
      'id': 'rev_005',
      'storeId': 'store_001',
      'userId': 'user_002',
      'userName': 'Nguyen Van A',
      'userAvatarUrl': 'https://example.com/avatar/user002.jpg',
      'starRating': 3,
      'comment': 'Do an binh thuong, thoi gian giao hang hon 1 tieng.',
      'imageUrls': [
        'https://example.com/review/rev005_1.jpg',
      ],
      'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-03T00:00:00Z')),
      'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-03T00:00:00Z')),
      'deletedAt': null,
    },

    // Danh gia 6 - user_003 danh gia store_002
    {
      'id': 'rev_006',
      'storeId': 'store_002',
      'userId': 'user_003',
      'userName': 'Tran Thi B',
      'userAvatarUrl': 'https://example.com/avatar/user003.jpg',
      'starRating': 4,
      'comment': 'Topping da, duong nam vua phai, uong rat thich.',
      'imageUrls': [],
      'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-02T00:00:00Z')),
      'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-02T00:00:00Z')),
      'deletedAt': null,
    },

    // Danh gia 7 - user_002 danh gia store_004
    {
      'id': 'rev_007',
      'storeId': 'store_004',
      'userId': 'user_002',
      'userName': 'Nguyen Van A',
      'userAvatarUrl': 'https://example.com/avatar/user002.jpg',
      'starRating': 5,
      'comment': 'Quan sach, than thien, bun bo ngon gia re.',
      'imageUrls': [
        'https://example.com/review/rev007_1.jpg',
      ],
      'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-01T00:00:00Z')),
      'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-01T00:00:00Z')),
      'deletedAt': null,
    },

    // Danh gia 8 - user_001 danh gia store_004
    {
      'id': 'rev_008',
      'storeId': 'store_004',
      'userId': 'user_001',
      'userName': 'Khoi',
      'userAvatarUrl': 'https://example.com/avatar/user001.jpg',
      'starRating': 4,
      'comment': 'Hu tieu ngon, nuoc sup ngot thanh, nha hang sach se.',
      'imageUrls': [
        'https://example.com/review/rev008_1.jpg',
        'https://example.com/review/rev008_2.jpg',
      ],
      'createdAt': Timestamp.fromDate(DateTime.parse('2026-03-31T00:00:00Z')),
      'updatedAt': Timestamp.fromDate(DateTime.parse('2026-03-31T00:00:00Z')),
      'deletedAt': null,
    },
  ];

  // ============================================================
  // DU LIEU ORDERS
  // ============================================================

  static List<Map<String, dynamic>> _buildOrders() => [
    // Don hang 1 - da hoan tat, user_001
    {
      'id': 'order_001',
      'userId': 'user_001',
      'storeId': 'store_001',
      'storeName': 'Com tam Phuc Loc Tho',
      'items': [
        {
          'foodId': 'prod_001',
          'name': 'Com tam suon bi cha',
          'price': 45000.0,
          'quantity': 2,
          'imageUrl': 'https://example.com/comtam.jpg',
        },
        {
          'foodId': 'prod_002',
          'name': 'Com tam ga xot',
          'price': 50000.0,
          'quantity': 1,
          'imageUrl': 'https://example.com/comtam_ga.jpg',
        },
      ],
      'totalAmount': 140000.0,
      'deliveryFee': 15000.0,
      'status': 3,  // 0: Cho xac nhan, 1: Dang chuan bi, 2: Dang giao, 3: Hoan thanh, 4: Da huy
      'deliveryAddress': 'Ky tuc xa UTC2, Quan 9, TP.HCM',
      'paymentMethod': 'momo',
      'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
      'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
      'deletedAt': null,
    },

    // Don hang 2 - dang giao, user_002
    {
      'id': 'order_002',
      'userId': 'user_002',
      'storeId': 'store_002',
      'storeName': 'Tra sua Tocotoco',
      'items': [
        {
          'foodId': 'prod_004',
          'name': 'Tra sua trach tang',
          'price': 29000.0,
          'quantity': 2,
          'imageUrl': 'https://example.com/trasua.jpg',
        },
        {
          'foodId': 'prod_005',
          'name': 'Tra sua khoai mon',
          'price': 33000.0,
          'quantity': 1,
          'imageUrl': 'https://example.com/trasua_khoai.jpg',
        },
      ],
      'totalAmount': 91000.0,
      'deliveryFee': 12000.0,
      'status': 2,  // 0: Cho xac nhan, 1: Dang chuan bi, 2: Dang giao, 3: Hoan thanh, 4: Da huy
      'deliveryAddress': '123 Duong Nguyen Trai, Quan 1, TP.HCM',
      'paymentMethod': 'card',
      'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
      'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
      'deletedAt': null,
    },

    // Don hang 3 - cho xac nhan, user_003
    {
      'id': 'order_003',
      'userId': 'user_003',
      'storeId': 'store_004',
      'storeName': 'Bun bo Hue Ba Le',
      'items': [
        {
          'foodId': 'prod_012',
          'name': 'Bun bo Hue lon',
          'price': 50000.0,
          'quantity': 1,
          'imageUrl': 'https://example.com/bunbohue.jpg',
        },
        {
          'foodId': 'prod_014',
          'name': 'Bun bo Hue nho',
          'price': 40000.0,
          'quantity': 1,
          'imageUrl': 'https://example.com/bunbohue_nho.jpg',
        },
      ],
      'totalAmount': 90000.0,
      'deliveryFee': 14000.0,
      'status': 0,  // 0: Cho xac nhan, 1: Dang chuan bi, 2: Dang giao, 3: Hoan thanh, 4: Da huy
      'deliveryAddress': '78 Le Lai, Quan Tan Binh, TP.HCM',
      'paymentMethod': 'cash',
      'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
      'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
      'deletedAt': null,
    },

    // Don hang 4 - da huy, user_001
    {
      'id': 'order_004',
      'userId': 'user_001',
      'storeId': 'store_003',
      'storeName': 'Ga ran KFC Nguyen Cuu',
      'items': [
        {
          'foodId': 'prod_011',
          'name': 'Combo KFC 1 nguoi',
          'price': 95000.0,
          'quantity': 1,
          'imageUrl': 'https://example.com/kfc_combo.jpg',
        },
      ],
      'totalAmount': 95000.0,
      'deliveryFee': 18000.0,
      'status': 4,  // 0: Cho xac nhan, 1: Dang chuan bi, 2: Dang giao, 3: Hoan thanh, 4: Da huy
      'deliveryAddress': 'Ky tuc xa UTC2, Quan 9, TP.HCM',
      'paymentMethod': 'zalo',
      'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-06T00:00:00Z')),
      'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-06T00:00:00Z')),
      'deletedAt': null,
    },

    // Don hang 5 - da hoan tat, user_002
    {
      'id': 'order_005',
      'userId': 'user_002',
      'storeId': 'store_003',
      'storeName': 'Ga ran KFC Nguyen Cuu',
      'items': [
        {
          'foodId': 'prod_009',
          'name': 'Ga lap xoi truyen thong',
          'price': 70000.0,
          'quantity': 2,
          'imageUrl': 'https://example.com/kfc_galap.jpg',
        },
        {
          'foodId': 'prod_010',
          'name': 'My ga pho mai',
          'price': 55000.0,
          'quantity': 1,
          'imageUrl': 'https://example.com/kfc_myga.jpg',
        },
      ],
      'totalAmount': 195000.0,
      'deliveryFee': 18000.0,
      'status': 3,  // 0: Cho xac nhan, 1: Dang chuan bi, 2: Dang giao, 3: Hoan thanh, 4: Da huy
      'deliveryAddress': '123 Duong Nguyen Trai, Quan 1, TP.HCM',
      'paymentMethod': 'card',
      'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-05T00:00:00Z')),
      'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-05T00:00:00Z')),
      'deletedAt': null,
    },

    // Don hang 6 - da hoan tat, user_003
    {
      'id': 'order_006',
      'userId': 'user_003',
      'storeId': 'store_001',
      'storeName': 'Com tam Phuc Loc Tho',
      'items': [
        {
          'foodId': 'prod_003',
          'name': 'Com tam ca ke',
          'price': 55000.0,
          'quantity': 1,
          'imageUrl': 'https://example.com/comtam_cake.jpg',
        },
      ],
      'totalAmount': 55000.0,
      'deliveryFee': 15000.0,
      'status': 3,  // 0: Cho xac nhan, 1: Dang chuan bi, 2: Dang giao, 3: Hoan thanh, 4: Da huy
      'deliveryAddress': '78 Le Lai, Quan Tan Binh, TP.HCM',
      'paymentMethod': 'cash',
      'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-04T00:00:00Z')),
      'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-04T00:00:00Z')),
      'deletedAt': null,
    },

    // Don hang 7 - cho xac nhan, user_001
    {
      'id': 'order_007',
      'userId': 'user_001',
      'storeId': 'store_002',
      'storeName': 'Tra sua Tocotoco',
      'items': [
        {
          'foodId': 'prod_006',
          'name': 'Tra sua trai cay',
          'price': 35000.0,
          'quantity': 2,
          'imageUrl': 'https://example.com/trasua_traitay.jpg',
        },
        {
          'foodId': 'prod_007',
          'name': 'Tra sua matcha',
          'price': 32000.0,
          'quantity': 1,
          'imageUrl': 'https://example.com/trasua_matcha.jpg',
        },
      ],
      'totalAmount': 102000.0,
      'deliveryFee': 12000.0,
      'status': 0,  // 0: Cho xac nhan, 1: Dang chuan bi, 2: Dang giao, 3: Hoan thanh, 4: Da huy
      'deliveryAddress': 'Ky tuc xa UTC2, Quan 9, TP.HCM',
      'paymentMethod': 'momo',
      'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-08T00:00:00Z')),
      'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-08T00:00:00Z')),
      'deletedAt': null,
    },
  ];

  static List<Map<String, dynamic>> _buildVouchers() => [
    {
      'id': 'sys_voucher_001',
      'title': 'Giam 20K cho don tu 100K',
      'subtitle': 'Danh cho khach hang moi',
      'pointsRequired': 200,
      'imageUrl': 'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=400&q=80',
      'remaining': 100,
      'terms': 'Ap dung cho tat ca quan an.',
      'minOrderValue': 100000.0,
      'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
      'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
    },
    {
      'id': 'sys_voucher_002',
      'title': 'Giam 50K cho don tu 200K',
      'subtitle': 'Danh cho khach hang than thiet',
      'pointsRequired': 500,
      'imageUrl': 'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=400&q=80',
      'remaining': 50,
      'terms': 'Ap dung cho tat ca quan an.',
      'minOrderValue': 200000.0,
      'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
      'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
    },
    {
      'id': 'sys_voucher_003',
      'title': 'Freeship cho moi don',
      'subtitle': 'Mien phi van chuyen khong gioi han',
      'pointsRequired': 300,
      'imageUrl': 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400&q=80',
      'remaining': 200,
      'terms': 'Ap dung cho tat ca quan an, toi da 30K.',
      'minOrderValue': 50000.0,
      'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
      'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
    },
    {
      'id': 'sys_voucher_004',
      'title': 'Giam 10% cho don tu 150K',
      'subtitle': 'Khuyen mai nhan ngu',
      'pointsRequired': 400,
      'imageUrl': 'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=400&q=80',
      'remaining': 75,
      'terms': 'Giam toi da 30K, ap dung cho tat ca quan an.',
      'minOrderValue': 150000.0,
      'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
      'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
    },
    {
      'id': 'sys_voucher_005',
      'title': 'Giam 100K cho don tu 500K',
      'subtitle': 'Uu dai cho don hang lon',
      'pointsRequired': 1000,
      'imageUrl': 'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=400&q=80',
      'remaining': 20,
      'terms': 'Ap dung cho tat ca quan an.',
      'minOrderValue': 500000.0,
      'createdAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
      'updatedAt': Timestamp.fromDate(DateTime.parse('2026-04-07T00:00:00Z')),
    },
  ];

  // ============================================================
  // CAC HÀM DEBUGGING
  // ============================================================

  /// Kiem tra ket noi Firestore bang cach doc 1 document.
  /// Neu doc duoc thi write cung phai duoc.
  static Future<bool> verifyFirestoreConnection() async {
    debugPrint('=== Kiem tra ket noi Firestore ===');
    try {
      await _firestore
          .collection('_connection_test')
          .doc('test')
          .get(GetOptions(source: Source.server));
      debugPrint('Ket noi Firestore: OK (document ton tai hoac null)');
      return true;
    } on FirebaseException catch (e) {
      debugPrint('FirebaseException: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Loi ket noi Firestore: $e');
      return false;
    }
  }

  /// Test write don gian de xac nhan Firestore co ghi duoc khong.
  static Future<bool> testSimpleWrite() async {
    debugPrint('=== Test write don gian ===');
    try {
      await _firestore.collection('_test').doc('_test_doc').set({
        'test': true,
        'timestamp': DateTime.now().toIso8601String(),
      });
      debugPrint('Test write: THANH CONG');
      return true;
    } on FirebaseException catch (e) {
      debugPrint('Test write that bai - FirebaseException: ${e.code}');
      debugPrint('  Message: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Test write that bai - Exception: $e');
      return false;
    }
  }

  /// Doc 1 document de xac nhan no co ton tai hay khong.
  static Future<void> checkDocument(String collection, String docId) async {
    try {
      final snap = await _firestore
          .collection(collection)
          .doc(docId)
          .get(GetOptions(source: Source.server));
      if (snap.exists) {
        debugPrint('Document ton tai: $collection/$docId');
      } else {
        debugPrint('Document khong ton tai: $collection/$docId');
      }
    } catch (e) {
      debugPrint('Loi khi doc $collection/$docId: $e');
    }
  }

  /// Xoa toan bo du lieu seed (de reset), bao gom ca sub-collections cua users.
  static Future<void> clearAllSeededData() async {
    debugPrint('=== Xoa toan bo du lieu seed ===');

    final collections = [
      'system_categories',
      'stores',
      'products',
      'banners',
      'vouchers',
    ];

    // Xoa cac collection thong thuong
    for (final coll in collections) {
      try {
        final snap = await _firestore.collection(coll).get();
        int count = 0;
        for (final doc in snap.docs) {
          await doc.reference.delete();
          count++;
        }
        debugPrint('Da xoa $count documents tu $coll');
      } catch (e) {
        debugPrint('Loi khi xoa $coll: $e');
      }
    }

    // Xoa users va sub-collections cua users
    try {
      final userSnap = await _firestore.collection('users').get();
      int userCount = 0;

      for (final userDoc in userSnap.docs) {
        // Xoa tat ca sub-collections cua user nay
        final subCollNames = [
          'addresses',
          'payment_methods',
          'notifications',
          'search_history',
          'expenses',
          'my_vouchers',
          'cart',
        ];

        for (final subCollName in subCollNames) {
          try {
            final subSnap = await userDoc.reference.collection(subCollName).get();
            for (final subDoc in subSnap.docs) {
              await subDoc.reference.delete();
            }
          } catch (_) {
            // Neu sub-collection khong ton tai thi bo qua
          }
        }

        // Xoa document goc cua user
        await userDoc.reference.delete();
        userCount++;
      }

      debugPrint('Da xoa $userCount users (va sub-collections) tu users');
    } catch (e) {
      debugPrint('Loi khi xoa users: $e');
    }
  }
}

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
    allSuccess &= await _seedWithLog('users', _buildUsers());
    allSuccess &= await _seedWithLog('vouchers', _buildVouchers());

    return allSuccess;
  }

  /// Seed mot collection voi log chi tiet.
  static Future<bool> _seedWithLog(
      String collectionName, List<Map<String, dynamic>> documents) async {
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

    debugPrint('--- $collectionName: $successCount thanh cong, $failCount that bai ---');
    return failCount == 0;
  }

  // ============================================================
  // DANH SACH DU LIEU
  // ============================================================

  static List<Map<String, dynamic>> _buildCategories() => [
        {
          'id': 'cate_001',
          'name': 'Đồ ăn nhanh',
          'icon': 'fastfood',
          'order': 1,
          'imageUrl':
              'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400&q=80',
          'createdAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'updatedAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'deletedAt': null,
        },
        {
          'id': 'cate_002',
          'name': 'Đồ uống',
          'icon': 'local_cafe',
          'order': 2,
          'imageUrl':
              'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=400&q=80',
          'createdAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'updatedAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'deletedAt': null,
        },
        {
          'id': 'cate_003',
          'name': 'Bánh mì',
          'icon': 'bakery_dining',
          'order': 3,
          'imageUrl':
              'https://images.unsplash.com/photo-1509722747041-616f39b57569?w=400&q=80',
          'createdAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'updatedAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'deletedAt': null,
        },
        {
          'id': 'cate_004',
          'name': 'Cơm tấm',
          'icon': 'restaurant',
          'order': 4,
          'imageUrl':
              'https://images.unsplash.com/photo-1569050467447-ce54b3bbc37d?w=400&q=80',
          'createdAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'updatedAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'deletedAt': null,
        },
        {
          'id': 'cate_005',
          'name': 'Lẩu & Buffet',
          'icon': 'soup_kitchen',
          'order': 5,
          'imageUrl':
              'https://images.unsplash.com/photo-1552566626-52f8b828add9?w=400&q=80',
          'createdAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'updatedAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'deletedAt': null,
        },
        {
          'id': 'cate_006',
          'name': 'Ăn vặt',
          'icon': 'cookie',
          'order': 6,
          'imageUrl':
              'https://images.unsplash.com/photo-1541592106381-b31e9677c0e5?w=400&q=80',
          'createdAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'updatedAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'deletedAt': null,
        },
        {
          'id': 'cate_007',
          'name': 'Trà sữa',
          'icon': 'local_drink',
          'order': 7,
          'imageUrl':
              'https://images.unsplash.com/photo-1558857563-b371033873b8?w=400&q=80',
          'createdAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'updatedAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'deletedAt': null,
        },
        {
          'id': 'cate_008',
          'name': 'Pizza',
          'icon': 'local_pizza',
          'order': 8,
          'imageUrl':
              'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400&q=80',
          'createdAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'updatedAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'deletedAt': null,
        },
      ];

  static List<Map<String, dynamic>> _buildStores() => [
        {
          'id': 'store_001',
          'merchantId': 'merchant_001',
          'name': 'FoodGo Burger',
          'description': 'Burger thit bo nuong that ngon, tuyet voi.',
          'address': '123 Nguyen Hue, Quan 1, TP.HCM',
          'location': {'latitude': 10.7765, 'longitude': 106.7009},
          'imageUrl':
              'https://images.unsplash.com/photo-1550547660-d9450f859349?w=800&q=80',
          'isOpen': true,
          'rating': 4.7,
          'reviewCount': 120,
          'deliveryTime': '15 - 25 phut',
          'deliveryFee': 15000.0,
          'minOrder': 50000.0,
          'categoryIds': ['cate_001'],
          'createdAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'updatedAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'deletedAt': null,
        },
        {
          'id': 'store_002',
          'merchantId': 'merchant_002',
          'name': 'FoodGo Pizza',
          'description': 'Pizza that phong, pho mai nguyen chat tu My.',
          'address': '45 Le Duan, Quan 3, TP.HCM',
          'location': {'latitude': 10.7795, 'longitude': 106.6950},
          'imageUrl':
              'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=800&q=80',
          'isOpen': true,
          'rating': 4.5,
          'reviewCount': 85,
          'deliveryTime': '20 - 30 phut',
          'deliveryFee': 20000.0,
          'minOrder': 100000.0,
          'categoryIds': ['cate_008'],
          'createdAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'updatedAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'deletedAt': null,
        },
        {
          'id': 'store_003',
          'merchantId': 'merchant_003',
          'name': 'FoodGo Trà Sữa',
          'description': 'Tra sua thom ngon, hanh trang tu Thai Lan.',
          'address': '78 Pasteur, Quan 1, TP.HCM',
          'location': {'latitude': 10.7815, 'longitude': 106.6980},
          'imageUrl':
              'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=800&q=80',
          'isOpen': true,
          'rating': 4.8,
          'reviewCount': 200,
          'deliveryTime': '10 - 20 phut',
          'deliveryFee': 10000.0,
          'minOrder': 30000.0,
          'categoryIds': ['cate_002', 'cate_007'],
          'createdAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'updatedAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'deletedAt': null,
        },
        {
          'id': 'store_004',
          'merchantId': 'merchant_004',
          'name': 'FoodGo Bánh Mì',
          'description': 'Banh mi nhan that ngon, chat luong hang dau.',
          'address': '90 Dong Khoi, Quan 1, TP.HCM',
          'location': {'latitude': 10.7775, 'longitude': 106.7015},
          'imageUrl':
              'https://images.unsplash.com/photo-1509722747041-616f39b57569?w=800&q=80',
          'isOpen': false,
          'rating': 4.6,
          'reviewCount': 150,
          'deliveryTime': '15 - 25 phut',
          'deliveryFee': 12000.0,
          'minOrder': 25000.0,
          'categoryIds': ['cate_003'],
          'createdAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'updatedAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'deletedAt': null,
        },
        {
          'id': 'store_005',
          'merchantId': 'merchant_005',
          'name': 'FoodGo Cơm Tấm',
          'description': 'Com tam Saigon truyen thong, ngon tuyet pham.',
          'address': '210 Vo Van Kiet, Quan 5, TP.HCM',
          'location': {'latitude': 10.7510, 'longitude': 106.6850},
          'imageUrl':
              'https://images.unsplash.com/photo-1569050467447-ce54b3bbc37d?w=800&q=80',
          'isOpen': true,
          'rating': 4.4,
          'reviewCount': 65,
          'deliveryTime': '20 - 30 phut',
          'deliveryFee': 18000.0,
          'minOrder': 40000.0,
          'categoryIds': ['cate_004'],
          'createdAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'updatedAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'deletedAt': null,
        },
        {
          'id': 'store_006',
          'merchantId': 'merchant_006',
          'name': 'FoodGo Lẩu',
          'description': 'Lau Thai chua cay, hau sac Thai Lan chinh hang.',
          'address': '55 Truong Chinh, Quan 12, TP.HCM',
          'location': {'latitude': 10.8020, 'longitude': 106.6750},
          'imageUrl':
              'https://images.unsplash.com/photo-1552566626-52f8b828add9?w=800&q=80',
          'isOpen': true,
          'rating': 4.9,
          'reviewCount': 95,
          'deliveryTime': '25 - 35 phut',
          'deliveryFee': 25000.0,
          'minOrder': 200000.0,
          'categoryIds': ['cate_005'],
          'createdAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'updatedAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'deletedAt': null,
        },
        {
          'id': 'store_007',
          'merchantId': 'merchant_007',
          'name': 'FoodGo Ăn Vặt',
          'description': 'Ga ran, muc chien, snack các loai hap dan.',
          'address': '88 Pham Viet Chanh, Quan 1, TP.HCM',
          'location': {'latitude': 10.7750, 'longitude': 106.7020},
          'imageUrl':
              'https://images.unsplash.com/photo-1541592106381-b31e9677c0e5?w=800&q=80',
          'isOpen': true,
          'rating': 4.3,
          'reviewCount': 78,
          'deliveryTime': '15 - 25 phut',
          'deliveryFee': 10000.0,
          'minOrder': 30000.0,
          'categoryIds': ['cate_006'],
          'createdAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'updatedAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'deletedAt': null,
        },
        {
          'id': 'store_008',
          'merchantId': 'merchant_008',
          'name': 'FoodGo Fast Food',
          'description': 'Fast food My, pho mai que, hotdog ngon gia re.',
          'address': '150 Nam Ky Khoi Nghia, Quan 3, TP.HCM',
          'location': {'latitude': 10.7800, 'longitude': 106.6900},
          'imageUrl':
              'https://images.unsplash.com/photo-1561758033-d89a9ad46330?w=800&q=80',
          'isOpen': true,
          'rating': 4.2,
          'reviewCount': 42,
          'deliveryTime': '15 - 20 phut',
          'deliveryFee': 12000.0,
          'minOrder': 35000.0,
          'categoryIds': ['cate_001', 'cate_006'],
          'createdAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'updatedAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'deletedAt': null,
        },
      ];

  static List<Map<String, dynamic>> _buildProducts() => [
        // FoodGo Burger - store_001
        {
          'id': 'prod_001',
          'storeId': 'store_001',
          'categoryId': 'cate_001',
          'categoryName': 'Đồ ăn nhanh',
          'name': 'Burger Bò',
          'description': 'Burger bo nuong that ngon, pho mai tan chay.',
          'basePrice': 55000.0,
          'imageUrl':
              'https://images.unsplash.com/photo-1553979459-d2229ba7433b?w=400&q=80',
          'isOutOfStock': false,
          'isFeatured': true,
          'optionGroups': [
            {
              'id': 'optg_001',
              'name': 'Chọn Size',
              'isRequired': true,
              'maxChoices': 1,
              'options': [
                {'id': 'opto_001', 'name': 'Size S', 'additionalPrice': 0, 'isOutOfStock': false},
                {'id': 'opto_002', 'name': 'Size M', 'additionalPrice': 10000, 'isOutOfStock': false},
                {'id': 'opto_003', 'name': 'Size L', 'additionalPrice': 20000, 'isOutOfStock': false},
              ],
            },
            {
              'id': 'optg_002',
              'name': 'Thêm Topping',
              'isRequired': false,
              'maxChoices': 5,
              'options': [
                {'id': 'opto_004', 'name': 'Them pho mai', 'additionalPrice': 5000, 'isOutOfStock': false},
                {'id': 'opto_005', 'name': 'Them nam', 'additionalPrice': 5000, 'isOutOfStock': false},
                {'id': 'opto_006', 'name': 'Them trung', 'additionalPrice': 7000, 'isOutOfStock': false},
              ],
            },
          ],
          'createdAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'updatedAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'deletedAt': null,
        },
        {
          'id': 'prod_002',
          'storeId': 'store_001',
          'categoryId': 'cate_001',
          'categoryName': 'Đồ ăn nhanh',
          'name': 'Burger Gà',
          'description': 'Burger ga chien gion tan, sot nuoc cham dac biet.',
          'basePrice': 50000.0,
          'imageUrl':
              'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400&q=80',
          'isOutOfStock': false,
          'optionGroups': [
            {
              'id': 'optg_003',
              'name': 'Chọn Size',
              'isRequired': true,
              'maxChoices': 1,
              'options': [
                {'id': 'opto_007', 'name': 'Size S', 'additionalPrice': 0, 'isOutOfStock': false},
                {'id': 'opto_008', 'name': 'Size M', 'additionalPrice': 10000, 'isOutOfStock': false},
                {'id': 'opto_009', 'name': 'Size L', 'additionalPrice': 20000, 'isOutOfStock': false},
              ],
            },
          ],
          'createdAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'updatedAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'deletedAt': null,
        },
        {
          'id': 'prod_003',
          'storeId': 'store_001',
          'categoryId': 'cate_001',
          'categoryName': 'Đồ ăn nhanh',
          'name': 'Khoai tây chiên',
          'description': 'Khoai tay chien gion rum, vi man vua phai.',
          'basePrice': 25000.0,
          'imageUrl':
              'https://images.unsplash.com/photo-1630384060421-cb20d0e0649d?w=400&q=80',
          'isOutOfStock': false,
          'optionGroups': [],
          'createdAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'updatedAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'deletedAt': null,
        },
        // FoodGo Pizza - store_002
        {
          'id': 'prod_004',
          'storeId': 'store_002',
          'categoryId': 'cate_008',
          'categoryName': 'Pizza',
          'name': 'Pizza Phô Mai',
          'description': 'Pizza pho mai 4 loai nhap khau tu My.',
          'basePrice': 120000.0,
          'imageUrl':
              'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400&q=80',
          'isOutOfStock': false,
          'isFeatured': true,
          'optionGroups': [
            {
              'id': 'optg_004',
              'name': 'Chọn Size',
              'isRequired': true,
              'maxChoices': 1,
              'options': [
                {'id': 'opto_010', 'name': 'Size S (20cm)', 'additionalPrice': 0, 'isOutOfStock': false},
                {'id': 'opto_011', 'name': 'Size M (25cm)', 'additionalPrice': 30000, 'isOutOfStock': false},
                {'id': 'opto_012', 'name': 'Size L (30cm)', 'additionalPrice': 60000, 'isOutOfStock': false},
              ],
            },
            {
              'id': 'optg_005',
              'name': 'Đế bánh',
              'isRequired': true,
              'maxChoices': 1,
              'options': [
                {'id': 'opto_013', 'name': 'De mong', 'additionalPrice': 0, 'isOutOfStock': false},
                {'id': 'opto_014', 'name': 'De day', 'additionalPrice': 5000, 'isOutOfStock': false},
                {'id': 'opto_015', 'name': 'De gia', 'additionalPrice': 10000, 'isOutOfStock': false},
              ],
            },
          ],
          'createdAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'updatedAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'deletedAt': null,
        },
        {
          'id': 'prod_005',
          'storeId': 'store_002',
          'categoryId': 'cate_008',
          'categoryName': 'Pizza',
          'name': 'Pizza Hải Sản',
          'description': 'Pizza voi tom, muc, ca cham day cao.',
          'basePrice': 150000.0,
          'imageUrl':
              'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=400&q=80',
          'isOutOfStock': false,
          'optionGroups': [
            {
              'id': 'optg_006',
              'name': 'Chọn Size',
              'isRequired': true,
              'maxChoices': 1,
              'options': [
                {'id': 'opto_016', 'name': 'Size S (20cm)', 'additionalPrice': 0, 'isOutOfStock': false},
                {'id': 'opto_017', 'name': 'Size M (25cm)', 'additionalPrice': 40000, 'isOutOfStock': false},
                {'id': 'opto_018', 'name': 'Size L (30cm)', 'additionalPrice': 80000, 'isOutOfStock': false},
              ],
            },
          ],
          'createdAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'updatedAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'deletedAt': null,
        },
        // FoodGo Trà Sữa - store_003
        {
          'id': 'prod_006',
          'storeId': 'store_003',
          'categoryId': 'cate_007',
          'categoryName': 'Trà sữa',
          'name': 'Trà Sữa Thái Đỏ',
          'description': 'Tra sua Thai Lan that ngon, vi ngot nhe.',
          'basePrice': 35000.0,
          'imageUrl':
              'https://images.unsplash.com/photo-1558857563-b371033873b8?w=400&q=80',
          'isOutOfStock': false,
          'isFeatured': true,
          'optionGroups': [
            {
              'id': 'optg_007',
              'name': 'Chọn Size',
              'isRequired': true,
              'maxChoices': 1,
              'options': [
                {'id': 'opto_019', 'name': 'S', 'additionalPrice': 0, 'isOutOfStock': false},
                {'id': 'opto_020', 'name': 'M', 'additionalPrice': 5000, 'isOutOfStock': false},
                {'id': 'opto_021', 'name': 'L', 'additionalPrice': 10000, 'isOutOfStock': false},
              ],
            },
            {
              'id': 'optg_008',
              'name': 'Chọn Đường',
              'isRequired': true,
              'maxChoices': 1,
              'options': [
                {'id': 'opto_022', 'name': '0% duong', 'additionalPrice': 0, 'isOutOfStock': false},
                {'id': 'opto_023', 'name': '30% duong', 'additionalPrice': 0, 'isOutOfStock': false},
                {'id': 'opto_024', 'name': '50% duong', 'additionalPrice': 0, 'isOutOfStock': false},
                {'id': 'opto_025', 'name': '100% duong', 'additionalPrice': 0, 'isOutOfStock': false},
              ],
            },
            {
              'id': 'optg_009',
              'name': 'Thêm Topping',
              'isRequired': false,
              'maxChoices': 5,
              'options': [
                {'id': 'opto_026', 'name': 'Them tran chau den', 'additionalPrice': 5000, 'isOutOfStock': false},
                {'id': 'opto_027', 'name': 'Them tran chau trang', 'additionalPrice': 5000, 'isOutOfStock': false},
                {'id': 'opto_028', 'name': 'Them pudding', 'additionalPrice': 7000, 'isOutOfStock': false},
                {'id': 'opto_029', 'name': 'Them flan', 'additionalPrice': 7000, 'isOutOfStock': false},
              ],
            },
          ],
          'createdAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'updatedAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'deletedAt': null,
        },
        {
          'id': 'prod_007',
          'storeId': 'store_003',
          'categoryId': 'cate_002',
          'categoryName': 'Đồ uống',
          'name': 'Trà Đào Cam',
          'description': 'Tra dao that cam that ngon, giai khat cuc te.',
          'basePrice': 30000.0,
          'imageUrl':
              'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=400&q=80',
          'isOutOfStock': false,
          'optionGroups': [
            {
              'id': 'optg_010',
              'name': 'Chọn Size',
              'isRequired': true,
              'maxChoices': 1,
              'options': [
                {'id': 'opto_030', 'name': 'S', 'additionalPrice': 0, 'isOutOfStock': false},
                {'id': 'opto_031', 'name': 'M', 'additionalPrice': 5000, 'isOutOfStock': false},
                {'id': 'opto_032', 'name': 'L', 'additionalPrice': 10000, 'isOutOfStock': false},
              ],
            },
          ],
          'createdAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'updatedAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'deletedAt': null,
        },
        // FoodGo Bánh Mì - store_004
        {
          'id': 'prod_008',
          'storeId': 'store_004',
          'categoryId': 'cate_003',
          'categoryName': 'Bánh mì',
          'name': 'Bánh Mì Thịt Nướng',
          'description': 'Banh mi that nong, thit nuong thom phuc.',
          'basePrice': 35000.0,
          'imageUrl':
              'https://images.unsplash.com/photo-1509722747041-616f39b57569?w=400&q=80',
          'isOutOfStock': false,
          'optionGroups': [
            {
              'id': 'optg_011',
              'name': 'Loại Bánh',
              'isRequired': true,
              'maxChoices': 1,
              'options': [
                {'id': 'opto_033', 'name': 'Banh my dang', 'additionalPrice': 0, 'isOutOfStock': false},
                {'id': 'opto_034', 'name': 'Banh my soc', 'additionalPrice': 2000, 'isOutOfStock': false},
              ],
            },
          ],
          'createdAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'updatedAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'deletedAt': null,
        },
        {
          'id': 'prod_009',
          'storeId': 'store_004',
          'categoryId': 'cate_003',
          'categoryName': 'Bánh mì',
          'name': 'Bánh Mì Chả Bông',
          'description': 'Banh mi cha bong truyen thong, nhieu cha.',
          'basePrice': 30000.0,
          'imageUrl':
              'https://images.unsplash.com/photo-1585441748780-3675d6a7f9c0?w=400&q=80',
          'isOutOfStock': false,
          'optionGroups': [],
          'createdAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'updatedAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'deletedAt': null,
        },
        // FoodGo Cơm Tấm - store_005
        {
          'id': 'prod_010',
          'storeId': 'store_005',
          'categoryId': 'cate_004',
          'categoryName': 'Cơm tấm',
          'name': 'Cơm Tấm Sườn Bì',
          'description': 'Com tam suon bi chao that ngon, tieu bieu Saigon.',
          'basePrice': 45000.0,
          'imageUrl':
              'https://images.unsplash.com/photo-1569050467447-ce54b3bbc37d?w=400&q=80',
          'isOutOfStock': false,
          'optionGroups': [],
          'createdAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'updatedAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'deletedAt': null,
        },
        {
          'id': 'prod_011',
          'storeId': 'store_005',
          'categoryId': 'cate_004',
          'categoryName': 'Cơm tấm',
          'name': 'Cơm Tấm Bò Kho',
          'description': 'Com tam bo kho dac biet, nuoc dung thom ngao.',
          'basePrice': 55000.0,
          'imageUrl':
              'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=400&q=80',
          'isOutOfStock': false,
          'optionGroups': [],
          'createdAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'updatedAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'deletedAt': null,
        },
        // FoodGo Lẩu - store_006
        {
          'id': 'prod_012',
          'storeId': 'store_006',
          'categoryId': 'cate_005',
          'categoryName': 'Lẩu & Buffet',
          'name': 'Lẩu Thái Chua Cay',
          'description': 'Lau Thai chua cay man mien, thit bo that ngon.',
          'basePrice': 250000.0,
          'imageUrl':
              'https://images.unsplash.com/photo-1552566626-52f8b828add9?w=400&q=80',
          'isOutOfStock': false,
          'isFeatured': true,
          'optionGroups': [
            {
              'id': 'optg_012',
              'name': 'Loại Nước Dùng',
              'isRequired': true,
              'maxChoices': 1,
              'options': [
                {'id': 'opto_035', 'name': 'Nuoc dau (tre)', 'additionalPrice': 0, 'isOutOfStock': false},
                {'id': 'opto_036', 'name': 'Nuoc dau (nhieu)', 'additionalPrice': 20000, 'isOutOfStock': false},
              ],
            },
            {
              'id': 'optg_013',
              'name': 'Thêm Khẩu Phần',
              'isRequired': false,
              'maxChoices': 5,
              'options': [
                {'id': 'opto_037', 'name': 'Them 1 nguoi', 'additionalPrice': 80000, 'isOutOfStock': false},
                {'id': 'opto_038', 'name': 'Them thit bo', 'additionalPrice': 50000, 'isOutOfStock': false},
                {'id': 'opto_039', 'name': 'Them tom', 'additionalPrice': 60000, 'isOutOfStock': false},
              ],
            },
          ],
          'createdAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'updatedAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'deletedAt': null,
        },
        {
          'id': 'prod_013',
          'storeId': 'store_006',
          'categoryId': 'cate_005',
          'categoryName': 'Lẩu & Buffet',
          'name': 'Lẩu Bò',
          'description': 'Lau bo nhat Ban, nuoc dung ngot thanh.',
          'basePrice': 350000.0,
          'imageUrl':
              'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400&q=80',
          'isOutOfStock': false,
          'optionGroups': [],
          'createdAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'updatedAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'deletedAt': null,
        },
        // FoodGo Ăn Vặt - store_007
        {
          'id': 'prod_014',
          'storeId': 'store_007',
          'categoryId': 'cate_006',
          'categoryName': 'Ăn vặt',
          'name': 'Gà Rán',
          'description': 'Ga chien vang ruc, gion tan, thit mit.',
          'basePrice': 40000.0,
          'imageUrl':
              'https://images.unsplash.com/photo-1541592106381-b31e9677c0e5?w=400&q=80',
          'isOutOfStock': false,
          'optionGroups': [
            {
              'id': 'optg_014',
              'name': 'Loại Gà',
              'isRequired': true,
              'maxChoices': 1,
              'options': [
                {'id': 'opto_040', 'name': 'Ga ta', 'additionalPrice': 0, 'isOutOfStock': false},
                {'id': 'opto_041', 'name': 'Ga ta (1/2 con)', 'additionalPrice': 25000, 'isOutOfStock': false},
              ],
            },
          ],
          'createdAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'updatedAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'deletedAt': null,
        },
        {
          'id': 'prod_015',
          'storeId': 'store_007',
          'categoryId': 'cate_006',
          'categoryName': 'Ăn vặt',
          'name': 'Mực Chiên',
          'description': 'Muc chien banh that, gion tan that ngon.',
          'basePrice': 60000.0,
          'imageUrl':
              'https://images.unsplash.com/photo-1599084993091-1cb5c0721cc6?w=400&q=80',
          'isOutOfStock': false,
          'optionGroups': [],
          'createdAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'updatedAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'deletedAt': null,
        },
        // FoodGo Fast Food - store_008
        {
          'id': 'prod_016',
          'storeId': 'store_008',
          'categoryId': 'cate_006',
          'categoryName': 'Ăn vặt',
          'name': 'Combo Phô Mai Que',
          'description': 'Pho mai que gion tan, kem saucac.',
          'basePrice': 65000.0,
          'imageUrl':
              'https://images.unsplash.com/photo-1630384060421-cb20d0e0649d?w=400&q=80',
          'isOutOfStock': false,
          'optionGroups': [],
          'createdAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'updatedAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'deletedAt': null,
        },
        {
          'id': 'prod_017',
          'storeId': 'store_008',
          'categoryId': 'cate_001',
          'categoryName': 'Đồ ăn nhanh',
          'name': 'Hot Dog',
          'description': 'Hotdog xuc xich My, mustard ngon.',
          'basePrice': 35000.0,
          'imageUrl':
              'https://images.unsplash.com/photo-1612392062126-e51e8ba9e0a5?w=400&q=80',
          'isOutOfStock': false,
          'optionGroups': [],
          'createdAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'updatedAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'deletedAt': null,
        },
      ];

  static List<Map<String, dynamic>> _buildBanners() => [
        {
          'id': 'banner_001',
          'title': 'Khuyen mai 20%',
          'imageUrl':
              'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800&q=80',
          'storeId': null,
          'isActive': true,
          'order': 1,
          'createdAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'updatedAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'deletedAt': null,
        },
        {
          'id': 'banner_002',
          'title': 'Mien phi giao hang',
          'imageUrl':
              'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=800&q=80',
          'storeId': null,
          'isActive': true,
          'order': 2,
          'createdAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'updatedAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'deletedAt': null,
        },
        {
          'id': 'banner_003',
          'title': 'Flash Sale',
          'imageUrl':
              'https://images.unsplash.com/photo-1543353071-873f17a7a088?w=800&q=80',
          'storeId': null,
          'isActive': true,
          'order': 3,
          'createdAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'updatedAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'deletedAt': null,
        },
      ];

  static List<Map<String, dynamic>> _buildUsers() => [
        {
          'id': 'user_001',
          'phone': '0909123456',
          'fullName': 'Nguyen Van A',
          'avatarUrl':
              'https://images.unsplash.com/photo-1633332755192-727a05c4013d?w=200&q=80',
          'loyaltyPoints': 2500,
          'settings': {
            'themeMode': 0,
            'isPushEnabled': true,
          },
          'savedAddresses': [
            {
              'id': 'addr_001',
              'label': 'Nhà',
              'addressText': '123 Nguyen Hue, Quan 1, TP.HCM',
              'latitude': 10.7765,
              'longitude': 106.7009,
              'isDefault': true,
            },
            {
              'id': 'addr_002',
              'label': 'Văn phòng',
              'addressText': '45 Le Duan, Quan 3, TP.HCM',
              'latitude': 10.7795,
              'longitude': 106.6950,
              'isDefault': false,
            },
          ],
          'createdAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'updatedAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'deletedAt': null,
        },
        {
          'id': 'user_002',
          'phone': '0912345678',
          'fullName': 'Tran Thi B',
          'avatarUrl':
              'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&q=80',
          'loyaltyPoints': 1200,
          'settings': {
            'themeMode': 0,
            'isPushEnabled': true,
          },
          'savedAddresses': [
            {
              'id': 'addr_003',
              'label': 'Nhà',
              'addressText': '78 Pasteur, Quan 1, TP.HCM',
              'latitude': 10.7815,
              'longitude': 106.6980,
              'isDefault': true,
            },
          ],
          'createdAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'updatedAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'deletedAt': null,
        },
      ];

  static List<Map<String, dynamic>> _buildVouchers() => [
        {
          'id': 'voucher_001',
          'storeId': null,
          'name': 'Mien phi giao hang',
          'code': 'FREESHIP',
          'discountType': 1,
          'discountValue': 0,
          'minOrderValue': 50000,
          'maxDiscount': 20000,
          'expiryDate': Timestamp.fromDate(DateTime(2026, 12, 31)),
          'usageLimit': 1000,
          'usageCount': 0,
          'createdAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'updatedAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'deletedAt': null,
        },
        {
          'id': 'voucher_002',
          'storeId': null,
          'name': 'Giam 15%',
          'code': 'SUMMER15',
          'discountType': 2,
          'discountValue': 15,
          'minOrderValue': 100000,
          'maxDiscount': 50000,
          'expiryDate': Timestamp.fromDate(DateTime(2026, 8, 31)),
          'usageLimit': 500,
          'usageCount': 0,
          'createdAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'updatedAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'deletedAt': null,
        },
        {
          'id': 'voucher_003',
          'storeId': null,
          'name': 'Giam 25.000 VND',
          'code': 'FOODGO25K',
          'discountType': 2,
          'discountValue': 25000,
          'minOrderValue': 150000,
          'maxDiscount': 25000,
          'expiryDate': Timestamp.fromDate(DateTime(2026, 6, 30)),
          'usageLimit': 200,
          'usageCount': 0,
          'createdAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'updatedAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'deletedAt': null,
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
      await _firestore
          .collection('_test')
          .doc('_test_doc')
          .set({'test': true, 'timestamp': DateTime.now().toIso8601String()});
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
  static Future<void> checkDocument(
      String collection, String docId) async {
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

  /// Xoa toan bo du lieu seed (de reset).
  static Future<void> clearAllSeededData() async {
    debugPrint('=== Xoa toan bo du lieu seed ===');

    final collections = [
      'system_categories',
      'stores',
      'products',
      'banners',
      'users',
      'vouchers',
    ];

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
  }
}

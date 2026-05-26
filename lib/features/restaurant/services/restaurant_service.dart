import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../home/models/store_model.dart';
import '../../home/models/product_model.dart';
import '../models/restaurant_category_model.dart';
import '../models/review_model.dart';

/// Service cung cap du lieu mock cho trang chi tiet quan an.
///
/// Mo phong du lieu tu Firestore de test UI nhanh chong.
class RestaurantService {
  RestaurantService._();

  /// Lay danh sach danh muc cua mot quan.
  static List<RestaurantCategoryModel> getCategories() {
    debugPrint('RestaurantService: Tra ve danh sach danh muc');
    return [
      RestaurantCategoryModel(id: 'all', name: 'Tat ca', order: 0),
      RestaurantCategoryModel(id: 'drinks', name: 'Nuoc uong', order: 1),
      RestaurantCategoryModel(id: 'fast_food', name: 'Do an nhanh', order: 2),
      RestaurantCategoryModel(id: 'vietnamese', name: 'An vat', order: 3),
      RestaurantCategoryModel(id: 'snacks', name: 'Do an vat', order: 4),
      RestaurantCategoryModel(id: 'dessert', name: 'Trang mieng', order: 5),
      RestaurantCategoryModel(id: 'breakfast', name: 'Bua sang', order: 6),
      RestaurantCategoryModel(id: 'seafood', name: 'Hai san', order: 7),
    ];
  }

  /// Lay toan bo san pham cua mot quan (tra ve Stream de dong nhat voi
  /// cac service khac trong du an).
  static Stream<List<ProductModel>> getProductsByStoreStream(String storeId) {
    debugPrint('RestaurantService: Tra ve Stream san pham cua quan [$storeId]');
    return Stream.value(_getMockProducts(storeId));
  }

  /// Lay danh sach san pham theo danh muc cua quan.
  static Stream<List<ProductModel>> getProductsByCategoryStream(
    String storeId,
    String categoryId,
  ) {
    debugPrint(
        'RestaurantService: Tra ve Stream san pham theo danh muc [$categoryId]');
    final allProducts = _getMockProducts(storeId);
    if (categoryId == 'all') {
      return Stream.value(allProducts);
    }
    return Stream.value(
      allProducts.where((p) => p.categoryId == categoryId).toList(),
    );
  }

  /// Tao doi tuong StoreModel mock cho trang chi tiet.
  static StoreModel getMockStore(String storeId) {
    return StoreModel(
      id: storeId,
      name: 'Quan An Ngon 247',
      address: '123 Nguyen Hue, Quan 1, TP.HCM',
      rating: 4.8,
      reviewCount: 1250,
      avtUrl: 'https://i.pravatar.cc/150?img=restaurant',
      backUrl: 'https://picsum.photos/seed/store1/800/400',
      isOpen: true,
      deliveryTime: '20 - 30 phut',
      deliveryFee: 15000,
      distance: 2.5,
      categoryIds: const [],
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
      updatedAt: DateTime.now(),
    );
  }

  /// Khoang cach tu nguoi dung den quan (don vi: km).
  static double getMockDistance() {
    return 2.5;
  }

  /// Lay danh sach mock danh gia cho mot quan.
  static List<ReviewModel> getMockReviews(String storeId) {
    debugPrint('RestaurantService: Tra ve danh sach danh gia cua quan [$storeId]');
    return _mockReviews.map((r) => ReviewModel(
      id: r.id,
      storeId: storeId,
      userId: r.userId,
      userName: r.userName,
      userAvatarUrl: r.userAvatarUrl,
      starRating: r.starRating,
      comment: r.comment,
      imageUrls: r.imageUrls,
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
    )).toList();
  }

  /// Lay thong ke phan bo so sao.
  static ReviewStarDistribution getMockStarDistribution() {
    return ReviewStarDistribution(
      star5: 850,
      star4: 250,
      star3: 100,
      star2: 30,
      star1: 20,
    );
  }

  // ================================================================
  // MOCK DATA - SAN PHAM
  // ================================================================

  static final List<ProductModel> _mockProducts = [
    // ---------- NUOC UONG ----------
    ProductModel(
      id: 'p001',
      storeId: 's001',
      categoryId: 'drinks',
      categoryName: 'Nuoc uong',
      name: 'Tra Sua Thai Do',
      description:
          'Tra Thai Doc Dao thom ngot, topping trung Chau trang mem min',
      basePrice: 35000,
      imageUrl: 'https://picsum.photos/seed/drink1/400/300',
      isOutOfStock: false,
      isFeatured: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'p002',
      storeId: 's001',
      categoryId: 'drinks',
      categoryName: 'Nuoc uong',
      name: 'Ca Fe Den Da',
      description: 'Ca Phe Den nguyen chat, da xay, thuong ngot vua phai',
      basePrice: 28000,
      imageUrl: 'https://picsum.photos/seed/drink2/400/300',
      isOutOfStock: false,
      isFeatured: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'p003',
      storeId: 's001',
      categoryId: 'drinks',
      categoryName: 'Nuoc uong',
      name: 'Matcha Latte',
      description: 'Matcha Nhat chat luong cao, kem sữa béo ngậy',
      basePrice: 40000,
      imageUrl: 'https://picsum.photos/seed/drink3/400/300',
      isOutOfStock: false,
      isFeatured: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'p004',
      storeId: 's001',
      categoryId: 'drinks',
      categoryName: 'Nuoc uong',
      name: 'Huong Duong Latte',
      description: 'Huong duong rang, sua tuoi, duong de',
      basePrice: 38000,
      imageUrl: 'https://picsum.photos/seed/drink4/400/300',
      isOutOfStock: false,
      isFeatured: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'p005',
      storeId: 's001',
      categoryId: 'drinks',
      categoryName: 'Nuoc uong',
      name: 'Tra Dao Cam Sa',
      description: 'Tra dao tuoi, cam vat, sa that chat',
      basePrice: 32000,
      imageUrl: 'https://picsum.photos/seed/drink5/400/300',
      isOutOfStock: true,
      isFeatured: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),

    // ---------- DO AN NHANH ----------
    ProductModel(
      id: 'p006',
      storeId: 's001',
      categoryId: 'fast_food',
      categoryName: 'Do an nhanh',
      name: 'Burger Ca Chua',
      description: 'Banh burger lon, than thit bo, ca chua, xa lat',
      basePrice: 55000,
      imageUrl: 'https://picsum.photos/seed/food1/400/300',
      isOutOfStock: false,
      isFeatured: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'p007',
      storeId: 's001',
      categoryId: 'fast_food',
      categoryName: 'Do an nhanh',
      name: 'My Y Tuoi',
      description: 'My y tuoi dai han, nuoc sot ca chua hanh, thit xong',
      basePrice: 45000,
      imageUrl: 'https://picsum.photos/seed/food2/400/300',
      isOutOfStock: false,
      isFeatured: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'p008',
      storeId: 's001',
      categoryId: 'fast_food',
      categoryName: 'Do an nhanh',
      name: 'Ga Ran Chong Giòn',
      description: 'Ga ran giòn rụm, gia vi day, nuoc mam chua ngot',
      basePrice: 65000,
      imageUrl: 'https://picsum.photos/seed/food3/400/300',
      isOutOfStock: false,
      isFeatured: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'p009',
      storeId: 's001',
      categoryId: 'fast_food',
      categoryName: 'Do an nhanh',
      name: 'Khoai Tay Chien',
      description: 'Khoai tay chien vang rum, muoi tay, sauce tu chon',
      basePrice: 30000,
      imageUrl: 'https://picsum.photos/seed/food4/400/300',
      isOutOfStock: false,
      isFeatured: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'p010',
      storeId: 's001',
      categoryId: 'fast_food',
      categoryName: 'Do an nhanh',
      name: 'Hot Dog Pho Mai',
      description: 'Xuc xich xong, pho mai tan chay, tuong ot',
      basePrice: 40000,
      imageUrl: 'https://picsum.photos/seed/food5/400/300',
      isOutOfStock: false,
      isFeatured: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),

    // ---------- AN VAT ----------
    ProductModel(
      id: 'p011',
      storeId: 's001',
      categoryId: 'vietnamese',
      categoryName: 'An vat',
      name: 'Com Suon Nuong',
      description: 'Com trang, suon nuong giuong, dua leo, nuoc mam pha',
      basePrice: 55000,
      imageUrl: 'https://picsum.photos/seed/viet1/400/300',
      isOutOfStock: false,
      isFeatured: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'p012',
      storeId: 's001',
      categoryId: 'vietnamese',
      categoryName: 'An vat',
      name: 'Pho Bo',
      description: 'Banh pho tai, nam, tach bo, hanh phi, than tot',
      basePrice: 50000,
      imageUrl: 'https://picsum.photos/seed/viet2/400/300',
      isOutOfStock: false,
      isFeatured: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'p013',
      storeId: 's001',
      categoryId: 'vietnamese',
      categoryName: 'An vat',
      name: 'Banh Mi Cha Ca',
      description: 'Banh mi giòn, cha ca nau, do chua, rau thom',
      basePrice: 35000,
      imageUrl: 'https://picsum.photos/seed/viet3/400/300',
      isOutOfStock: false,
      isFeatured: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'p014',
      storeId: 's001',
      categoryId: 'vietnamese',
      categoryName: 'An vat',
      name: 'Bun Bo Hue',
      description: 'Bun bo Hue dai, chan nuoi, nem chua, huong toi',
      basePrice: 50000,
      imageUrl: 'https://picsum.photos/seed/viet4/400/300',
      isOutOfStock: false,
      isFeatured: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'p015',
      storeId: 's001',
      categoryId: 'vietnamese',
      categoryName: 'An vat',
      name: 'Bun Cha Ha Noi',
      description: 'Bun cha nuong, cha cuon, dosn chua, ca cuot',
      basePrice: 48000,
      imageUrl: 'https://picsum.photos/seed/viet5/400/300',
      isOutOfStock: false,
      isFeatured: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),

    // ---------- DO AN VAT ----------
    ProductModel(
      id: 'p016',
      storeId: 's001',
      categoryId: 'snacks',
      categoryName: 'Do an vat',
      name: 'Banh Trang Tron',
      description: 'Banh trang, muoi ot, tau hu, rau thom, me rang',
      basePrice: 15000,
      imageUrl: 'https://picsum.photos/seed/snack1/400/300',
      isOutOfStock: false,
      isFeatured: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'p017',
      storeId: 's001',
      categoryId: 'snacks',
      categoryName: 'Do an vat',
      name: 'Khoai Tay Lac',
      description: 'Khoai tay lac gion, pho mai que, sauce hanh',
      basePrice: 25000,
      imageUrl: 'https://picsum.photos/seed/snack2/400/300',
      isOutOfStock: false,
      isFeatured: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'p018',
      storeId: 's001',
      categoryId: 'snacks',
      categoryName: 'Do an vat',
      name: 'Nuoc Mia Dua',
      description: 'Nuoc mia tuoi, them dua cot dua that',
      basePrice: 12000,
      imageUrl: 'https://picsum.photos/seed/snack3/400/300',
      isOutOfStock: false,
      isFeatured: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'p019',
      storeId: 's001',
      categoryId: 'snacks',
      categoryName: 'Do an vat',
      name: 'Tra Cay',
      description: 'Tra cay tuoi, thach dua, trai cay nhieu loai',
      basePrice: 22000,
      imageUrl: 'https://picsum.photos/seed/snack4/400/300',
      isOutOfStock: false,
      isFeatured: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'p020',
      storeId: 's001',
      categoryId: 'snacks',
      categoryName: 'Do an vat',
      name: 'Sua Chua Nep Cam',
      description: 'Sua chua nep cam thanh mat, dinh duong',
      basePrice: 20000,
      imageUrl: 'https://picsum.photos/seed/snack5/400/300',
      isOutOfStock: true,
      isFeatured: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),

    // ---------- TRANG MIENG ----------
    ProductModel(
      id: 'p021',
      storeId: 's001',
      categoryId: 'dessert',
      categoryName: 'Trang mieng',
      name: 'Che Thai',
      description: 'Thach,dua,sua dac,dua hau,rau cau,banh lot',
      basePrice: 20000,
      imageUrl: 'https://picsum.photos/seed/dessert1/400/300',
      isOutOfStock: false,
      isFeatured: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'p022',
      storeId: 's001',
      categoryId: 'dessert',
      categoryName: 'Trang mieng',
      name: 'Kem Vien',
      description: 'Kem vien vani, soi chocolate, dau tay, cac loai',
      basePrice: 25000,
      imageUrl: 'https://picsum.photos/seed/dessert2/400/300',
      isOutOfStock: false,
      isFeatured: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'p023',
      storeId: 's001',
      categoryId: 'dessert',
      categoryName: 'Trang mieng',
      name: 'Banh Flan',
      description: 'Banh flan caramel, nhanh min, ngot nhe',
      basePrice: 15000,
      imageUrl: 'https://picsum.photos/seed/dessert3/400/300',
      isOutOfStock: false,
      isFeatured: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'p024',
      storeId: 's001',
      categoryId: 'dessert',
      categoryName: 'Trang mieng',
      name: 'Rau Cau Dua',
      description: 'Rau cau dua that, ngot nhe, thanh mat',
      basePrice: 12000,
      imageUrl: 'https://picsum.photos/seed/dessert4/400/300',
      isOutOfStock: false,
      isFeatured: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),

    // ---------- BUA SANG ----------
    ProductModel(
      id: 'p025',
      storeId: 's001',
      categoryId: 'breakfast',
      categoryName: 'Bua sang',
      name: 'Banh Mi Op La',
      description: 'Banh mi sao te, op la trung, bơ, hành phi',
      basePrice: 25000,
      imageUrl: 'https://picsum.photos/seed/breakfast1/400/300',
      isOutOfStock: false,
      isFeatured: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'p026',
      storeId: 's001',
      categoryId: 'breakfast',
      categoryName: 'Bua sang',
      name: 'Xoi Man',
      description: 'Xoi gao nep, nhan man thit muoi,cha cuon, trung',
      basePrice: 30000,
      imageUrl: 'https://picsum.photos/seed/breakfast2/400/300',
      isOutOfStock: false,
      isFeatured: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'p027',
      storeId: 's001',
      categoryId: 'breakfast',
      categoryName: 'Bua sang',
      name: 'Che Cu Ky',
      description: 'Che cu ky, dau phong, dau run, muoi tinh',
      basePrice: 15000,
      imageUrl: 'https://picsum.photos/seed/breakfast3/400/300',
      isOutOfStock: false,
      isFeatured: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),

    // ---------- HAI SAN ----------
    ProductModel(
      id: 'p028',
      storeId: 's001',
      categoryId: 'seafood',
      categoryName: 'Hai san',
      name: 'Lau Ca Bot',
      description: 'Lau ca bot tuoi, rau cu, nuoc le, ca cuot',
      basePrice: 180000,
      imageUrl: 'https://picsum.photos/seed/seafood1/400/300',
      isOutOfStock: false,
      isFeatured: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'p029',
      storeId: 's001',
      categoryId: 'seafood',
      categoryName: 'Hai san',
      name: 'Tam Bot',
      description: 'Tam bot tuoi lon, nuong muoi tich, leo chan',
      basePrice: 120000,
      imageUrl: 'https://picsum.photos/seed/seafood2/400/300',
      isOutOfStock: false,
      isFeatured: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'p030',
      storeId: 's001',
      categoryId: 'seafood',
      categoryName: 'Hai san',
      name: 'Ca Ti Hon',
      description: 'Ca ti hon rang tinh, muoi ot, rau me',
      basePrice: 85000,
      imageUrl: 'https://picsum.photos/seed/seafood3/400/300',
      isOutOfStock: false,
      isFeatured: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'p031',
      storeId: 's001',
      categoryId: 'seafood',
      categoryName: 'Hai san',
      name: 'Cua Hoang De',
      description: 'Cua hoang de tuoi, hap la, che bap',
      basePrice: 250000,
      imageUrl: 'https://picsum.photos/seed/seafood4/400/300',
      isOutOfStock: true,
      isFeatured: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  static List<ProductModel> _getMockProducts(String storeId) {
    return _mockProducts
        .map((p) => ProductModel(
              id: p.id,
              storeId: storeId,
              categoryId: p.categoryId,
              categoryName: p.categoryName,
              name: p.name,
              description: p.description,
              basePrice: p.basePrice,
              imageUrl: p.imageUrl,
              isOutOfStock: p.isOutOfStock,
              isFeatured: p.isFeatured,
              createdAt: p.createdAt,
              updatedAt: p.updatedAt,
            ))
        .toList();
  }

  // ================================================================
  // MOCK DATA - DANH GIA
  // ================================================================

  static final List<ReviewModel> _mockReviews = [
    ReviewModel(
      id: 'r001',
      storeId: 's001',
      userId: 'u001',
      userName: 'Nguyen Van A',
      userAvatarUrl: 'https://i.pravatar.cc/150?img=1',
      starRating: 5,
      comment:
          'Quan an rat ngon, dac biet la com suon nuong that suot. Thuc don da dong du, mon moi deu thu vi. Nhan vien phuc vu nhanh chong va than thien.',
      imageUrls: [
        'https://picsum.photos/seed/review1a/300/300',
        'https://picsum.photos/seed/review1b/300/300',
        'https://picsum.photos/seed/review1c/300/300',
      ],
      createdAt: DateTime(2026, 4, 5, 10, 30),
      updatedAt: DateTime(2026, 4, 5, 10, 30),
    ),
    ReviewModel(
      id: 'r002',
      storeId: 's001',
      userId: 'u002',
      userName: 'Tran Thi B',
      userAvatarUrl: 'https://i.pravatar.cc/150?img=5',
      starRating: 4,
      comment:
          'Khoang cach gan, giao hang nhanh hon mong doi. Mon an duoc goi lan 2 van con ngon, dam bao chat luong on dinh.',
      imageUrls: [],
      createdAt: DateTime(2026, 4, 4, 14, 15),
      updatedAt: DateTime(2026, 4, 4, 14, 15),
    ),
    ReviewModel(
      id: 'r003',
      storeId: 's001',
      userId: 'u003',
      userName: 'Le Van C',
      userAvatarUrl: 'https://i.pravatar.cc/150?img=8',
      starRating: 5,
      comment: null,
      imageUrls: [],
      createdAt: DateTime(2026, 4, 3, 9, 0),
      updatedAt: DateTime(2026, 4, 3, 9, 0),
    ),
    ReviewModel(
      id: 'r004',
      storeId: 's001',
      userId: 'u004',
      userName: 'Pham Thi D',
      userAvatarUrl: 'https://i.pravatar.cc/150?img=12',
      starRating: 3,
      comment:
          'Mon an huu ich, nhung thoi gian giao hang tre hon du kien 15 phut. Ban dau goi tra sua that doan, tra rat thom nhung it ngot hon mong doi.',
      imageUrls: [],
      createdAt: DateTime(2026, 4, 2, 18, 45),
      updatedAt: DateTime(2026, 4, 2, 18, 45),
    ),
    ReviewModel(
      id: 'r005',
      storeId: 's001',
      userId: 'u005',
      userName: 'Hoang Van E',
      userAvatarUrl: 'https://i.pravatar.cc/150?img=20',
      starRating: 4,
      comment:
          'Ga ran that suot, vo gieng, khong bi dai. Pho mai que cung rat ngon, pho mai tan chay vua phai.',
      imageUrls: [
        'https://picsum.photos/seed/review5a/300/300',
      ],
      createdAt: DateTime(2026, 4, 1, 12, 0),
      updatedAt: DateTime(2026, 4, 1, 12, 0),
    ),
    ReviewModel(
      id: 'r006',
      storeId: 's001',
      userId: 'u006',
      userName: 'Vo Thi F',
      userAvatarUrl: 'https://i.pravatar.cc/150?img=25',
      starRating: 2,
      comment:
          'Banh mi cha ca khong tuan thuat nhu luc dau. Bot pho mai, cha ca it, rau thom con la cac o.',
      imageUrls: [],
      createdAt: DateTime(2026, 3, 30, 20, 30),
      updatedAt: DateTime(2026, 3, 30, 20, 30),
    ),
    ReviewModel(
      id: 'r007',
      storeId: 's001',
      userId: 'u007',
      userName: 'Duong Van G',
      userAvatarUrl: 'https://i.pravatar.cc/150?img=33',
      starRating: 1,
      comment:
          'Don hang bi thieu mon, goi 3 mon nhung chi nhan duoc 1 mon. Lien he ho tro khong duoc giai quyet. Rat that vong.',
      imageUrls: [],
      createdAt: DateTime(2026, 3, 28, 22, 0),
      updatedAt: DateTime(2026, 3, 28, 22, 0),
    ),
    ReviewModel(
      id: 'r008',
      storeId: 's001',
      userId: 'u008',
      userName: 'Bui Thi H',
      userAvatarUrl: 'https://i.pravatar.cc/150?img=40',
      starRating: 5,
      comment:
          'Che Thai o day la tot nhat tuoi lam. Rau cau, dua, thach, banh lot, sua dac deu tot. Gian dien qua, that suot.',
      imageUrls: [
        'https://picsum.photos/seed/review8a/300/300',
        'https://picsum.photos/seed/review8b/300/300',
      ],
      createdAt: DateTime(2026, 3, 25, 15, 10),
      updatedAt: DateTime(2026, 3, 25, 15, 10),
    ),
  ];
}

import 'package:share_plus/share_plus.dart';

import '../../features/home/models/product_model.dart';
import '../../features/home/models/store_model.dart';

class ShareService {
  ShareService._();

  static const String _baseUrl = 'https://food-go-17a5d.web.app';

  static Future<void> shareProduct(ProductModel product) async {
    final text = 'Xem món này trên FoodGo!\n'
        '${product.name}\n'
        '${_formatPrice(product.basePrice)}đ\n'
        '$_baseUrl/product/${product.id}';
    await Share.share(text);
  }

  static Future<void> shareStore(StoreModel store) async {
    final text = 'Khám phá ${store.name} trên FoodGo!\n'
        '${store.address}\n'
        '$_baseUrl/store/${store.id}';
    await Share.share(text);
  }

  static String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
  }
}

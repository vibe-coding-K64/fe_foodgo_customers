import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';
import '../models/cart_model.dart';

/// Service goi API lay du lieu gio hang.
class CartService {
  const CartService();

  /// Lay thong tin gio hang hien tai.
  ///
  /// Endpoint: GET /cart
  /// API tra ve truc tiep Map (Object), khong co truong `data` bao ngoai.
  Future<CartModel> getCart() async {
    try {
      final response =
          await ApiClient.get<Map<String, dynamic>>('/cart');

      // API tra ve truc tiep Object -> response.data la Map.
      final Map<String, dynamic>? rawData = response.data;

      if (rawData == null) {
        debugPrint('CartService: Du lieu tra ve la null');
        throw Exception('Khong the lay du lieu gio hang');
      }

      debugPrint('CartService: Da nhan du lieu gio hang');

      return CartModel.fromJson(rawData);
    } catch (e) {
      debugPrint('CartService: Loi getCart - $e');
      rethrow;
    }
  }
}

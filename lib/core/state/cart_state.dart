import 'package:flutter/foundation.dart';

/// State quan ly so luong mon trong gio hang.
///
/// Day la mock state provider tam thoi, se duoc thay the
/// boi cart service thuc te khi tich hop backend.
class CartState extends ChangeNotifier {
  int _itemCount = 0;

  int get itemCount => _itemCount;

  /// Tang so luong mon them vao gio.
  void addItem() {
    _itemCount++;
    notifyListeners();
  }

  /// Giam so luong mon trong gio.
  void removeItem() {
    if (_itemCount > 0) {
      _itemCount--;
      notifyListeners();
    }
  }

  /// Xoa het mon trong gio.
  void clearCart() {
    _itemCount = 0;
    notifyListeners();
  }
}

/// File dinh nghia cac route (duong dan man hinh) cua ung dung.
class AppRoutes {
  AppRoutes._();

  // Route mac dinh khi khoi dong ung dung.
  static const String splash = '/';
  static const String main = '/main';

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';

  // Home
  static const String home = '/home';

  // Search
  static const String search = '/search';

  // Store
  static const String storeDetail = '/store/detail';
  static const String menu = '/store/menu';

  // Cart
  static const String cart = '/cart';

  // Order
  static const String orderList = '/order/list';
  static const String orderDetail = '/order/detail';

  // Profile
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String settings = '/profile/settings';
  static const String addressList = '/profile/address';
  static const String addressAdd = '/profile/address/add';
  static const String addressEdit = '/profile/address/edit';
}

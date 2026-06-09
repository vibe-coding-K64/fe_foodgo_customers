# FoodGo Customers

Ứng dụng khách hàng của hệ thống FoodGo - ứng dụng đặt món, theo dõi đơn hàng và quản lý tài khoản.

---

## Công nghệ sử dụng

| Công nghệ | Phiên bản |
|-----------|-----------|
| Flutter SDK | ^3.11.1 |
| Dart SDK | ^3.11.1 |
| Android minSdk | mặc định của Flutter |
| Android targetSdk | mặc định của Flutter |
| Java | JDK 17 |

### Các thư viện chính

| Package | Mục đích |
|---------|----------|
| `dio: ^5.4.0` | HTTP client gọi API |
| `firebase_core: ^4.6.0` | Khởi tạo Firebase |
| `firebase_auth: ^6.3.0` | Xác thực người dùng |
| `cloud_firestore: ^6.2.0` | Cơ sở dữ liệu Firestore |
| `shared_preferences: ^2.3.3` | Lưu trữ cấu hình cục bộ |
| `flutter_map: ^7.0.2` | Bản đồ tích hợp |
| `latlong2: ^0.9.1` | Xử lý tọa độ địa lý |
| `geolocator: ^13.0.2` | Lấy vị trí hiện tại |
| `image_picker: ^1.1.2` | Chọn ảnh từ thư viện hoặc máy ảnh |
| `url_launcher: ^6.2.5` | Mở liên kết bên ngoài |
| `share_plus: ^10.0.0` | Chia sẻ nội dung |
| `fl_chart: ^0.69.2` | Biểu đồ thống kê |
| `flutter_map_animations: ^0.7.1` | Hiệu ứng bản đồ |

---

## Các bước cài đặt và chạy project

### 1. Yêu cầu hệ thống

- Flutter SDK 3.11.1 trở lên (kiểm tra bằng `flutter --version`)
- Dart SDK 3.11.1 trở lên
- Android Studio / Android SDK (nếu chạy trên Android)
- Xcode (nếu chạy trên iOS, chỉ trên macOS)
- Git

### 2. Clone project

```bash
git clone <url-của-repository>
cd fe_foodgo_customers
```

### 3. Cài đặt Firebase

1. Đi đến [Firebase Console](https://console.firebase.google.com/)
2. Tạo một project mới hoặc chọn project hiện có
3. Đăng ký ứng dụng Android (nhập applicationId: `com.example.fe_foodgo_customers`)
4. Tải file `google-services.json` vào thư mục `android/app/`
5. Đăng ký ứng dụng iOS (nếu cần), tải `GoogleService-Info.plist` vào `ios/Runner/`
6. Bật Firebase Authentication > Phương thức đăng nhập: **Email/Password**
7. Bật Cloud Firestore > Tạo collection `vouchers` (nếu cần)

### 4. Chỉnh sửa cấu hình API (QUAN TRỌNG)

Trước khi chạy, cần chỉnh sửa baseURL trong file `lib/core/network/api_client.dart` thành địa chỉ IP của máy chủ backend:

- Mở file `lib/core/network/api_client.dart`
- Tìm dòng:
  ```dart
  static const String _baseUrl =
      'https://be-foodgo.canluaz.io.vn/api';
  ```
- Thay thành địa chỉ IP của máy chủ server backend, VD:
  ```dart
  static const String _baseUrl =
      'http://192.168.1.200:8080/api';
  ```
  Trong đó `192.168.1.200` là địa chỉ IPv4 của máy tính chạy backend trên cùng mạng wifi với điện thoại.

### 5. Cài đặt quyền Android (nếu cần truy cập vị trí)

Trong `android/app/src/main/AndroidManifest.xml`, đảm bảo đã khai báo:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

### 6. Cài đặt quyền iOS (nếu cần truy cập vị trí)

Trong `ios/Runner/Info.plist`, thêm:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Ứng dụng cần truy cập vị trí để tìm nhà hàng gần bạn.</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>Ứng dụng cần truy cập vị trí để tìm nhà hàng gần bạn.</string>
```

### 7. Cài đặt dependencies

```bash
flutter pub get
```

### 8. Chạy ứng dụng

Chạy trên Android (thiết bị nối):
```bash
flutter run
```

Chạy trên Android với máy thật:
```bash
flutter run -d <device_id>
```

Kiểm tra thiết bị hiện có:
```bash
flutter devices
```

Chạy chế độ release:
```bash
flutter run --release
```

---

## Tài khoản test

| Thuộc tính | Giá trị |
|------------|---------|
| Email | `khachhang@gmail.com` |
| Mật khẩu | `password123` |

> Sử dụng tài khoản này để đăng nhập vào ứng dụng khách hàng.

---

## Lưu ý quan trọng

### Về địa chỉ API (baseURL)

Điện thoại và máy tính server **phải kết nối cùng một mạng wifi** và phải nằm cùng lớp mạng (cùng subnet).

Cách lấy địa chỉ IP của máy tính chủ (Windows):

1. Mở Command Prompt (cmd)
2. Gõ lệnh: `ipconfig`
3. Tìm mục **IPv4 Address** của adapter wifi (thường là `192.168.x.x`)

VD: Nếu IPv4 là `192.168.1.50`, thì baseURL trong `api_client.dart` sẽ là:

```dart
static const String _baseUrl =
    'http://192.168.1.50:8080/api';
```

### Về Firebase

- File `google-services.json` phải được đặt đúng vị trí tại `android/app/google-services.json`.
- Nếu không có file này, ứng dụng sẽ không khởi tạo được Firebase và sẽ bị crash.
- Nếu chạy trên iOS, file `GoogleService-Info.plist` phải đặt tại `ios/Runner/GoogleService-Info.plist`.

### Về Android Emulator

Nếu sử dụng Android Emulator, địa chỉ `10.0.2.2` sẽ trỏ về máy tính chủ (localhost). Nếu backend chạy trên máy chủ, hãy thử đặt baseURL thành `http://10.0.2.2:PORT/api`.

### Về iOS Simulator

Nếu chạy trên iOS Simulator, sử dụng địa chỉ IP thực của máy chủ (không dùng `localhost` vì iOS Simulator chạy trong VM riêng biệt).

### Về minSdk (Android)

Nếu gặp lỗi khi build, kiểm tra `android/app/build.gradle.kts` và đảm bảo `minSdk` đủ lớn (geolocator yêu cầu ít nhất Android SDK 21). Có thể cần đặt `minSdk = 21` hoặc cao hơn.

### Lệnh hữu ích

```bash
# Xóa cache và cài lại dependencies
flutter clean
flutter pub get

# Kiểm tra phiên bản Flutter
flutter --version

# Kiểm tra các thiết bị
flutter devices

# Chạy với chế độ debug (có log)
flutter run -v

# Build APK debug
flutter build apk --debug

# Build APK release
flutter build apk --release
```

---

## Cấu trúc thư mục chính

```
lib/
  core/
    network/          # ApiClient, Dio interceptor
    utils/           # AuthStorage, các hàm hỗ trợ
    localization/     # File ngôn ngữ (vi, en)
  features/
    auth/            # Đăng nhập, đăng ký
    home/            # Trang chủ
    store/           # Cửa hàng, menu
    cart/            # Giỏ hàng
    checkout/        # Thanh toán
    order/           # Quản lý đơn hàng
    profile/         # Hồ sơ người dùng
    address/         # Quản lý địa chỉ
    payment/         # Phương thức thanh toán
    rewards/         # Điểm thưởng, voucher
    notifications/   # Thông báo
    activity/        # Hoạt động, chat
    search/          # Tìm kiếm
    settings/        # Cài đặt
    expense/         # Quản lý chi tiêu
```

# Hướng dẫn tích hợp AI Chatbot - Customer App

## 1. API Endpoints

Base URL: `http://localhost:8086`

### 1.1 Chat với AI

```
POST /api/ai/chat
Content-Type: application/json
X-User-Id: <userId>
```

**Request:**

```json
{
  "message": "Tôi muốn đặt đồ ăn"
}
```

**Response (200):**

```json
{
  "success": true,
  "statusCode": 200,
  "message": "Phan hoi tu tro ly AI",
  "data": "Chào bạn! Tôi có thể giúp bạn đặt đồ ăn..."
}
```

**Response (400):**

```json
{
  "success": false,
  "statusCode": 400,
  "message": "Tin nhan khong duoc de trong.",
  "data": null
}
```

### 1.2 Xóa lịch sử chat

```
DELETE /api/ai/chat/clear
X-User-Id: <userId>
```

**Response:**

```json
{
  "success": true,
  "statusCode": 200,
  "message": "Da xoa lich su chat thanh cong.",
  "data": null
}
```

### 1.3 Kiểm tra trạng thái AI

```
GET /api/ai/health
```

---

## 2. Cấu hình cần thiết

### 2.1 API Client

```dart
class ApiClient {
  // Android emulator: 10.0.2.2, iOS simulator: localhost, thiết bị thật: IP thực của máy chạy backend
  static const String baseUrl = 'http://10.0.2.2:8086';

  final String? _userId;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_userId != null) 'X-User-Id': _userId,
  };

  Future<String> sendMessage(String message) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/ai/chat'),
      headers: _headers,
      body: jsonEncode({'message': message}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return data['data'];
      }
      throw Exception(data['message'] ?? 'Lỗi không xác định');
    }
    throw Exception('HTTP ${response.statusCode}');
  }

  Future<void> clearHistory() async {
    await http.delete(
      Uri.parse('$baseUrl/api/ai/chat/clear'),
      headers: _headers,
    );
  }
}
```

### 2.2 Lưu ý

1. **X-User-Id**: Truyền header này để backend lưu lịch sử riêng cho từng user. Lấy từ secure storage sau khi đăng nhập.
2. **Lưu local**: Nên lưu tin nhắn vào SharedPreferences để hiển thị lịch sử khi mở app.
3. **Error handling**: Luôn bắt exception khi gọi API.


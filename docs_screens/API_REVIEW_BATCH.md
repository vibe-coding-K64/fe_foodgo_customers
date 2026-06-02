# API: Gửi đánh giá món ăn (Batch Review)

## Mục tiêu

App gửi đánh giá nhiều món trong 1 đơn hàng — **chỉ 1 request duy nhất** — bao gồm thông tin đánh giá và ảnh đính kèm.

---

## Endpoint

```
POST /reviews/batch
Content-Type: multipart/form-data
```

---

## Request Body

Request là **multipart/form-data** gồm 2 loại part:

### 1. Part `metadata` (bắt buộc)

- `Content-Type: application/json`
- Chứa toàn bộ thông tin đánh giá dưới dạng JSON string:

```json
{
  "orderId": "order_abc123",
  "storeId": "store_xyz789",
  "userId": "user_001",
  "userName": "Nguyễn Văn A",
  "userAvatarUrl": "https://cdn.foodgo.com/avatars/user_001.jpg",
  "items": [
    {
      "productId": "prod_burger001",
      "starRating": 5,
      "comment": "Burger ngon, giao nhanh",
      "imageUrls": ["https://storage.foodgo.com/reviews/img1.jpg", "https://storage.foodgo.com/reviews/img2.jpg"]
    },
    {
      "productId": "prod_coca002",
      "starRating": 4,
      "comment": "Đồ uống ổn",
      "imageUrls": []
    }
  ]
}
```

#### Mô tả các field trong metadata

| Field | Kiểu | Bắt buộc | Mô tả |
|---|---|---|---|
| `orderId` | String | ✅ | ID đơn hàng |
| `storeId` | String | ✅ | ID cửa hàng |
| `userId` | String | ✅ | ID người dùng |
| `userName` | String | ✅ | Tên người dùng |
| `userAvatarUrl` | String | ❌ | URL avatar người dùng |
| `items` | Array | ✅ | Danh sách đánh giá (chỉ gửi những món có đánh giá sao) |

#### Mỗi item trong `items`

| Field | Kiểu | Bắt buộc | Mô tả |
|---|---|---|---|
| `productId` | String | ✅ | ID sản phẩm |
| `starRating` | Integer (1-5) | ✅ | Số sao đánh giá |
| `comment` | String | ❌ | Nội dung bình luận (có thể rỗng) |
| `imageUrls` | Array\<String\> | ❌ | Danh sách URL ảnh đã upload (rỗng nếu không có ảnh) |

### 2. Part `images` (bắt buộc nếu có ảnh)

- `Content-Type: image/jpeg` (hoặc `image/png`, `image/webp`)
- Mỗi ảnh là 1 part riêng, cùng key `images`
- Có thể gửi từ 1 đến nhiều ảnh (tối đa 5 ảnh/món, có thể có nhiều món)

```
--boundary
Content-Disposition: form-data; name="metadata"
Content-Type: application/json

{"orderId":"order_abc123","storeId":"store_xyz789",...}

--boundary
Content-Disposition: form-data; name="images"; filename="review_img_001.jpg"
Content-Type: image/jpeg

[binary data]

--boundary
Content-Disposition: form-data; name="images"; filename="review_img_002.jpg"
Content-Type: image/jpeg

[binary data]

--boundary--
```

> **Lưu ý:** Nếu không có ảnh, vẫn gửi request bình thường, bỏ qua các part `images`.

---

## Response thành công

```json
HTTP 200
Content-Type: application/json

{
  "success": true,
  "message": "Đánh giá đã được gửi thành công",
  "data": {
    "count": 2,
    "reviewIds": ["review_001", "review_002"]
  }
}
```

| Field | Kiểu | Mô tả |
|---|---|---|
| `success` | Boolean | `true` nếu thành công |
| `message` | String | Thông báo cho người dùng |
| `data.count` | Integer | Số đánh giá đã lưu |
| `data.reviewIds` | Array\<String\> | Danh sách ID của các đánh giá vừa tạo |

---

## Response lỗi

```json
HTTP 400 / 500
Content-Type: application/json

{
  "success": false,
  "message": "Mô tả lỗi cụ thể",
  "errors": [
    { "field": "items[0].starRating", "message": "starRating phải từ 1 đến 5" }
  ]
}
```

---

## Những gì Backend cần làm

### 1. Parse multipart request
- Tách part `metadata` → parse JSON
- Tách các part `images` → lưu ảnh vào storage (S3, Cloudinary, local disk, ...)

### 2. Upload ảnh
- Với mỗi file ảnh nhận được → upload lên storage
- Sau khi upload thành công → nhận URL của ảnh
- Các ảnh cần được đặt tên unique (VD: `review_{timestamp}_{uuid}.jpg`)

### 3. Gán URL ảnh vào items
- Backend gán URL ảnh đã upload vào đúng `imageUrls` của item tương ứng
- **Thứ tự:** App gửi ảnh theo thứ tự, backend cần gán theo đúng thứ tự (ví dụ: 2 ảnh đầu cho món 1, 0 ảnh cho món 2...)

### 4. Lưu vào database
- Tạo document/row trong collection/table `reviews`
- Mỗi review nên lưu: `orderId`, `storeId`, `userId`, `userName`, `userAvatarUrl`, `productId`, `starRating`, `comment`, `imageUrls`, `createdAt`

### 5. Trả response
- Trả về `success: true` kèm số lượng đánh giá đã lưu

---

## Ví dụ minh hoạ đầy đủ

### Request từ app (Flutter)

```dart
final formData = FormData.fromMap({
  'metadata': jsonEncode({
    'orderId': 'order_abc123',
    'storeId': 'store_xyz789',
    'userId': 'user_001',
    'userName': 'Nguyễn Văn A',
    'userAvatarUrl': 'https://cdn.foodgo.com/avatars/user_001.jpg',
    'items': [
      {
        'productId': 'prod_burger001',
        'starRating': 5,
        'comment': 'Burger ngon, giao nhanh',
        'imageUrls': []  // backend sẽ gán URL sau khi upload
      }
    ]
  }),
  'images': [
    await MultipartFile.fromFile('path/to/img1.jpg', filename: 'img1.jpg'),
    await MultipartFile.fromFile('path/to/img2.jpg', filename: 'img2.jpg'),
  ],
});

final response = await Dio().post(
  'https://api.foodgo.com/reviews/batch',
  data: formData,
);
```

### Response backend trả về

```json
{
  "success": true,
  "message": "Đánh giá đã được gửi thành công",
  "data": {
    "count": 1,
    "reviewIds": ["review_uuid_xxx"]
  }
}
```

---

## Ràng buộc

| Thông số | Giá trị |
|---|---|
| Số món đánh giá/request | Tối đa 20 items |
| Số ảnh/món | Tối đa 5 ảnh |
| Định dạng ảnh | JPEG, PNG, WebP |
| Kích thước ảnh tối đa | 10 MB/ảnh |
| starRating | 1 - 5 |

# BeFoodGo API Documentation

**Base URL:** `http://localhost:8080/api`

**Authentication:** JWT Bearer Token (Authorization header). Token được lấy từ response của các API `/auth/login` hoặc `/auth/register`.

**Common Response Wrapper:** Hầu hết các API (trừ một số controller cũ) sử dụng wrapper chuẩn:

```json
{
  "success": true,
  "statusCode": 200,
  "message": "Mo ta thanh cong",
  "data": { ... },
  "timestamp": "2026-05-28T12:00:00Z"
}
```

---

## Mục lục

1. [Auth - Xác thực](#1-auth---xác-thực)
2. [Products - Sản phẩm](#2-products---sản-phẩm)
3. [Stores - Cửa hàng](#3-stores---cửa-hàng)
4. [Cart - Giỏ hàng](#4-cart---giỏ-hàng)
5. [Orders - Đơn hàng](#5-orders---đơn-hàng)
6. [Checkout - Đặt hàng](#6-checkout---đặt-hàng)
7. [Payments - Thanh toán](#7-payments---thanh-toán)
8. [Addresses - Địa chỉ](#8-addresses---địa-chỉ)
9. [Categories - Danh mục](#9-categories---danh-mục)
10. [Search - Tìm kiếm](#10-search---tìm-kiếm)
11. [Vouchers - Mã giảm giá](#11-vouchers---mã-giảm-giá)
12. [Reviews - Đánh giá](#12-reviews---đánh-giá)
13. [Profile - Hồ sơ](#13-profile---hồ-sơ)
14. [Firebase Dev - Dev](#14-firebase-dev---dev)

---

## 1. Auth - Xác thực

**Base Path:** `/api/auth`

### 1.1 Đăng ký tài khoản khách hàng

```
POST /api/auth/register
```

**Mô tả:** Tạo tài khoản khách hàng mới với email, mật khẩu (mã hóa BCrypt), họ tên và số điện thoại. Mặc định roles = [1] (Khách hàng).

**Request Body:**

```json
{
  "email": "nguoidung@gmail.com",
  "password": "password123",
  "fullName": "Nguyen Van A",
  "phoneNumber": "0123456789"
}
```

| Trường | Kiểu | Bắt buộc | Mô tả |
|--------|------|-----------|-------|
| email | String | Có | Email hợp lệ, chưa tồn tại |
| password | String | Có | Tối thiểu 6 ký tự |
| fullName | String | Có | Họ và tên đầy đủ |
| phoneNumber | String | Có | Bắt đầu bằng 0, 10-11 chữ số |

**Response (200):**

```json
{
  "success": true,
  "statusCode": 200,
  "message": "Dang ky thanh cong",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiJ9...",
    "tokenType": "Bearer",
    "expiresIn": 86400000,
    "user": {
      "id": "user_001",
      "email": "nguoidung@gmail.com",
      "fullName": "Nguyen Van A",
      "phoneNumber": "0123456789",
      "photoUrl": null,
      "roles": [1]
    }
  },
  "timestamp": "2026-05-28T12:00:00Z"
}
```

**Lỗi:** 400 - Email hoặc số điện thoại đã tồn tại.

---

### 1.2 Đăng nhập

```
POST /api/auth/login
```

**Mô tả:** Đăng nhập bằng email và mật khẩu. Trả về JWT token chứa userId.

**Request Body:**

```json
{
  "email": "nguoidung@gmail.com",
  "password": "password123"
}
```

**Response (200):** Tương tự `/auth/register` - trả về `AuthResponse` chứa JWT token và thông tin user.

**Lỗi:** 400 - Email hoặc mật khẩu không đúng.

---

### 1.3 Gửi mã OTP

```
POST /api/auth/send-otp
```

**Mô tả:** Gửi mã OTP 6 chữ số đến email hoặc số điện thoại để khôi phục mật khẩu. Mã OTP có hiệu lực 5 phút. Trong môi trường dev/demo, mã OTP sẽ in ra console.

**Request Body:**

```json
{
  "emailOrPhone": "nguoidung@gmail.com"
}
```

**Response (200):**

```json
{
  "success": true,
  "statusCode": 200,
  "message": "Ma OTP da duoc gui",
  "data": {
    "message": "Da gui ma OTP den email cua ban. Vui long kiem tra hop thu."
  },
  "timestamp": "2026-05-28T12:00:00Z"
}
```

**Lỗi:** 400 - Không tìm thấy tài khoản.

---

### 1.4 Xác thực mã OTP

```
POST /api/auth/verify-otp
```

**Mô tả:** Xác thực mã OTP nhận được. Nếu đúng, trả về token tạm thời (hiệu lực 5 phút) để sử dụng cho reset-password.

**Request Body:**

```json
{
  "emailOrPhone": "nguoidung@gmail.com",
  "otpCode": "123456"
}
```

**Response (200):**

```json
{
  "success": true,
  "statusCode": 200,
  "message": "Xac thuc OTP thanh cong",
  "data": {
    "tempToken": "eyJhbGciOiJIUzI1NiJ9...",
    "tokenType": "Bearer",
    "expiresIn": 300000,
    "expiresAt": "2026-05-28T12:05:00Z"
  },
  "timestamp": "2026-05-28T12:00:00Z"
}
```

**Lỗi:** 400 - Mã OTP không đúng hoặc đã hết hạn.

---

### 1.5 Đặt lại mật khẩu

```
POST /api/auth/reset-password
```

**Mô tả:** Đặt lại mật khẩu mới sau khi xác thực OTP thành công. Token tạm thời có hiệu lực 5 phút sau khi xác thực OTP.

**Request Body:**

```json
{
  "tempToken": "eyJhbGciOiJIUzI1NiJ9...",
  "newPassword": "newpassword123"
}
```

**Response (200):**

```json
{
  "success": true,
  "statusCode": 200,
  "message": "Dat lai mat khau thanh cong.",
  "data": null,
  "timestamp": "2026-05-28T12:00:00Z"
}
```

**Lỗi:** 400 - Token không hợp lệ hoặc đã hết hạn.

---

### 1.6 Đăng ký tài khoản người bán

```
POST /api/auth/register-merchant
```

**Mô tả:** Tạo tài khoản người bán mới với roles = [3].

**Request Body:**

```json
{
  "email": "merchant@gmail.com",
  "password": "password123",
  "fullName": "Cua Hang A",
  "phoneNumber": "0987654321"
}
```

**Response (200):** Trả về thông tin merchant đã đăng ký.

**Lỗi:** 400 - Email hoặc số điện thoại đã tồn tại.

---

### 1.7 Kiểm tra quyền người bán

```
GET /api/auth/check-merchant?uid={userId}
```

**Mô tả:** Kiểm tra xem tài khoản có quyền người bán (role = 3) hay không.

**Query Parameters:**

| Tham số | Kiểu | Bắt buộc | Mô tả |
|---------|------|-----------|-------|
| uid | String | Có | ID tài khoản người dùng |

**Response (200):** Trả về kết quả kiểm tra quyền.

---

## 2. Products - Sản phẩm

**Base Path:** `/api/products`

### 2.1 Lấy danh sách sản phẩm

```
GET /api/products?storeId={storeId}
```

**Mô tả:** Lấy tất cả sản phẩm của một cửa hàng.

**Query Parameters:**

| Tham số | Kiểu | Bắt buộc | Mô tả |
|---------|------|-----------|-------|
| storeId | String | Có | ID cửa hàng |

**Response (200):**

```json
{
  "success": true,
  "message": "Lấy danh sách thành công",
  "data": [
    {
      "id": "prod_001",
      "storeId": "store_001",
      "categoryId": "cat_001",
      "categoryName": "Cơm",
      "name": "Cơm tấm sườn bì chả",
      "description": "Cơm tấm sườn nướng bì chả truyền thống",
      "basePrice": 45000,
      "imageUrl": "https://example.com/com-tam.jpg",
      "outOfStock": false,
      "featured": true,
      "optionGroups": [
        {
          "name": "Size",
          "isRequired": false,
          "maxChoices": 1,
          "options": [
            { "name": "M", "price": 0 },
            { "name": "L", "price": 10000 }
          ]
        }
      ]
    }
  ]
}
```

---

### 2.2 Lấy chi tiết sản phẩm

```
GET /api/products/{id}
```

**Path Parameters:**

| Tham số | Kiểu | Mô tả |
|---------|------|-------|
| id | String | ID sản phẩm |

**Response (200):** Trả về chi tiết sản phẩm tương tự cấu trúc trên.

**Lỗi:** 404 - Không tìm thấy món ăn.

---

### 2.3 Tạo sản phẩm

```
POST /api/products
```

**Mô tả:** Tạo một sản phẩm mới cho cửa hàng.

**Request Body:**

```json
{
  "storeId": "store_001",
  "categoryId": "cat_001",
  "categoryName": "Cơm",
  "name": "Cơm tấm sườn bì chả",
  "description": "Cơm tấm sườn nướng bì chả truyền thống",
  "basePrice": 45000,
  "imageUrl": "https://example.com/com-tam.jpg",
  "outOfStock": false,
  "featured": true,
  "optionGroups": [
    {
      "name": "Size",
      "isRequired": false,
      "maxChoices": 1,
      "options": [
        { "name": "M", "price": 0 },
        { "name": "L", "price": 10000 }
      ]
    }
  ]
}
```

**Response (200):**

```json
{
  "success": true,
  "message": "Tạo món ăn thành công lúc: 2026-05-28T12:00:00Z",
  "data": null
}
```

---

### 2.4 Cập nhật sản phẩm

```
PUT /api/products/{id}
```

**Path Parameters:**

| Tham số | Kiểu | Mô tả |
|---------|------|-------|
| id | String | ID sản phẩm |

**Request Body:** Tương tự POST `/api/products`.

**Response (200):**

```json
{
  "success": true,
  "message": "Cập nhật thành công lúc: 2026-05-28T12:00:00Z",
  "data": null
}
```

---

### 2.5 Xóa sản phẩm

```
DELETE /api/products/{id}
```

**Response (200):**

```json
{
  "success": true,
  "message": "Xóa thành công lúc: 2026-05-28T12:00:00Z",
  "data": null
}
```

---

### 2.6 Lấy sản phẩm nổi bật

```
GET /api/products/featured?limit={limit}&categoryId={categoryId}
```

**Query Parameters:**

| Tham số | Kiểu | Bắt buộc | Mô tả |
|---------|------|-----------|-------|
| limit | Integer | Không | Số lượng sản phẩm (mặc định: 10) |
| categoryId | String | Không | Lọc theo danh mục |

**Response (200):**

```json
{
  "success": true,
  "message": "Success",
  "data": [
    {
      "id": "prod_001",
      "name": "Cơm tấm sườn bì chả",
      "description": "...",
      "basePrice": 45000,
      "imageUrl": "https://...",
      "isOutOfStock": false,
      "store": {
        "id": "store_001",
        "name": "Cơm Tấm Phúc Lộc Thọ",
        "rating": 4.8,
        "avtUrl": "https://...",
        "deliveryFee": 15000,
        "deliveryTime": "20-30 phút"
      }
    }
  ]
}
```

---

## 3. Stores - Cửa hàng

**Base Path:** `/api/stores`

### 3.1 Lấy thông tin cửa hàng

```
GET /api/stores/{id}
```

**Response (200):** Trả về `StoreDTO`

```json
{
  "id": "store_001",
  "name": "Cơm Tấm Phúc Lộc Thọ",
  "description": "Quán cơm tấm ngon...",
  "address": "123 Nguyễn Trãi, Q.1, TP.HCM",
  "taxCode": "0123456789",
  "businessLicense": "https://...",
  "coverImageUrl": "https://...",
  "logoUrl": "https://...",
  "bankName": "Vietcombank",
  "bankAccountNumber": "1234567890",
  "isAcceptingOrders": true
}
```

---

### 3.2 Cập nhật thông tin cửa hàng

```
PUT /api/stores/{id}
```

**Request Body:** Tương tự `StoreDTO`.

**Response (200):**

```json
{
  "message": "Cập nhật thông tin quán thành công",
  "data": { ... }
}
```

---

### 3.3 Tạo cửa hàng cho người bán

```
POST /api/stores/merchant/{uid}
```

**Path Parameters:**

| Tham số | Kiểu | Mô tả |
|---------|------|-------|
| uid | String | ID người bán |

**Request Body:** `StoreDTO`

**Response (200):** Trả về thông tin cửa hàng đã tạo.

---

### 3.4 Tìm cửa hàng gần đây

```
GET /api/stores/nearby?lat={lat}&lng={lng}&radius={radius}&limit={limit}&categoryId={categoryId}
```

**Query Parameters:**

| Tham số | Kiểu | Bắt buộc | Mô tả |
|---------|------|-----------|-------|
| lat | Double | Có | Vĩ độ |
| lng | Double | Có | Kinh độ |
| radius | Double | Không | Bán kính tìm kiếm (mặc định: 5000m) |
| limit | Integer | Không | Số lượng kết quả (mặc định: 10) |
| categoryId | String | Không | Lọc theo danh mục |

**Response (200):**

```json
{
  "success": true,
  "data": [
    {
      "id": "store_001",
      "name": "Cơm Tấm Phúc Lộc Thọ",
      "address": "123 Nguyễn Trãi",
      "rating": 4.8,
      "reviewCount": 500,
      "avtUrl": "https://...",
      "deliveryTime": "20-30 phút",
      "deliveryFee": 15000,
      "distance": 1.2,
      "isOpen": true,
      "categoryIds": ["cat_001", "cat_002"]
    }
  ]
}
```

---

### 3.5 Lấy cửa hàng phổ biến

```
GET /api/stores/popular?limit={limit}&categoryId={categoryId}&minRating={minRating}
```

**Query Parameters:**

| Tham số | Kiểu | Bắt buộc | Mô tả |
|---------|------|-----------|-------|
| limit | Integer | Không | Số lượng kết quả (mặc định: 10) |
| categoryId | String | Không | Lọc theo danh mục |
| minRating | Double | Không | Điểm đánh giá tối thiểu (mặc định: 0) |

**Response (200):**

```json
{
  "success": true,
  "data": [
    {
      "id": "store_001",
      "name": "Cơm Tấm Phúc Lộc Thọ",
      "address": "123 Nguyễn Trãi",
      "rating": 4.8,
      "reviewCount": 500,
      "avtUrl": "https://...",
      "backUrl": "https://...",
      "deliveryTime": "20-30 phút",
      "deliveryFee": 15000,
      "isOpen": true,
      "categoryIds": ["cat_001"]
    }
  ]
}
```

---

## 4. Cart - Giỏ hàng

**Base Path:** `/api/cart`

### 4.1 Lấy giỏ hàng

```
GET /api/cart?userId={userId}
```

**Mô tả:** Truy xuất toàn bộ giỏ hàng của khách hàng, bao gồm thông tin cửa hàng và danh sách các món đã chọn.

**Query Parameters:**

| Tham số | Kiểu | Bắt buộc | Mô tả |
|---------|------|-----------|-------|
| userId | String | Có | ID người dùng khách hàng |

**Response (200):**

```json
{
  "success": true,
  "statusCode": 200,
  "message": "Lấy giỏ hàng thành công.",
  "data": {
    "items": [
      {
        "id": "cart_item_001",
        "userId": "user_001",
        "storeId": "store_001",
        "storeName": "Cơm Tấm Phúc Lộc Thọ",
        "storeImageUrl": "https://...",
        "foodId": "prod_001",
        "name": "Cơm tấm sườn bì chả",
        "price": 50000,
        "quantity": 2,
        "size": "M",
        "sizePrice": 0,
        "toppings": [
          { "name": "Trân châu", "price": 5000 }
        ],
        "note": "Không thêm hành",
        "imageUrl": "https://...",
        "createdAt": "2026-05-28T10:00:00Z",
        "updatedAt": "2026-05-28T10:00:00Z"
      }
    ],
    "storeId": "store_001",
    "storeName": "Cơm Tấm Phúc Lộc Thọ",
    "storeImageUrl": "https://..."
  },
  "timestamp": "2026-05-28T12:00:00Z"
}
```

---

### 4.2 Thêm món vào giỏ hàng

```
POST /api/cart/add
```

**Mô tả:** Thêm một món ăn vào giỏ hàng. Nếu giỏ hàng đã có món từ cửa hàng khác, hệ thống sẽ trả về lỗi yêu cầu xác nhận xóa giỏ hàng cũ.

**Request Body:**

```json
{
  "userId": "user_001",
  "storeId": "store_001",
  "foodId": "prod_001",
  "size": "M",
  "toppings": [
    { "name": "Trân châu", "price": 5000 }
  ],
  "note": "Không thêm hành",
  "quantity": 2
}
```

| Trường | Kiểu | Bắt buộc | Mô tả |
|--------|------|-----------|-------|
| userId | String | Có | ID người dùng |
| storeId | String | Có | ID cửa hàng |
| foodId | String | Có | ID sản phẩm |
| size | String | Không | Kích thước (VD: M, L) |
| toppings | Array | Không | Danh sách topping đã chọn |
| note | String | Không | Ghi chú cho cửa hàng |
| quantity | Integer | Có | Số lượng (>= 1) |

**Response (200):**

```json
{
  "success": true,
  "statusCode": 200,
  "message": "Đã thêm món vào giỏ hàng thành công.",
  "data": { /* CartItem */ },
  "timestamp": "2026-05-28T12:00:00Z"
}
```

**Lỗi:**
- 400 - Món ăn hết hàng hoặc vi phạm quy tắc một cửa hàng.
- 404 - Sản phẩm không tồn tại.

---

### 4.3 Cập nhật số lượng món trong giỏ hàng

```
PUT /api/cart/{itemId}/quantity
```

**Mô tả:** Cập nhật số lượng của một món trong giỏ hàng. Số lượng phải lớn hơn 0.

**Path Parameters:**

| Tham số | Kiểu | Mô tả |
|---------|------|-------|
| itemId | String | ID của món trong giỏ hàng (cartItemId) |

**Request Body:**

```json
{
  "userId": "user_001",
  "quantity": 3
}
```

**Response (200):**

```json
{
  "success": true,
  "statusCode": 200,
  "message": "Cập nhật số lượng món thành công.",
  "data": null,
  "timestamp": "2026-05-28T12:00:00Z"
}
```

**Lỗi:**
- 400 - Số lượng <= 0.
- 404 - Món không tồn tại trong giỏ hàng.

---

### 4.4 Xóa một món khỏi giỏ hàng

```
DELETE /api/cart/{itemId}?userId={userId}
```

**Path Parameters:**

| Tham số | Kiểu | Mô tả |
|---------|------|-------|
| itemId | String | ID của món trong giỏ hàng |

**Query Parameters:**

| Tham số | Kiểu | Bắt buộc | Mô tả |
|---------|------|-----------|-------|
| userId | String | Có | ID người dùng |

**Response (200):**

```json
{
  "success": true,
  "statusCode": 200,
  "message": "Đã xóa món khỏi giỏ hàng thành công.",
  "data": null,
  "timestamp": "2026-05-28T12:00:00Z"
}
```

---

### 4.5 Xóa toàn bộ giỏ hàng

```
DELETE /api/cart?userId={userId}
```

**Query Parameters:**

| Tham số | Kiểu | Bắt buộc | Mô tả |
|---------|------|-----------|-------|
| userId | String | Có | ID người dùng |

**Response (200):**

```json
{
  "success": true,
  "statusCode": 200,
  "message": "Đã xóa toàn bộ giỏ hàng thành công.",
  "data": null,
  "timestamp": "2026-05-28T12:00:00Z"
}
```

---

## 5. Orders - Đơn hàng

**Base Path:** `/api/orders`

### 5.1 Lấy danh sách đơn hàng theo cửa hàng

```
GET /api/orders?storeId={storeId}
```

**Query Parameters:**

| Tham số | Kiểu | Bắt buộc | Mô tả |
|---------|------|-----------|-------|
| storeId | String | Có | ID cửa hàng |

**Response (200):** Trả về danh sách `OrderDTO`.

```json
[
  {
    "id": "order_001",
    "userId": "user_001",
    "storeId": "store_001",
    "storeName": "Cơm Tấm Phúc Lộc Thọ",
    "code": "ABC123",
    "customerName": "Nguyễn Văn A",
    "customerPhone": "0123456789",
    "deliveryAddress": "123 Nguyễn Trãi, Q.1, TP.HCM",
    "driverName": "Trần Văn Tài",
    "driverPhone": "0987654321",
    "items": [
      {
        "id": "item_001",
        "foodId": "prod_001",
        "name": "Cơm tấm sườn bì chả",
        "quantity": 2,
        "price": 45000,
        "imageUrl": "https://..."
      }
    ],
    "totalAmount": 90000,
    "shippingFee": 15000,
    "discountAmount": 0,
    "finalAmount": 105000,
    "paymentMethod": "momo",
    "status": "0",
    "createdAt": "2026-05-28T10:00:00",
    "updatedAt": "2026-05-28T10:30:00"
  }
]
```

**Trạng thái đơn hàng (status):**
- `0` = Chờ xác nhận
- `1` = Đang chuẩn bị
- `2` = Đang giao
- `3` = Hoàn thành
- `-1` = Đã hủy

---

### 5.2 Lấy chi tiết đơn hàng

```
GET /api/orders/{id}
```

**Response (200):** Trả về `OrderDTO` chi tiết. **Lỗi:** 404 - Không tìm thấy.

---

### 5.3 Tạo đơn hàng (thủ công - ưu tiên dùng Checkout)

```
POST /api/orders
```

**Request Body:** `OrderDTO`

**Response (200):**

```json
{
  "success": true,
  "statusCode": 200,
  "message": "Tạo đơn hàng thành công.",
  "data": { /* OrderDTO */ },
  "timestamp": "2026-05-28T12:00:00Z"
}
```

---

### 5.4 Cập nhật trạng thái đơn hàng

```
PATCH /api/orders/{id}/status
```

**Request Body:**

```json
{
  "status": "1"
}
```

**Response (200):** Trả về kết quả cập nhật. **Lỗi:** 404 - Không tìm thấy.

---

### 5.5 Hủy đơn hàng

```
POST /api/orders/{id}/cancel?userId={userId}
```

**Mô tả:** Cho phép khách hàng hủy đơn hàng của mình. Chỉ có thể hủy khi đơn hàng ở trạng thái Chờ xác nhận (status = 0).

**Path Parameters:**

| Tham số | Kiểu | Mô tả |
|---------|------|-------|
| id | String | ID đơn hàng |

**Query Parameters:**

| Tham số | Kiểu | Bắt buộc | Mô tả |
|---------|------|-----------|-------|
| userId | String | Có | ID người dùng (để xác thực quyền sở hữu) |

**Response (200):**

```json
{
  "success": true,
  "statusCode": 200,
  "message": "Hủy đơn hàng thành công.",
  "data": { /* OrderDTO */ },
  "timestamp": "2026-05-28T12:00:00Z"
}
```

**Lỗi:**
- 400 - Không thể hủy - đơn đang ở trạng thái không cho phép hủy.
- 403 - Khách hàng không có quyền hủy đơn hàng này.
- 404 - Không tìm thấy đơn hàng.

---

## 6. Checkout - Đặt hàng

**Base Path:** `/api/orders`

### 6.1 Đặt hàng (Checkout)

```
POST /api/orders/checkout
```

**Mô tả:** Thực hiện đặt hàng cho khách hàng. Quy trình gồm: kiểm tra giỏ hàng, kiểm tra khoảng cách Haversine, tính tổng tiền server-side, xử lý voucher, và tạo đơn hàng atomically. Sau khi đặt hàng thành công, giỏ hàng sẽ bị xóa.

**Request Body:**

```json
{
  "userId": "user_001",
  "addressId": "addr_001",
  "paymentMethod": "momo",
  "voucherId": "sys_voucher_001",
  "note": "Giao nhanh"
}
```

| Trường | Kiểu | Bắt buộc | Mô tả |
|--------|------|-----------|-------|
| userId | String | Có | ID người dùng |
| addressId | String | Có | ID địa chỉ giao hàng |
| paymentMethod | String | Có | `cash`, `momo`, `zalo`, `card` |
| voucherId | String | Không | ID voucher sử dụng |
| note | String | Không | Ghi chú cho đơn hàng |

**Response (200):**

```json
{
  "success": true,
  "statusCode": 200,
  "message": "Dat hang thanh cong, vui long cho cua hang xac nhan.",
  "data": {
    "orderId": "AbCdEfGhIjKlMnOpQrStUvWxYz123456",
    "orderCode": "QRSTUV",
    "storeId": "store_001",
    "storeName": "Cơm Tấm Phúc Lộc Thọ",
    "userId": "user_001",
    "items": [
      {
        "foodId": "prod_001",
        "name": "Cơm tấm sườn bì chả",
        "price": 45000,
        "quantity": 2,
        "imageUrl": "https://...",
        "options": [
          { "name": "Trân châu", "price": 5000 }
        ]
      }
    ],
    "totalAmount": 95000,
    "deliveryFee": 15000,
    "discountAmount": 20000,
    "finalAmount": 90000,
    "paymentMethod": "momo",
    "deliveryAddress": "Ký túc xá UTC2, Quận 9, TP.HCM",
    "status": 0,
    "createdAt": "2026-05-28T10:00:00Z",
    "note": "Giao nhanh"
  },
  "timestamp": "2026-05-28T12:00:00Z"
}
```

**Lỗi:**
- 400 - Giỏ hàng rỗng, khoảng cách vượt giới hạn, voucher không hợp lệ, hoặc món ăn hết hàng.
- 404 - Không tìm thấy địa chỉ hoặc voucher.

---

## 7. Payments - Thanh toán

**Base Path:** `/api/payments`

**Yêu cầu xác thực:** Cần gửi JWT token trong header `Authorization: Bearer <token>`.

### 7.1 Lấy danh sách phương thức thanh toán

```
GET /api/payments
```

**Response (200):**

```json
{
  "success": true,
  "statusCode": 200,
  "message": "Lay danh sach phuong thuc thanh toan thanh cong.",
  "data": [
    {
      "id": "pm_001",
      "name": "Vi MoMo cua toi",
      "type": "momo",
      "details": "**** **** **** 1234",
      "isDefault": true,
      "cardBrand": null,
      "last4Digits": null,
      "walletBrand": "momo",
      "isLinked": true,
      "createdAt": "2026-05-26T00:00:00Z",
      "updatedAt": "2026-05-26T00:00:00Z"
    }
  ],
  "timestamp": "2026-05-28T12:00:00Z"
}
```

**Lỗi:** 401 - Chưa xác thực.

---

### 7.2 Lấy một phương thức thanh toán

```
GET /api/payments/{id}
```

**Response (200):** Trả về `PaymentResponse`. **Lỗi:** 401, 404.

---

### 7.3 Thêm phương thức thanh toán mới

```
POST /api/payments
```

**Request Body:**

```json
{
  "type": "momo",
  "name": "Vi MoMo cua toi",
  "details": "**** **** **** 1234",
  "isDefault": true
}
```

| Trường | Kiểu | Bắt buộc | Mô tả |
|--------|------|-----------|-------|
| type | String | Có | `momo`, `zalo`, `card`, `cash` |
| name | String | Có | Tên hiển thị |
| details | String | Không | Chi tiết bổ sung |
| isDefault | Boolean | Không | Đặt làm mặc định |

**Response (200):**

```json
{
  "success": true,
  "statusCode": 200,
  "message": "Them phuong thuc thanh toan thanh cong.",
  "data": { /* PaymentResponse */ },
  "timestamp": "2026-05-28T12:00:00Z"
}
```

**Lỗi:** 400 - Dữ liệu không hợp lệ hoặc loại thanh toán không hợp lệ. 401 - Chưa xác thực.

---

### 7.4 Đặt phương thức thanh toán mặc định

```
PUT /api/payments/{id}/default
```

**Response (200):**

```json
{
  "success": true,
  "statusCode": 200,
  "message": "Dat phuong thuc thanh toan mac dinh thanh cong.",
  "data": null,
  "timestamp": "2026-05-28T12:00:00Z"
}
```

**Lỗi:** 401, 404.

---

### 7.5 Xóa phương thức thanh toán

```
DELETE /api/payments/{id}
```

**Response (200):**

```json
{
  "success": true,
  "statusCode": 200,
  "message": "Xoa phuong thuc thanh toan thanh cong.",
  "data": null,
  "timestamp": "2026-05-28T12:00:00Z"
}
```

---

## 8. Addresses - Địa chỉ

**Base Path:** `/api/addresses`

### 8.1 Thêm địa chỉ mới

```
POST /api/addresses
```

**Mô tả:** Thêm một địa chỉ giao hàng mới. Nếu `isDefault = true`, hệ thống sẽ tự động bỏ mặc định các địa chỉ cũ.

**Request Body:**

```json
{
  "userId": "user_001",
  "name": "Nhà riêng",
  "address": "Ký túc xá UTC2, Quận 9, TP.HCM",
  "receiverName": "Khôi",
  "receiverPhone": "0123456789",
  "lat": 10.8455,
  "lng": 106.7939,
  "isDefault": false
}
```

**Response (200):**

```json
{
  "success": true,
  "statusCode": 200,
  "message": "Da them dia chi thanh cong.",
  "data": {
    "id": "addr_001",
    "userId": "user_001",
    "name": "Nhà riêng",
    "address": "Ký túc xá UTC2, Quận 9, TP.HCM",
    "receiverName": "Khôi",
    "receiverPhone": "0123456789",
    "lat": 10.8455,
    "lng": 106.7939,
    "isDefault": false
  },
  "timestamp": "2026-05-28T12:00:00Z"
}
```

---

### 8.2 Lấy danh sách địa chỉ

```
GET /api/addresses?userId={userId}
```

**Response (200):**

```json
{
  "success": true,
  "statusCode": 200,
  "message": "Da lay danh sach dia chi thanh cong.",
  "data": [ /* Array<Address> */ ],
  "timestamp": "2026-05-28T12:00:00Z"
}
```

---

### 8.3 Lấy thông tin một địa chỉ

```
GET /api/addresses/{id}?userId={userId}
```

**Response (200):** Trả về `Address`. **Lỗi:** 404.

---

### 8.4 Cập nhật địa chỉ

```
PUT /api/addresses/{id}
```

**Request Body:** `AddressRequest` (giống POST).

**Response (200):**

```json
{
  "success": true,
  "statusCode": 200,
  "message": "Da cap nhat dia chi thanh cong.",
  "data": { /* Address */ },
  "timestamp": "2026-05-28T12:00:00Z"
}
```

---

### 8.5 Đặt địa chỉ làm mặc định

```
PUT /api/addresses/{id}/default?userId={userId}
```

**Response (200):**

```json
{
  "success": true,
  "statusCode": 200,
  "message": "Da dat dia chi lam mac dinh thanh cong.",
  "data": null,
  "timestamp": "2026-05-28T12:00:00Z"
}
```

---

### 8.6 Xóa địa chỉ

```
DELETE /api/addresses/{id}?userId={userId}
```

**Response (200):**

```json
{
  "success": true,
  "statusCode": 200,
  "message": "Da xoa dia chi thanh cong.",
  "data": null,
  "timestamp": "2026-05-28T12:00:00Z"
}
```

---

## 9. Categories - Danh mục

**Base Path:** `/api/categories`

### 9.1 Lấy danh sách danh mục

```
GET /api/categories?storeId={storeId}
```

**Response (200):**

```json
{
  "success": true,
  "message": "Success",
  "data": [
    {
      "id": "cat_001",
      "storeId": "store_001",
      "name": "Cơm",
      "icon": "🍚",
      "order": 1,
      "imageUrl": "https://...",
      "createdAt": "2026-05-28T10:00:00",
      "updatedAt": "2026-05-28T10:00:00"
    }
  ]
}
```

---

### 9.2 Lấy danh mục theo ID

```
GET /api/categories/{id}
```

**Response (200):** Trả về `CategoryDTO`. **Lỗi:** 404.

---

### 9.3 Tạo danh mục

```
POST /api/categories
```

**Request Body:**

```json
{
  "storeId": "store_001",
  "name": "Cơm",
  "icon": "🍚",
  "order": 1,
  "imageUrl": "https://example.com/cat-com.jpg"
}
```

**Response (201):**

```json
{
  "success": true,
  "message": "Created successfully with id: cat_001",
  "data": "cat_001"
}
```

---

### 9.4 Cập nhật danh mục

```
PUT /api/categories/{id}
```

**Request Body:** `CategoryDTO`

**Response (200):**

```json
{
  "success": true,
  "message": "Updated successfully",
  "data": "2026-05-28T12:00:00Z"
}
```

---

### 9.5 Xóa danh mục

```
DELETE /api/categories/{id}
```

**Response (200):**

```json
{
  "success": true,
  "message": "Xóa thành công lúc: 2026-05-28T12:00:00Z",
  "data": null
}
```

---

## 10. Search - Tìm kiếm

**Base Path:** `/api/search`

### 10.1 Tìm kiếm món ăn và quán ăn

```
GET /api/search?query={query}&userLat={userLat}&userLng={userLng}&sortBy={sortBy}&userId={userId}
```

**Mô tả:** Tìm kiếm món ăn hoặc quán ăn theo từ khóa, lọc theo khoảng cách tối đa 10km từ vị trí người dùng, lưu lịch sử tìm kiếm và sắp xếp kết quả.

**Query Parameters:**

| Tham số | Kiểu | Bắt buộc | Mô tả |
|---------|------|-----------|-------|
| query | String | Có | Từ khóa tìm kiếm (tên món ăn hoặc tên quán ăn) |
| userLat | Double | Có | Vĩ độ của địa chỉ giao hàng |
| userLng | Double | Có | Kinh độ của địa chỉ giao hàng |
| sortBy | String | Không | `priceAsc` (giá tăng dần), `priceDesc` (giá giảm dần), `ratingDesc` (đánh giá giảm dần) |
| userId | String | Không | ID người dùng để lưu lịch sử tìm kiếm |

**Response (200):**

```json
{
  "success": true,
  "statusCode": 200,
  "message": "Tim thay 5 ket qua phu hop.",
  "data": [
    {
      "productId": "prod_001",
      "productName": "Cơm tấm sườn bì chả",
      "storeId": "store_001",
      "storeName": "Cơm Tấm Phúc Lộc Thọ",
      "price": 45000,
      "rating": 4.8,
      "reviewCount": 500,
      "distance": 2.5,
      "imageUrl": "https://..."
    }
  ],
  "timestamp": "2026-05-28T12:00:00Z"
}
```

**Lỗi:**
- 400 - Từ khóa tìm kiếm rỗng hoặc tọa độ không hợp lệ.
- 500 - Lỗi hệ thống.

---

## 11. Vouchers - Mã giảm giá

**Base Path:** `/api/vouchers`

### 11.1 Tạo voucher

```
POST /api/vouchers
```

**Request Body:**

```json
{
  "storeId": "store_001",
  "code": "GIAM50K",
  "type": 0,
  "value": 50000,
  "minOrderValue": 100000,
  "limitCount": 100,
  "usedCount": 0,
  "expiryDate": "2026-12-31T23:59:59",
  "isActive": true
}
```

| Trường | Kiểu | Bắt buộc | Mô tả |
|--------|------|-----------|-------|
| storeId | String | Có | ID cửa hàng |
| code | String | Có | Mã voucher |
| type | Integer | Có | 0 = Giảm tiền mặt, 1 = Giảm % |
| value | Double | Có | Giá trị giảm |
| minOrderValue | Double | Có | Giá trị đơn hàng tối thiểu |
| limitCount | Integer | Có | Số lượng voucher giới hạn |
| expiryDate | Date | Có | Ngày hết hạn |
| isActive | Boolean | Có | Còn hiệu lực hay không |

**Response (200):** `"2026-05-28T12:00:00Z"` (timestamp tạo thành công)

---

### 11.2 Lấy voucher theo ID

```
GET /api/vouchers/{id}
```

**Response (200):** Trả về `Voucher`. **Lỗi:** 404.

---

### 11.3 Lấy danh sách vouchers

```
GET /api/vouchers?storeId={storeId}
```

**Query Parameters:**

| Tham số | Kiểu | Bắt buộc | Mô tả |
|---------|------|-----------|-------|
| storeId | String | Không | Lọc theo cửa hàng |

**Response (200):** Trả về danh sách `Voucher`.

---

### 11.4 Cập nhật voucher

```
PUT /api/vouchers/{id}
```

**Request Body:** `VoucherDTO`

**Response (200):** `"2026-05-28T12:00:00Z"`

---

### 11.5 Xóa voucher

```
DELETE /api/vouchers/{id}
```

**Response (200):** `"Xóa thành công lúc: ..."`

---

## 12. Reviews - Đánh giá

**Base Path:** `/api/reviews`

### 12.1 Tạo đánh giá

```
POST /api/reviews
```

**Mô tả:** Cho phép khách hàng tạo đánh giá cho đơn hàng đã nhận. Chỉ cho phép đánh giá khi đơn hàng ở trạng thái Hoàn thành (status = 3). Một đơn hàng chỉ được phép đánh giá một lần.

**Request Body:**

```json
{
  "orderId": "order_001",
  "storeId": "store_001",
  "userId": "user_001",
  "userName": "Nguyễn Văn A",
  "userAvatarUrl": "https://...",
  "starRating": 5,
  "comment": "Món ăn rất ngon, giao hàng nhanh!",
  "imageUrls": ["https://..."]
}
```

| Trường | Kiểu | Bắt buộc | Mô tả |
|--------|------|-----------|-------|
| orderId | String | Có | ID đơn hàng |
| storeId | String | Có | ID cửa hàng |
| userId | String | Có | ID người dùng |
| userName | String | Có | Tên người dùng |
| userAvatarUrl | String | Không | URL avatar |
| starRating | Integer | Có | Số sao (1-5) |
| comment | String | Có | Nội dung bình luận |
| imageUrls | Array | Không | Danh sách URL ảnh |

**Response (200):**

```json
{
  "success": true,
  "statusCode": 200,
  "message": "Tao danh gia thanh cong.",
  "data": {
    "id": "review_001",
    "orderId": "order_001",
    "storeId": "store_001",
    "userId": "user_001",
    "userName": "Nguyễn Văn A",
    "userAvatarUrl": "https://...",
    "starRating": 5,
    "comment": "Món ăn rất ngon, giao hàng nhanh!",
    "imageUrls": ["https://..."],
    "createdAt": "2026-05-28T10:00:00",
    "updatedAt": "2026-05-28T10:00:00"
  },
  "timestamp": "2026-05-28T12:00:00Z"
}
```

**Lỗi:**
- 400 - Đơn hàng không cho phép đánh giá (trạng thái khác 3 hoặc đã đánh giá).
- 403 - Người dùng không phải chủ sở hữu đơn hàng.
- 404 - Không tìm thấy đơn hàng.

---

### 12.2 Lấy danh sách đánh giá theo cửa hàng

```
GET /api/reviews?storeId={storeId}
```

**Response (200):**

```json
{
  "success": true,
  "statusCode": 200,
  "message": "Lay danh sach danh gia thanh cong.",
  "data": [ /* Array<ReviewDTO> */ ],
  "timestamp": "2026-05-28T12:00:00Z"
}
```

---

## 13. Profile - Hồ sơ

**Base Path:** `/api/customers`

**Yêu cầu xác thực:** Cần gửi JWT token trong header `Authorization: Bearer <token>`.

### 13.1 Cập nhật thông tin hồ sơ

```
PUT /api/customers/profile
```

**Mô tả:** Cập nhật họ và tên và ảnh đại diện. Không cho phép thay đổi email hoặc số điện thoại tại đây.

**Request Body:**

```json
{
  "fullName": "Nguyễn Văn A Mới",
  "avatarUrl": "https://example.com/avatar/new.jpg"
}
```

| Trường | Kiểu | Bắt buộc | Mô tả |
|--------|------|-----------|-------|
| fullName | String | Không | Họ và tên (tối đa 100 ký tự) |
| avatarUrl | String | Không | URL ảnh đại diện |

**Response (200):**

```json
{
  "success": true,
  "statusCode": 200,
  "message": "Cap nhat ho so thanh cong.",
  "data": {
    "id": "user_001",
    "email": "nguoidung@gmail.com",
    "fullName": "Nguyễn Văn A Mới",
    "phoneNumber": "0123456789",
    "photoUrl": "https://example.com/avatar/new.jpg",
    "roles": [1]
  },
  "timestamp": "2026-05-28T12:00:00Z"
}
```

**Lỗi:** 400, 401, 404.

---

### 13.2 Đổi mật khẩu chủ động

```
PUT /api/customers/password
```

**Mô tả:** Đổi mật khẩu cũ sang mật khẩu mới. Yêu cầu nhập đúng mật khẩu cũ để xác nhận.

**Request Body:**

```json
{
  "oldPassword": "matkhaucu123",
  "newPassword": "matkhaumoi123"
}
```

**Response (200):**

```json
{
  "success": true,
  "statusCode": 200,
  "message": "Doi mat khau thanh cong.",
  "data": null,
  "timestamp": "2026-05-28T12:00:00Z"
}
```

**Lỗi:**
- 400 - Mật khẩu cũ không đúng.
- 401 - Chưa xác thực.
- 404 - Không tìm thấy tài khoản.

---

## 14. Firebase Dev - Dev

**Base Path:** `/api/firebase`

**Cảnh báo:** Chỉ sử dụng trong môi trường phát triển.

### 14.1 Reset Firebase data

```
POST /api/firebase/reset
```

**Mô tả:** Xóa tất cả dữ liệu hiện tại trên Firebase và seed lại từ đầu. Chỉ nên sử dụng trong môi trường dev.

**Response (200):**

```json
{
  "success": true,
  "message": "Firebase reset thanh cong"
}
```

**Lỗi (500):**

```json
{
  "success": false,
  "error": "Loi reset Firebase"
}
```

---

## Phụ lục

### A. Cấu trúc UserResponse

```json
{
  "id": "user_001",
  "email": "nguoidung@gmail.com",
  "fullName": "Nguyen Van A",
  "phoneNumber": "0123456789",
  "photoUrl": "https://example.com/avatar.jpg",
  "roles": [1]
}
```

**Roles:**
- `1` = Khách hàng
- `2` = Tài xế
- `3` = Người bán
- `4` = Admin

### B. Cấu trúc Address

```json
{
  "id": "addr_001",
  "userId": "user_001",
  "name": "Nhà riêng",
  "address": "Ký túc xá UTC2, Quận 9, TP.HCM",
  "receiverName": "Khôi",
  "receiverPhone": "0123456789",
  "lat": 10.8455,
  "lng": 106.7939,
  "isDefault": true
}
```

### C. Cấu trúc Voucher

```json
{
  "id": "voucher_001",
  "storeId": "store_001",
  "code": "GIAM50K",
  "type": 0,
  "value": 50000,
  "minOrderValue": 100000,
  "limitCount": 100,
  "usedCount": 10,
  "expiryDate": "2026-12-31T23:59:59",
  "isActive": true
}
```

### D. Mã HTTP Response phổ biến

| Mã | Mô tả |
|----|-------|
| 200 | Thành công |
| 201 | Tạo mới thành công |
| 400 | Yêu cầu không hợp lệ |
| 401 | Chưa xác thực |
| 403 | Không có quyền |
| 404 | Không tìm thấy |
| 500 | Lỗi hệ thống |

---

*Tài liệu này được tạo tự động từ mã nguồn backend BeFoodGo API. Cập nhật: 2026-05-28*

# Luồng Đăng Ký & Quên Mật Khẩu — Khách Hàng (Customer)

> **Base URL:** `http://localhost:8086/api/auth`  
> **Database:** Firebase Firestore (collection: `users`)  
> **Xác thực:** JWT (Access Token 3h, Refresh Token 30 ngày)  
> **OTP:** 6 chữ số, hiệu lực 5 phút, cooldown gửi lại 60 giây

---

## Mục lục

1. [Đăng Ký Tài Khoản](#1-đăng-ký-tài-khoản)
2. [Đăng Nhập](#2-đăng-nhập)
3. [Quên Mật Khẩu](#3-quên-mật-khẩu)
4. [Xác Thực Email (gửi lại)](#4-xác-thực-email-gửi-lại)
5. [Các Endpoint Phụ Trợ](#5-các-endpoint-hỗ-trợ)
6. [Mã Lỗi & Xử Lý](#6-mã-lỗi-và-xử-lý)
7. [Cấu Trúc Dữ Liệu](#7-cấu-trúc-dữ-liệu)

---

## 1. Đăng Ký Tài Khoản

Đăng ký gồm **2 bước**: gửi OTP xác thực email, sau đó hoàn tất tạo tài khoản.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         LUỒNG ĐĂNG KÝ KHÁCH HÀNG                          │
│                                                                         │
│  Bước 1                        Bước 2                                   │
│  ┌──────────────────┐         ┌──────────────────────────────────┐   │
│  │  POST            │         │  POST                             │   │
│  │ /register/       │  OTP    │  /register/complete               │   │
│  │ verify-email     │────────►│                                  │   │
│  └──────────────────┘         └──────────────────────────────────┘   │
│         │                              │                              │
│         │ input:                       │ input:                        │
│         │ • email                      │ • email                       │
│         │ • password                   │ • otpCode (6 chữ số)          │
│         │ • fullName                   └──────────────────────────────┘│
│         │ • phoneNumber                                                  │
│         │                                                                │
│         │  output:                                                       │
│         │  { message, expiresIn }                                        │
│         │  (OTP in email + console log)                                  │
│                                                                         │
│         ▼                                                                │
│  OTP được lưu trong bộ nhớ (ConcurrentHashMap)                          │
│  + pendingRegistration để chờ hoàn tất                                    │
└─────────────────────────────────────────────────────────────────────────┘
```

### Bước 1: Gửi OTP xác thực email

```
POST /api/auth/register/verify-email
Content-Type: application/json

{
  "email": "nguyen.van.a@example.com",
  "password": "SecurePass123",
  "fullName": "Nguyễn Văn A",
  "phoneNumber": "0912345678"
}
```

**Validation phía server:**
| Trường | Quy tắc |
|--------|---------|
| `email` | Không trống, đúng định dạng email, chưa tồn tại trong Firestore |
| `password` | Tối thiểu 6 ký tự, được mã hóa BCrypt khi lưu |
| `fullName` | Không trống |
| `phoneNumber` | Bắt đầu bằng `0`, 10–11 chữ số, chưa tồn tại |

**Response thành công (200):**

```json
{
  "success": true,
  "message": "Mã OTP đã được gửi đến email của bạn. Vui lòng kiểm tra hộp thư.",
  "expiresIn": 300
}
```

**Response lỗi (400/409):**

```json
{
  "success": false,
  "message": "Email đã được sử dụng"
}
```

### Bước 1.5: Gửi lại OTP (tùy chọn)

```
POST /api/auth/register/resend-otp
Content-Type: application/json

{
  "email": "nguyen.van.a@example.com"
}
```

> Chỉ gửi được khi đã qua bước 1 và chưa hoàn tất đăng ký.  
> Cooldown: **60 giây** giữa các lần gửi.

### Bước 2: Hoàn tất đăng ký

```
POST /api/auth/register/complete
Content-Type: application/json

{
  "email": "nguyen.van.a@example.com",
  "otpCode": "123456"
}
```

**Xử lý phía server:**

1. Kiểm tra OTP còn hiệu lực (5 phút) và khớp với email
2. Tạo document mới trong Firestore collection `users`:
   - `id`: `user_001`, `user_002`, ...
   - `email`, `password` (BCrypt), `fullName`, `phoneNumber`
   - `roles`: `[1]` — Customer
   - `isEmailVerified`: `true`
   - `isActive`: `true`
   - `createdAt`, `updatedAt`
3. Sinh JWT Access Token + Refresh Token
4. Xóa OTP và pendingRegistration khỏi bộ nhớ

**Response thành công (200):**

```json
{
  "success": true,
  "message": "Đăng ký thành công",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiJ9...",
    "tokenType": "Bearer",
    "expiresIn": 10800000,
    "refreshToken": "eyJhbGciOiJIUzI1NiJ9...",
    "refreshExpiresIn": 2592000000,
    "user": {
      "id": "user_001",
      "email": "nguyen.van.a@example.com",
      "fullName": "Nguyễn Văn A",
      "phoneNumber": "0912345678",
      "roles": [1],
      "isEmailVerified": true,
      "isActive": true
    }
  }
}
```

**Lưu ý:** Tài khoản có `isEmailVerified = true` ngay khi đăng ký thành công (vì đã xác thực qua OTP). Không cần bước xác thực email riêng sau đăng ký.

---

## 2. Đăng Nhập

```
┌─────────────────────────────────────────────────────────────────────────┐
│                            LUỒNG ĐĂNG NHẬP                               │
│                                                                         │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │  POST /api/auth/login                                            │  │
│  │                                                                  │  │
│  │  input:                                                          │  │
│  │  { "email", "password" }                                          │  │
│  │                                                                  │  │
│  │  server:                                                         │  │
│  │  1. Tìm user theo email trong Firestore                          │  │
│  │  2. Kiểm tra mật khẩu (BCrypt)                                  │  │
│  │  3. Kiểm tra isEmailVerified == true                             │  │
│  │  4. Sinh JWT + Refresh Token                                      │  │
│  │                                                                  │  │
│  │  output: AuthResponse (token + user info)                         │  │
│  └──────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────┘
```

```
POST /api/auth/login
Content-Type: application/json

{
  "email": "nguyen.van.a@example.com",
  "password": "SecurePass123"
}
```

**Điều kiện đăng nhập thành công:**
- Email tồn tại trong Firestore
- Mật khẩu khớp (BCrypt)
- `isEmailVerified == true`

**Response thành công:** Cùng format `AuthResponse` như bước 2 đăng ký.

---

## 3. Quên Mật Khẩu

Quên mật khẩu gồm **3 bước**: gửi OTP, xác thực OTP, đặt lại mật khẩu mới.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        LUỒNG QUÊN MẬT KHẨU                              │
│                                                                         │
│  Bước 1                    Bước 2                      Bước 3           │
│  ┌──────────────┐         ┌────────────────┐         ┌─────────────┐  │
│  │  POST        │  OTP    │  POST          │ temp    │  POST       │  │
│  │  /send-otp   │────────►│  /verify-otp   │ token   │  /reset-    │  │
│  │              │         │                │────────►│  password  │  │
│  └──────────────┘         └────────────────┘         └─────────────┘  │
│         │                         │                        │          │
│         │ input:                  │ input:                 │ input:   │
│         │ • emailOrPhone          │ • emailOrPhone         │ • tempToken
│         │                         │ • otpCode              │ • newPassword
│         │ output:                 │                        │          │
│         │ { message,             │ output:                │ output:  │
│         │   expiresIn }          │ { tempToken,           │ { success
│         │                        │   expiresIn }          │   message }
│         │                        │                        │          │
│         │  OTP in email          │  tempToken: 5 phút     │  Password
│         │  (console log dev)     │  validity              │  updated
└─────────────────────────────────────────────────────────────────────────┘
```

### Bước 1: Gửi OTP đặt lại mật khẩu

```
POST /api/auth/send-otp
Content-Type: application/json

{
  "emailOrPhone": "nguyen.van.a@example.com"
}
```

**Validation:**
- Tài khoản phải tồn tại (theo email hoặc số điện thoại) trong Firestore
- Gửi mã OTP qua email

**Response thành công:**

```json
{
  "success": true,
  "message": "Mã OTP đã được gửi đến email của bạn.",
  "expiresIn": 300
}
```

### Bước 2: Xác thực OTP

```
POST /api/auth/verify-otp
Content-Type: application/json

{
  "emailOrPhone": "nguyen.van.a@example.com",
  "otpCode": "123456"
}
```

**Xử lý phía server:**

1. Kiểm tra OTP còn hiệu lực (5 phút) và khớp
2. Sinh `tempToken` — token tạm thời chỉ dùng để đặt lại mật khẩu
3. `tempToken` có hiệu lực **5 phút**

**Response thành công:**

```json
{
  "success": true,
  "message": "Xác thực OTP thành công.",
  "tempToken": "eyJhbGciOiJIUzI1NiJ9...",
  "expiresIn": 300000
}
```

### Bước 3: Đặt lại mật khẩu mới

```
POST /api/auth/reset-password
Content-Type: application/json

{
  "tempToken": "eyJhbGciOiJIUzI1NiJ9...",
  "newPassword": "NewSecurePass456"
}
```

**Xử lý phía server:**

1. Giải mã và xác thực `tempToken`
2. Kiểm tra `tempToken` chưa hết hạn (5 phút)
3. Cập nhật mật khẩu mới (BCrypt) cho user trong Firestore
4. Xóa OTP khỏi bộ nhớ

**Response thành công:**

```json
{
  "success": true,
  "message": "Mật khẩu đã được đặt lại thành công."
}
```

### Bước 3.5: Gửi lại OTP (tùy chọn)

```
POST /api/auth/resend-otp
Content-Type: application/json

{
  "emailOrPhone": "nguyen.van.a@example.com"
}
```

> Cooldown: **60 giây**.  
> Trong môi trường dev, OTP luôn được in ra console.

---

## 4. Xác Thực Email (gửi lại)

Dùng cho trường hợp user đã có tài khoản nhưng chưa xác thực email (hoặc muốn xác thực lại).

### Bước 1: Gửi OTP xác thực

```
POST /api/auth/send-verify-email-otp
Content-Type: application/json

{
  "email": "nguyen.van.a@example.com"
}
```

### Bước 2: Xác thực OTP

```
POST /api/auth/verify-email
Content-Type: application/json

{
  "email": "nguyen.van.a@example.com",
  "otpCode": "123456"
}
```

**Xử lý:** Cập nhật `isEmailVerified = true` trong Firestore cho user tương ứng.

---

## 5. Các Endpoint Hỗ Trợ

| Method | Endpoint | Mô tả | Auth |
|--------|----------|--------|------|
| `POST` | `/api/auth/refresh-token` | Làm mới JWT | Refresh Token |
| `POST` | `/api/auth/logout` | Đăng xuất (thu hồi refresh token) | Access Token |
| `GET` | `/api/auth/me` | Lấy thông tin user hiện tại | Access Token |
| `POST` | `/api/auth/fcm-token` | Lưu FCM token cho push notification | Access Token |

---

## 6. Mã Lỗi và Xử Lý

| HTTP Code | Scenario | Response |
|-----------|----------|----------|
| 400 | Thiếu hoặc sai định dạng trường | `{ "success": false, "message": "..." }` |
| 401 | Sai mật khẩu / Token hết hạn | `{ "success": false, "message": "Sai mật khẩu" }` |
| 404 | Email/số điện thoại chưa đăng ký | `{ "success": false, "message": "Tài khoản không tồn tại" }` |
| 409 | Email/số điện thoại đã tồn tại | `{ "success": false, "message": "Email đã được sử dụng" }` |
| 410 | OTP hết hạn | `{ "success": false, "message": "Mã OTP đã hết hạn" }` |
| 429 | Gửi OTP quá nhanh (cooldown) | `{ "success": false, "message": "Vui lòng chờ 60 giây trước khi gửi lại" }` |
| 403 | Email chưa xác thực khi đăng nhập | `{ "success": false, "message": "Vui lòng xác thực email trước khi đăng nhập" }` |

---

## 7. Cấu Trúc Dữ Liệu

### 7.1. User Document (Firestore: `users`)

```json
{
  "id": "user_001",
  "email": "nguyen.van.a@example.com",
  "password": "$2a$10$...",        // BCrypt hash
  "fullName": "Nguyễn Văn A",
  "phoneNumber": "0912345678",
  "photoUrl": null,
  "roles": [1],                    // 1 = Customer, 2 = Driver, 3 = Merchant, 4 = Admin
  "isEmailVerified": true,
  "isActive": true,
  "createdAt": "2026-06-04T12:00:00",
  "updatedAt": "2026-06-04T12:00:00"
}
```

### 7.2. OTP Storage (In-Memory)

OTP được lưu trong `ConcurrentHashMap` với cấu trúc:

```java
// Key: email hoặc "phone:" + số điện thoại
// Value:
{
  "code": "123456",
  "userId": "user_001",        // null khi đăng ký
  "expiresAt": 1751653200000L, // timestamp ms
  "createdAt": 1751652900000L
}
```

### 7.3. Pending Registration (In-Memory)

```json
{
  "email": "nguyen.van.a@example.com",
  "password": "$2a$10$...",
  "fullName": "Nguyễn Văn A",
  "phoneNumber": "0912345678",
  "createdAt": 1751652900000L
}
```

### 7.4. JWT Token Claims

**Access Token (3 giờ):**

```json
{
  "sub": "user_001",
  "roles": [1],
  "iat": 1751652900,
  "exp": 1751663700
}
```

**Refresh Token (30 ngày):**

```json
{
  "sub": "user_001",
  "type": "refresh",
  "iat": 1751652900,
  "exp": 1751912100
}
```

---

## 8. So Sánh: Đăng Ký vs Quên Mật Khẩu

| Tiêu chí | Đăng Ký | Quên Mật Khẩu |
|----------|---------|----------------|
| Số bước | 2 | 3 |
| Bước 1 | Gửi OTP + thông tin đăng ký | Gửi OTP |
| Bước 2 | Xác thực OTP → tạo tài khoản | Xác thực OTP → nhận tempToken |
| Bước 3 | — | Đặt mật khẩu mới bằng tempToken |
| OTP lưu kèm | PendingRegistration (thông tin tài khoản) | userId từ Firestore |
| Kết quả | Tạo document `users` mới | Cập nhật `password` của document có sẵn |
| Tài khoản mới | `isEmailVerified = true` ngay | Giữ nguyên `isEmailVerified` |

---

## 9. Email Template

### Đăng ký — Mã xác thực email

```
Subject: Ma xac thuc email - FoodGo
```

Nội dung: Mã 6 chữ số, thiết kế giao diện FoodGo (màu cam).

### Quên mật khẩu — Mã xác thực đặt lại

```
Subject: Ma xac thuc dat lai mat khau - FoodGo
```

Nội dung: Cảnh báo bảo mật + mã 6 chữ số, thiết kế giao diện FoodGo.

> **Dev mode:** OTP luôn được in ra console (Log), bất kể email có gửi thành công hay không.

---

*Document tạo ngày: 2026-06-04*

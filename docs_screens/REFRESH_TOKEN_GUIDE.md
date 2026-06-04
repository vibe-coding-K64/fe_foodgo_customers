# Hướng dẫn Frontend tích hợp Refresh Token

## 1. Cách hoạt động

Backend sử dụng cặp **Access Token** và **Refresh Token**:

```
Access Token:  JwtTokenProvider tạo, expiry 3 giờ → dùng để gọi API
Refresh Token: JwtTokenProvider tạo, expiry 30 ngày → dùng để lấy access token mới khi hết hạn
```

### Token Flow

```
1. Login: POST /api/auth/login
   - Receives: { token, expiresIn, refreshToken, refreshExpiresIn, user }
   - Store: token + refreshToken

2. API Call: Authorization: Bearer <token>

3. If 401 response (token expired):
   - POST /api/auth/refresh-token
     Body: { "refreshToken": "<stored-refresh-token>" }
   - Receives: { token, expiresIn, refreshToken, refreshExpiresIn }
   - Replace stored tokens with new ones

4. Logout: POST /api/auth/logout
   Headers: Authorization: Bearer <token>
   Body: { "refreshToken": "<stored-refresh-token>" }
   - Both tokens are revoked server-side
```

## 2. Chi tiết Token

**Access Token** được gửi ở header:
```
Authorization: Bearer <access_token>
```

**Refresh Token** được gửi trong body request khi refresh:
```json
POST /api/auth/refresh-token
Body: { "refreshToken": "<refresh_token>" }
```

### Token Specification

| Thuộc tính | Access Token | Refresh Token |
|------------|-------------|---------------|
| JWT `type` claim | `"ACCESS_TOKEN"` | `"REFRESH_TOKEN"` |
| Expiry | 3 giờ (10800000 ms) | 30 ngày (2592000000 ms) |
| Mục đích | API authorization | Lấy access token mới |
| Nơi gửi | Header `Authorization` | Request body |
| Nơi lưu | Frontend memory/state | Secure storage |

### Refresh Response Format

```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",       // New access token
  "tokenType": "Bearer",
  "expiresIn": 10800000,                      // 3 hours in ms
  "refreshToken": "eyJhbGciOiJIUzI1NiJ9...", // New refresh token
  "refreshExpiresIn": 2592000000              // 30 days in ms
}
```

### Error Response (400)

```json
{
  "success": false,
  "message": "Refresh token khong hop le hoac da bi thu hoi.",
  "code": 400,
  "data": null
}
```

## 3. Cấu trúc code frontend (React + Axios)

### a) Token Service (lưu trữ)

```typescript
// services/tokenService.ts

const ACCESS_TOKEN_KEY = 'foodgo_access_token';
const REFRESH_TOKEN_KEY = 'foodgo_refresh_token';

// Lưu tokens
export const setTokens = (accessToken: string, refreshToken: string) => {
  localStorage.setItem(ACCESS_TOKEN_KEY, accessToken);
  localStorage.setItem(REFRESH_TOKEN_KEY, refreshToken);
};

// Đọc access token
export const getAccessToken = () => localStorage.getItem(ACCESS_TOKEN_KEY);

// Đọc refresh token
export const getRefreshToken = () => localStorage.getItem(REFRESH_TOKEN_KEY);

// Xoá tokens (logout)
export const clearTokens = () => {
  localStorage.removeItem(ACCESS_TOKEN_KEY);
  localStorage.removeItem(REFRESH_TOKEN_KEY);
};
```

### b) Auth Service (API)

```typescript
// services/authService.ts
import { setTokens, getAccessToken, getRefreshToken, clearTokens } from './tokenService';

const API_BASE = 'http://localhost:8080/api';

// --- LOGIN ---
export const login = async (email: string, password: string) => {
  const res = await fetch(`${API_BASE}/auth/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email, password }),
  });

  const data = await res.json();

  if (!res.ok) {
    throw new Error(data.message || 'Login failed');
  }

  // Lưu cả access token và refresh token
  setTokens(data.token, data.refreshToken);

  return data; // { token, refreshToken, expiresIn, refreshExpiresIn, user }
};

// --- REFRESH TOKEN ---
export const refreshAccessToken = async () => {
  const refreshToken = getRefreshToken();
  if (!refreshToken) {
    throw new Error('No refresh token');
  }

  const res = await fetch(`${API_BASE}/auth/refresh-token`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ refreshToken }),
  });

  const data = await res.json();

  if (!res.ok) {
    // Refresh token hết hạn hoặc bị revoke → logout
    clearTokens();
    window.location.href = '/login';
    throw new Error(data.message || 'Refresh token expired');
  }

  // Lưu tokens mới
  setTokens(data.token, data.refreshToken);
  return data; // { token, refreshToken, expiresIn, refreshExpiresIn }
};

// --- LOGOUT ---
export const logout = async () => {
  const accessToken = getAccessToken();

  await fetch(`${API_BASE}/auth/logout`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${accessToken}`,
    },
    body: JSON.stringify({ refreshToken: getRefreshToken() }),
  });

  clearTokens();
};

// --- Lấy thông tin user hiện tại ---
export const getMe = async () => {
  const res = await fetch(`${API_BASE}/auth/me`, {
    headers: { Authorization: `Bearer ${getAccessToken()}` },
  });
  return res.json();
};
```

### c) Axios Interceptor (Tự động refresh khi 401)

```typescript
// services/apiClient.ts
import axios from 'axios';
import { getAccessToken, getRefreshToken, setTokens, clearTokens } from './tokenService';

const api = axios.create({
  baseURL: 'http://localhost:8080/api',
  headers: { 'Content-Type': 'application/json' },
});

// Bước 1: Thêm access token vào mọi request
api.interceptors.request.use((config) => {
  const token = getAccessToken();
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Bước 2: Bắt 401 → refresh token → thử lại request
api.interceptors.response.use(
  (response) => response,
  async (error) => {
    const originalRequest = error.config;

    // Nếu nhận 401 và chưa từng thử refresh
    if (error.response?.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true;

      const refreshToken = getRefreshToken();
      if (!refreshToken) {
        clearTokens();
        window.location.href = '/login';
        return Promise.reject(error);
      }

      try {
        // Gọi refresh endpoint
        const res = await axios.post(
          `${api.defaults.baseURL}/auth/refresh-token`,
          { refreshToken }
        );

        const { token, refreshToken: newRefreshToken } = res.data;

        // Lưu tokens mới
        setTokens(token, newRefreshToken);

        // Thử lại request ban đầu với token mới
        originalRequest.headers.Authorization = `Bearer ${token}`;
        return api(originalRequest);

      } catch (refreshError) {
        clearTokens();
        window.location.href = '/login';
        return Promise.reject(refreshError);
      }
    }

    return Promise.reject(error);
  }
);

export default api;
```

## 4. Cách sử dụng trong component

```tsx
import api from './services/apiClient';
import { login, logout } from './services/authService';

// Login
const handleLogin = async () => {
  try {
    const user = await login('email@example.com', 'password123');
    console.log(user.user); // thông tin user
    navigate('/dashboard');
  } catch (error) {
    console.error('Login failed:', error);
  }
};

// Gọi API (tự động refresh nếu 401)
const fetchOrders = async () => {
  try {
    const res = await api.get('/orders');
    return res.data;
  } catch (error) {
    console.error('Failed to fetch orders:', error);
  }
};

// Logout
const handleLogout = async () => {
  await logout();
  navigate('/login');
};
```

## 5. Lưu ý quan trọng

### 5.1. Bảo mật

- **localStorage**: Refresh token được lưu trong localStorage. Đây là cách phổ biến nhưng có rủi ro XSS. Nếu ứng dụng có nguy cơ XSS cao, nên dùng `httpOnly cookie` thay thế.
- **CORS**: Backend đã mở CORS cho mọi origin (`*`), nên frontend không cần cấu hình thêm ở backend.

### 5.2. Refresh Token mới

Backend **revoke token cũ** và trả về **cặp token mới**. Luôn cập nhật cả access token và refresh token trong localStorage.

### 5.3. Refresh token bị revoke

Khi backend trả về **400** với message "Refresh token khong hop le hoac da bi thu hoi", nghĩa là:
- Token đã bị thu hồi (logout từ thiết bị khác)
- Token đã hết hạn

→ Xoá session và chuyển user về trang login.

### 5.4. Tránh infinite loop

Interceptor dùng flag `_retry` trên `originalRequest` để đảm bảo chỉ refresh **một lần duy nhất** mỗi request. Nếu refresh thất bại, chuyển thẳng sang logout.

## 6. API Endpoints Reference

| Endpoint | Method | Auth | Body | Mô tả |
|----------|--------|------|------|-------|
| `/api/auth/login` | POST | No | `{ email, password }` | Đăng nhập, trả về cặp token |
| `/api/auth/refresh-token` | POST | No | `{ refreshToken }` | Refresh access token |
| `/api/auth/logout` | POST | Optional | `{ refreshToken }` | Revoke tokens |
| `/api/auth/me` | GET | Yes | - | Lấy thông tin user hiện tại |

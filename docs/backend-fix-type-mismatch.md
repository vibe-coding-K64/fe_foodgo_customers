# Hướng dẫn sửa lỗi Type Mismatch ở API Search

## Mô tả lỗi

```
type 'String' is not a subtype of type 'num?' in type cast
```

Frontend (Flutter app) nhận được lỗi khi gọi API `/api/search`.

## Nguyên nhân

Backend trả về các trường số (`numeric`) dưới dạng **chuỗi String** thay vì **số nguyên/r thực** trong JSON response.

**Sai (String):**
```json
{
  "price": "45000",
  "rating": "4.5",
  "reviewCount": "120",
  "distance": "2.1",
  "deliveryTime": "25"
}
```

**Đúng (Number):**
```json
{
  "price": 45000,
  "rating": 4.5,
  "reviewCount": 120,
  "distance": 2.1,
  "deliveryTime": 25
}
```

## Các API bị ảnh hưởng

### 1. `GET /api/search` (Tìm kiếm sản phẩm)

Response trong trường `data[]` chứa các trường sau - tất cả phải là **number**:

| Trường | Kiểu hiện tại (sai) | Kiểu phải trả về | Mô tả |
|--------|---------------------|------------------|-------|
| `price` | `String` | `Number` (float) | Giá sản phẩm |
| `rating` | `String` | `Number` (float) | Điểm đánh giá (0-5) |
| `reviewCount` | `String` | `Number` (int) | Số lượng đánh giá |
| `distance` | `String` | `Number` (float) | Khoảng cách (km) |
| `deliveryTime` | `String` | `Number` (int) | Thời gian giao (phút) |

**Ví dụ response đúng:**

```json
{
  "success": true,
  "data": [
    {
      "productId": "prod_001",
      "productName": "Trà sữa Trân Châu Đường Đen",
      "storeId": "store_001",
      "storeName": "Gong Cha",
      "address": "123 Nguyễn Trãi, Q1, TP.HCM",
      "price": 45000,
      "rating": 4.8,
      "reviewCount": 256,
      "distance": 1.2,
      "deliveryTime": 20,
      "imageUrl": "https://...",
      "isOutOfStock": false,
      "optionGroups": []
    }
  ]
}
```

### 2. `GET /api/products/featured` (Sản phẩm nổi bật)

Tương tự, các trường trong `store` và `products[]` cũng phải là number:

| Trường | Kiểu phải trả về | Mô tả |
|--------|------------------|-------|
| `basePrice` hoặc `price` | `Number` (float) | Giá sản phẩm |
| `rating` | `Number` (float) | Điểm đánh giá |
| `deliveryFee` | `Number` (float) | Phí giao hàng |
| `distance` | `Number` (float) | Khoảng cách |

### 3. `GET /api/products/{id}` (Chi tiết sản phẩm)

Trong `optionGroups[].options[]`:

| Trường | Kiểu phải trả về | Mô tả |
|--------|------------------|-------|
| `price` | `Number` (float) | Giá option (size/topping) |

## Tổng kết danh sách trường cần sửa

Tất cả các trường sau trong **toàn bộ API** phải trả về kiểu **Number**, không phải String:

- `price` (sản phẩm, option)
- `basePrice`
- `rating`
- `reviewCount`
- `review_count`
- `distance`
- `deliveryTime`
- `delivery_time`
- `deliveryFee`
- `delivery_fee`
- `lat`
- `lng`
- `sales`
- `isRequired` → phải là `Boolean`, không phải String `"true"`/`"false"`

## Cách kiểm tra nhanh

Chạy lệnh sau để kiểm tra response của API:

```bash
curl -X GET "https://be-foodgo.canluaz.io.vn/api/search?query=tra%20sua&userLat=10.85&userLng=106.79" \
  -H "Authorization: Bearer <token>" | jq '.data[0] | keys'
```

Sau đó kiểm tra kiểu dữ liệu:

```bash
curl ... | jq '.data[0].price | type'
```

Kết quả phải là `"number"`, không phải `"string"`.

## Lưu ý quan trọng

1. **Không wrap number trong ngoặc kép** khi trả về JSON từ database
2. **Kiểm tra tất cả các endpoint** vì nhiều API có thể bị ảnh hưởng tương tự
3. **Test cả các trường hợp null** - các trường không bắt buộc nên trả về `null` hoặc không có trường đó, không phải chuỗi rỗng `""` cho giá trị số

## Liên hệ

Nếu có thắc mắc, liên hệ team Mobile (Flutter) để được hỗ trợ thêm.

# Backend Task: Thêm `optionGroups` vào API Search

> **Ngày:** 28/05/2026

---

## Mô tả

API `GET /api/search` hiện tại không trả về `optionGroups` trong response. Khiến trang kết quả tìm kiếm không hiển thị được thông tin topping/size, và không mở được bottom sheet chọn tùy chọn.

---

## Yêu cầu

### 1. Sửa API response

Thêm `optionGroups` vào mỗi item trong `data[]` của `GET /api/search`:

```json
{
  "success": true,
  "code": 200,
  "message": "Tim thay 3 ket qua phu hop.",
  "data": [
    {
      "productId": "prod_004",
      "productName": "Tra sua tran chau",
      "storeId": "store_002",
      "storeName": "Tra sua Tocotoco",
      "price": 25000.0,
      "rating": 4.5,
      "reviewCount": 120,
      "distance": 1.2,
      "imageUrl": "https://...",
      "isOutOfStock": false,
      "optionGroups": [
        {
          "name": "Kich thuoc",
          "isSingleSelect": true,
          "isRequired": true,
          "options": [
            { "name": "Vua",  "price": 0.0 },
            { "name": "Lon",  "price": 10000.0 }
          ]
        },
        {
          "name": "Topping",
          "isSingleSelect": false,
          "isRequired": false,
          "options": [
            { "name": "Tran chau",  "price": 5000.0 },
            { "name": "Thach",       "price": 3000.0 },
            { "name": "Pudding",     "price": 5000.0 }
          ]
        }
      ]
    }
  ]
}
```

### 2. Java Model

**`SearchResultDTO.java`** (hoặc tương tự — class trả về cho API search) cần thêm field `optionGroups`:

```java
public class SearchResultDTO {
    private String productId;
    private String productName;
    // ... các field hiện tại ...
    private List<OptionGroupDTO> optionGroups;  // ← THÊM
}
```

**`OptionGroupDTO.java`** (tái sử dụng từ `FeaturedProductResponse`):

```java
public class OptionGroupDTO {
    private String name;
    private Boolean isSingleSelect;   // Boolean wrapper
    private Boolean isRequired;        // Boolean wrapper
    private List<OptionDTO> options;
}
```

### 3. Logic khi build kết quả

Khi query Firestore `products`, join thêm `optionGroups` từ document gốc:

```
Firestore: products/{productId}
  -> Lấy field: optionGroups[]
  -> Map sang OptionGroupDTO
  -> Gắn vào SearchResultDTO
```

### 4. Lưu ý quan trọng

- **`optionGroups` phải là `null` hoặc mảng rỗng `[]`** nếu sản phẩm không có tùy chọn — KHÔNG omit field
- Frontend check `item.optionGroups.isNotEmpty` để quyết định mở bottom sheet
- Nếu không muốn sửa API, có thể thêm endpoint riêng `GET /api/products/{productId}/options` và frontend gọi thêm khi tap sản phẩm từ trang search

---

## Kiểm tra

- [ ] API `GET /api/search` trả về `optionGroups` đầy đủ cho mỗi sản phẩm
- [ ] `isSingleSelect` đúng: `true` cho "Kich thuoc", `false` cho "Topping"
- [ ] Sản phẩm không có tùy chọn trả về `optionGroups: []`
- [ ] Frontend (Flutter) nhận đúng `optionGroups` và mở bottom sheet khi tap sản phẩm từ trang search

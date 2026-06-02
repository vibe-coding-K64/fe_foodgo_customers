# API: Xem Danh Gia Quan An (Chi doc)

## Muc tieu

Trang "Danh gia quan an" chi yeu cau **xem danh sach danh gia** cua mot quan an/cua hang. Nguoi dung khong the tao danh gia moi tu trang nay.

---

## Endpoint

```
GET /reviews
```

---

## Query Parameters

| Tham so | Kieu | Bat buoc | Mo ta |
|---|---|---|---|
| `storeId` | String | ✅ | ID cua hang/quan an |

---

## Request Header

```
GET /reviews?storeId=store_xyz789
Content-Type: application/json
Authorization: Bearer <token>
```

---

## Response Thanh Cong

```json
HTTP 200
Content-Type: application/json

{
  "success": true,
  "message": "Lay danh sach danh gia thanh cong",
  "data": [
    {
      "id": "review_001",
      "orderId": "order_abc123",
      "storeId": "store_xyz789",
      "userId": "user_001",
      "userName": "Nguyen Van A",
      "userAvatarUrl": "https://cdn.foodgo.com/avatars/user_001.jpg",
      "starRating": 5,
      "comment": "Quan an ngon, gia ca phai chang, phuc vu tot",
      "imageUrls": [
        "https://storage.foodgo.com/reviews/review_001_img1.jpg",
        "https://storage.foodgo.com/reviews/review_001_img2.jpg"
      ],
      "createdAt": "2026-05-28T14:30:00.000Z",
      "updatedAt": "2026-05-28T14:30:00.000Z"
    },
    {
      "id": "review_002",
      "orderId": "order_def456",
      "storeId": "store_xyz789",
      "userId": "user_002",
      "userName": "Tran Thi B",
      "userAvatarUrl": "",
      "starRating": 4,
      "comment": "Mon an kha ngon, giao hang dung gio",
      "imageUrls": [],
      "createdAt": "2026-05-27T10:15:00.000Z",
      "updatedAt": "2026-05-27T10:15:00.000Z"
    },
    {
      "id": "review_003",
      "orderId": "order_ghi789",
      "storeId": "store_xyz789",
      "userId": "user_003",
      "userName": "Le Van C",
      "userAvatarUrl": "https://cdn.foodgo.com/avatars/user_003.png",
      "starRating": 3,
      "comment": "",
      "imageUrls": [
        "https://storage.foodgo.com/reviews/review_003_img1.jpg"
      ],
      "createdAt": "2026-05-25T19:45:00.000Z",
      "updatedAt": "2026-05-25T19:45:00.000Z"
    },
    {
      "id": "review_004",
      "orderId": "order_jkl012",
      "storeId": "store_xyz789",
      "userId": "user_004",
      "userName": "Pham Van D",
      "userAvatarUrl": null,
      "starRating": 2,
      "comment": null,
      "imageUrls": [],
      "createdAt": "2026-05-24T08:00:00.000Z",
      "updatedAt": "2026-05-24T08:00:00.000Z"
    }
  ]
}
```

### Mo ta cac field trong data (data la mot Array)

| Field | Kieu | Mo ta | Xu ly frontend |
|---|---|---|---|
| `id` | String | ID danh gia | Hien thi hoac map item |
| `orderId` | String? | ID don hang (optional) | Khong hien thi tren UI |
| `storeId` | String | ID cua hang/quan an | Khong hien thi tren UI |
| `userId` | String | ID nguoi dung | Khong hien thi tren UI |
| `userName` | String | Ten nguoi danh gia | Hien thi o header item |
| `userAvatarUrl` | String? | URL avatar | Neu rong/null -> hien thi icon person mac dinh |
| `starRating` | Integer | So sao (1 - 5) | Hien thi 5 icon star |
| `comment` | String? | Noi dung binh luan | Neu rong/null -> hien thi "(Khong co binh luan)" |
| `imageUrls` | Array\<String\> | DS URL hinh anh | Neu rong -> khong hien thi khoi hinh anh |
| `createdAt` | String (ISO 8601) | Thoi gian tao | Format HH:mm - DD/MM/YYYY |
| `updatedAt` | String (ISO 8601) | Thoi gian cap nhat | Khong hien thi tren UI |

---

## Response Loi

### 400 - Bad Request

```json
HTTP 400
Content-Type: application/json

{
  "success": false,
  "message": "storeId la thong so bat buoc"
}
```

### 404 - Cua hang khong ton tai

```json
HTTP 404
Content-Type: application/json

{
  "success": false,
  "message": "Cua hang khong ton tai"
}
```

### 500 - Loi server

```json
HTTP 500
Content-Type: application/json

{
  "success": false,
  "message": "Da xay ra loi tren server. Vui long thu lai sau."
}
```

---

## Aliases - Backend co the tra ve cac ten truong khac

Frontend ho tro nhieu ten truong khac nhau:

| Truong chinh | Alias 1 | Alias 2 | Alias 3 |
|---|---|---|---|
| `userAvatarUrl` | `avatarUrl` | `avatar` | - |
| `imageUrls` | `reviewImages` | `images` | - |

Backend co the tra bat ky alias nao, frontend tu dong nhan dien.

---

## Map JSON -> ReviewModel (Dart)

```dart
ReviewModel.fromJson(json)
```

```dart
ReviewModel({
  id:            json['id']               ?? '',
  orderId:       json['orderId'],              // optional
  storeId:       json['storeId']          ?? '',
  userId:        json['userId']           ?? '',
  userName:      json['userName']          ?? '',
  userAvatarUrl: json['userAvatarUrl']     ?? json['avatarUrl'] ?? json['avatar'] ?? '',
  starRating:    json['starRating']        ?? 0,
  comment:       json['comment'],                // optional
  imageUrls:     json['imageUrls']          ?? json['reviewImages'] ?? json['images'] ?? [],
  createdAt:     DateTime.parse(json['createdAt']),
  updatedAt:     DateTime.parse(json['updatedAt']),
})
```

---

## Map ReviewModel -> Widget

| ReviewModel | Widget | Vi tri |
|---|---|---|
| `starRating` | So sao trung binh (dong `averageRating.toStringAsFixed(1)`) | Header, ben trai |
| `distribution.total` | "X danh gia" | Header, phia duoi label "Sao" |
| `distribution` | Pie Chart + thanh tien trinh | Header, ben phai |
| `userName` | Text (bold) | Item header |
| `createdAt` | "HH:mm - DD/MM/YYYY" | Item header, phia duoi ten |
| `starRating` | 5 icon star (vang/xam) | Item header, ben phai |
| `comment` | Text hoac "(Khong co binh luan)" | Item body |
| `imageUrls` | Wrap grid (80x80, boi tron 8px) | Item body, phia duoi comment |

---

## Lich su phien ban

| Phien ban | Ngay | Mo ta |
|---|---|---|
| 1.0 | 2026-06-02 | Phien ban dau tien |

---

## Ghi chu

- Trang nay **chi doc**, khong co request POST/PUT/DELETE nao.
- Danh sach tra ve **sap xep theo thoi gian tao** (moi nhat truoc, cu nhat sau) - do backend quyet dinh.
- Backend co the phan trang bang cach them tham so `page` va `limit` (neu can).
- `imageUrls` co the tra ve cac truong ten khac nhu `reviewImages` hoac `images`.
- `userAvatarUrl` co the tra ve `null`, `""`, hoac URL that - da xu ly trong `fromJson`.
- `comment` co the tra ve `null` hoac `""` - hien thi "(Khong co binh luận)".

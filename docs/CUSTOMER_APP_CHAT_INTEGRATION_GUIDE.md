# Chat Customer - Hướng Dẫn Tích Hợp

## API Endpoints (Backend)

Base URL: `/api/chat`

### `GET /conversations`

Lấy danh sách cuộc trò chuyện của user hiện tại.

Response:

```json
{
  "content": [
    {
      "id": "abc123",
      "orderId": "order_001",
      "customerId": "uid_1",
      "customerName": "Nguyen Van A",
      "driverId": "uid_2",
      "driverName": "Tran Van B",
      "lastMessage": "Toi dang o diem A",
      "lastMessageAt": 1750612800000,
      "unreadCustomer": 2,
      "unreadDriver": 0,
      "status": "active",
      "createdAt": 1750600000000,
      "updatedAt": 1750612800000
    }
  ]
}
```

### `GET /conversations/order/{orderId}`

Lấy hoặc tạo cuộc trò chuyện cho đơn hàng.

Response:

```json
{
  "content": {
    "id": "abc123",
    "orderId": "order_001",
    "customerId": "uid_1",
    "customerName": "Nguyen Van A",
    "driverId": "uid_2",
    "driverName": "Tran Van B",
    "lastMessage": "",
    "lastMessageAt": 1750612800000,
    "unreadCustomer": 0,
    "unreadDriver": 0,
    "status": "active",
    "createdAt": 1750600000000,
    "updatedAt": 1750612800000
  }
}
```

### `GET /conversations/{conversationId}/messages`

Lấy tin nhắn trong cuộc trò chuyện. Tự động đánh dấu đã đọc.

Response:

```json
{
  "content": [
    {
      "id": "msg_001",
      "conversationId": "abc123",
      "senderId": "uid_1",
      "senderName": "Nguyen Van A",
      "senderRole": "1",
      "content": "Xin chao, toi can hoan tra don",
      "type": "TEXT",
      "isRead": true,
      "createdAt": 1750612800000
    },
    {
      "id": "msg_002",
      "conversationId": "abc123",
      "senderId": "uid_2",
      "senderName": "Tran Van B",
      "senderRole": "2",
      "content": "Da nhan, toi dang o gan do",
      "type": "TEXT",
      "isRead": false,
      "createdAt": 1750612850000
    }
  ]
}
```

### `POST /send`

Gửi tin nhắn.

Request:

```json
{
  "orderId": "order_001",
  "content": "Xin chao, ban dang o dau?"
}
```

Response:

```json
{
  "content": {
    "id": "msg_003",
    "conversationId": "abc123",
    "senderId": "uid_1",
    "senderName": "Nguyen Van A",
    "senderRole": "1",
    "content": "Xin chao, ban dang o dau?",
    "type": "TEXT",
    "isRead": false,
    "createdAt": 1750612900000
  }
}
```

### `PUT /conversations/{conversationId}/read`

Đánh dấu tất cả tin nhắn trong cuộc trò chuyện là đã đọc.

Response:

```json
{
  "content": null
}
```

---

## Firestore Schema

### `conversations`


| Field            | Type   | Description                   |
| ---------------- | ------ | ----------------------------- |
| `orderId`        | string | ID đơn hàng                   |
| `customerId`     | string | Firebase UID khách hàng       |
| `customerName`   | string | Tên khách hàng                |
| `driverId`       | string | ID tài xế                     |
| `driverName`     | string | Tên tài xế                    |
| `lastMessage`    | string | Tin nhắn cuối cùng            |
| `lastMessageAt`  | number | Timestamp ms                  |
| `unreadCustomer` | number | Số tin chưa đọc (phía khách)  |
| `unreadDriver`   | number | Số tin chưa đọc (phía tài xế) |
| `status`         | string | "active"                      |
| `createdAt`      | number | Timestamp ms tạo              |
| `updatedAt`      | number | Timestamp ms cập nhật         |


### `messages`


| Field            | Type    | Description                   |
| ---------------- | ------- | ----------------------------- |
| `conversationId` | string  | ID cuộc trò chuyện            |
| `senderId`       | string  | ID người gửi                  |
| `senderName`     | string  | Tên người gửi                 |
| `senderRole`     | string  | "1" (customer) | "2" (driver) |
| `content`        | string  | Nội dung tin nhắn             |
| `type`           | string  | "TEXT" | "IMAGE" | "SYSTEM"   |
| `isRead`         | boolean | Đã đọc                        |
| `createdAt`      | number  | Timestamp ms tạo              |


---

## Firestore Operations (Direct Access)

**Conversation**

- Tạo/lấy: query `conversations` where `orderId == :orderId` → tạo mới nếu chưa có
- Danh sách: query `conversations` where `customerId == :uid` order by `lastMessageAt` desc (onSnapshot)
- Đánh dấu đọc: update `unreadCustomer = 0` trong document và `isRead = true` cho messages có `senderRole == "2"`

**Message**

- Lắng nghe: query `messages` where `conversationId == :id` order by `createdAt` asc (onSnapshot)
- Gửi: create document vào collection `messages`, update `lastMessage`, `lastMessageAt` trong `conversations`

---

## Luồng Logic

```
Mở chat từ đơn hàng đang giao
│
├─ Bước 1: Tạo/lấy conversation
│   → Gọi GET /conversations/order/{orderId}
│   → Backend query Firestore theo orderId
│   → Nếu chưa có → tạo mới với customerId, driverId, driverName
│   → Trả về conversation
│
├─ Bước 2: Lắng nghe tin nhắn real-time
│   → Gọi watchMessages(conversation.id) trên Firestore
│   → onSnapshot tự động emit khi có thay đổi
│   → Cập nhật UI mỗi khi có tin mới
│
├─ Bước 3: Gửi tin nhắn
│   → Gọi POST /send { orderId, content }
│   → Backend ghi vào Firestore messages (senderRole = "1")
│   → Backend push WebSocket tới tài xế
│   → Cập nhật lastMessage trong conversations
│
├─ Bước 4: Nhận tin từ tài xế
│   → Tài xế gọi POST /send → backend ghi Firestore → push WebSocket
│   → Firestore onSnapshot thức dậy → stream emit → UI tự cập nhật
│
└─ Bước 5: Đánh dấu đã đọc
    → Gọi PUT /conversations/{id}/read
    → Backend update unreadCustomer = 0 và isRead = true
```

---

## Điểm khác biệt so với Driver App


|              | Driver App               | Customer App             |
| ------------ | ------------------------ | ------------------------ |
| Đọc tin nhắn | REST API `GET /messages` | Firestore `onSnapshot`   |
| Gửi tin nhắn | REST API `POST /send`    | REST API `POST /send`    |
| Real-time    | WebSocket STOMP          | Firestore `onSnapshot`   |
| Xác thực     | JWT token                | JWT token (cùng backend) |



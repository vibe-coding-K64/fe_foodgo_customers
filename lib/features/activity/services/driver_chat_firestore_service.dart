import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/network/api_client.dart';

/// Service chat cho Customer App.
///
/// Luong hoat dong:
/// 1. Mo chat: doc truc tiep tu Firestore theo orderId.
///    - Khong co conversation -> tra ve null, hien man hinh trong.
/// 2. Gui tin nhan dau tien: ghi vao Firestore roi goi API sync.
/// 3. Sau do: lang nghe Firestore realtime (onSnapshot).
///
/// Schema Firestore: xem docs/CUSTOMER_APP_CHAT_INTEGRATION_GUIDE.md.
class DriverChatFirestoreService {
  const DriverChatFirestoreService();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Doc conversation tu Firestore theo orderId.
  /// Tra ve null neu khong co (hien man hinh trong).
  Future<ConversationInfo?> getConversationByOrderId(String orderId) async {
    debugPrint(
      'DriverChatFirestoreService: Tim conversation theo orderId=$orderId',
    );

    try {
      final snap = await _firestore
          .collection('conversations')
          .where('orderId', isEqualTo: orderId)
          .limit(1)
          .get();

      if (snap.docs.isEmpty) {
        debugPrint(
          'DriverChatFirestoreService: Khong co conversation cho orderId=$orderId',
        );
        return null;
      }

      final doc = snap.docs.first;
      debugPrint(
        'DriverChatFirestoreService: Tim thay conversation [${doc.id}]',
      );
      return _conversationFromDoc(doc);
    } catch (e) {
      debugPrint(
        'DriverChatFirestoreService: Loi doc conversation — $e',
      );
      return null;
    }
  }

  /// Stream lang nghe tin nhan real-time cua mot conversation.
  /// Su dung onSnapshot tren Firestore.
  Stream<List<ChatMessageInfo>> watchMessages(String conversationId) {
    debugPrint(
      'DriverChatFirestoreService: watchMessages — conversationId=$conversationId',
    );

    return _firestore
        .collection('messages')
        .where('conversationId', isEqualTo: conversationId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) {
      debugPrint(
        'DriverChatFirestoreService: Nhan ${snap.docs.length} tin nhan tu Firestore',
      );
      return snap.docs.map((doc) => _messageFromDoc(doc)).toList();
    });
  }

  /// Gui tin nhan.
  ///
  /// Goi POST /send — backend tu ghi vao Firestore.
  /// Stream watchMessages se tu dong emit tin nhan moi khi Firestore cap nhat.
  Future<ChatMessageInfo?> sendMessage({
    required String orderId,
    required String customerId,
    required String customerName,
    required String content,
    String type = 'TEXT',
  }) async {
    debugPrint(
      'DriverChatFirestoreService: Gui tin nhan — orderId=$orderId, content=$content',
    );

    try {
      final response = await ApiClient.post<Map<String, dynamic>>(
        '/chat/send',
        data: {
          'orderId': orderId,
          'content': content,
          if (type != 'TEXT') 'type': type,
        },
      );

      // API tra ve { success, data: { message fields } }
      final data = response.data;
      if (data == null || data['success'] != true) {
        debugPrint(
          'DriverChatFirestoreService: API tra ve success=false — ${data?['message']}',
        );
        return null;
      }

      final msgData = data['data'] as Map<String, dynamic>?;
      if (msgData == null) {
        debugPrint(
          'DriverChatFirestoreService: API khong tra ve data',
        );
        return null;
      }

      debugPrint(
        'DriverChatFirestoreService: Gui thanh cong [${msgData['id']}]',
      );
      return ChatMessageInfo(
        id: msgData['id'] as String? ?? '',
        conversationId: msgData['conversationId'] as String? ?? '',
        senderId: msgData['senderId'] as String? ?? customerId,
        senderName: msgData['senderName'] as String? ?? customerName,
        senderRole: msgData['senderRole'] as String? ?? '1',
        content: msgData['content'] as String? ?? content,
        type: msgData['type'] as String? ?? type,
        isRead: msgData['read'] as bool? ?? false,
        createdAt: _parseMs(msgData['createdAt']),
      );
    } on DioException catch (e) {
      _debugDioError('sendMessage', e);
      return null;
    } catch (e) {
      debugPrint(
        'DriverChatFirestoreService: Loi sendMessage — $e',
      );
      return null;
    }
  }

  /// Tao conversation moi trong Firestore.
  /// Dung khi nguoi dung gui tin nhan dau tien ma chua co conversation.
  Future<ConversationInfo?> createConversation({
    required String orderId,
    required String customerId,
    required String customerName,
    required String driverId,
    required String driverName,
  }) async {
    debugPrint(
      'DriverChatFirestoreService: Tao conversation — '
      'orderId=$orderId, customerId=$customerId, driverId=$driverId',
    );

    final now = DateTime.now();
    final convData = {
      'orderId': orderId,
      'customerId': customerId,
      'customerName': customerName,
      'driverId': driverId,
      'driverName': driverName,
      'lastMessage': '',
      'lastMessageAt': now.millisecondsSinceEpoch,
      'unreadCustomer': 0,
      'unreadDriver': 0,
      'status': 'active',
      'createdAt': now.millisecondsSinceEpoch,
      'updatedAt': now.millisecondsSinceEpoch,
    };

    try {
      final docRef = await _firestore.collection('conversations').add(convData);
      debugPrint(
        'DriverChatFirestoreService: Da tao conversation [${docRef.id}]',
      );
      return ConversationInfo(
        id: docRef.id,
        orderId: orderId,
        customerId: customerId,
        customerName: customerName,
        driverId: driverId,
        driverName: driverName,
        lastMessage: '',
        lastMessageAt: now,
        unreadCustomer: 0,
        status: 'active',
        createdAt: now,
        updatedAt: now,
      );
    } catch (e) {
      debugPrint(
        'DriverChatFirestoreService: Loi tao conversation — $e',
      );
      return null;
    }
  }

  /// Danh dau tat ca tin nhan trong conversation la da doc (phia customer).
  Future<void> markAsRead(String conversationId) async {
    try {
      final batch = _firestore.batch();
      final snap = await _firestore
          .collection('messages')
          .where('conversationId', isEqualTo: conversationId)
          .where('senderRole', isEqualTo: '2') // chi tin nhan tu tai xe
          .where('isRead', isEqualTo: false)
          .get();

      for (final doc in snap.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      batch.update(
        _firestore.collection('conversations').doc(conversationId),
        {'unreadCustomer': 0},
      );

      await batch.commit();
      debugPrint(
        'DriverChatFirestoreService: Da danh dau $conversationId la da doc',
      );
    } catch (e) {
      debugPrint(
        'DriverChatFirestoreService: Loi markAsRead — $e',
      );
    }
  }

  void _debugDioError(String method, DioException e) {
    if (e.response != null) {
      debugPrint(
        'DriverChatFirestoreService: Loi $method — '
        'HTTP ${e.response?.statusCode}: ${e.response?.data}',
      );
    } else {
      debugPrint(
        'DriverChatFirestoreService: Loi $method — ${e.message}',
      );
    }
  }

  ConversationInfo _conversationFromDoc(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ConversationInfo(
      id: doc.id,
      orderId: data['orderId'] as String? ?? '',
      customerId: data['customerId'] as String? ?? '',
      customerName: data['customerName'] as String? ?? '',
      driverId: data['driverId'] as String? ?? '',
      driverName: data['driverName'] as String? ?? '',
      lastMessage: data['lastMessage'] as String? ?? '',
      lastMessageAt: _parseMs(data['lastMessageAt']),
      unreadCustomer: data['unreadCustomer'] as int? ?? 0,
      status: data['status'] as String? ?? 'active',
      createdAt: _parseMs(data['createdAt']),
      updatedAt: _parseMs(data['updatedAt']),
    );
  }

  ChatMessageInfo _messageFromDoc(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessageInfo(
      id: doc.id,
      conversationId: data['conversationId'] as String? ?? '',
      senderId: data['senderId'] as String? ?? '',
      senderName: data['senderName'] as String? ?? '',
      senderRole: data['senderRole'] as String? ?? '1',
      content: data['content'] as String? ?? '',
      type: data['type'] as String? ?? 'TEXT',
      isRead: data['isRead'] as bool? ?? false,
      createdAt: _parseMs(data['createdAt']),
    );
  }

  DateTime _parseMs(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is double) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    }
    return DateTime.now();
  }
}

/// Thong tin cuoc tro chuyen.
class ConversationInfo {
  final String id;
  final String orderId;
  final String customerId;
  final String customerName;
  final String driverId;
  final String driverName;
  final String lastMessage;
  final DateTime lastMessageAt;
  final int unreadCustomer;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ConversationInfo({
    required this.id,
    required this.orderId,
    required this.customerId,
    required this.customerName,
    required this.driverId,
    required this.driverName,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.unreadCustomer,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
}

/// Thong tin mot tin nhan.
class ChatMessageInfo {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String senderRole;
  final String content;
  final String type;
  final bool isRead;
  final DateTime createdAt;

  const ChatMessageInfo({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.content,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  bool get isFromDriver => senderRole == '2';
  bool get isFromCustomer => senderRole == '1';
  bool get isTextMessage => type == 'TEXT';
  bool get isImageMessage => type == 'IMAGE';
  bool get isSystemMessage => type == 'SYSTEM';
}

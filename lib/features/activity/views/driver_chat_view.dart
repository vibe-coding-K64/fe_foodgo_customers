import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/localization/language_service.dart';
import '../../../core/utils/auth_storage.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../services/driver_chat_firestore_service.dart';

///=============================================================================
/// SECTION: MODELS
///=============================================================================

enum ChatMessageType {
  text,
  image,
  location,
  system,
}

enum ChatSender {
  driver,
  user,
}

class ChatMessageModel {
  final String id;
  final String content;
  final DateTime timestamp;
  final ChatSender sender;
  final ChatMessageType type;

  const ChatMessageModel({
    required this.id,
    required this.content,
    required this.timestamp,
    required this.sender,
    this.type = ChatMessageType.text,
  });
}

///=============================================================================
/// SECTION: VIEW
///=============================================================================

/// Man hinh chat voi tai xe.
///
/// Doc tin nhan real-time tu Firestore bang onSnapshot.
/// Giao tiep: DriverChatFirestoreService.
class DriverChatView extends StatefulWidget {
  /// ID cua conversation trong Firestore. Co the rong neu chua co.
  final String? conversationId;

  /// ID don hang lien quan.
  final String orderId;

  /// ID tai xe.
  final String driverId;

  /// Ten tai xe hien thi tren AppBar.
  final String driverName;

  /// Bien so xe.
  final String vehiclePlate;

  /// So dien thoai tai xe.
  final String driverPhone;

  /// URL avatar tai xe.
  final String driverAvatarUrl;

  const DriverChatView({
    super.key,
    this.conversationId,
    required this.orderId,
    required this.driverId,
    required this.driverName,
    required this.vehiclePlate,
    required this.driverPhone,
    this.driverAvatarUrl = '',
  });

  @override
  State<DriverChatView> createState() => _DriverChatViewState();
}

class _DriverChatViewState extends State<DriverChatView> {
  static const _chatService = DriverChatFirestoreService();

  List<ChatMessageModel> _messages = [];
  bool _loading = true;
  StreamSubscription<List<ChatMessageInfo>>? _sub;

  String? _conversationId;

  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String get _userId => AuthStorage.getUserId() ?? '';
  String get _userName {
    final user = AuthStorage.getUser();
    return user?['fullName'] as String? ??
           user?['name'] as String? ??
           'Khach hang';
  }

  @override
  void initState() {
    super.initState();
    _conversationId = widget.conversationId;
    if (_conversationId != null) {
      _startListening(_conversationId!);
    } else {
      setState(() => _loading = false);
    }
  }

  void _startListening(String conversationId) {
    _sub?.cancel();
    _sub = _chatService.watchMessages(conversationId).listen(
      (messages) {
        if (!mounted) return;
        setState(() {
          _messages = messages.map(_toChatModel).toList();
          _loading = false;
        });
        _scrollToBottom();
      },
      onError: (e) {
        debugPrint('DriverChatView: Loi stream messages — $e');
        if (mounted) {
          setState(() => _loading = false);
        }
      },
    );
    _chatService.markAsRead(conversationId);
  }

  ChatMessageModel _toChatModel(ChatMessageInfo info) {
    ChatMessageType type;
    switch (info.type.toUpperCase()) {
      case 'IMAGE':
        type = ChatMessageType.image;
        break;
      case 'LOCATION':
        type = ChatMessageType.location;
        break;
      case 'SYSTEM':
        type = ChatMessageType.system;
        break;
      default:
        type = ChatMessageType.text;
    }

    return ChatMessageModel(
      id: info.id,
      content: info.content,
      timestamp: info.createdAt,
      sender: info.isFromDriver ? ChatSender.driver : ChatSender.user,
      type: type,
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();

    final msg = await _chatService.sendMessage(
      orderId: widget.orderId,
      customerId: _userId,
      customerName: _userName,
      content: text,
    );

    if (msg == null) {
      if (mounted) {
        showAppToast(
          context,
          message: context.t('error_unknown'),
          type: AppToastType.error,
        );
      }
      return;
    }

    // Neu chua co conversation, bat dau lang nghe tu conversationId backend tra ve.
    if (_conversationId == null && msg.conversationId.isNotEmpty) {
      _conversationId = msg.conversationId;
      _startListening(_conversationId!);
    }
  }

  void _sendQuickReply(String text) async {
    final msg = await _chatService.sendMessage(
      orderId: widget.orderId,
      customerId: _userId,
      customerName: _userName,
      content: text,
    );

    if (msg == null) {
      if (mounted) {
        showAppToast(
          context,
          message: context.t('error_unknown'),
          type: AppToastType.error,
        );
      }
      return;
    }

    if (_conversationId == null && msg.conversationId.isNotEmpty) {
      _conversationId = msg.conversationId;
      _startListening(_conversationId!);
    }
  }

  void _callDriver() async {
    if (widget.driverPhone.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: widget.driverPhone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildMessageList()),
            _buildQuickReplyBar(),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.textPrimary,
      elevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          widget.driverAvatarUrl.isNotEmpty
              ? CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.surfaceVariant,
                  backgroundImage: NetworkImage(widget.driverAvatarUrl),
                  onBackgroundImageError: (_, __) {},
                )
              : CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.surfaceVariant,
                  child: const Icon(
                    Icons.person,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.driverName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                widget.vehiclePlate,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.phone_outlined),
          onPressed: _callDriver,
          tooltip: context.t('driver_chat_call_btn'),
        ),
      ],
    );
  }

  Widget _buildMessageList() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 48,
                color: AppColors.textHint,
              ),
              const SizedBox(height: 12),
              Text(
                context.t('driver_chat_input_hint'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final isUser = message.sender == ChatSender.user;

        final showSenderInfo = index == 0 ||
            _messages[index - 1].sender != message.sender;

        return _ChatBubbleWidget(
          message: message,
          isUser: isUser,
          showSenderInfo: showSenderInfo,
          avatarUrl: widget.driverAvatarUrl,
        );
      },
    );
  }

  Widget _buildQuickReplyBar() {
    final quickReplies = [
      context.t('quick_reply_coming_down'),
      context.t('quick_reply_where_are_you'),
      context.t('quick_reply_call_when_arrive'),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: quickReplies.map((reply) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ActionChip(
                label: Text(
                  reply,
                  style: TextStyle(fontSize: 13, color: AppColors.primary),
                ),
                backgroundColor: AppColors.primary.withOpacity(0.08),
                side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                onPressed: () => _sendQuickReply(reply),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _textController,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: context.t('driver_chat_input_hint'),
                  hintStyle: TextStyle(fontSize: 15, color: AppColors.textHint),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.send, size: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

}

///=============================================================================
/// SECTION: CHAT BUBBLE WIDGET
///=============================================================================

class _ChatBubbleWidget extends StatelessWidget {
  final ChatMessageModel message;
  final bool isUser;
  final bool showSenderInfo;
  final String avatarUrl;

  const _ChatBubbleWidget({
    required this.message,
    required this.isUser,
    required this.showSenderInfo,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: isUser ? 4 : (showSenderInfo ? 12 : 4.0),
        bottom: 4.0,
      ),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser && showSenderInfo) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.surfaceVariant,
              backgroundImage: avatarUrl.isNotEmpty
                  ? NetworkImage(avatarUrl)
                  : null,
              child: avatarUrl.isEmpty
                  ? const Icon(Icons.person, size: 14, color: AppColors.textSecondary)
                  : null,
            ),
            const SizedBox(width: 8),
          ] else if (!isUser) ...[
            const SizedBox(width: 36),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                _buildBubbleContent(context),
                const SizedBox(height: 2),
                Text(
                  _formatTime(message.timestamp),
                  style: TextStyle(fontSize: 11, color: AppColors.textHint),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubbleContent(BuildContext context) {
    if (message.type == ChatMessageType.location) {
      return _buildLocationBubble(context);
    }
    if (message.type == ChatMessageType.image) {
      return _buildImageBubble();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isUser ? AppColors.primary : AppColors.surfaceVariant,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isUser ? 18 : 4),
          bottomRight: Radius.circular(isUser ? 4 : 18),
        ),
      ),
      child: Text(
        message.content,
        style: TextStyle(
          fontSize: 15,
          color: isUser ? Colors.white : AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildLocationBubble(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUser ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isUser ? null : Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isUser
                  ? Colors.white.withOpacity(0.2)
                  : AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.location_on,
              color: isUser ? Colors.white : AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.t('order_delivery_address'),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isUser ? Colors.white : AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  message.content,
                  style: TextStyle(
                    fontSize: 12,
                    color: isUser ? Colors.white70 : AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageBubble() {
    return Container(
      width: 180,
      height: 140,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: NetworkImage(message.content),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

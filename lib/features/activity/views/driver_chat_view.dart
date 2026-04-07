import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/language_service.dart';

///=============================================================================
/// SECTION: MODELS
///=============================================================================

/// Loai tin nhan.
enum ChatMessageType {
  text,    // Tin nhan text thong thuong.
  image,   // Tin nhan chua hinh anh.
  location, // Tin nhan chua vi tri.
}

/// Nguoi gui tin nhan.
enum ChatSender {
  driver,  // Tai xe.
  user,    // Khach hang.
}

/// Model mot tin nhan trong cuoc tro chuyen.
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

/// Model cuoc tro chuyen voi tai xe.
class DriverChatModel {
  final String driverName;
  final String vehiclePlate;
  final String driverPhone;
  final String driverAvatarUrl;
  final List<ChatMessageModel> messages;

  const DriverChatModel({
    required this.driverName,
    required this.vehiclePlate,
    required this.driverPhone,
    required this.driverAvatarUrl,
    required this.messages,
  });
}

///=============================================================================
/// SECTION: VIEW
///=============================================================================

/// Man hinh chat voi tai xe.
///
/// Hien thi cuoc tro chuyen giua khach hang va tai xe, bao gom:
///   - AppBar voi thong tin tai xe va nut goi dien.
///   - Danh sach tin nhan (bong bong trai / phai).
///   - Thanh tin nhan mau (Quick Replies).
///   - Vung nhap tin nhan + nut gui.
/// Bat phim duoc xu ly tot nho SafeArea va Column co MainAxisSize.min.
class DriverChatView extends StatefulWidget {
  final DriverChatModel chat;

  const DriverChatView({
    super.key,
    required this.chat,
  });

  @override
  State<DriverChatView> createState() => _DriverChatViewState();
}

class _DriverChatViewState extends State<DriverChatView> {
  /// Danh sach tin nhan cua cuoc tro chuyen (Stateful de co the them tin nhan).
  late List<ChatMessageModel> _messages;

  /// Controller cua o nhap tin nhan.
  final TextEditingController _textController = TextEditingController();

  /// ScrollController de tu dong cuon xuong khi co tin nhan moi.
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Copy mock data sang state de co the modify (khi gui tin nhan).
    _messages = List.from(widget.chat.messages);
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Tu dong cuon xuong cuoi danh sach tin nhan.
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

  /// Gui tin nhan text cua nguoi dung.
  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final newMessage = ChatMessageModel(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      content: text,
      timestamp: DateTime.now(),
      sender: ChatSender.user,
      type: ChatMessageType.text,
    );

    setState(() {
      _messages.add(newMessage);
    });
    _textController.clear();
    _scrollToBottom();
  }

  /// Gui tin nhan mau (Quick Reply).
  void _sendQuickReply(String text) {
    final newMessage = ChatMessageModel(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      content: text,
      timestamp: DateTime.now(),
      sender: ChatSender.user,
      type: ChatMessageType.text,
    );

    setState(() {
      _messages.add(newMessage);
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            // Vung hien thi danh sach tin nhan (Expanded de fill phan con lai).
            Expanded(
              child: _buildMessageList(),
            ),
            // Thanh Quick Replies (cuon ngang).
            _buildQuickReplyBar(),
            // Vung nhap tin nhan.
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  ///=============================================================================
  /// APP BAR
  ///=============================================================================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.textPrimary,
      elevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          debugPrint('DriverChatView: Nguoi dung bam nut Back');
          Navigator.pop(context);
        },
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar tai xe.
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.surfaceVariant,
            backgroundImage: widget.chat.driverAvatarUrl.isNotEmpty
                ? NetworkImage(widget.chat.driverAvatarUrl)
                : null,
            child: widget.chat.driverAvatarUrl.isEmpty
                ? const Icon(
                    Icons.person,
                    size: 20,
                    color: AppColors.textSecondary,
                  )
                : null,
          ),
          const SizedBox(width: 10),
          // Ten tai xe va bien so xe.
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.chat.driverName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                widget.chat.vehiclePlate,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        // Nut goi dien cho tai xe.
        IconButton(
          icon: const Icon(Icons.phone_outlined),
          onPressed: () {
            debugPrint('DriverChatView: Nguoi dung bam goi dien cho tai xe [${widget.chat.driverPhone}]');
          },
          tooltip: context.t('driver_chat_call_btn'),
        ),
      ],
    );
  }

  ///=============================================================================
  /// DANH SACH TIN NHAN
  ///=============================================================================

  Widget _buildMessageList() {
    if (_messages.isEmpty) {
      return Center(
        child: Text(
          context.t('driver_chat_input_hint'),
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textHint,
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

        // Kiem tra xem co can hien thi avatar khong (chi hien khi can nhom).
        // Hien thi avatar/ten khi nguoi gui thay doi.
        final showSenderInfo = index == 0 ||
            _messages[index - 1].sender != message.sender;

        return _ChatBubbleWidget(
          message: message,
          isUser: isUser,
          showSenderInfo: showSenderInfo,
          avatarUrl: widget.chat.driverAvatarUrl,
        );
      },
    );
  }

  ///=============================================================================
  /// QUICK REPLY BAR
  ///=============================================================================

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
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.primary,
                  ),
                ),
                backgroundColor: AppColors.primary.withOpacity(0.08),
                side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                onPressed: () {
                  debugPrint('DriverChatView: Nguoi dung bam quick reply: [$reply]');
                  _sendQuickReply(reply);
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  ///=============================================================================
  /// VUNG NHAP TIN NHAN
  ///=============================================================================

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
          // Nut dinh kem (hinh anh / vi tri).
          GestureDetector(
            onTap: () {
              debugPrint('DriverChatView: Nguoi dung bam nut dinh kem');
              _showAttachOptions(context);
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.attach_file,
                size: 20,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // O nhap tin nhan.
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
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: context.t('driver_chat_input_hint'),
                  hintStyle: TextStyle(
                    fontSize: 15,
                    color: AppColors.textHint,
                  ),
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
          // Nut gui tin nhan.
          GestureDetector(
            onTap: () {
              debugPrint('DriverChatView: Nguoi dung bam nut gui');
              _sendMessage();
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.send,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Hien thi bottom sheet cho cac tuy chon dinh kem.
  void _showAttachOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Nut gui vi tri.
                ListTile(
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.location_on_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                  title: Text(
                    context.t('order_delivery_address'),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    context.t('driver_chat_location_sent'),
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  onTap: () {
                    debugPrint('DriverChatView: Nguoi dung chon gui vi tri');
                    Navigator.pop(context);
                    final locationMsg = ChatMessageModel(
                      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
                      content: context.t('driver_chat_location_sent'),
                      timestamp: DateTime.now(),
                      sender: ChatSender.user,
                      type: ChatMessageType.location,
                    );
                    setState(() {
                      _messages.add(locationMsg);
                    });
                    _scrollToBottom();
                  },
                ),
                const Divider(height: 1),
                // Nut gui hinh anh.
                ListTile(
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.image_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                  title: Text(
                    LanguageService.translate('driver_chat_send_image'),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    context.t('driver_chat_image_sent'),
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  onTap: () {
                    debugPrint('DriverChatView: Nguoi dung chon gui hinh anh');
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

///=============================================================================
/// SECTION: CHAT BUBBLE WIDGET
///=============================================================================

/// Widget bong bong tin nhan.
///
/// Hien thi noi dung tin nhan voi bong bong trai (tai xe) hoac phai (khach).
class _ChatBubbleWidget extends StatelessWidget {
  final ChatMessageModel message;
  final bool isUser;      // True: khach (ben phai), False: tai xe (ben trai).
  final bool showSenderInfo; // Co hien thi avatar/ten khong.
  final String avatarUrl; // URL avatar cua tai xe.

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
          // Avatar tai xe (chi hien thi khi la tin nhan cua tai xe va can showSenderInfo).
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
            const SizedBox(width: 36), // Khoang trong de can chinh avatar.
          ],
          // Noi dung bong bong.
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                _buildBubbleContent(),
                const SizedBox(height: 2),
                // Thoi gian gui tin nhan.
                Text(
                  _formatTime(message.timestamp),
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubbleContent() {
    // Neu la tin nhan vi tri.
    if (message.type == ChatMessageType.location) {
      return _buildLocationBubble();
    }

    // Neu la tin nhan hinh anh.
    if (message.type == ChatMessageType.image) {
      return _buildImageBubble();
    }

    // Tin nhan text thong thuong.
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

  Widget _buildLocationBubble() {
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
                  LanguageService.translate('order_delivery_address'),
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

  /// Format thoi gian thanh chuoi (VD: "14:30").
  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

///=============================================================================
/// SECTION: MOCK DATA
///=============================================================================

/// Mock data cuoc tro chuyen voi tai xe.
final mockDriverChat = DriverChatModel(
  driverName: 'Le Van B',
  vehiclePlate: '59A-123.45',
  driverPhone: '091 234 5678',
  driverAvatarUrl: '',
  messages: [
    ChatMessageModel(
      id: 'msg_1',
      content: 'Toi dang lay mon tu cua hang nhe.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
      sender: ChatSender.driver,
    ),
    ChatMessageModel(
      id: 'msg_2',
      content: 'Ok ban, cam on ban.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 23)),
      sender: ChatSender.user,
    ),
    ChatMessageModel(
      id: 'msg_3',
      content: 'Toi da lay mon xong roi, dang len duong nhe.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
      sender: ChatSender.driver,
    ),
    ChatMessageModel(
      id: 'msg_4',
      content: 'Ban o dau roi?',
      timestamp: DateTime.now().subtract(const Duration(minutes: 18)),
      sender: ChatSender.user,
    ),
    ChatMessageModel(
      id: 'msg_5',
      content: 'Toi dang o duong Nguyen Hue, gan den roi ban nhe.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      sender: ChatSender.driver,
    ),
  ],
);

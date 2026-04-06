import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/language_service.dart';

/// Loai nguoi gui tin nhan.
enum MessageSender {
  staff,
  user,
}

/// Model mot tin nhan trong chat.
class ChatMessage {
  final String content;
  final MessageSender sender;
  final DateTime timestamp;
  final bool isRead;

  const ChatMessage({
    required this.content,
    required this.sender,
    required this.timestamp,
    this.isRead = false,
  });
}

/// Man hinh Chat voi nhan vien ho tro.
///
/// Hien thi:
///   - AppBar voi ten nhan vien va trang thai online.
///   - Danh sach tin nhan (ListView, bong bong trai/phai).
///   - Vung nhap tin nhan co nut dinh kem + nut gui.
///
/// Duoc goi tu:
///   - SupportView: bam nut "Chat voi nhan vien"
class SupportChatView extends StatefulWidget {
  const SupportChatView({super.key});

  @override
  State<SupportChatView> createState() => _SupportChatViewState();
}

class _SupportChatViewState extends State<SupportChatView> {
  /// Controller o nhap tin nhan.
  final _messageController = TextEditingController();

  /// ScrollController de cuon xuong khi co tin nhan moi.
  final _scrollController = ScrollController();

  /// Khoa ban phim (trang thai dang nhap).
  bool _isTyping = false;

  /// Danh sach tin nhan mock (3-4 cau hoi tra loi).
  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _messages.addAll(_buildInitialMessages());
    debugPrint('SupportChat: Man hinh chat da mo');
  }

  /// Tao danh sach tin nhan khoi tao mock.
  List<ChatMessage> _buildInitialMessages() {
    final now = DateTime.now();
    return [
      ChatMessage(
        content: LanguageService.translate('chat_staff_greeting'),
        sender: MessageSender.staff,
        timestamp: DateTime(now.year, now.month, now.day, 10, 25),
        isRead: true,
      ),
      ChatMessage(
        content: 'Toi muon huy don hang 12345',
        sender: MessageSender.user,
        timestamp: DateTime(now.year, now.month, now.day, 10, 27),
        isRead: true,
      ),
      ChatMessage(
        content: 'Vang ban, don hang 12345 cua ban dang trong trang thai "Dang chuan bi". Ban co the huy trong vong 5 phut ke tu luc dat. Ban co muon minh kiem tra chi tiet khong?',
        sender: MessageSender.staff,
        timestamp: DateTime(now.year, now.month, now.day, 10, 28),
        isRead: true,
      ),
      ChatMessage(
        content: 'Duoc, ban kiem tra giup toi di',
        sender: MessageSender.user,
        timestamp: DateTime(now.year, now.month, now.day, 10, 30),
        isRead: true,
      ),
      ChatMessage(
        content: 'Don hang 12345 da duoc xac nhan va dang duoc chuan bi. Hien tai ban con 2 phut de huy neu muon. Neu can ho tro them, ban nhan tin tra loi nhe!',
        sender: MessageSender.staff,
        timestamp: DateTime(now.year, now.month, now.day, 10, 31),
        isRead: false,
      ),
    ];
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Cuon xuong tin nhan moi nhat.
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  /// Xu ly gui tin nhan.
  void _onSend() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    debugPrint('SupportChat: Gui tin nhan [$text]');

    setState(() {
      _messages.add(ChatMessage(
        content: text,
        sender: MessageSender.user,
        timestamp: DateTime.now(),
      ));
    });

    _messageController.clear();
    setState(() => _isTyping = false);

    // Cuon xuong sau khi gui.
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  /// Xu ly bam nut dinh kem.
  void _onAttachment() {
    debugPrint('SupportChat: Nguoi dung bam nut dinh kem');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(LanguageService.translate('chat_attachment')),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Xu ly thay doi text trong o nhap.
  void _onTextChanged(String value) {
    final hasText = value.trim().isNotEmpty;
    if (hasText != _isTyping) {
      setState(() => _isTyping = hasText);
    }
  }

  /// Tao dinh dang thoi gian.
  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// Tao dinh dang ngay (Hien thi "Hom nay" / "Hom qua").
  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDate = DateTime(dt.year, dt.month, dt.day);

    if (msgDate == today) {
      return LanguageService.translate('chat_today');
    } else if (msgDate == today.subtract(const Duration(days: 1))) {
      return LanguageService.translate('chat_yesterday');
    } else {
      return '${dt.day}/${dt.month}/${dt.year}';
    }
  }

  /// Kiem tra xem co can hien thi nhan ngay khong (giua 2 tin nhan cach nhau hon 5 phut).
  bool _shouldShowDateDivider(int index) {
    if (index == 0) return true;
    final prev = _messages[index - 1].timestamp;
    final curr = _messages[index].timestamp;
    return curr.difference(prev).inMinutes >= 5 ||
        !_isSameDay(prev, curr);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            // Vung hien thi tin nhan.
            Expanded(
              child: _buildMessageList(),
            ),
            // Vung nhap tin nhan.
            _buildInputArea(context),
          ],
        ),
      ),
    );
  }

  /// AppBar voi ten nhan vien va trang thai online.
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          debugPrint('SupportChat: Nguoi dung bam nut back');
          Navigator.pop(context);
        },
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          // Avatar nhan vien.
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.support_agent,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          // Ten va trang thai.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  LanguageService.translate('chat_staff_name'),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      LanguageService.translate('chat_status_online'),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Danh sach tin nhan (ListView).
  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final showDate = _shouldShowDateDivider(index);

        return Column(
          children: [
            // Nhan ngay chia khoang (neu can).
            if (showDate)
              _buildDateDivider(message.timestamp),
            // Bong bong tin nhan.
            _buildChatBubble(message, index),
          ],
        );
      },
    );
  }

  /// Nhan ngay chia khoang giua cac nhom tin nhan.
  Widget _buildDateDivider(DateTime timestamp) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          _formatDate(timestamp),
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  /// Mot bong bong tin nhan (trai = nhan vien, phai = nguoi dung).
  Widget _buildChatBubble(ChatMessage message, int index) {
    final isStaff = message.sender == MessageSender.staff;
    final isLastUnread = !isStaff &&
        index == _messages.length - 1 &&
        !message.isRead;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment:
            isStaff ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isStaff) const SizedBox(width: 44),
          if (isStaff) const SizedBox(width: 44),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: isStaff ? AppColors.surface : AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft:
                      Radius.circular(isStaff ? 4 : 16),
                  bottomRight:
                      Radius.circular(isStaff ? 16 : 4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: TextStyle(
                      fontSize: 14,
                      color: isStaff
                          ? AppColors.textPrimary
                          : Colors.white,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.timestamp),
                        style: TextStyle(
                          fontSize: 10,
                          color: isStaff
                              ? AppColors.textHint
                              : Colors.white.withAlpha(180),
                        ),
                      ),
                      if (isLastUnread)
                        Container(
                          margin: const EdgeInsets.only(left: 4),
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isStaff) const SizedBox(width: 44),
          if (!isStaff) const SizedBox(width: 0),
        ],
      ),
    );
  }

  /// Vung nhap tin nhan o day man hinh.
  Widget _buildInputArea(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        12,
        10,
        12,
        10 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 6,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Nut dinh kem (Camera/Image).
          GestureDetector(
            onTap: _onAttachment,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.add_photo_alternate_outlined,
                color: AppColors.textSecondary,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // O nhap tin nhan.
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(22),
              ),
              child: TextField(
                controller: _messageController,
                maxLines: null,
                textInputAction: TextInputAction.newline,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                onChanged: _onTextChanged,
                decoration: InputDecoration(
                  hintText: LanguageService.translate('chat_input_hint'),
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textHint,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  border: InputBorder.none,
                  counterText: '',
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Nut gui.
          GestureDetector(
            onTap: _isTyping ? _onSend : null,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _isTyping ? AppColors.primary : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.send_rounded,
                color: _isTyping ? Colors.white : AppColors.textHint,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

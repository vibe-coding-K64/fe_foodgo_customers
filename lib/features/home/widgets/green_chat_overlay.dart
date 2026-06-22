import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/services/chat_session_store.dart';
import '../../chat/services/chat_service.dart';

/// Bong bóng chat messenger của GreenBot, hiển thị overlay trên trang chu.
///
/// Trang thái cuộc trò chuyện được lưu trong [ChatSessionStore] (in-memory):
///   - Trong app: đóng/mở overlay nhiều lần vẫn giữ nguyên đoạn chat hiện có.
///   - Tắt app (process chết) hoặc mở lại app: messages bị xoá hết, GreenBot
///     lại hiển thị 3 câu chào đầu tiên.
///
/// Không ghi Firestore.
class GreenChatOverlay extends StatefulWidget {
  const GreenChatOverlay({super.key});

  @override
  State<GreenChatOverlay> createState() => _GreenChatOverlayState();
}

class _GreenChatOverlayState extends State<GreenChatOverlay> {
  static const String _botName = 'GreenBot';
  static const String _botAvatar = 'asset/img/logo.png';

  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocus = FocusNode();

  /// Lay store tu dau de khong phai khoi tao lai moi lan mo overlay.
  ChatSessionStore get _store => ChatSessionStore.instance;

  /// Lay ChatService singleton.
  ChatService get _chatService => ChatService.instance;

  bool _botTyping = false;
  bool _aiOnline = false;
  bool _checkingHealth = false;

  @override
  void initState() {
    super.initState();
    // Dam bao luon co it nhat 3 message chao dau (chi them lan dau, khong reset).
    _store.ensureSeeded();
    _inputFocus.addListener(_handleFocusChange);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    _checkAiHealth();
  }

  Future<void> _checkAiHealth() async {
    if (_checkingHealth) return;
    _checkingHealth = true;
    final online = await _chatService.checkHealth();
    if (mounted) {
      setState(() {
        _aiOnline = online;
        _checkingHealth = false;
      });
    }
  }

  @override
  void dispose() {
    _inputFocus.removeListener(_handleFocusChange);
    _inputController.dispose();
    _scrollController.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!_inputFocus.hasFocus) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  Future<void> _handleSend() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _botTyping) return;

    setState(() {
      _store.add(ChatMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        text: text,
        isBot: false,
        timestamp: DateTime.now(),
      ));
      _inputController.clear();
      _botTyping = true;
    });
    _scrollToBottom();

    try {
      final result = await _chatService.sendMessage(text);
      if (!mounted) return;
      setState(() {
        _store.add(ChatMessage(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          text: result.reply,
          isBot: true,
          timestamp: DateTime.now(),
        ));
        _botTyping = false;
      });
    } on ChatException catch (e) {
      if (!mounted) return;
      setState(() {
        _store.add(ChatMessage(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          text: e.message,
          isBot: true,
          timestamp: DateTime.now(),
        ));
        _botTyping = false;
      });
    }

    _scrollToBottom();
    _inputFocus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final messages = _store.snapshot();
    return Padding(
      padding: EdgeInsets.only(
        top: mediaQuery.padding.top + 8,
        bottom: mediaQuery.viewInsets.bottom + mediaQuery.padding.bottom + 8,
        left: 8,
        right: 8,
      ),
      child: Material(
        color: Colors.transparent,
        child: Container(
          height: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              children: [
                _buildHeader(context),
                _buildMessages(messages),
                if (_botTyping) _buildTypingIndicator(),
                _buildInput(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.asset(
                _botAvatar,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.smart_toy,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _botName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                _buildStatusText(),
              ],
            ),
          ),
          // Nut xoa lich su chat.
          PopupMenuButton<String>(
            tooltip: 'Tùy chọn',
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: Colors.white,
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 20, color: Colors.red),
                    SizedBox(width: 10),
                    Text('Xóa lịch sử chat',
                        style: TextStyle(fontSize: 14, color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            tooltip: 'Đóng',
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusText() {
    if (_checkingHealth) {
      return const Text(
        'Đang kiểm tra...',
        style: TextStyle(color: Colors.white70, fontSize: 12),
      );
    }
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _aiOnline ? Colors.lightGreenAccent : Colors.red.shade300,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          _aiOnline ? 'Đang hoạt động' : 'Offline',
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  void _handleMenuAction(String action) {
    if (action == 'clear') {
      _showClearHistoryDialog();
    }
  }

  Future<void> _showClearHistoryDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa lịch sử chat'),
        content: const Text(
            'Bạn có chắc muốn xóa toàn bộ lịch sử chat không? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _chatService.clearHistory();
      _store.reset();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa lịch sử chat'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } on ChatException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể xóa: ${e.message}'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  Widget _buildMessages(List<ChatMessage> messages) {
    return Expanded(
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          return _MessageBubble(message: message);
        },
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 4),
      child: Row(
        children: [
          _TypingDot(delayMs: 0),
          const SizedBox(width: 4),
          _TypingDot(delayMs: 150),
          const SizedBox(width: 4),
          _TypingDot(delayMs: 300),
        ],
      ),
    );
  }

  Widget _buildInput() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _inputController,
                focusNode: _inputFocus,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _handleSend(),
                decoration: InputDecoration(
                  hintText: 'Nhập tin nhắn...',
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Material(
              color: AppColors.primary,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _botTyping ? null : _handleSend,
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(Icons.send, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isBot = message.isBot;
    final align = isBot ? Alignment.centerLeft : Alignment.centerRight;
    final bubbleColor = isBot ? AppColors.surfaceVariant : AppColors.primary;
    final textColor = isBot ? AppColors.textPrimary : Colors.white;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: Radius.circular(isBot ? 4 : 16),
      bottomRight: Radius.circular(isBot ? 16 : 4),
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      alignment: align,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: bubbleColor, borderRadius: radius),
          child: Text(
            message.text,
            style: TextStyle(color: textColor, fontSize: 14, height: 1.3),
          ),
        ),
      ),
    );
  }
}

class _TypingDot extends StatefulWidget {
  const _TypingDot({required this.delayMs});

  final int delayMs;

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller.drive(Tween(begin: 0.3, end: 1.0)),
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: AppColors.textSecondary,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

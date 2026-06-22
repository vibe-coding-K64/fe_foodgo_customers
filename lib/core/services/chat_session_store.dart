/// Session chat in-memory cho GreenBot.
///
/// Chi ton tai trong vong doi cua app process:
///   - Dong/mo GreenChatOverlay trong app: van giu nguyen messages.
///   - User tat app (process chet) hoac mo lai app: messages bi mat het,
///     GreenBot hien thi lai seed messages.
///
/// Truoc day messages chi song trong State cua GreenChatOverlay nen moi lan
/// dong overlay la mat; gio duoc day ra singleton de chia se qua cac lan mo.
class ChatSessionStore {
  ChatSessionStore._();
  static final ChatSessionStore instance = ChatSessionStore._();

  static const String _botName = 'GreenBot';

  bool _hasUserMessages = false;
  final List<ChatMessage> _messages = <ChatMessage>[];

  /// Reset ve trang thai ban dau, goi khi muon clear chat (vi du logout).
  void reset() {
    _hasUserMessages = false;
    _messages.clear();
    _seedIfEmpty();
  }

  /// Lay snapshot danh sach message hien tai (copy de ben ngoai khong sua duoc).
  List<ChatMessage> snapshot() => List<ChatMessage>.unmodifiable(_messages);

  /// Them 1 message moi vao session.
  void add(ChatMessage message) {
    _hasUserMessages = true;
    _messages.add(message);
  }

  /// User da tung gui it nhat 1 message hay chua.
  bool get hasUserMessages => _hasUserMessages;

  /// Seed 3 message chao dau tien (chi chay khi store rong).
  void ensureSeeded() {
    _seedIfEmpty();
  }

  void _seedIfEmpty() {
    if (_messages.isNotEmpty) return;
    final now = DateTime.now();
    _messages.addAll(<ChatMessage>[
      ChatMessage(
        id: 'seed-1',
        text: 'Xin chào! Mình là $_botName 🤖🌱',
        isBot: true,
        timestamp: now.subtract(const Duration(minutes: 3)),
      ),
      ChatMessage(
        id: 'seed-2',
        text: 'Mình có thể giúp bạn tìm món ăn, theo dõi đơn hàng '
            'hoặc giải đáp thắc mắc về FoodGo.',
        isBot: true,
        timestamp: now.subtract(const Duration(minutes: 3)),
      ),
      ChatMessage(
        id: 'seed-3',
        text: 'Bạn cần hỗ trợ gì hôm nay?',
        isBot: true,
        timestamp: now.subtract(const Duration(minutes: 2, seconds: 50)),
      ),
    ]);
  }
}

/// Model luu trong ChatSessionStore.
///
/// Dat chung file de GreenChatOverlay va cac noi khac cung dung.
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.text,
    required this.isBot,
    required this.timestamp,
  });

  final String id;
  final String text;
  final bool isBot;
  final DateTime timestamp;
}
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/auth_storage.dart';

/// Ket qua tra ve tu AI chatbot.
class ChatResult {
  const ChatResult({required this.reply});
  final String reply;
}

/// Exception khi chat that bai.
class ChatException implements Exception {
  const ChatException(this.message);
  @override
  final String message;
}

/// Service goi cac endpoint AI chatbot tu backend.
///
/// Base URL da duoc cau hinh trong [ApiClient._baseUrl]
/// la "https://be-foodgo.canluaz.io.vn/api".
///
/// Cac endpoint:
///
///   POST /api/ai/chat          - Gui tin nhan va nhan phan hoi tu AI.
///   DELETE /api/ai/chat/clear - Xoa lich su chat cua nguoi dung.
///   GET /api/ai/health         - Kiem tra trang thai AI.
class ChatService {
  ChatService._();

  static final ChatService _instance = ChatService._();
  static ChatService get instance => _instance;

  /// Gui tin nhan cho AI va nhan phan hoi.
  ///
  /// Header [X-User-Id] duoc tu dong gan tu [AuthStorage.getUserId].
  ///
  /// Neu server tra ve success=false hoac HTTP != 200, nem [ChatException].
  Future<ChatResult> sendMessage(String message) async {
    final userId = AuthStorage.getUserId();

    try {
      final response = await ApiClient.post<Map<String, dynamic>>(
        '/ai/chat',
        data: {'message': message},
        options: Options(
          headers: {
            if (userId != null) 'X-User-Id': userId,
          },
        ),
      );

      final data = response.data;
      if (data == null) {
        throw const ChatException('Không nhận được phản hồi từ server.');
      }

      if (data['success'] != true) {
        throw ChatException(
          data['message'] as String? ?? 'Lỗi không xác định từ server.',
        );
      }

      final reply = data['data'] as String?;
      if (reply == null) {
        throw const ChatException('Phản hồi từ AI không hợp lệ.');
      }

      return ChatResult(reply: reply);
    } on DioException catch (e) {
      final msg = _extractDioError(e);
      throw ChatException(msg);
    } catch (e) {
      if (e is ChatException) rethrow;
      throw ChatException('Đã xảy ra lỗi không mong muốn: $e');
    }
  }

  /// Xoa lich su chat cua nguoi dung hien tai.
  ///
  /// Header [X-User-Id] duoc tu dong gan tu [AuthStorage.getUserId].
  ///
  /// Neu that bai se nem [ChatException].
  Future<void> clearHistory() async {
    final userId = AuthStorage.getUserId();

    try {
      final response = await ApiClient.delete<Map<String, dynamic>>(
        '/ai/chat/clear',
        options: Options(
          headers: {
            if (userId != null) 'X-User-Id': userId,
          },
        ),
      );

      final data = response.data;
      if (data == null) {
        throw const ChatException('Không nhận được phản hồi từ server.');
      }

      if (data['success'] != true) {
        throw ChatException(
          data['message'] as String? ?? 'Lỗi không xác định khi xóa lịch sử.',
        );
      }
    } on DioException catch (e) {
      final msg = _extractDioError(e);
      throw ChatException(msg);
    } catch (e) {
      if (e is ChatException) rethrow;
      throw ChatException('Đã xảy ra lỗi không mong muốn: $e');
    }
  }

  /// Kiem tra trang thai AI (health check).
  ///
  /// Tra ve [true] neu AI san sang, [false] neu co loi.
  Future<bool> checkHealth() async {
    try {
      final response = await ApiClient.get<Map<String, dynamic>>(
        '/ai/health',
      );

      final data = response.data;
      if (data == null) return false;
      return data['success'] == true;
    } catch (_) {
      return false;
    }
  }

  String _extractDioError(DioException e) {
    if (e.response != null) {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        final msg = data['message'] as String?;
        if (msg != null && msg.isNotEmpty) return msg;
      }
      return 'Lỗi server (HTTP ${e.response?.statusCode}).';
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Hết thời gian kết nối. Vui lòng kiểm tra mạng.';
      case DioExceptionType.sendTimeout:
        return 'Gửi yêu cầu quá lâu. Vui lòng thử lại.';
      case DioExceptionType.receiveTimeout:
        return 'Nhận phản hồi quá lâu. Vui lòng thử lại.';
      case DioExceptionType.connectionError:
        return 'Không thể kết nối server. Vui lòng kiểm tra mạng.';
      default:
        return 'Đã xảy ra lỗi kết nối. Vui lòng thử lại.';
    }
  }
}

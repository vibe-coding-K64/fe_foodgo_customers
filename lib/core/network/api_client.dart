import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../utils/auth_storage.dart';

/// Interceptor tu dong gan token va refresh token khi het han.
///
/// Gan header `Authorization: Bearer <token>` cho moi request.
/// Neu server tra ve 401, tu dong dung refreshToken de lay token moi roi retry.
class AuthInterceptor extends Interceptor {
  AuthInterceptor._();

  static final AuthInterceptor instance = AuthInterceptor._();

  bool _isRefreshing = false;
  final List<_QueuedRequest> _pendingRequests = [];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = AuthStorage.getToken();
    if (token != null && token.isNotEmpty) {
      final tokenType = AuthStorage.getTokenType() ?? 'Bearer';
      options.headers['Authorization'] = '$tokenType $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    if (_isRefreshing) {
      _enqueue(err, handler);
      return;
    }

    _isRefreshing = true;

    try {
      final refreshed = await _refreshToken();
      if (refreshed) {
        _retryPendingRequests();
        handler.next(err);
      } else {
        await AuthStorage.clearAuth();
        _rejectPendingRequests(err);
        handler.next(err);
      }
    } catch (e) {
      await AuthStorage.clearAuth();
      _rejectPendingRequests(err);
      handler.next(err);
    } finally {
      _isRefreshing = false;
      _pendingRequests.clear();
    }
  }

  Future<bool> _refreshToken() async {
    final refreshToken = AuthStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return false;

    try {
      final dio = Dio(BaseOptions(
        baseUrl: ApiClient._baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ));

      final response = await dio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      final data = response.data;
      if (data == null) return false;

      final newToken = data['token'] as String?;
      final newExpiresIn = data['expiresIn'] as int? ?? 0;
      final newRefreshToken = data['refreshToken'] as String? ?? '';
      final newRefreshExpiresIn = data['refreshExpiresIn'] as int? ?? 0;
      final newTokenType = data['tokenType'] as String? ?? 'Bearer';

      if (newToken == null || newToken.isEmpty) return false;

      final user = AuthStorage.getUser();
      if (user != null) {
        await AuthStorage.saveAuthData(
          token: newToken,
          tokenType: newTokenType,
          user: user,
          expiresIn: newExpiresIn,
          refreshToken: newRefreshToken,
          refreshExpiresIn: newRefreshExpiresIn,
        );
      }

      return true;
    } catch (e) {
      debugPrint('AuthInterceptor: Refresh token failed - $e');
      return false;
    }
  }

  void _enqueue(DioException err, ErrorInterceptorHandler handler) {
    _pendingRequests.add(_QueuedRequest(err, handler));
  }

  void _retryPendingRequests() {
    for (final req in _pendingRequests) {
      req.handler.next(req.error);
    }
  }

  void _rejectPendingRequests(DioException err) {
    for (final req in _pendingRequests) {
      req.handler.next(err);
    }
  }
}

class _QueuedRequest {
  final DioException error;
  final ErrorInterceptorHandler handler;

  _QueuedRequest(this.error, this.handler);
}

/// Client HTTP su dung Dio de goi cac API tu my-json-server.
///
/// Chi dinh Base URL va cac tham so mac dinh tai day.
class ApiClient {
  ApiClient._();

  /// Base URL cua API my-json-server.
  // static const String _baseUrl =
  //     'https://my-json-server.typicode.com/ngominhkhoi05/foodgo-mock-api';
  static const String _baseUrl =
      'http://192.168.1.200:8080/api';

  /// Dio instance dung chung, khoi tao lazy (chi khi can).
  static Dio? _dio;

  /// Lay Dio instance, khoi tao neu chua co.
  static Dio get instance {
    _dio ??= Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Chi them interceptor log khi o che do debug.
    if (kDebugMode) {
      _dio!.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (obj) => debugPrint('[ApiClient] $obj'),
        ),
      );
    }

    // AuthInterceptor luon duoc them de tu dong gan token va refresh token.
    if (!_dio!.interceptors.any((i) => i is AuthInterceptor)) {
      _dio!.interceptors.add(AuthInterceptor.instance);
    }

    return _dio!;
  }

  /// Phuong thuc GET, ho tro truyen query parameters.
  ///
  /// [path]    : Duong dan endpoint (VD: "/nearby_stores").
  /// [queryParameters] : Cac tham so query (VD: {"q": "pho"}).
  /// [options] : Cac tuy chon them (headers, timeout, ...).
  ///
  /// Tra ve [Response] cua Dio.
  static Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    debugPrint('[ApiClient] GET $path | params: $queryParameters');
    return instance.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Phuong thuc POST.
  static Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    debugPrint('[ApiClient] POST $path | data: $data');
    return instance.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Phuong thuc PUT.
  static Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    debugPrint('[ApiClient] PUT $path | data: $data');
    return instance.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Phuong thuc DELETE.
  static Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    debugPrint('[ApiClient] DELETE $path');
    return instance.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

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
    if (kDebugMode && _dio!.interceptors.isEmpty) {
      _dio!.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (obj) => debugPrint('[ApiClient] $obj'),
        ),
      );
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

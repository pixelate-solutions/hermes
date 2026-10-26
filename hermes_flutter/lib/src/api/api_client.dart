import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../config/app_config.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient()
      : _dio = Dio(
          BaseOptions(
            baseUrl: AppConfig.apiUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 30),
            headers: {'Content-Type': 'application/json'},
          ),
        );

  final Dio _dio;

  Options _options(String? token, {ResponseType? responseType}) {
    return Options(
      responseType: responseType,
      headers: {
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );
  }

  Future<Map<String, dynamic>> getJson(
    String path, {
    String? token,
    Map<String, dynamic>? query,
  }) async {
    final data = await _guard(() => _dio.get(path,
        queryParameters: query, options: _options(token)));
    return Map<String, dynamic>.from(data.data as Map);
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    String? token,
    Object? body,
  }) async {
    final data =
        await _guard(() => _dio.post(path, data: body, options: _options(token)));
    return Map<String, dynamic>.from(data.data as Map);
  }

  Future<Map<String, dynamic>> putJson(
    String path, {
    String? token,
    Object? body,
  }) async {
    final data =
        await _guard(() => _dio.put(path, data: body, options: _options(token)));
    return Map<String, dynamic>.from(data.data as Map);
  }

  Future<Uint8List> getBytes(String path, {String? token}) async {
    final data = await _guard(
      () => _dio.get<List<int>>(
        path,
        options: _options(token, responseType: ResponseType.bytes),
      ),
    );
    return Uint8List.fromList(data.data ?? const []);
  }

  Future<Response<T>> _guard<T>(Future<Response<T>> Function() request) async {
    try {
      return await request();
    } on DioException catch (error) {
      final response = error.response;
      final body = response?.data;
      var message = error.message ?? 'Request failed';
      if (body is Map && body['detail'] != null) {
        message = body['detail'].toString();
      } else if (body is String && body.isNotEmpty) {
        message = body;
      }
      throw ApiException(message, statusCode: response?.statusCode);
    }
  }
}

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@Singleton()
class DioSettingsAuth {
  DioSettingsAuth() {
    _setup();
  }

  final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'http://207.126.161.154:8000/api/v1/',
      contentType: 'application/json',
      headers: {'Content-Type': 'application/json'},
      connectTimeout: const Duration(seconds: 40),
      receiveTimeout: const Duration(seconds: 40),
    ),
  );

  void _setup() {
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true),
      );
    }
  }
}

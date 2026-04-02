import "dart:async";

import "package:dio/dio.dart";
import "package:flutter/foundation.dart";
import "package:injectable/injectable.dart";

@Singleton()
class DioSettingsBackend {
  DioSettingsBackend() {
    setup();
  }

  Dio dio = Dio(
    BaseOptions(
      baseUrl: 'http://78.138.17.28/api/v1/',
      // baseUrl: 'http://localhost:8000/api/v1/',
      contentType: 'application/json',
      headers: {'Content-Type': 'application/json'},
      connectTimeout: const Duration(seconds: 40),
      receiveTimeout: const Duration(seconds: 40),
    ),
  );

  Future<void> setup() async {
    final interceptors = dio.interceptors;

    interceptors.cast();

    final logInterceptor = LogInterceptor(
      requestBody: true,
      responseBody: true,
    );
    final headerInterceptors = QueuedInterceptorsWrapper(
      onRequest: (options, handler) => handler.next(options),
      onError: (DioException error, handler) {
        handler.next(error);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
    );
    interceptors.addAll([if (kDebugMode) logInterceptor, headerInterceptors]);
  }
}

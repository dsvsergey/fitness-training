import "dart:async";

import "package:dio/dio.dart";
import "package:flutter/foundation.dart";

import "../const.dart";

class DioSettings {
  DioSettings() {
    setup();
  }

  Dio dio = Dio(
    BaseOptions(
      baseUrl:
          'https://api.mindbodyonline.com/public/v${AppConsts.apiVersion}/',
      contentType: 'application/json',
      headers: {
        'Content-Type': 'application/json',
        'SiteId': AppConsts.siteId,
        'Api-Key': AppConsts.apiKey,
      },
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

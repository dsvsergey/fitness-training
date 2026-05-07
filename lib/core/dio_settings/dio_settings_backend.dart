import "dart:async";

import "package:dio/dio.dart";
import "package:flutter/foundation.dart";
import "package:get_it/get_it.dart";
import "package:injectable/injectable.dart";

import "../bloc/bloc_application/application_bloc.dart";

@Singleton()
class DioSettingsBackend {
  DioSettingsBackend() {
    setup();
  }

  Dio dio = Dio(
    BaseOptions(
      baseUrl: 'http://207.126.161.154:8000/api/v1/',
      contentType: 'application/json',
      headers: {'Content-Type': 'application/json'},
      connectTimeout: const Duration(seconds: 40),
      receiveTimeout: const Duration(seconds: 40),
    ),
  );

  Future<void> setup() async {
    final logInterceptor = LogInterceptor(
      requestBody: true,
      responseBody: true,
    );
    final authInterceptor = QueuedInterceptorsWrapper(
      onRequest: (options, handler) {
        if (!options.headers.containsKey('Authorization')) {
          final token = GetIt.I<ApplicationBloc>().state.user?.token;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        }
        handler.next(options);
      },
      onError: (DioException error, handler) {
        final status = error.response?.statusCode;
        if (status == 401 || status == 403) {
          final bloc = GetIt.I<ApplicationBloc>();
          if (bloc.state.isAuth) {
            bloc.add(LogoutEvent());
          }
        }
        handler.next(error);
      },
      onResponse: (response, handler) => handler.next(response),
    );
    dio.interceptors.addAll([if (kDebugMode) logInterceptor, authInterceptor]);
  }
}

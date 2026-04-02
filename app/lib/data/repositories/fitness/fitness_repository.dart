import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../domain/exception/application_exception.dart';
import '../../../domain/exception/auth_exception.dart';
import '../../../domain/exception/connection_exception.dart';

mixin FitnessRepository {
  dynamic onException(dynamic onError) {
    if (onError is TimeoutException || onError is SocketException) {
      debugPrint('Connection error: ${onError.message}');
      throw ConnectionException(massage: onError.message);
    } else if (onError is DioException) {
      final statusCode = onError.response?.statusCode ?? 0;
      final responseData = onError.response?.data;
      final message = responseData is Map ? responseData['detail'] ?? '' : '';

      debugPrint('DioException: Status Code: $statusCode');
      debugPrint('Response Data: $responseData');

      if (statusCode == 401 || statusCode == 403) {
        throw AuthException(massage: message);
      } else if (statusCode >= 400 && statusCode < 500) {
        throw ApplicationException(massage: message);
      } else if (statusCode >= 500) {
        throw ApplicationException(massage: 'Server error: $message');
      }
    }

    debugPrint('Unhandled error: $onError');
    throw ApplicationException(massage: onError.toString());
  }
}

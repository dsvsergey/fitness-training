// Verifies that clearing the client comment (trainee notes) reaches the
// backend: updateTrainee strips null fields, and the backend only updates the
// keys it receives, so notes must be sent as an explicit null.

import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:fitness_training/core/dio_settings/dio_settings_backend.dart';
import 'package:fitness_training/data/models/fitness/trainee_model.dart';
import 'package:fitness_training/data/repositories/fitness/trainee.dart';
import 'package:flutter_test/flutter_test.dart';

class _CapturingAdapter implements HttpClientAdapter {
  RequestOptions? captured;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    captured = options;
    return ResponseBody.fromString(
      jsonEncode({
        'id': 7,
        'first_name': 'Ann',
        'last_name': 'Lee',
        'photo_url': 'https://api.example.com/media/avatars/trainee_7_ab.png',
      }),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// Builds a backend whose interceptors are stripped: the auth interceptor
/// reaches into GetIt for ApplicationBloc, which is not registered in tests.
(DioSettingsBackend, _CapturingAdapter) _backend() {
  final backend = DioSettingsBackend();
  final adapter = _CapturingAdapter();
  backend.dio.interceptors.clear();
  backend.dio.httpClientAdapter = adapter;
  return (backend, adapter);
}

void main() {
  test('cleared notes are sent as an explicit null', () async {
    final (backend, adapter) = _backend();
    final repository = TraineeRepositoryImpl(fitness: backend);

    await repository.updateTrainee(
      7,
      TraineeModel((b) => b
        ..id = 7
        ..firstName = 'Ann'),
    );

    final data = adapter.captured!.data as Map<String, dynamic>;
    expect(data.containsKey('notes'), isTrue);
    expect(data['notes'], isNull);
    expect(data.containsKey('photo_url'), isFalse);
  });

  test('notes are sent as is', () async {
    final (backend, adapter) = _backend();
    final repository = TraineeRepositoryImpl(fitness: backend);

    await repository.updateTrainee(
      7,
      TraineeModel((b) => b
        ..id = 7
        ..notes = 'Bad knee'),
    );

    final data = adapter.captured!.data as Map<String, dynamic>;
    expect(data['notes'], 'Bad knee');
  });
}

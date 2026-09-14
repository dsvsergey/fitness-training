// Verifies the trainee avatar request shape.
//
// Same trap as the coach upload (see coach_repository_avatar_test.dart):
// DioSettingsBackend hardcodes `contentType: 'application/json'` in its
// BaseOptions, so a FormData request that does not override it per call is
// mislabelled and rejected by the server.

import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:fitness_training/core/dio_settings/dio_settings_backend.dart';
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
  test('uploadAvatar posts multipart form data to the trainee avatar endpoint',
      () async {
    final (backend, adapter) = _backend();
    final repository = TraineeRepositoryImpl(fitness: backend);

    await repository.uploadAvatar(7, Uint8List.fromList([1, 2, 3]), 'a.png');

    expect(adapter.captured!.method, 'POST');
    expect(adapter.captured!.path, '/trainees/7/avatar/');
    expect(adapter.captured!.data, isA<FormData>());
    expect(adapter.captured!.contentType, contains('multipart/form-data'));
  });

  test('uploadAvatar sends the bytes under the "file" field', () async {
    final (backend, adapter) = _backend();
    final repository = TraineeRepositoryImpl(fitness: backend);

    await repository.uploadAvatar(7, Uint8List.fromList([1, 2, 3]), 'a.png');

    final form = adapter.captured!.data as FormData;
    expect(form.files.single.key, 'file');
    expect(form.files.single.value.filename, 'a.png');
  });

  test('uploadAvatar returns the trainee parsed from the response', () async {
    final (backend, _) = _backend();
    final repository = TraineeRepositoryImpl(fitness: backend);

    final trainee = await repository.uploadAvatar(
      7,
      Uint8List.fromList([1, 2, 3]),
      'a.png',
    );

    expect(
      trainee.photoUrl,
      'https://api.example.com/media/avatars/trainee_7_ab.png',
    );
  });

  test('deleteAvatar sends DELETE to the trainee avatar endpoint', () async {
    final (backend, adapter) = _backend();
    final repository = TraineeRepositoryImpl(fitness: backend);

    await repository.deleteAvatar(7);

    expect(adapter.captured!.method, 'DELETE');
    expect(adapter.captured!.path, '/trainees/7/avatar/');
  });
}

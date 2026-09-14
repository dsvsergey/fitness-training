// Verifies the avatar upload request shape.
//
// DioSettingsBackend hardcodes `contentType: 'application/json'` in its
// BaseOptions, so a FormData request that does not override it per call is
// mislabelled and rejected by the server. That override is easy to drop during
// a refactor and invisible in review, hence this test.

import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:fitness_training/core/dio_settings/dio_settings_backend.dart';
import 'package:fitness_training/data/repositories/fitness/coach.dart';
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
      jsonEncode({'id': 1, 'image_url': 'https://api.example.com/media/a.png'}),
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
  test('uploadAvatar posts multipart form data to /coaches/me/avatar/',
      () async {
    final (backend, adapter) = _backend();
    final repository = CoachRepositoryImpl(fitness: backend);

    await repository.uploadAvatar(
      Uint8List.fromList([1, 2, 3]),
      'avatar.png',
    );

    expect(adapter.captured!.method, 'POST');
    expect(adapter.captured!.path, '/coaches/me/avatar/');
    expect(adapter.captured!.data, isA<FormData>());
    expect(adapter.captured!.contentType, contains('multipart/form-data'));
  });

  test('uploadAvatar sends the bytes under the "file" field', () async {
    final (backend, adapter) = _backend();
    final repository = CoachRepositoryImpl(fitness: backend);

    await repository.uploadAvatar(
      Uint8List.fromList([1, 2, 3]),
      'avatar.png',
    );

    final form = adapter.captured!.data as FormData;
    expect(form.files.single.key, 'file');
    expect(form.files.single.value.filename, 'avatar.png');
  });

  test('uploadAvatar returns the coach parsed from the response', () async {
    final (backend, _) = _backend();
    final repository = CoachRepositoryImpl(fitness: backend);

    final coach = await repository.uploadAvatar(
      Uint8List.fromList([1, 2, 3]),
      'avatar.png',
    );

    expect(coach.imageUrl, 'https://api.example.com/media/a.png');
  });

  test('deleteAvatar sends DELETE to /coaches/me/avatar/', () async {
    final (backend, adapter) = _backend();
    final repository = CoachRepositoryImpl(fitness: backend);

    await repository.deleteAvatar();

    expect(adapter.captured!.method, 'DELETE');
    expect(adapter.captured!.path, '/coaches/me/avatar/');
  });
}

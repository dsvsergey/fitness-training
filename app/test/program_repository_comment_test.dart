// Verifies that clearing a program comment reaches the backend.
//
// built_value drops null fields from toJson, and the backend's PUT only
// updates keys it receives (model_dump(exclude_unset=True)), so a cleared
// comment must be sent as an explicit null or the old text stays.

import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:fitness_training/core/dio_settings/dio_settings_backend.dart';
import 'package:fitness_training/data/models/fitness/program_fitness_model.dart';
import 'package:fitness_training/data/repositories/fitness/program_fitness.dart';
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
      jsonEncode({'id': 3, 'name': 'Program A'}),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late _CapturingAdapter adapter;
  late ProgramFitnessRepositoryImpl repository;

  setUp(() {
    final backend = DioSettingsBackend();
    adapter = _CapturingAdapter();
    // The auth interceptor reaches into GetIt, which is empty in tests.
    backend.dio.interceptors.clear();
    backend.dio.httpClientAdapter = adapter;
    repository = ProgramFitnessRepositoryImpl(fitness: backend);
  });

  test('a cleared comment is sent as an explicit null', () async {
    await repository.updateProgram(
      3,
      ProgramFitnessModel((b) => b
        ..id = 3
        ..name = 'Program A'),
    );

    final data = adapter.captured!.data as Map<String, dynamic>;
    expect(data.containsKey('comment'), isTrue);
    expect(data['comment'], isNull);
  });

  test('a comment is sent as is', () async {
    await repository.updateProgram(
      3,
      ProgramFitnessModel((b) => b
        ..id = 3
        ..name = 'Program A'
        ..comment = 'Knee pain'),
    );

    final data = adapter.captured!.data as Map<String, dynamic>;
    expect(data['comment'], 'Knee pain');
  });
}

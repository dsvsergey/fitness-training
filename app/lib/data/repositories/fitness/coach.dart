import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../core/dio_settings/dio_settings_backend.dart';
import '../../models/fitness/fitness.dart';
import 'fitness.dart';

abstract class CoachRepository {
  Future<List<CoachModel>> getCoaches({
    int skip,
    int limit,
    String? authorization,
  });
  Future<CoachModel> getCoach(int coachId);
  Future<CoachModel> createCoach(CoachModel coach);
  Future<CoachModel> updateCoach(int coachId, CoachModel coach);
  Future<void> deleteCoach(int coachId);
  Future<CoachModel> uploadAvatar(Uint8List bytes, String filename);
  Future<CoachModel> deleteAvatar();
}

@Singleton(as: CoachRepository)
class CoachRepositoryImpl with FitnessRepository implements CoachRepository {
  final DioSettingsBackend fitness;

  CoachRepositoryImpl({required this.fitness});

  @override
  Future<List<CoachModel>> getCoaches({
    int skip = 0,
    int limit = 100,
    String? authorization,
  }) => fitness.dio
      .get(
        "/coaches/",
        queryParameters: {"skip": skip, "limit": limit},
        options: authorization != null
            ? Options(headers: {'Authorization': authorization})
            : null,
      )
      .then((value) {
        if (value.data is! List) {
          throw FormatException(
            'Expected List but got ${value.data.runtimeType}',
          );
        }
        return (value.data as List)
            .map((item) => CoachModel.fromJson(item as Map<String, dynamic>))
            .toList();
      })
      .catchError(onException);

  @override
  Future<CoachModel> getCoach(int coachId) => fitness.dio
      .get("/coaches/$coachId")
      .then((value) {
        if (value.data is! Map<String, dynamic>) {
          throw FormatException(
            'Expected Map but got ${value.data.runtimeType}',
          );
        }
        return CoachModel.fromJson(value.data);
      })
      .catchError(onException);

  @override
  Future<CoachModel> createCoach(CoachModel coach) => fitness.dio
      .post("/coaches/", data: coach.toJson())
      .then((value) {
        if (value.data is! Map<String, dynamic>) {
          throw FormatException(
            'Expected Map but got ${value.data.runtimeType}',
          );
        }
        return CoachModel.fromJson(value.data);
      })
      .catchError(onException);

  @override
  Future<CoachModel> updateCoach(int coachId, CoachModel coach) => fitness.dio
      .put("/coaches/me/", data: coach.toJson())
      .then((value) {
        if (value.data is! Map<String, dynamic>) {
          throw FormatException(
            'Expected Map but got ${value.data.runtimeType}',
          );
        }
        return CoachModel.fromJson(value.data);
      })
      .catchError(onException);

  @override
  Future<void> deleteCoach(int coachId) => fitness.dio
      .delete("/coaches/$coachId")
      .catchError(onException);

  @override
  Future<CoachModel> uploadAvatar(Uint8List bytes, String filename) {
    final form = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: filename),
    });

    return fitness.dio
        .post(
          "/coaches/me/avatar/",
          data: form,
          // BaseOptions pins application/json for every request; without this
          // override the multipart body is mislabelled and the upload fails.
          options: Options(contentType: 'multipart/form-data'),
        )
        .then((value) {
          if (value.data is! Map<String, dynamic>) {
            throw FormatException(
              'Expected Map but got ${value.data.runtimeType}',
            );
          }
          return CoachModel.fromJson(value.data);
        })
        .catchError(onException);
  }

  @override
  Future<CoachModel> deleteAvatar() => fitness.dio
      .delete("/coaches/me/avatar/")
      .then((value) {
        if (value.data is! Map<String, dynamic>) {
          throw FormatException(
            'Expected Map but got ${value.data.runtimeType}',
          );
        }
        return CoachModel.fromJson(value.data);
      })
      .catchError(onException);
}

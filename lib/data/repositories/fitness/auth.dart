import 'dart:async';

import 'package:injectable/injectable.dart';

import '../../../core/dio_settings/dio_settings_backend.dart';
import '../../models/fitness/fitness.dart';
import 'fitness.dart';

abstract class AuthRepository {
  Future<UserFitnessModel> login({
    required String username,
    required String password,
  });
}

@Singleton(as: AuthRepository)
class AuthRepositoryImpl extends AuthRepository with FitnessRepository {
  final DioSettingsBackend fitness;

  AuthRepositoryImpl({required this.fitness});

  @override
  Future<UserFitnessModel> login({
    required String username,
    required String password,
  }) =>
      fitness.dio.post(
        "/login/",
        data: {
          "Username": username,
          "Password": password,
        },
      ).then((value) {
        // Add default id since server doesn't return it
        final data = Map<String, dynamic>.from(value.data);
        if (!data.containsKey('id')) {
          data['id'] = 1; // Default user id
        }
        return UserFitnessModel.fromJson(data);
      }).catchError(onException);
}

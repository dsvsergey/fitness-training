import 'dart:async';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../core/dio_settings/dio_settings_auth.dart';
import '../../models/fitness/fitness.dart';
import 'fitness.dart';

abstract class AuthRepository {
  Future<UserFitnessModel> login({
    required String email,
    required String password,
  });

  Future<TraineeModel> register({
    required String email,
    required String firstName,
    required String lastName,
    required String password,
  });

  Future<String> getGoogleAuthUrl({String role = 'trainee'});

  Future<UserFitnessModel> getTraineeMe(String token);

  Future<UserFitnessModel> getCoachMe(String token);
}

@Singleton(as: AuthRepository)
class AuthRepositoryImpl extends AuthRepository with FitnessRepository {
  final DioSettingsAuth _auth;

  AuthRepositoryImpl({required DioSettingsAuth auth}) : _auth = auth;

  @override
  Future<UserFitnessModel> login({
    required String email,
    required String password,
  }) =>
      _auth.dio
          .post('/login/', data: {'email': email, 'password': password})
          .then(
            (r) => UserFitnessModel.fromJson(r.data as Map<String, dynamic>),
          )
          .catchError(onException);

  @override
  Future<TraineeModel> register({
    required String email,
    required String firstName,
    required String lastName,
    required String password,
  }) =>
      _auth.dio
          .post('/trainees/register/', data: {
            'email': email,
            'first_name': firstName,
            'last_name': lastName,
            'password': password,
          })
          .then(
            (r) => TraineeModel.fromJson(r.data as Map<String, dynamic>),
          )
          .catchError(onException);

  @override
  Future<String> getGoogleAuthUrl({String role = 'trainee'}) =>
      _auth.dio
          .get('/google/authorize', queryParameters: {'role': role})
          .then((r) => r.data['url'] as String)
          .catchError(onException);

  @override
  Future<UserFitnessModel> getTraineeMe(String token) =>
      _auth.dio
          .get(
            '/trainees/me/',
            options: Options(headers: {'Authorization': 'Bearer $token'}),
          )
          .then((r) => UserFitnessModel.fromJson({
                'access_token': token,
                'trainee': r.data,
              }))
          .catchError(onException);

  @override
  Future<UserFitnessModel> getCoachMe(String token) =>
      _auth.dio
          .get(
            '/coaches/me/',
            options: Options(headers: {'Authorization': 'Bearer $token'}),
          )
          .then((r) => UserFitnessModel.fromJson({
                'access_token': token,
                'coach': r.data,
              }))
          .catchError(onException);
}

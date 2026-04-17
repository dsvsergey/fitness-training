import 'dart:convert';

import 'package:fitness_training/data/models/fitness/fitness.dart';
import 'package:injectable/injectable.dart';

import '../../../data/repositories/fitness/fitness.dart';
import '../../entities/fitness/fitness.dart';

abstract class AuthUsecase {
  Future<UserFitnessEntity> login({
    required String email,
    required String password,
  });

  Future<TraineeEntity> register({
    required String email,
    required String firstName,
    required String lastName,
    required String password,
  });

  Future<String> getGoogleAuthUrl({String role = 'trainee'});

  Future<UserFitnessEntity> loginWithToken(String token);
}

@LazySingleton(as: AuthUsecase)
class AuthUsecaseImpl implements AuthUsecase {
  final AuthRepository _api;

  AuthUsecaseImpl({required AuthRepository api}) : _api = api;

  @override
  Future<UserFitnessEntity> login({
    required String email,
    required String password,
  }) =>
      _api.login(email: email, password: password).then((v) => v.entity);

  @override
  Future<TraineeEntity> register({
    required String email,
    required String firstName,
    required String lastName,
    required String password,
  }) =>
      _api
          .register(
            email: email,
            firstName: firstName,
            lastName: lastName,
            password: password,
          )
          .then((v) => v.entity);

  @override
  Future<String> getGoogleAuthUrl({String role = 'trainee'}) =>
      _api.getGoogleAuthUrl(role: role);

  @override
  Future<UserFitnessEntity> loginWithToken(String token) async {
    final parts = token.split('.');
    if (parts.length < 2) throw ArgumentError('Invalid JWT format');
    final payload = utf8.decode(
      base64Url.decode(base64Url.normalize(parts[1])),
    );
    final sub =
        (jsonDecode(payload) as Map<String, dynamic>)['sub'] as String? ?? '';
    final role = sub.split(':').first;
    final model = role == 'coach'
        ? await _api.getCoachMe(token)
        : await _api.getTraineeMe(token);
    return model.entity;
  }
}

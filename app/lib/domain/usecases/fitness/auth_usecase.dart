import 'package:fitness_training/data/models/fitness/fitness.dart';
import 'package:injectable/injectable.dart';

import '../../../data/repositories/fitness/fitness.dart';
import '../../entities/fitness/fitness.dart';

abstract class AuthUsecase {
  Future<UserFitnessEntity> login({
    required String username,
    required String password,
  });
}

@LazySingleton(as: AuthUsecase)
class AuthUsecaseImpl implements AuthUsecase {
  late final AuthRepository _api;

  AuthUsecaseImpl({required AuthRepository api}) : _api = api;

  @override
  Future<UserFitnessEntity> login(
          {required String username, required String password}) =>
      _api
          .login(username: username, password: password)
          .then((value) => value.entity);
}

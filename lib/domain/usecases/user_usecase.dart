import 'package:dio/dio.dart';

import '../../data/repositories/mindbody_repository.dart';
import '../../data/repositories/preferences_repository.dart';

class UserUsecase {
  final _preferences = PreferencesRepository();
  late final MindbodyRepository _api;
  final Dio dio;

  UserUsecase({required this.dio}) {
    _api = MindbodyRepository(dio: dio, getToken: _preferences.getToken);
  }

  Future<void> login({
    required String login,
    required String password,
  }) =>
      _api
          .login(
            username: login,
            password: password,
          )
          .then((value) => _preferences.saveToken(value));

  Future<void> logout() => _preferences.cleanToken();
}

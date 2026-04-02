import 'dart:convert';

import 'package:fitness_training/core/const.dart';
import 'package:fitness_training/data/models/mindbody/token_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesRepository {
  Future<void> saveToken(TokenModel token) =>
      SharedPreferences.getInstance().then((value) =>
          value.setString(AppConsts.accessToken, jsonEncode(token.toJson())));

  Future<TokenModel?> getToken() => SharedPreferences.getInstance().then(
        (value) {
          if (value.getString(AppConsts.accessToken) == null) return null;
          return TokenModel.fromJson(
            jsonDecode(value.getString(AppConsts.accessToken) ?? ""),
          );
        },
      ).catchError((onError) {
        return null;
      });

  Future<void> cleanToken() => SharedPreferences.getInstance()
      .then((value) => value.remove(AppConsts.accessToken));
}

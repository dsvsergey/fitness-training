import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fitness_training/data/models/mindbody/appointments_model.dart';
import 'package:fitness_training/data/models/mindbody/clients_model.dart';
import 'package:fitness_training/data/models/mindbody/locations_model.dart';
import 'package:fitness_training/data/models/mindbody/token_model.dart';
import 'package:fitness_training/data/models/mindbody/visits_model.dart';
import 'package:fitness_training/domain/exception/application_exception.dart';
import 'package:fitness_training/domain/exception/auth_exception.dart';
import 'package:fitness_training/domain/exception/connection_exception.dart';
import 'package:flutter/material.dart';

class MindbodyRepository {
  MindbodyRepository({
    required this.getToken,
    required this.dio,
  });
  final Dio dio;
  final ValueGetter<Future<TokenModel?>> getToken;

  Future<TokenModel> login({
    required String username,
    required String password,
  }) =>
      dio.post(
        "usertoken/issue",
        data: {
          "username": username,
          "password": password,
        },
      ).then((value) {
        return TokenModel.fromJson(value.data);
      }).catchError(_onException);

  Future<ClientsModel> getClients({List<String>? clientIDs}) =>
      getToken().then((value) => dio.get('client/clients',
              options: Options(headers: {
                'authorization': '${value!.tokenType} ${value.accessToken}'
              }),
              queryParameters: {
                'request.clientIDs': clientIDs ?? [],
              }).then((value) {
            final result = ClientsModel.fromJson(value.data);
            return result;
          }).catchError(_onException));

  Future<AppointmentsModel> getAppointments({
    String? staffId,
    int limit = 100,
    int offset = 0,
    DateTime? endDate,
    DateTime? startDate,
    List<int>? locationId,
  }) =>
      getToken().then((value) => dio.get('appointment/staffappointments',
              options: Options(
                headers: {
                  'authorization': '${value!.tokenType} ${value.accessToken}'
                },
              ),
              queryParameters: {
                'request.locationIds': locationId ?? List<int>.empty(),
                if (startDate != null)
                  'request.startDate': startDate.toIso8601String(),
                if (endDate != null)
                  'request.endDate': endDate.toIso8601String(),
                'request.limit': limit,
                'request.offset': offset,
                'request.staffIds': [if (staffId != null) staffId],
              }).then(
            (value) {
              return AppointmentsModel.fromJson(value.data);
            },
          ).catchError(_onException));

  Future<LocationsModel> getlocations({String? clientId}) =>
      getToken().then((value) => dio.get('site/locations',
              options: Options(
                headers: {
                  'authorization': '${value!.tokenType} ${value.accessToken}'
                },
              ),
              queryParameters: {
                'request.clientId': clientId ?? [],
              }).then((value) {
            return LocationsModel.fromJson(value.data);
          }).catchError(_onException));

  Future<VisitsModel> getVisits(String clientId) =>
      getToken().then((value) => dio.get('client/clientvisits',
              options: Options(
                headers: {
                  'authorization': '${value!.tokenType} ${value.accessToken}'
                },
              ),
              queryParameters: {
                'request.clientId': clientId,
              }).then((value) {
            return VisitsModel.fromJson(value.data);
          }).catchError(_onException));

  dynamic _onException(dynamic onError) {
    if (onError is TimeoutException || onError is SocketException) {
      throw ConnectionException(massage: onError.message);
    } else if (onError is DioException &&
        (onError.response?.statusCode ?? 0) >= 400 &&
        (onError.response?.statusCode ?? 0) < 500) {
      final massage = jsonDecode(onError.response?.toString() ?? '');
      throw AuthException(massage: massage['Error']['Message'] ?? '');
    }
    throw ApplicationException(
      massage: onError.toString(),
    );
  }
}

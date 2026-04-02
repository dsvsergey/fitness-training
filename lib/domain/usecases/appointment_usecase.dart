import 'dart:math';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';

import '../../data/models/mindbody/client_model.dart' as data;
import '../../data/repositories/mindbody_repository.dart';
import '../../data/repositories/preferences_repository.dart';
import '../entities/appointment_entity.dart';
import '../entities/client_entity.dart';

class AppointmentUsecase {
  late final MindbodyRepository _api;
  final _preferences = PreferencesRepository();
  final Dio dio;
  AppointmentUsecase({required this.dio}) {
    _api = MindbodyRepository(dio: dio, getToken: _preferences.getToken);
  }

  Future<List<AppointmentEntity>> getAppointment() async {
    final appointments = await _api.getAppointments(
      staffId: '100000055',
      limit: 100,
      offset: 0,
      endDate: DateTime.now(),
      startDate: DateTime.now(),
      locationId: [],
    );
    final clientIds = appointments.appointments?.map((e) => e.clientId).toSet();
    // final clients = await _api.getClients(
    //     clientIDs: clientIds
    //         .toList()
    //         .getRange(0, min(19, clientIds.length - 1))
    //         .toList());
    final clients = List<data.ClientModel>.empty(growable: true);
    const chunkSize = 20;
    final numberOfChunks = (clientIds!.length / chunkSize).ceil();
    // final a = (clientIds.length ~/ 20).floor();
    for (var i = 0; i < numberOfChunks; i++) {
      final start = i * chunkSize;
      final endMax = min((i + 1) * chunkSize, clientIds.length);
      final nonNullableClientIds = clientIds
          .toList()
          .getRange(start, endMax)
          .whereType<String>()
          .toList();
      final c = await _api.getClients(
        clientIDs: nonNullableClientIds,
      );
      clients.addAll(c.clients?.cast() ?? []);
    }
    return List.generate(appointments.appointments!.length, (index) {
      final appointment = appointments.appointments?[index];
      final client = clients
          .firstWhereOrNull((element) => element.id == appointment?.clientId);
      return AppointmentEntity(
        date: appointment?.startDateTime ?? DateTime.now(),
        client: client != null
            ? ClientEntity(
                id: client.id!,
                name: '${client.firstName} ${client.lastName}',
                weight: 0,
                height: 0,
                phoneNumber: client.mobilePhone,
              )
            : null,
      );
    });
  }

  Future<List<ClientEntity>> getClients() async {
    final clients = await _api.getClients();
    return List.generate(clients.clients?.length ?? 0, (index) {
      final client = clients.clients?[index];
      return ClientEntity(
        id: '',
        name: '${client?.firstName} ${client?.lastName}',
        weight: 0,
        height: 0,
        phoneNumber: client?.mobilePhone,
      );
    });
  }
}

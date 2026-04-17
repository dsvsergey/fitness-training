import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import '../../../core/bloc/bloc_application/application_bloc.dart';
import '../../../core/dio_settings/dio_settings_backend.dart';
import '../../models/fitness/fitness.dart';
import 'fitness.dart';

abstract class MachineRepository {
  Future<List<MachineModel>> getMachines({int skip = 0, int limit = 100});
  Future<MachineModel> getMachine(int machineId);
  Future<MachineModel> createMachine(MachineModel machine);
  Future<MachineModel> updateMachine(int machineId, MachineModel machine);
  Future<void> deleteMachine(int machineId);
}

@Singleton(as: MachineRepository)
class MachineRepositoryImpl
    with FitnessRepository
    implements MachineRepository {
  final DioSettingsBackend fitness;
  MachineRepositoryImpl({required this.fitness});

  @override
  Future<List<MachineModel>> getMachines({
    int skip = 0,
    int limit = 100,
  }) async {
    try {
      final response = await fitness.dio.get(
        "/machines/",
        queryParameters: {"skip": skip, "limit": limit},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization':
                GetIt.I<ApplicationBloc>().state.user?.authorization,
          },
        ),
      );
      return (response.data as List)
          .map((item) => MachineModel.fromJson(item))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      return onException(e);
    }
  }

  @override
  Future<MachineModel> getMachine(int machineId) => fitness.dio
      .get(
        "/machines/$machineId",
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization':
                GetIt.I<ApplicationBloc>().state.user?.authorization,
          },
        ),
      )
      .then((value) {
        return MachineModel.fromJson(value.data);
      })
      .catchError(onException);

  @override
  Future<MachineModel> createMachine(MachineModel machine) => fitness.dio
      .post(
        "/machines/",
        data: machine.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization':
                GetIt.I<ApplicationBloc>().state.user?.authorization,
          },
        ),
      )
      .then((value) {
        return MachineModel.fromJson(value.data);
      })
      .catchError(onException);

  @override
  Future<MachineModel> updateMachine(int machineId, MachineModel machine) =>
      fitness.dio
          .put(
            "/machines/$machineId",
            data: machine.toJson(),
            options: Options(
              headers: {
                'Content-Type': 'application/json',
                'Authorization':
                    GetIt.I<ApplicationBloc>().state.user?.authorization,
              },
            ),
          )
          .then((value) {
            return MachineModel.fromJson(value.data);
          })
          .catchError(onException);

  @override
  Future<void> deleteMachine(int machineId) => fitness.dio
      .delete(
        "/machines/$machineId",
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization':
                GetIt.I<ApplicationBloc>().state.user?.authorization,
          },
        ),
      )
      .catchError(onException);
}

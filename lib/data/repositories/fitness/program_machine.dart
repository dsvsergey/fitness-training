import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import '../../../core/bloc/bloc_application/application_bloc.dart';
import '../../../core/dio_settings/dio_settings_backend.dart';
import '../../models/fitness/fitness.dart';
import 'fitness.dart';

abstract class ProgramMachineRepository {
  Future<List<ProgramMachineModel>> getProgramMachines({
    int skip = 0,
    int limit = 100,
  });
  Future<ProgramMachineModel?> getProgramMachine(int programMachineId);
  Future<ProgramMachineModel?> getProgramMachineByProgramAndMachine(
      int programId, int machineId);
  Future<ProgramMachineModel> createProgramMachine(
      ProgramMachineModel programMachine);
  Future<ProgramMachineModel> updateProgramMachine(
      int programMachineId, ProgramMachineModel programMachine);
  Future<void> deleteProgramMachine(int programMachineId);
}

@Singleton(as: ProgramMachineRepository)
class ProgramMachineRepositoryImpl
    with FitnessRepository
    implements ProgramMachineRepository {
  final DioSettingsBackend fitness;
  ProgramMachineRepositoryImpl({required this.fitness});

  @override
  Future<List<ProgramMachineModel>> getProgramMachines({
    int skip = 0,
    int limit = 100,
  }) =>
      fitness.dio
          .get(
        "/program-machines/",
        queryParameters: {
          "skip": skip,
          "limit": limit,
        },
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': GetIt.I<ApplicationBloc>().state.user?.authorization,
        }),
      )
          .then((value) {
        return (value.data as List)
            .map((item) => ProgramMachineModel.fromJson(item))
            .toList();
      }).catchError(onException);

  @override
  Future<ProgramMachineModel?> getProgramMachine(int programMachineId) =>
      fitness.dio
          .get(
        "/program-machines/$programMachineId",
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': GetIt.I<ApplicationBloc>().state.user?.authorization,
        }),
      )
          .then((value) {
        return ProgramMachineModel.fromJson(value.data);
      }).catchError(onException);

  @override
  Future<ProgramMachineModel> createProgramMachine(
          ProgramMachineModel programMachine) =>
      fitness.dio
          .post(
        "/program-machines/",
        data: programMachine.toJson(),
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': GetIt.I<ApplicationBloc>().state.user?.authorization,
        }),
      )
          .then((value) {
        return ProgramMachineModel.fromJson(value.data);
      }).catchError(onException);

  @override
  Future<ProgramMachineModel> updateProgramMachine(
          int programMachineId, ProgramMachineModel programMachine) =>
      fitness.dio
          .put(
        "/program-machines/$programMachineId",
        data: programMachine.toJson(),
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': GetIt.I<ApplicationBloc>().state.user?.authorization,
        }),
      )
          .then((value) {
        return ProgramMachineModel.fromJson(value.data);
      }).catchError(onException);

  @override
  Future<void> deleteProgramMachine(int programMachineId) => fitness.dio
      .delete(
        "/program-machines/$programMachineId",
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': GetIt.I<ApplicationBloc>().state.user?.authorization,
        }),
      )
      .catchError(onException);

  @override
  Future<ProgramMachineModel?> getProgramMachineByProgramAndMachine(
          int programId, int machineId) =>
      fitness.dio
          .get(
            "/program-machines/program/$programId/machine/$machineId/",
            options: Options(headers: {
              'Content-Type': 'application/json',
              'Authorization':
                  GetIt.I<ApplicationBloc>().state.user?.authorization,
            }),
          )
          .then((value) => ProgramMachineModel.fromJson(value.data));
}

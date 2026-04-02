import 'package:fitness_training/data/models/fitness/fitness.dart';
import 'package:injectable/injectable.dart';

import '../../../data/repositories/fitness/fitness.dart';
import '../../entities/fitness/fitness.dart';

abstract class WorkoutAppointmentUsecase {
  Future<WorkoutAppointmentResultEntity> getAllWorkoutAppointments({
    WorkoutAppointmentFilterEntity? filter,
    int skip,
    int limit,
  });
  Future<WorkoutAppointmentEntity> getWorkoutAppointment(int appointmentId);
  Future<WorkoutAppointmentEntity> createWorkoutAppointment(
      WorkoutAppointmentEntity appointment);
  Future<WorkoutAppointmentEntity> updateWorkoutAppointment(
      int appointmentId, WorkoutAppointmentEntity appointment);
  Future<void> deleteWorkoutAppointment(int appointmentId);
  Future<WorkoutAppointmentEntity> setWorkoutCompleted(int appointmentId);
}

@LazySingleton(as: WorkoutAppointmentUsecase)
class WorkoutAppointmentUsecaseImpl implements WorkoutAppointmentUsecase {
  final WorkoutAppointmentRepository _api;

  WorkoutAppointmentUsecaseImpl({required WorkoutAppointmentRepository api})
      : _api = api;

  @override
  Future<WorkoutAppointmentEntity> createWorkoutAppointment(
          WorkoutAppointmentEntity appointment) =>
      _api
          .createWorkoutAppointment(appointment.model)
          .then((value) => value.entity);

  @override
  Future<void> deleteWorkoutAppointment(int appointmentId) =>
      _api.deleteWorkoutAppointment(appointmentId);

  @override
  Future<WorkoutAppointmentResultEntity> getAllWorkoutAppointments(
          {int skip = 0,
          int limit = 1000,
          WorkoutAppointmentFilterEntity? filter}) =>
      _api
          .getAllWorkoutAppointments(
              skip: skip,
              limit: limit,
              filter: filter?.model ??
                  WorkoutAppointmentFilterEntity((p) => p
                    ..startDate = DateTime(DateTime.now().year,
                            DateTime.now().month, DateTime.now().day)
                        .toString()).model)
          .then((value) => value.entity);

  @override
  Future<WorkoutAppointmentEntity> getWorkoutAppointment(int appointmentId) =>
      _api.getWorkoutAppointment(appointmentId).then((value) => value.entity);

  @override
  Future<WorkoutAppointmentEntity> updateWorkoutAppointment(
          int appointmentId, WorkoutAppointmentEntity appointment) =>
      _api
          .updateWorkoutAppointment(appointmentId, appointment.model)
          .then((value) => value.entity);

  @override
  Future<WorkoutAppointmentEntity> setWorkoutCompleted(int appointmentId) =>
      _api.setWorkoutCompleted(appointmentId).then((value) => value.entity);
}

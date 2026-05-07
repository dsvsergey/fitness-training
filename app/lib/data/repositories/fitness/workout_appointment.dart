import 'package:built_collection/built_collection.dart';
import 'package:injectable/injectable.dart';

import '../../../core/dio_settings/dio_settings_backend.dart';
import '../../models/fitness/fitness.dart';
import 'fitness.dart';

abstract class WorkoutAppointmentRepository {
  Future<WorkoutAppointmentResultModel> getAllWorkoutAppointments({
    int skip,
    int limit,
    WorkoutAppointmentFilterModel filter,
  });
  Future<WorkoutAppointmentModel> getWorkoutAppointment(int appointmentId);
  Future<WorkoutAppointmentModel> createWorkoutAppointment(
      WorkoutAppointmentModel appointment);
  Future<WorkoutAppointmentModel> updateWorkoutAppointment(
      int appointmentId, WorkoutAppointmentModel appointment);
  Future<void> deleteWorkoutAppointment(int appointmentId);
  Future<WorkoutAppointmentModel> setWorkoutCompleted(int appointmentId);
}

@Singleton(as: WorkoutAppointmentRepository)
class WorkoutAppointmentRepositoryImpl
    with FitnessRepository
    implements WorkoutAppointmentRepository {
  final DioSettingsBackend fitness;
  WorkoutAppointmentRepositoryImpl({required this.fitness});

  @override
  Future<WorkoutAppointmentResultModel> getAllWorkoutAppointments({
    WorkoutAppointmentFilterModel? filter,
    int skip = 0,
    int limit = 100,
  }) =>
      fitness.dio
          .get(
            "/workout-appointments/",
            queryParameters: {"skip": skip, "limit": limit},
            data: filter?.toJson(),
          )
          .then((value) => value.data == null
              ? WorkoutAppointmentResultModel().rebuild((b) => b
                ..appointments = ListBuilder<WorkoutAppointmentModel>()
                ..workDays = ListBuilder<DateTime>())
              : WorkoutAppointmentResultModel.fromJson(value.data))
          .catchError(onException);

  @override
  Future<WorkoutAppointmentModel> getWorkoutAppointment(int appointmentId) =>
      fitness.dio
          .get("/workout-appointments/$appointmentId")
          .then((value) => WorkoutAppointmentModel.fromJson(value.data))
          .catchError(onException);

  @override
  Future<WorkoutAppointmentModel> createWorkoutAppointment(
          WorkoutAppointmentModel appointment) =>
      fitness.dio
          .post("/workout-appointments/", data: appointment.toJson())
          .then((value) => WorkoutAppointmentModel.fromJson(value.data))
          .catchError(onException);

  @override
  Future<WorkoutAppointmentModel> updateWorkoutAppointment(
          int appointmentId, WorkoutAppointmentModel appointment) =>
      fitness.dio
          .put(
            "/workout-appointments/$appointmentId",
            data: appointment.toJson(),
          )
          .then((value) => WorkoutAppointmentModel.fromJson(value.data))
          .catchError(onException);

  @override
  Future<void> deleteWorkoutAppointment(int appointmentId) => fitness.dio
      .delete("/workout-appointments/$appointmentId")
      .catchError(onException);

  @override
  Future<WorkoutAppointmentModel> setWorkoutCompleted(int appointmentId) =>
      fitness.dio
          .put("/workout-appointments/$appointmentId/completed")
          .then((value) => WorkoutAppointmentModel.fromJson(value.data))
          .catchError(onException);
}

part of 'program_screen_bloc.dart';

sealed class ProgramScreenEvent extends Equatable {
  const ProgramScreenEvent();

  @override
  List<Object> get props => [];
}

final class SetTraineeEvent extends ProgramScreenEvent {
  final TraineeEntity trainee;

  const SetTraineeEvent({required this.trainee});

  @override
  List<Object> get props => [trainee];
}

final class UpdateTraineeEvent extends ProgramScreenEvent {
  final TraineeEntity trainee;

  const UpdateTraineeEvent({required this.trainee});

  @override
  List<Object> get props => [trainee];
}

final class EditTraineeEvent extends ProgramScreenEvent {
  final TraineeEntity trainee;

  const EditTraineeEvent({required this.trainee});

  @override
  List<Object> get props => [trainee];
}

final class CancelEditTraineeEvent extends ProgramScreenEvent {
  final TraineeEntity trainee;

  const CancelEditTraineeEvent({required this.trainee});

  @override
  List<Object> get props => [trainee];
}

final class SaveEditTraineeEvent extends ProgramScreenEvent {
  final TraineeEntity trainee;

  const SaveEditTraineeEvent({required this.trainee});

  @override
  List<Object> get props => [trainee];
}

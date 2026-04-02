part of 'program_screen_bloc.dart';

sealed class ProgramScreenState extends Equatable {
  TraineeEntity? get trainee;
  const ProgramScreenState();

  @override
  List<Object> get props => [if (trainee != null) trainee!];
}

final class ProgramScreenInitial extends ProgramScreenState {
  @override
  TraineeEntity? get trainee => null;
}

final class CreateNewProgram extends ProgramScreenState {
  @override
  final TraineeEntity? trainee;

  CreateNewProgram(ProgramScreenState state) : trainee = state.trainee;
}

final class LoadedTrainee extends ProgramScreenState {
  @override
  final TraineeEntity trainee;

  const LoadedTrainee({required this.trainee});
}

final class EditingTrainee extends ProgramScreenState {
  @override
  final TraineeEntity? trainee;

  const EditingTrainee({required this.trainee});
}

final class SavingTrainee extends ProgramScreenState {
  @override
  final TraineeEntity? trainee;

  const SavingTrainee({required this.trainee});
}

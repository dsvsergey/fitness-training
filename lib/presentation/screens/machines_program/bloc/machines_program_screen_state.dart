part of 'machines_program_screen_bloc.dart';

sealed class MachinesProgramScreenState extends Equatable {
  const MachinesProgramScreenState();

  @override
  List<Object> get props => [];
}

final class MachinesProgramScreenInitial extends MachinesProgramScreenState {}

final class ProgramFitnessUpdated extends MachinesProgramScreenState {
  final ProgramFitnessEntity? program;

  const ProgramFitnessUpdated({required this.program});

  @override
  List<Object> get props => [if (program != null) program!];
}

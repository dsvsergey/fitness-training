part of 'machines_program_screen_bloc.dart';

sealed class MachinesProgramScreenEvent extends Equatable {
  const MachinesProgramScreenEvent();

  @override
  List<Object> get props => [];
}

final class ProgramFitnessUpdateEvent extends MachinesProgramScreenEvent {
  final int programId;

  const ProgramFitnessUpdateEvent({required this.programId});

  @override
  List<Object> get props => [programId];
}

final class ReorderMachinesEvent extends MachinesProgramScreenEvent {
  final int programId;
  final List<int> orderedIds;

  const ReorderMachinesEvent({
    required this.programId,
    required this.orderedIds,
  });

  @override
  List<Object> get props => [programId, orderedIds];
}

part of 'create_program_bloc.dart';

sealed class CreateProgramState extends Equatable {
  List<MachineEntity>? get machines;
  const CreateProgramState();

  @override
  List<Object> get props => [if (machines != null) machines!];
}

final class CreateProgramInitial extends CreateProgramState {
  @override
  List<MachineEntity>? get machines => null;
}

final class LoadedMachines extends CreateProgramState {
  @override
  final List<MachineEntity> machines;

  const LoadedMachines({required this.machines});
}

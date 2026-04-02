part of 'create_program_bloc.dart';

sealed class CreateProgramEvent extends Equatable {
  const CreateProgramEvent();

  @override
  List<Object> get props => [];
}

class MachinesLoadedEvent extends CreateProgramEvent {}

class MachineSelected extends CreateProgramEvent {
  final MachineEntity machine;

  const MachineSelected({required this.machine});

  @override
  List<Object> get props => [machine];
}

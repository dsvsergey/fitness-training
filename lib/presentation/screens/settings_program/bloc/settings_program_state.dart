part of 'settings_program_bloc.dart';

sealed class SettingsProgramState extends Equatable {
  ProgramMachineEntity? get programMachine;

  const SettingsProgramState();

  @override
  List<Object> get props => [if (programMachine != null) programMachine!];
}

final class SettingsProgramInitial extends SettingsProgramState {
  @override
  ProgramMachineEntity? get programMachine => null;
}

final class LoadedMachineSetting extends SettingsProgramState {
  const LoadedMachineSetting({required this.programMachine});

  @override
  final ProgramMachineEntity? programMachine;
}

final class SettingsProgramLoadInProgress extends SettingsProgramState {
  @override
  final ProgramMachineEntity? programMachine;

  SettingsProgramLoadInProgress(SettingsProgramState state)
      : programMachine = state.programMachine;
}

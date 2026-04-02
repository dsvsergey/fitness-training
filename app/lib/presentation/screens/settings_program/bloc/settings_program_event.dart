part of 'settings_program_bloc.dart';

sealed class SettingsProgramEvent extends Equatable {
  const SettingsProgramEvent();

  @override
  List<Object> get props => [];
}

final class GetMachineSettingEvent extends SettingsProgramEvent {
  final ProgramFitnessEntity programFitness;
  final MachineEntity machine;

  const GetMachineSettingEvent(
      {required this.programFitness, required this.machine});

  @override
  List<Object> get props => [programFitness, machine];
}

final class StartLoadInProgressEvent extends SettingsProgramEvent {}

import 'fitness/fitness.dart';

class ProgramSettingsEntity {
  final MachineEntity machine;
  final List<ProgramSettingsProporties> proporties;
  final int weight;

  ProgramSettingsEntity({
    required this.machine,
    this.proporties = const <ProgramSettingsProporties>[],
    this.weight = 0,
  });
}

class ProgramSettingsProporties {
  final String name;
  final int value;
  final ProportiesType type;

  ProgramSettingsProporties({
    required this.name,
    required this.value,
    required this.type,
  });
}

enum ProportiesType {
  seats,
  back,
  pin,
  handle,
}

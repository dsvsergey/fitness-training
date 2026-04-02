import 'program_settings_entity.dart';

class ProgramEntity {
  final int id;
  final String name;
  final List<ProgramSettingsEntity> settings;

  ProgramEntity({
    required this.id,
    required this.name,
    required this.settings,
  });
}

// List<ProgramModel> programModels = programNames
//     .toSet()
//     .map((name) => ProgramModel(
//           name: name,
//           settings: [
//             ProgramSettingsModel(
//               machine: apparatusModels.first,
//               proporties: [
//                 ProgramSettingsProporties(
//                   name: 'Seats',
//                   value: 100,
//                   type: ProportiesType.seats,
//                 ),
//                 ProgramSettingsProporties(
//                   name: 'Pin',
//                   value: 100,
//                   type: ProportiesType.pin,
//                 ),
//                 ProgramSettingsProporties(
//                   name: 'Back',
//                   value: 100,
//                   type: ProportiesType.back,
//                 ),
//                 ProgramSettingsProporties(
//                   name: 'Handle',
//                   value: 100,
//                   type: ProportiesType.handle,
//                 ),
//               ],
//               weight: 65,
//             ),
//           ],
//           id: 0,
//         ))
//     .toList();
List<String> programNames = [
  "A",
  "B",
  "C",
];

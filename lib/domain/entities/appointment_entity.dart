import 'client_entity.dart';

class AppointmentEntity {
  final Duration duration;
  final DateTime date;
  final ClientEntity? client;

  AppointmentEntity({
    this.duration = const Duration(minutes: 30),
    required this.date,
    required this.client,
  });
}

// List<AppointmentModel> appointments = [
//   AppointmentModel(
//     client: ClientModel(
//       birthday: DateTime(2023, 11, 22),
//       name: 'Andrew Trainer',
//       weight: 70,
//       height: 200,
//       phoneNumber: '+123 456 789 9192',
//       photo: AppPngs.userImage,
//     ),
//     date: DateTime.now(),
//   ),
//   AppointmentModel(
//     client: ClientModel(
//       birthday: DateTime(2023, 11, 22),
//       name: 'Andrew',
//       weight: 70,
//       height: 170,
//       phoneNumber: '+123 456 789 8888',
//       photo: AppPngs.user,
//     ),
//     date: DateTime.now(),
//   ),
//   AppointmentModel(
//     client: ClientModel(
//       name: 'Camilla',
//       weight: 70,
//       height: 160,
//       phoneNumber: '+123 456 789 2222',
//       photo: AppPngs.camilla,
//       birthday: DateTime(2023, 11, 22),
//     ),
//     date: DateTime.now(),
//   ),
//   AppointmentModel(
//     client: ClientModel(
//       birthday: DateTime(2023, 11, 22),
//       name: 'Anna',
//       weight: 80,
//       height: 180,
//       phoneNumber: '+123 333 222 1111',
//       photo: AppPngs.anna,
//     ),
//     date: DateTime.now(),
//   ),
//   AppointmentModel(
//     client: ClientModel(
//       birthday: DateTime(2023, 11, 22),
//       name: 'Aleksandr',
//       weight: 70,
//       height: 160,
//       phoneNumber: '+ 380 632625621',
//       photo: AppPngs.aleksandr,
//     ),
//     date: DateTime.now(),
//   ),
// ];

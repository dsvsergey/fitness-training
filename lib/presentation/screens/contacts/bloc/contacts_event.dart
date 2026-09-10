part of 'contacts_bloc.dart';

sealed class ContactsEvent extends Equatable {}

final class GetContactsList extends ContactsEvent {
  @override
  List<Object?> get props => [];
}

final class FindByNameContactsList extends ContactsEvent {
  final String? searchQuery;

  FindByNameContactsList({required this.searchQuery});

  @override
  List<Object?> get props => [if (searchQuery != null) searchQuery!];
}

final class CreateTraineeEvent extends ContactsEvent {
  final TraineeEntity trainee;

  CreateTraineeEvent({required this.trainee});

  @override
  List<Object?> get props => [trainee];
}

final class UpdateTraineeContactEvent extends ContactsEvent {
  final int traineeId;
  final TraineeEntity trainee;

  UpdateTraineeContactEvent({
    required this.traineeId,
    required this.trainee,
  });

  @override
  List<Object?> get props => [traineeId, trainee];
}

final class DeleteTraineeEvent extends ContactsEvent {
  final int traineeId;

  DeleteTraineeEvent({required this.traineeId});

  @override
  List<Object?> get props => [traineeId];
}

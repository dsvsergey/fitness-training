part of 'contacts_bloc.dart';

sealed class ContactsState extends Equatable {
  String? get searchQuery;
  List<TraineeEntity>? get clients;
  bool? get hasMoreData;

  @override
  List<Object?> get props => [
        if (searchQuery != null) searchQuery!,
        if (clients != null) clients!,
        if (hasMoreData != null) hasMoreData!,
      ];
}

final class ContactsInitial extends ContactsState {
  @override
  String? get searchQuery => null;

  @override
  List<TraineeEntity>? get clients => null;

  @override
  bool? get hasMoreData => false;
}

final class ContactsError extends ContactsState {
  @override
  final String? searchQuery;

  @override
  final List<TraineeEntity>? clients;

  ContactsError(ContactsState state)
      : searchQuery = state.searchQuery,
        clients = state.clients,
        hasMoreData = state.hasMoreData;

  @override
  final bool? hasMoreData;
}

final class ContactsLoading extends ContactsState {
  @override
  final String? searchQuery;

  @override
  final List<TraineeEntity>? clients;

  @override
  final bool? hasMoreData;

  ContactsLoading(ContactsState state)
      : searchQuery = state.searchQuery,
        clients = state.clients,
        hasMoreData = state.hasMoreData;
}

final class ContactsSuccess extends ContactsState {
  ContactsSuccess(ContactsState state,
      {required this.clients, required this.hasMoreData})
      : searchQuery = state.searchQuery;
  @override
  final List<TraineeEntity> clients;

  @override
  final String? searchQuery;

  @override
  final bool? hasMoreData;
}

final class FindByNameSuccess extends ContactsState {
  FindByNameSuccess(
      {required this.clients,
      required this.searchQuery,
      required this.hasMoreData});
  @override
  final List<TraineeEntity> clients;

  @override
  final String? searchQuery;

  @override
  final bool? hasMoreData;
}

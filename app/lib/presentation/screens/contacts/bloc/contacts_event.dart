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

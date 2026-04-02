import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../domain/entities/fitness/fitness.dart';
import '../../../../domain/usecases/fitness/fitness.dart';

part 'contacts_event.dart';
part 'contacts_state.dart';

class ContactsBloc extends Bloc<ContactsEvent, ContactsState> {
  ContactsBloc() : super(ContactsInitial()) {
    on<GetContactsList>((event, emit) async {
      try {
        emit(ContactsLoading(state));
        final clients = state.clients ?? <TraineeEntity>[];
        final newClients = await GetIt.I<TraineeUsecase>()
            .getTrainees(skip: clients.length, limit: 20, q: state.searchQuery);
        if (newClients.trainees?.isNotEmpty ?? false) {
          clients.addAll(newClients.trainees!.toList());
        }
        debugPrint('Clients Count: ${clients.length}');
        emit(ContactsSuccess(state,
            clients: clients,
            hasMoreData: (newClients.totalCount ?? 0) > clients.length));
      } catch (e) {
        emit(ContactsError(state));
      }
    });

    on<FindByNameContactsList>(
      (event, emit) async {
        try {
          emit(ContactsLoading(state));
          final clients = await GetIt.I<TraineeUsecase>()
              .getTrainees(skip: 0, limit: 20, q: event.searchQuery);
          emit(FindByNameSuccess(
              clients: clients.trainees?.toList() ?? [],
              searchQuery: event.searchQuery,
              hasMoreData:
                  (clients.totalCount ?? 0) > (clients.trainees?.length ?? 0)));
        } catch (e) {
          emit(ContactsError(state));
        }
      },
    );
  }
}

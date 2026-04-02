import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../../domain/entities/fitness/fitness.dart';
import '../../../../../domain/usecases/fitness/fitness.dart';

part 'program_screen_event.dart';
part 'program_screen_state.dart';

class ProgramScreenBloc extends Bloc<ProgramScreenEvent, ProgramScreenState> {
  ProgramScreenBloc() : super(ProgramScreenInitial()) {
    on<SetTraineeEvent>((event, emit) {
      emit(LoadedTrainee(trainee: event.trainee));
    });

    on<UpdateTraineeEvent>((event, emit) async {
      try {
        final traineeId = event.trainee.id;
        if (traineeId == null) {
          emit(LoadedTrainee(trainee: event.trainee));
          return;
        }

        final updatedTrainee = await GetIt.I<TraineeUsecase>().getTrainee(
          traineeId,
        );
        emit(LoadedTrainee(trainee: updatedTrainee));
      } catch (error) {
        // Якщо виникла помилка, використовуємо існуючі дані тренера
        emit(LoadedTrainee(trainee: event.trainee));
      }
    });
  }
}

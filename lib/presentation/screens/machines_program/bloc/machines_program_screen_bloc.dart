import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../domain/entities/fitness/fitness.dart';
import '../../../../domain/usecases/fitness/program_fitness_usecase.dart';

part 'machines_program_screen_event.dart';
part 'machines_program_screen_state.dart';

class MachinesProgramScreenBloc
    extends Bloc<MachinesProgramScreenEvent, MachinesProgramScreenState> {
  MachinesProgramScreenBloc() : super(MachinesProgramScreenInitial()) {
    on<ProgramFitnessUpdateEvent>((event, emit) async {
      emit(MachinesProgramScreenInitial());
      final program =
          await GetIt.I<ProgramFitnessUsecase>().getProgram(event.programId);
      emit(ProgramFitnessUpdated(program: program));
    });
  }
}

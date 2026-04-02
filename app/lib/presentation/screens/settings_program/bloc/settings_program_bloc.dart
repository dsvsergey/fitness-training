import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import '../../../../domain/entities/fitness/fitness.dart';
import '../../../../domain/usecases/fitness/fitness.dart';

part 'settings_program_event.dart';
part 'settings_program_state.dart';

@singleton
class SettingsProgramBloc
    extends Bloc<SettingsProgramEvent, SettingsProgramState> {
  SettingsProgramBloc() : super(SettingsProgramInitial()) {
    on<GetMachineSettingEvent>((event, emit) async {
      emit(SettingsProgramInitial());
      if (!emit.isDone) {
        emit(SettingsProgramLoadInProgress(state));
        final programMachine = await GetIt.I<ProgramMachineUsecase>()
            .getProgramMachineByProgramAndMachine(
                event.programFitness.id!, event.machine.id!);
        if (programMachine != null) {
          emit(LoadedMachineSetting(programMachine: programMachine));
        }
      }
    });

    on<StartLoadInProgressEvent>(
        (event, emit) => emit(SettingsProgramLoadInProgress(state)));
  }
}

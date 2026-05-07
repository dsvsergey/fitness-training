import 'package:built_collection/built_collection.dart';
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

    on<ReorderMachinesEvent>((event, emit) async {
      final current = state;
      if (current is! ProgramFitnessUpdated || current.program == null) return;

      final program = current.program!;
      final byId = {
        for (final pm in program.programMachines ?? <ProgramMachineEntity>[])
          pm.id: pm,
      };

      final reordered = event.orderedIds
          .asMap()
          .entries
          .map((e) {
            final pm = byId[e.value];
            if (pm == null) return null;
            return pm.rebuild((b) => b..index = e.key);
          })
          .whereType<ProgramMachineEntity>()
          .toBuiltList();

      emit(ProgramFitnessUpdated(
        program: program.rebuild(
          (b) => b..programMachines = reordered.toBuilder(),
        ),
      ));

      try {
        final updated = await GetIt.I<ProgramFitnessUsecase>()
            .reorderMachines(event.programId, event.orderedIds);
        emit(ProgramFitnessUpdated(program: updated));
      } catch (_) {
        final fresh = await GetIt.I<ProgramFitnessUsecase>()
            .getProgram(event.programId);
        emit(ProgramFitnessUpdated(program: fresh));
      }
    });
  }
}

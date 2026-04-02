import 'package:equatable/equatable.dart';
import 'package:fitness_training/domain/usecases/fitness/fitness.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../../domain/entities/fitness/fitness.dart';

part 'create_program_event.dart';
part 'create_program_state.dart';

class CreateProgramBloc extends Bloc<CreateProgramEvent, CreateProgramState> {
  CreateProgramBloc() : super(CreateProgramInitial()) {
    on<MachinesLoadedEvent>((event, emit) async {
      emit(CreateProgramInitial());
      var machines = await GetIt.I<MachineUsecase>().getMachines();
      if (!emit.isDone) {
        emit(LoadedMachines(machines: machines));
      }
    });
  }
}

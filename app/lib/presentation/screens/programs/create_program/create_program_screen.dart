import 'package:auto_route/auto_route.dart';
import 'package:fitness_training/core/resources/localization/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/router/router.dart';
import '../../../../domain/entities/fitness/fitness.dart';
import '../../../../domain/usecases/fitness/fitness.dart';
import '../../../utils/dialogs_utils.dart';
import '../../../utils/string_utils.dart';
import '../../../widgets/button_widget.dart';
import 'bloc/create_program_bloc.dart';

@RoutePage()
class CreateProgramScreen extends StatefulWidget {
  const CreateProgramScreen({super.key, required this.model, this.program});

  final TraineeEntity model;
  final ProgramFitnessEntity? program;

  @override
  State<CreateProgramScreen> createState() => _CreateProgramScreenState();
}

class _CreateProgramScreenState extends State<CreateProgramScreen> {
  final List<MachineEntity> _selectedMachines = [];
  late String? _programTitle;
  late String? _title;

  @override
  void initState() {
    super.initState();
    if (widget.program != null) {
      _selectedMachines.addAll(
          widget.program!.programMachines!.map((p0) => p0.machine!).toList());
      _programTitle = widget.program?.name;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _programTitle = AppLocalizations.of(context)!.newProgram;
    _title = AppLocalizations.of(context)!.selectTrainingMachines;
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    context.read<CreateProgramBloc>().add(MachinesLoadedEvent());

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          backgroundColor: context.theme.colors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: Icon(FIcons.arrowLeft, color: context.theme.colors.foreground),
            onPressed: () => AutoRouter.of(context).pop(const ContactsRoute()),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  DialogUtils.showEditMachineDialog(context: context)
                      .then((value) {
                    if (value != null) {
                      GetIt.I<MachineUsecase>()
                          .createMachine(MachineEntity((p0) => p0
                            ..name = value['name']
                                .toString()
                                .capitalizeEachWord()
                            ..index = -1))
                          .then((_) => context
                              .read<CreateProgramBloc>()
                              .add(MachinesLoadedEvent()));
                    }
                  }),
              child: Text(
                AppLocalizations.of(context)!.addMachine,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: context.theme.colors.foreground,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
      body: BlocBuilder<CreateProgramBloc, CreateProgramState>(
        buildWhen: (_, current) => current is LoadedMachines,
        builder: (context, state) {
          final machines = state.machines ?? [];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
                child: Text(
                  '${_title ?? ''} ${_programTitle ?? ''}',
                  style: context.theme.typography.lg.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.theme.colors.foreground,
                  ),
                ),
              ),
              Divider(height: 1, color: context.theme.colors.border),
              Expanded(
                child: machines.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.fitness_center_outlined,
                              size: 56,
                              color: context.theme.colors.mutedForeground,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No machines yet',
                              style: context.theme.typography.sm.copyWith(
                                color: context.theme.colors.mutedForeground,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tap "Add machine" to get started',
                              style: context.theme.typography.xs.copyWith(
                                color: context.theme.colors.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            for (final machine in machines)
                              GestureDetector(
                                onLongPressStart: (details) {
                                  final offset = details.globalPosition;
                                  showMenu(
                                    context: context,
                                    position: RelativeRect.fromLTRB(
                                      offset.dx,
                                      offset.dy,
                                      MediaQuery.of(context).size.width -
                                          offset.dx,
                                      MediaQuery.of(context).size.height -
                                          offset.dy,
                                    ),
                                    items: [
                                      PopupMenuItem(
                                        value: 'Edit',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit,
                                                color: context
                                                    .theme.colors.foreground),
                                            const SizedBox(width: 8),
                                            Text(
                                              AppLocalizations.of(context)!
                                                  .edit,
                                              style: TextStyle(
                                                color: context
                                                    .theme.colors.foreground,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'Delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete,
                                                color: context
                                                    .theme.colors.destructive),
                                            const SizedBox(width: 8),
                                            Text(
                                              AppLocalizations.of(context)!
                                                  .delete,
                                              style: TextStyle(
                                                color: context
                                                    .theme.colors.destructive,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ).then((value) {
                                    if (value == 'Edit') {
                                      DialogUtils.showEditMachineDialog(
                                              context: context,
                                              name: machine.name)
                                          .then((value) {
                                        if (value != null) {
                                          GetIt.I<MachineUsecase>()
                                              .updateMachine(
                                                  machine.id!,
                                                  machine.rebuild((p0) =>
                                                      p0..name =
                                                          value['name']))
                                              .then((_) => context
                                                  .read<CreateProgramBloc>()
                                                  .add(MachinesLoadedEvent()));
                                        }
                                      });
                                    } else if (value == 'Delete') {
                                      DialogUtils.showConfirmationDialog(
                                        context,
                                        AppLocalizations.of(context)!
                                            .confirmation,
                                        '${AppLocalizations.of(context)!.deleteMachine} ${machine.name}?',
                                      ).then((confirmed) {
                                        if (confirmed ?? false) {
                                          _selectedMachines.remove(machine);
                                          GetIt.I<MachineUsecase>()
                                              .deleteMachine(machine.id!)
                                              .then((_) => context
                                                  .read<CreateProgramBloc>()
                                                  .add(MachinesLoadedEvent()));
                                        }
                                      });
                                    }
                                  });
                                },
                                onTap: () => setState(() {
                                  if (_selectedMachines.contains(machine)) {
                                    _selectedMachines.remove(machine);
                                  } else {
                                    _selectedMachines.add(machine);
                                  }
                                }),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: _selectedMachines.contains(machine)
                                        ? context.theme.colors.primary
                                        : context.theme.colors.secondary,
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: _selectedMachines.contains(machine)
                                          ? context.theme.colors.primary
                                          : context.theme.colors.border,
                                    ),
                                  ),
                                  child: Text(
                                    machine.name.capitalizeEachWord(),
                                    style: TextStyle(
                                      color: _selectedMachines.contains(machine)
                                          ? context.theme.colors.primaryForeground
                                          : context.theme.colors.foreground,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ButtonWidget(
                  onPressed: _selectedMachines.isNotEmpty
                      ? () => AutoRouter.of(context).push(
                            SelectTrainingRoute(
                              selectedMachines: _selectedMachines,
                              trainee: widget.model,
                              program: widget.program,
                            ),
                          )
                      : null,
                  title: AppLocalizations.of(context)!.next,
                ),
              ),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }
}

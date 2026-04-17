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
        preferredSize: const Size.fromHeight(56),
        child: FHeader.nested(
          title: const SizedBox.shrink(),
          prefixes: [
            FHeaderAction.back(
              onPress: () => AutoRouter.of(context).pop(const ContactsRoute()),
            ),
          ],
          suffixes: [
            FHeaderAction(
              icon: Text(
                AppLocalizations.of(context)!.addMachine,
                style: context.theme.typography.lg.copyWith(
                  fontWeight: FontWeight.w800,
                  color: context.theme.colors.primary,
                  fontSize: isTablet ? 25 : 20,
                ),
              ),
              onPress: () =>
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
            ),
          ],
        ),
      ),
      body: BlocBuilder<CreateProgramBloc, CreateProgramState>(
        buildWhen: (_, current) => current is LoadedMachines,
        builder: (context, state) {
          return Column(
            children: [
              Text(
                '$_title $_programTitle',
                textAlign: TextAlign.center,
                style: isTablet
                    ? context.theme.typography.xl3
                        .copyWith(fontWeight: FontWeight.w800)
                    : context.theme.typography.xl2
                        .copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      children: [
                        for (final machine in state.machines ?? [])
                          GestureDetector(
                            onLongPressStart: (details) {
                              final offset = details.globalPosition;
                              showMenu(
                                context: context,
                                position: RelativeRect.fromLTRB(
                                  offset.dx,
                                  offset.dy,
                                  MediaQuery.of(context).size.width - offset.dx,
                                  MediaQuery.of(context).size.height -
                                      offset.dy,
                                ),
                                items: [
                                  PopupMenuItem(
                                    value: 'Edit',
                                    child: Row(
                                      children: [
                                        const Icon(Icons.edit,
                                            color: Color(0xFF1E1E1E)),
                                        const SizedBox(width: 8),
                                        Text(
                                          AppLocalizations.of(context)!.edit,
                                          style: TextStyle(
                                            color: const Color(0xFF1E1E1E),
                                            fontSize: isTablet ? 25 : 20,
                                            fontFamily: 'Inter',
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
                                        const Icon(Icons.delete,
                                            color: Colors.red),
                                        const SizedBox(width: 8),
                                        Text(
                                          AppLocalizations.of(context)!.delete,
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontSize: isTablet ? 25 : 20,
                                            fontFamily: 'Inter',
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
                                                  p0..name = value['name']))
                                          .then((_) => context
                                              .read<CreateProgramBloc>()
                                              .add(MachinesLoadedEvent()));
                                    }
                                  });
                                } else if (value == 'Delete') {
                                  DialogUtils.showConfirmationDialog(
                                    context,
                                    AppLocalizations.of(context)!.confirmation,
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
                            child: GestureDetector(
                              onTap: () => setState(() {
                                if (_selectedMachines.contains(machine)) {
                                  _selectedMachines.remove(machine);
                                } else {
                                  _selectedMachines.add(machine);
                                }
                              }),
                              child: Container(
                                width: 65,
                                height: 65,
                                decoration: BoxDecoration(
                                  color: _selectedMachines.contains(machine)
                                      ? context.theme.colors.primary
                                      : null,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    machine.name.capitalizeEachWord(),
                                    style: TextStyle(
                                      color: _selectedMachines.contains(machine)
                                          ? context
                                              .theme.colors.primaryForeground
                                          : context
                                              .theme.colors.mutedForeground,
                                      fontSize: 40,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
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

import 'package:auto_route/auto_route.dart';
import 'package:fitness_training/core/resources/localization/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/resources/resources.dart';
import '../../../../core/resources/themes/app_colors.dart';
import '../../../../core/resources/themes/app_fonts.dart';
import '../../../../core/router/router.dart';
import '../../../../core/utils/device_info.dart';
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
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isLargeScreen = screenWidth > 600;
    context.read<CreateProgramBloc>().add(MachinesLoadedEvent());
    return Scaffold(
      appBar: AppBar(
        leadingWidth: isLargeScreen ? 100 : 80,
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Image.asset(
            AppPngs.back,
          ),
          onPressed: () {
            AutoRouter.of(context).pop(const ContactsRoute());
          },
        ),
        actions: [
          TextButton(
              onPressed: () =>
                  DialogUtils.showEditMachineDialog(context: context)
                      .then((value) {
                    if (value != null) {
                      return GetIt.I<MachineUsecase>()
                          .createMachine(MachineEntity((p0) => p0
                            ..name =
                                value["name"].toString().capitalizeEachWord()
                            ..index = -1))
                          .then((value) => context
                              .read<CreateProgramBloc>()
                              .add(MachinesLoadedEvent()));
                    }
                  }),
              child: Text(
                AppLocalizations.of(context)!.addMachine,
                style: AppFonts.w800s18
                    .copyWith(fontSize: DeviceInfo.isTablet(context) ? 25 : 20),
              ))
        ],
      ),
      body: Align(
        alignment: Alignment.center,
        child: BlocBuilder<CreateProgramBloc, CreateProgramState>(
          buildWhen: (previous, current) => current is LoadedMachines,
          builder: (context, state) {
            return Column(
              children: [
                Text(
                  "$_title $_programTitle",
                  textAlign: TextAlign.center,
                  style: isLargeScreen ? AppFonts.w800s40 : AppFonts.w800s24,
                ),
                SizedBox(height: 20.h),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Wrap(
                        spacing: 20.h,
                        runSpacing: 20.w,
                        children: [
                          for (MachineEntity machine in state.machines ?? [])
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
                                      value: "Edit",
                                      child: Row(
                                        children: <Widget>[
                                          const Icon(Icons.edit,
                                              color: Color(0xFF1E1E1E)),
                                          const SizedBox(
                                              width:
                                                  8.0), // gives some space between the icon and the text
                                          Text(
                                            AppLocalizations.of(context)!.edit,
                                            style: TextStyle(
                                              color: const Color(0xFF1E1E1E),
                                              fontSize:
                                                  DeviceInfo.isTablet(context)
                                                      ? 25
                                                      : 20,
                                              fontFamily: "Inter",
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: "Delete",
                                      child: Row(
                                        children: <Widget>[
                                          const Icon(Icons.delete,
                                              color: Colors.red),
                                          const SizedBox(
                                              width:
                                                  8.0), // gives some space between the icon and the text
                                          Text(
                                            AppLocalizations.of(context)!
                                                .delete,
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontSize:
                                                  DeviceInfo.isTablet(context)
                                                      ? 25
                                                      : 20,
                                              fontFamily: "Inter",
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ).then((value) {
                                  if (value == "Edit") {
                                    DialogUtils.showEditMachineDialog(
                                            context: context,
                                            name: machine.name)
                                        .then((value) {
                                      if (value != null) {
                                        return GetIt.I<MachineUsecase>()
                                            .updateMachine(
                                                machine.id!,
                                                machine.rebuild((p0) =>
                                                    p0..name = value["name"]))
                                            .then((value) => context
                                                .read<CreateProgramBloc>()
                                                .add(MachinesLoadedEvent()));
                                      }
                                    });
                                  } else if (value == "Delete") {
                                    DialogUtils.showConfirmationDialog(
                                            context,
                                            AppLocalizations.of(context)!
                                                .confirmation,
                                            "${AppLocalizations.of(context)!.deleteMachine} ${machine.name}?")
                                        .then((value) {
                                      if (value != null && value) {
                                        if (_selectedMachines
                                            .contains(machine)) {
                                          _selectedMachines.remove(machine);
                                        }
                                        GetIt.I<MachineUsecase>()
                                            .deleteMachine(machine.id!)
                                            .then((value) => context
                                                .read<CreateProgramBloc>()
                                                .add(MachinesLoadedEvent()));
                                      }
                                    });
                                  }
                                });
                              },
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    if (_selectedMachines.contains(machine)) {
                                      _selectedMachines.remove(machine);
                                    } else {
                                      _selectedMachines.add(machine);
                                    }
                                  });
                                },
                                child: Container(
                                  width: 65, //isLargeScreen ? 130.w : 65.w,
                                  height: 65, //isLargeScreen ? 10.h : 65.h,
                                  decoration: BoxDecoration(
                                    color: _selectedMachines.contains(machine)
                                        ? AppColors.colorMain
                                        : null,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      machine.name.capitalizeEachWord(),
                                      style: TextStyle(
                                        color:
                                            _selectedMachines.contains(machine)
                                                ? AppColors.white
                                                : AppColors.grey,
                                        fontSize: 40, //isLargeScreen ? 80 : 40,
                                        fontFamily: "Inter",
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                        ],
                      ),
                    ),
                  ),
                ),
                //  const Spacer(),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ButtonWidget(
                    onPressed: _selectedMachines.isNotEmpty
                        ? () {
                            AutoRouter.of(context).push(
                              SelectTrainingRoute(
                                  selectedMachines: _selectedMachines,
                                  trainee: widget.model,
                                  program: widget.program),
                            );
                          }
                        : null,
                    title: AppLocalizations.of(context)!.next,
                  ),
                ),

                const SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }
}

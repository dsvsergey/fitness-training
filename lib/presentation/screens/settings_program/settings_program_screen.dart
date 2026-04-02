// ignore_for_file: deprecated_member_use

import "package:auto_route/auto_route.dart";
import "package:collection/collection.dart";
import "package:fitness_training/core/resources/localization/l10n/app_localizations.dart";
import "package:fitness_training/presentation/widgets/workout_settings_widget.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_screenutil/flutter_screenutil.dart";
import "package:flutter_svg/svg.dart";
import "package:get_it/get_it.dart";
import "package:intl/intl.dart";

import "../../../core/resources/resources.dart";
import "../../../core/resources/themes/app_colors.dart";
import '../../../core/resources/themes/app_fonts.dart';
import "../../../core/router/router.dart";
import "../../../core/utils/device_info.dart";
import "../../../domain/entities/fitness/fitness.dart";
import "../../../domain/entities/history_training_entity.dart";
import "../../../domain/usecases/fitness/fitness.dart";
import "../../../domain/usecases/fitness/workout_session_usecase.dart";
import "../../utils/dialogs_utils.dart";
import "../../widgets/button_widget.dart";
import "../../widgets/custom_timer_widget.dart";
import "../../widgets/history_widget.dart";
import "../../widgets/machine_feature_widget.dart";
import "../metronome/metronome_controls.dart";
import "bloc/settings_program_bloc.dart";

@RoutePage()
class SettingsProgramScreen extends StatefulWidget {
  final ProgramFitnessEntity program;
  final MachineEntity machine;

  const SettingsProgramScreen(
      {super.key, required this.program, required this.machine});

  @override
  State<SettingsProgramScreen> createState() => _SettingsProgramScreenState();
}

class _SettingsProgramScreenState extends State<SettingsProgramScreen> {
  dynamic currentTime = DateFormat.jm().format(DateTime.now());
  int _currentTabIndex = 0;
  final _hasChanges = ValueNotifier<bool>(false);
  final _noteController = TextEditingController();

  HistoryTrainihgEntity historyModel = HistoryTrainihgEntity(
    weight: 20,
    time: const Duration(hours: 1),
    date: DateTime.now(),
  );

  String? textProgram;
  bool isGridView = true;
  // late ProgramSettingsModel _programSettings;
  @override
  void initState() {
    super.initState();
  }

  final a = HistoryTrainihgEntity(
    weight: 20,
    time: const Duration(hours: 2),
    date: DateTime(2023, 11, 22),
  );
  double timer = 0;

  void onsive(double tim) {
    setState(() {
      timer = tim;
      historyModel = HistoryTrainihgEntity(
        weight: 20,
        time: Duration(seconds: timer.toInt()),
        date: DateTime.now(),
      );
    });
  }

  void showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    // final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    return BlocProvider(
        create: (context) => SettingsProgramBloc()
          ..add(GetMachineSettingEvent(
              programFitness: widget.program, machine: widget.machine)),
        child: Scaffold(
          appBar: AppBar(
              // leadingWidth: 120,
              // leading: TextButton(
              //   onPressed: () => AutoRouter.of(context).pop(),
              //   child: const Text(
              //     "< Back",
              //     style: TextStyle(
              //       fontFamily: 'Inter',
              //       fontWeight: FontWeight.w800,
              //       fontSize: 20,
              //       color: AppColors.colorMain,
              //     ),
              //   ),
              // ),
              backgroundColor: Colors.white,
              elevation: 0,
              leadingWidth: DeviceInfo.isTablet(context) ? 100 : 80,
              leading: IconButton(
                icon: Image.asset(
                  AppPngs.back,
                  height: screenHeight > 750 ? 150 : 80,
                  width: DeviceInfo.isTablet(context) ? 250 : 120,
                ),
                onPressed: () {
                  AutoRouter.of(context).pop();
                },
              ),
              actions: <Widget>[
                BlocBuilder<SettingsProgramBloc, SettingsProgramState>(
                  buildWhen: (previous, current) =>
                      current is LoadedMachineSetting,
                  builder: (context, state) {
                    final isEditButtonAvaible = state.programMachine != null &&
                            state.programMachine?.angal != null ||
                        state.programMachine?.back != null ||
                        state.programMachine?.chest != null ||
                        state.programMachine?.handle != null ||
                        state.programMachine?.knees != null ||
                        state.programMachine?.legs != null ||
                        state.programMachine?.pin != null ||
                        state.programMachine?.seats != null &&
                            state.programMachine!.workouts.isNotEmpty;
                    if (isEditButtonAvaible) {
                      return TextButton(
                        onPressed: () => DialogUtils.showSettingsDialog(
                                context: context,
                                machine: widget.machine,
                                programMachine: state.programMachine)
                            .then((value) {
                          if (value != null) {
                            GetIt.I<ProgramMachineUsecase>()
                                .updateProgramMachine(
                                    state.programMachine!.id!, value)
                                .whenComplete(() =>
                                    BlocProvider.of<SettingsProgramBloc>(
                                            context)
                                        .add(GetMachineSettingEvent(
                                            machine: widget.machine,
                                            programFitness: widget.program)));
                          }
                        }),
                        child: Text(
                          AppLocalizations.of(context)!.edit,
                          style: AppFonts.w800s18.copyWith(
                              fontSize: DeviceInfo.isTablet(context) ? 25 : 20),
                        ),
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
              ]),
          body: BlocBuilder<SettingsProgramBloc, SettingsProgramState>(
              buildWhen: (previous, current) => current is LoadedMachineSetting,
              builder: (context, state) {
                _noteController.text = state.programMachine?.note ?? '';
                _hasChanges.value = false;
                if (state.programMachine?.workouts.isEmpty ?? true) {
                  return Column(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Text(
                          "${AppLocalizations.of(context)!.settingsFor} ${widget.machine.name}",
                          textAlign: TextAlign.center,
                          style: AppFonts.w800s24,
                        ),
                      ),
                      SizedBox(height: DeviceInfo.isTablet(context) ? 100 : 20),
                      SizedBox(
                        child: InkWell(
                          onTap: () => DialogUtils.showSettingsDialog(
                                  context: context,
                                  machine: widget.machine,
                                  programMachine: state.programMachine)
                              .then(
                            (value) {
                              if (value != null) {
                                GetIt.I<ProgramMachineUsecase>()
                                    .updateProgramMachine(value.id!, value)
                                    .whenComplete(() =>
                                        BlocProvider.of<SettingsProgramBloc>(
                                                context)
                                            .add(GetMachineSettingEvent(
                                                programFitness: widget.program,
                                                machine: widget.machine)));
                              }
                            },
                          ),
                          borderRadius: BorderRadius.circular(100),
                          child: SvgPicture.asset(
                            "assets/svgs/settings_program.svg",
                            width: DeviceInfo.isTablet(context) ? 250 : 200,
                            height: DeviceInfo.isTablet(context) ? 250 : 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: DeviceInfo.isTablet(context) ? 100 : 20,
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ButtonWidget(
                          onPressed: () => AutoRouter.of(context).pop(),
                          title: AppLocalizations.of(context)!.next,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      )
                    ],
                  );
                } else {
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        Text(
                          "${AppLocalizations.of(context)!.settingsFor} ${widget.machine.name}",
                          textAlign: TextAlign.center,
                          style: AppFonts.w800s24,
                        ),
                        DeviceInfo.isTablet(context)
                            ? LayoutBuilder(builder: (context, constraints) {
                                return SizedBox(
                                  width: constraints.maxWidth,
                                  child: machineSettingEntityPanelTablet(
                                      state.programMachine!),
                                );
                              })
                            : machineSettingEntityPanelMobile(
                                state.programMachine!),
                        Padding(
                          padding: EdgeInsets.only(
                              left: DeviceInfo.isTablet(context) ? 30 : 10,
                              right: DeviceInfo.isTablet(context) ? 30 : 10),
                          child: DefaultTabController(
                            length: 2,
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  SizedBox(
                                      height: DeviceInfo.isTablet(context)
                                          ? 10
                                          : 10),
                                  TabBar(
                                    onTap: (value) {
                                      setState(() {
                                        _currentTabIndex = value;
                                      });
                                    },
                                    tabAlignment: TabAlignment.start,
                                    labelColor: AppColors.black,
                                    unselectedLabelColor: AppColors.grey,
                                    indicatorColor: AppColors.white,
                                    indicatorSize: TabBarIndicatorSize.tab,
                                    labelPadding: const EdgeInsets.all(10),
                                    dividerColor: AppColors.white,
                                    tabs: [
                                      Tab(
                                        height: 35,
                                        child: Text(
                                          AppLocalizations.of(context)!.history,
                                          style: screenWidth > 600
                                              ? _currentTabIndex == 0
                                                  ? AppFonts.w700s30.copyWith(
                                                      color: AppColors.black,
                                                    )
                                                  : AppFonts.w700s30.copyWith(
                                                      color: AppColors.grey,
                                                    )
                                              : _currentTabIndex == 0
                                                  ? AppFonts.w700s24.copyWith(
                                                      color: AppColors.black,
                                                    )
                                                  : AppFonts.w700s24.copyWith(
                                                      color: AppColors.grey,
                                                    ),
                                        ),
                                      ),
                                      Tab(
                                        height: 35,
                                        child: Text(
                                          AppLocalizations.of(context)!.note,
                                          style: screenWidth > 600
                                              ? _currentTabIndex == 1
                                                  ? AppFonts.w700s30.copyWith(
                                                      color: AppColors.black,
                                                    )
                                                  : AppFonts.w700s30.copyWith(
                                                      color: AppColors.grey,
                                                    )
                                              : _currentTabIndex == 1
                                                  ? AppFonts.w700s24.copyWith(
                                                      color: AppColors.black,
                                                    )
                                                  : AppFonts.w700s24.copyWith(
                                                      color: AppColors.grey,
                                                    ),
                                        ),
                                      ),
                                    ],
                                    isScrollable: true,
                                  ),
                                  SizedBox(
                                    height: 340, // Adjust this value as needed
                                    child: TabBarView(
                                      children: [
                                        Column(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: DeviceInfo.isTablet(
                                                          context)
                                                      ? 10
                                                      : 10,
                                                  right: DeviceInfo.isTablet(
                                                          context)
                                                      ? 10
                                                      : 10),
                                              child: Table(
                                                columnWidths: const {
                                                  0: FractionColumnWidth(.33),
                                                  1: FractionColumnWidth(.33),
                                                  2: FractionColumnWidth(.33),
                                                },
                                                children: [
                                                  TableRow(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 4.0),
                                                        child: Text(
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .date,
                                                          style: DeviceInfo
                                                                  .isTablet(
                                                                      context)
                                                              ? AppFonts.w500s24
                                                              : AppFonts
                                                                  .w500s18,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 4.0),
                                                        child: Text(
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .weight,
                                                          style: DeviceInfo
                                                                  .isTablet(
                                                                      context)
                                                              ? AppFonts.w500s24
                                                              : AppFonts
                                                                  .w500s18,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 4.0),
                                                        child: Text(
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .time,
                                                          style: DeviceInfo
                                                                  .isTablet(
                                                                      context)
                                                              ? AppFonts.w500s24
                                                              : AppFonts
                                                                  .w500s18,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              height: 300,
                                              child: SingleChildScrollView(
                                                child: HistoryWidget(
                                                    programMachine:
                                                        state.programMachine),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Stack(
                                            alignment: Alignment.topRight,
                                            children: [
                                              TextField(
                                                controller: _noteController,
                                                maxLines: null,
                                                onChanged: (text) {
                                                  _hasChanges.value = true;
                                                },
                                                decoration: InputDecoration(
                                                  border: InputBorder.none,
                                                  hintText: AppLocalizations.of(
                                                          context)!
                                                      .noteHint,
                                                ),
                                              ),
                                              ValueListenableBuilder<bool>(
                                                valueListenable: _hasChanges,
                                                builder:
                                                    (context, value, child) {
                                                  if (!value) {
                                                    return const SizedBox
                                                        .shrink();
                                                  }
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        FloatingActionButton(
                                                          backgroundColor:
                                                              AppColors.white,
                                                          foregroundColor:
                                                              AppColors
                                                                  .colorMain,
                                                          mini: true,
                                                          onPressed: () {
                                                            _noteController
                                                                .text = state
                                                                    .programMachine
                                                                    ?.note ??
                                                                '';
                                                            _hasChanges.value =
                                                                false;
                                                          },
                                                          child: const Icon(
                                                              Icons.cancel),
                                                        ),
                                                        const SizedBox(
                                                            width: 10),
                                                        FloatingActionButton(
                                                          backgroundColor:
                                                              AppColors.white,
                                                          foregroundColor:
                                                              AppColors
                                                                  .colorMain,
                                                          mini: true,
                                                          onPressed: () {
                                                            GetIt.I<ProgramMachineUsecase>()
                                                                .updateProgramMachine(
                                                                    state
                                                                        .programMachine!
                                                                        .id!,
                                                                    state
                                                                        .programMachine!
                                                                        .rebuild((p0) => p0
                                                                          ..note =
                                                                              _noteController.text))
                                                                .then((value) {
                                                              context
                                                                  .read<
                                                                      SettingsProgramBloc>()
                                                                  .add(GetMachineSettingEvent(
                                                                      programFitness:
                                                                          widget
                                                                              .program,
                                                                      machine:
                                                                          widget
                                                                              .machine));
                                                              _hasChanges
                                                                      .value =
                                                                  false;
                                                            });
                                                          },
                                                          child: const Icon(
                                                              Icons.save),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    child: ButtonWidget(
                                      onPressed: () =>
                                          AutoRouter.of(context).pop(),
                                      title: AppLocalizations.of(context)!.next,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  )
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                }
              }),
        ));
  }

  Widget machineSettingEntityPanelMobile(ProgramMachineEntity programMachine) {
    return Padding(
      padding: DeviceInfo.isTablet(context)
          ? const EdgeInsets.all(20.0)
          : const EdgeInsets.all(8.0),
      child: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          WorkoutSettingsWidget(
            textOne: AppLocalizations.of(context)!.seats,
            textProgramOne: programMachine.seats?.toString() ?? '',
            textTwo: AppLocalizations.of(context)!.back,
            textProgramTwo: programMachine.back?.toString() ?? '',
          ),
          const SizedBox(
            height: 10,
          ),
          WorkoutSettingsWidget(
            textOne: AppLocalizations.of(context)!.pin,
            textProgramOne: programMachine.pin?.toString() ?? '',
            textTwo: AppLocalizations.of(context)!.handle,
            textProgramTwo: programMachine.handle?.toString() ?? '',
          ),
          const SizedBox(
            height: 10,
          ),
          WorkoutSettingsWidget(
            textOne: AppLocalizations.of(context)!.knees,
            textProgramOne: programMachine.handle?.toString() ?? '',
            textTwo: AppLocalizations.of(context)!.feet,
            textProgramTwo: programMachine.pin?.toString() ?? '',
          ),
          const SizedBox(
            height: 10,
          ),
          WorkoutSettingsWidget(
            textOne: AppLocalizations.of(context)!.angle,
            textProgramOne: programMachine.handle?.toString() ?? '',
            textTwo: AppLocalizations.of(context)!.chest,
            textProgramTwo: programMachine.pin?.toString() ?? '',
          ),
          const SizedBox(
            height: 10,
          ),
          WorkoutSettingsWidget(
            textOne: AppLocalizations.of(context)!.thighs,
            textProgramOne: programMachine.thighs ?? '',
            textTwo: AppLocalizations.of(context)!.grip,
            textProgramTwo: programMachine.grip ?? '',
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (programMachine.workouts.isNotEmpty)
                      SizedBox(
                        width: 220,
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              AppSvgs.weight,
                              height: 18,
                              width: 20,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              AppLocalizations.of(context)!.weightLb,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                fontSize: 21.0,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Text(
                              programMachine.workouts
                                      .where((p0) =>
                                          p0.sessionStatus ==
                                          SessionStatusEnumEntity.planned)
                                      .first
                                      .weight
                                      ?.toString() ??
                                  '',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                                fontSize: 24.0,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                BlocBuilder<SettingsProgramBloc, SettingsProgramState>(
                  builder: (context, state) {
                    return CustomTimerWidget(
                        title: AppLocalizations.of(context)!.timer,
                        image: AppSvgs.timer,
                        onPressed: () => onTimerButtonPressed(context, state));
                  },
                ),
                CustomTimerWidget(
                  title: AppLocalizations.of(context)!.metronome,
                  image: AppSvgs.metronom,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const MetronomeControl(),
                      ),
                    );
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget machineSettingEntityPanelTablet(ProgramMachineEntity programMachine) {
    return Padding(
      padding: const EdgeInsets.only(left: 40, top: 15, right: 40),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double screenHeight = MediaQuery.of(context).size.height * 0.43;
          return ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: constraints.maxWidth,
              minWidth: constraints.maxWidth,
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: screenHeight,
                    child: GridView.count(
                        primary: false,
                        padding: const EdgeInsets.all(8),
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        crossAxisCount: 3,
                        childAspectRatio: 1.4,
                        children: [
                          if (programMachine.seats != null)
                            MachineFeatureWidget(
                              label: AppLocalizations.of(context)!.seats,
                              value: programMachine.seats?.toString(),
                              icon: SvgPicture.asset(AppSvgs.seats,
                                  height: 60, width: 60),
                            ),
                          if (programMachine.back != null)
                            MachineFeatureWidget(
                              label: AppLocalizations.of(context)!.back,
                              value: programMachine.back?.toString(),
                              icon: Image.asset(AppPngs.body,
                                  width: 60, height: 60),
                            ),
                          if (programMachine.pin != null)
                            MachineFeatureWidget(
                              label: AppLocalizations.of(context)!.pin,
                              value: programMachine.pin?.toString(),
                              icon: Image.asset(AppPngs.pin,
                                  width: 60, height: 60),
                            ),
                          if (programMachine.handle != null)
                            MachineFeatureWidget(
                              label: AppLocalizations.of(context)!.handle,
                              value: programMachine.handle ?? '',
                              icon: Image.asset(AppPngs.handle,
                                  width: 60, height: 60),
                            ),
                          if (programMachine.knees != null)
                            MachineFeatureWidget(
                              label: AppLocalizations.of(context)!.knees,
                              value: programMachine.knees ?? '',
                              icon: SvgPicture.asset(
                                AppSvgs.knees,
                                height: 60,
                                width: 60,
                                color: AppColors.grey,
                              ),
                            ),
                          if (programMachine.chest != null)
                            MachineFeatureWidget(
                              label: AppLocalizations.of(context)!.chest,
                              value: programMachine.chest ?? '',
                              icon: SvgPicture.asset(
                                AppSvgs.chest,
                                height: 60,
                                width: 60,
                                color: AppColors.grey,
                              ),
                            ),
                          if (programMachine.legs != null)
                            MachineFeatureWidget(
                              label: AppLocalizations.of(context)!.feet,
                              value: programMachine.legs ?? '',
                              icon: SvgPicture.asset(
                                AppSvgs.legs,
                                height: 60,
                                width: 60,
                                color: AppColors.grey,
                              ),
                              additionalText: programMachine.forTwoLegs ?? false
                                  ? AppLocalizations.of(context)!.bi
                                  : AppLocalizations.of(context)!.uni,
                            ),
                          if (programMachine.thighs != null)
                            MachineFeatureWidget(
                              label: AppLocalizations.of(context)!.thighs,
                              value: programMachine.thighs ?? '',
                              icon: SvgPicture.asset(
                                AppSvgs.thighs,
                                height: 60,
                                width: 60,
                                color: AppColors.grey,
                              ),
                            ),
                          if (programMachine.grip != null)
                            MachineFeatureWidget(
                              label: AppLocalizations.of(context)!.grip,
                              value: programMachine.grip?.toString(),
                              icon: SvgPicture.asset(
                                AppSvgs.grip,
                                height: 60,
                                width: 60,
                                color: AppColors.grey,
                              ),
                            ),
                          if (programMachine.angal != null)
                            MachineFeatureWidget(
                              label: AppLocalizations.of(context)!.angle,
                              value: programMachine.angal?.toString(),
                              icon: SvgPicture.asset(
                                AppSvgs.angle,
                                height: 60,
                                width: 60,
                                color: AppColors.grey,
                              ),
                            ),
                        ]),
                  ),
                ),
                Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        BlocBuilder<SettingsProgramBloc, SettingsProgramState>(
                          builder: (context, state) {
                            return CustomTimerWidget(
                                title: AppLocalizations.of(context)!.timer,
                                image: AppSvgs.timer,
                                onPressed: () =>
                                    onTimerButtonPressed(context, state));
                          },
                        ),
                        const SizedBox(
                          height: 60,
                        ),
                        CustomTimerWidget(
                          title: AppLocalizations.of(context)!.metronome,
                          image: AppSvgs.metronom,
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const MetronomeControl(),
                              ),
                            );
                          },
                        ),
                      ],
                    )),
              ],
            ),
          );
        },
      ),
    );
  }

  void onTimerButtonPressed(
    BuildContext context,
    SettingsProgramState state,
  ) async {
    final WorkoutSessionEntity? workoutSession = state.programMachine?.workouts
        .firstWhereOrNull((p0) => p0.dateSession == null);

    double? value = await context.router.push<double>(StopwatchTimerRoutes(
        trainerName: state.programMachine!.machine!.name,
        weight: workoutSession!.weight!));

    if (value != null) {
      final workoutSessionUsecase = GetIt.I<WorkoutSessionUsecase>();
      final updatedWorkoutSession =
          await workoutSessionUsecase.updateWorkoutSession(
        workoutSession.id!,
        workoutSession.rebuild((p0) => p0
          ..sessionStatus = SessionStatusEnumEntity.completed
          ..sessionTime = value.toInt()
          ..dateSession = _dateWithZeroTime(DateTime.now())),
      );

      if (mounted) {
        final nextWeight = await DialogUtils.showNextWeightDialog(
          // ignore: use_build_context_synchronously
          context: context,
          machine: widget.machine,
          weight: updatedWorkoutSession.weight!,
        );

        await workoutSessionUsecase.createWorkoutSession(
          updatedWorkoutSession.rebuild((p0) => p0
            ..id = null
            ..dateSession = null
            ..sessionTime = null
            ..sessionStatus = SessionStatusEnumEntity.planned
            ..createdAt = null
            ..weight = nextWeight ?? updatedWorkoutSession.weight!),
        );

        // ignore: use_build_context_synchronously
        context.read<SettingsProgramBloc>().add(GetMachineSettingEvent(
            machine: widget.machine, programFitness: widget.program));
      }
    }
  }

  DateTime _dateWithZeroTime(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);
}

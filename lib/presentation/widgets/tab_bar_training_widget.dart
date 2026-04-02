import "package:auto_route/auto_route.dart";
import "package:collection/collection.dart";
import "package:fitness_training/core/resources/localization/l10n/app_localizations.dart";
import "package:fitness_training/domain/usecases/fitness/fitness.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:get_it/get_it.dart";

import '../../core/resources/themes/app_colors.dart';
import '../../core/resources/themes/app_fonts.dart';
import "../../core/router/router.dart";
import "../../domain/entities/fitness/fitness.dart";
import "../screens/programs/program_screen/bloc/program_screen_bloc.dart";
import "training_program_widget.dart";

class TabBarTrainingWidget extends StatefulWidget {
  const TabBarTrainingWidget({
    super.key,
    required this.model,
  });

  final TraineeEntity model;
  @override
  State<TabBarTrainingWidget> createState() => _TabBarTrainingWidgetState();
}

class _TabBarTrainingWidgetState extends State<TabBarTrainingWidget> {
  int currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Column(
        children: [
          TabBar(
            onTap: (value) {
              currentTabIndex = value;
              setState(() {});
            },
            tabAlignment: TabAlignment.center,
            labelColor: AppColors.black,
            unselectedLabelColor: AppColors.grey,
            indicatorColor: AppColors.white,
            indicatorSize: TabBarIndicatorSize.tab,
            labelPadding: const EdgeInsets.all(10),
            dividerColor: AppColors.white,
            tabs: [
              Tab(
                height: 50,
                child: Text(
                  AppLocalizations.of(context)!.currentProgram,
                  style: screenWidth > 600
                      ? currentTabIndex == 0
                          ? AppFonts.w700s30.copyWith(
                              color: AppColors.black,
                            )
                          : AppFonts.w700s30.copyWith(
                              color: AppColors.grey,
                            )
                      : currentTabIndex == 0
                          ? AppFonts.w700s24.copyWith(
                              color: AppColors.black,
                            )
                          : AppFonts.w700s24.copyWith(
                              color: AppColors.grey,
                            ),
                ),
              ),
              Tab(
                height: 50,
                child: Text(
                  AppLocalizations.of(context)!.archive,
                  style: screenWidth > 600
                      ? currentTabIndex == 1
                          ? AppFonts.w700s30.copyWith(
                              color: AppColors.black,
                            )
                          : AppFonts.w700s30.copyWith(
                              color: AppColors.grey,
                            )
                      : currentTabIndex == 1
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
            height: MediaQuery.of(context).size.height,
            child: TabBarView(
              children: [
                TrainingProgramWidget(
                  programs: widget.model.programs
                          ?.where((p0) => p0.isArchive == false)
                          .sorted((a, b) => a.number!.compareTo(b.number!))
                          .toList() ??
                      [],
                  onDismissed: (program) {},
                  onArchived: (program) => GetIt.I<ProgramFitnessUsecase>()
                      .setArchiveProgram(program.id!, true)
                      .then((value) =>
                          BlocProvider.of<ProgramScreenBloc>(context)
                              .add(UpdateTraineeEvent(trainee: widget.model))),
                  onTap: (program) {
                    AutoRouter.of(context).push(
                      MachinesProgramRoute(
                          trainee: widget.model, program: program),
                    );
                  },
                ),
                TrainingProgramWidget(
                  programs: widget.model.programs
                          ?.where((p0) => p0.isArchive == true)
                          .sorted((a, b) => a.number!.compareTo(b.number!))
                          .toList() ??
                      [],
                  onDismissed: (program) {},
                  onArchived: (program) => GetIt.I<ProgramFitnessUsecase>()
                      .setArchiveProgram(program.id!, false)
                      .then((value) =>
                          BlocProvider.of<ProgramScreenBloc>(context)
                              .add(UpdateTraineeEvent(trainee: widget.model))),
                  onTap: (program) {
                    AutoRouter.of(context).push(
                      MachinesProgramRoute(
                          trainee: widget.model, program: program),
                    );
                  },
                ),

                // Add the content for the second tab here
                // Container(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

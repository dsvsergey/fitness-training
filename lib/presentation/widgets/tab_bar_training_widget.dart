import "package:auto_route/auto_route.dart";
import "package:collection/collection.dart";
import "package:fitness_training/core/resources/localization/l10n/app_localizations.dart";
import "package:fitness_training/domain/usecases/fitness/fitness.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:forui/forui.dart";
import "package:get_it/get_it.dart";

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
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Column(
        children: [
          TabBar(
            onTap: (value) => setState(() => currentTabIndex = value),
            tabAlignment: TabAlignment.center,
            labelColor: context.theme.colors.foreground,
            unselectedLabelColor: context.theme.colors.mutedForeground,
            indicatorColor: Colors.transparent,
            indicatorSize: TabBarIndicatorSize.tab,
            labelPadding: const EdgeInsets.all(10),
            dividerColor: Colors.transparent,
            tabs: [
              Tab(
                height: 50,
                child: Text(
                  AppLocalizations.of(context)!.currentProgram,
                  style: context.theme.typography.xl2.copyWith(
                    fontWeight: FontWeight.w700,
                    color: currentTabIndex == 0
                        ? context.theme.colors.foreground
                        : context.theme.colors.mutedForeground,
                  ),
                ),
              ),
              Tab(
                height: 50,
                child: Text(
                  AppLocalizations.of(context)!.archive,
                  style: context.theme.typography.xl2.copyWith(
                    fontWeight: FontWeight.w700,
                    color: currentTabIndex == 1
                        ? context.theme.colors.foreground
                        : context.theme.colors.mutedForeground,
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
                          ?.where((p) => p.isArchive == false)
                          .sorted((a, b) => a.number!.compareTo(b.number!))
                          .toList() ??
                      [],
                  onDismissed: (program) {},
                  onArchived: (program) =>
                      GetIt.I<ProgramFitnessUsecase>()
                          .setArchiveProgram(program.id!, true)
                          .then((_) =>
                              BlocProvider.of<ProgramScreenBloc>(context)
                                  .add(UpdateTraineeEvent(
                                      trainee: widget.model))),
                  onTap: (program) => AutoRouter.of(context).push(
                    MachinesProgramRoute(
                        trainee: widget.model, program: program),
                  ),
                ),
                TrainingProgramWidget(
                  programs: widget.model.programs
                          ?.where((p) => p.isArchive == true)
                          .sorted((a, b) => a.number!.compareTo(b.number!))
                          .toList() ??
                      [],
                  onDismissed: (program) {},
                  onArchived: (program) =>
                      GetIt.I<ProgramFitnessUsecase>()
                          .setArchiveProgram(program.id!, false)
                          .then((_) =>
                              BlocProvider.of<ProgramScreenBloc>(context)
                                  .add(UpdateTraineeEvent(
                                      trainee: widget.model))),
                  onTap: (program) => AutoRouter.of(context).push(
                    MachinesProgramRoute(
                        trainee: widget.model, program: program),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

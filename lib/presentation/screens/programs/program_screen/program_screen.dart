import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:fitness_training/core/resources/localization/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/bloc/bloc_application/application_bloc.dart';
import '../../../../core/router/router.dart';
import '../../../../domain/usecases/fitness/fitness.dart';
import '../../../utils/dialogs_utils.dart';
import '../../../widgets/button_widget.dart';
import '../../../widgets/tab_bar_training_widget.dart';
import '../../../widgets/user_cart_widget.dart';
import 'bloc/program_screen_bloc.dart';

@RoutePage()
class ProgramScreen extends StatelessWidget {
  const ProgramScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: BlocBuilder<ProgramScreenBloc, ProgramScreenState>(
          buildWhen: (_, current) => current is LoadedTrainee,
          builder: (context, state) => FHeader.nested(
            title: Text(
              state is LoadedTrainee ? state.trainee.fullName : '',
            ),
            prefixes: [
              FHeaderAction.back(
                onPress: () {
                  BlocProvider.of<ApplicationBloc>(context)
                      .add(SelectTraineeEvent(selectedTrainee: null));
                  AutoRouter.of(context).pop();
                },
              ),
            ],
            suffixes: [
              FHeaderAction(
                icon: const Icon(FIcons.squarePen),
                onPress: () => _onEditPressed(context, state),
              ),
            ],
          ),
        ),
      ),
      body: BlocListener<ProgramScreenBloc, ProgramScreenState>(
        listener: (context, state) {
          if (state is CreateNewProgram && state.trainee != null) {
            BlocProvider.of<ProgramScreenBloc>(context)
                .add(UpdateTraineeEvent(trainee: state.trainee!));
          }
        },
        child: BlocBuilder<ProgramScreenBloc, ProgramScreenState>(
          buildWhen: (_, current) => current is LoadedTrainee,
          builder: (context, state) {
            if (state is! LoadedTrainee) return const SizedBox.shrink();

            final trainee = state.trainee;
            final activeProgramCount = trainee.programs
                    ?.where((p) => p.isArchive == false)
                    .length ??
                0;
            final initials = trainee.fullName
                .split(' ')
                .map((w) => w.isNotEmpty ? w[0] : '')
                .take(2)
                .join();

            return SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    trainee.photoUrl != null
                        ? FAvatar(
                            image: NetworkImage(trainee.photoUrl!),
                            fallback: Text(initials),
                            size: 96,
                          )
                        : FAvatar.raw(
                            size: 96,
                            child: Text(
                              initials,
                              style: context.theme.typography.xl2
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                    const SizedBox(height: 16),
                    UserCardWidget(model: trainee),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ButtonWidget(
                        onPressed: activeProgramCount >= 4
                            ? null
                            : () => AutoRouter.of(context).push(
                                  CreateProgramRoute(model: trainee),
                                ),
                        title:
                            AppLocalizations.of(context)!.titleButton,
                      ),
                    ),
                    TabBarTrainingWidget(model: trainee),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _onEditPressed(
    BuildContext context,
    ProgramScreenState state,
  ) async {
    if (state is! LoadedTrainee) return;
    final value = await DialogUtils.showEditDialog(
      context: context,
      title: AppLocalizations.of(context)!.editProfile,
      weight: state.trainee.weight?.toInt(),
      height: state.trainee.height?.toInt(),
    );
    if (value != null && context.mounted) {
      await GetIt.I<TraineeUsecase>().updateTrainee(
        state.trainee.id!,
        state.trainee.rebuild(
          (p) => p
            ..weight = double.tryParse(value['weight'])
            ..height = double.tryParse(value['height']),
        ),
      );
      if (context.mounted) {
        BlocProvider.of<ProgramScreenBloc>(context)
            .add(UpdateTraineeEvent(trainee: state.trainee));
      }
    }
  }
}

import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:colorize_text_avatar/colorize_text_avatar.dart';
import 'package:fitness_training/core/resources/localization/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/bloc/bloc_application/application_bloc.dart';
import '../../../../core/resources/resources.dart';
import '../../../../core/resources/themes/app_fonts.dart';
import '../../../../core/router/router.dart';
import '../../../../core/utils/device_info.dart';
import '../../../../domain/entities/fitness/fitness.dart';
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
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    return Scaffold(
      appBar: AppBar(
          leadingWidth: screenWidth > 600 ? 100 : 80,
          leading: IconButton(
            icon: Image.asset(
              AppPngs.back,
            ),
            onPressed: () {
              BlocProvider.of<ApplicationBloc>(context)
                  .add(SelectTraineeEvent(selectedTrainee: null));
              AutoRouter.of(context).pop();
              // AutoRouter.of(context).pop(const ContactsRoute());
            },
          ),
          actions: <Widget>[
            BlocBuilder<ProgramScreenBloc, ProgramScreenState>(
              buildWhen: (previous, current) => current is LoadedTrainee,
              builder: (context, state) {
                return TextButton(
                    onPressed: () => DialogUtils.showEditDialog(
                                context: context,
                                title: "Edit",
                                weight: state.trainee?.weight?.toInt(),
                                height: state.trainee?.height?.toInt())
                            .then((value) {
                          if (value != null) {
                            return GetIt.I<TraineeUsecase>().updateTrainee(
                                state.trainee!.id!,
                                state.trainee!.rebuild((p0) => p0
                                  ..weight = double.tryParse(value["weight"])
                                  ..height = double.tryParse(value["height"])));
                          } else {
                            return Future.value();
                          }
                        }).whenComplete(() =>
                                BlocProvider.of<ProgramScreenBloc>(context).add(
                                    UpdateTraineeEvent(
                                        trainee: state.trainee!))),
                    child: Text(
                      AppLocalizations.of(context)!.editProfile,
                      style: AppFonts.w800s18.copyWith(
                          fontSize: DeviceInfo.isTablet(context) ? 25 : 20),
                    ));
              },
            )
          ]),
      body: BlocListener<ProgramScreenBloc, ProgramScreenState>(
        listener: (context, state) {
          if (state is CreateNewProgram && state.trainee != null) {
            BlocProvider.of<ProgramScreenBloc>(context)
                .add(UpdateTraineeEvent(trainee: state.trainee!));
          }
        },
        child: BlocBuilder<ProgramScreenBloc, ProgramScreenState>(
            buildWhen: (previous, current) => current is LoadedTrainee,
            builder: (content, state) {
              if (state is LoadedTrainee) {
                final trainee = state.trainee;
                final activeProgramCount = trainee.programs
                        ?.where((p0) => p0.isArchive == false)
                        .length ??
                    0;
                return SingleChildScrollView(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        state.trainee.photoUrl == null
                            ? TextAvatar(
                                size: screenWidth > 600 ? 160 : 130,
                                shape: Shape.Circular,
                                text: state.trainee.fullName,
                                numberLetters: 2,
                                fontSize: 40,
                              )
                            : ClipOval(
                                child: Image.network(
                                  state.trainee.photoUrl!,
                                  width: screenWidth > 600 ? 160 : 130,
                                  height: screenWidth > 600 ? 160 : 130,
                                  fit: BoxFit.cover,
                                ),
                              ),
                        // CircleAvatar(
                        //   radius: screenWidth > 600 ? 160 : 80,
                        //   backgroundColor: AppColors.white,
                        //   backgroundImage: AssetImage(model.photo ?? ''),
                        // ),
                        const SizedBox(height: 11),
                        UserCardWidget(model: state.trainee),
                        SizedBox(height: screenWidth > 600 ? 50 : 20),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: // LoadingButtonWidget(
                              ButtonWidget(
                            onPressed: activeProgramCount >= 4
                                ? null
                                : () =>
                                    _onButtonPressed(content, state.trainee),
                            title: AppLocalizations.of(context)!.titleButton,
                          ),
                        ),
                        TabBarTrainingWidget(
                          model: state.trainee,
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return Container();
              }
            }),
      ),
    );
  }

  void _onButtonPressed(BuildContext context, TraineeEntity trainee) async {
    AutoRouter.of(context).push(
      CreateProgramRoute(model: trainee),
    );
  }
}

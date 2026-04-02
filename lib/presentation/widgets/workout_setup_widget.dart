import 'package:flutter/material.dart';

import '../../core/const.dart';
import '../../core/resources/resources.dart';
import '../../domain/entities/program_settings_entity.dart';
import 'program_information_widget.dart';
import 'shared_prefs_widget.dart';

class WorkoutSetupWidget extends StatelessWidget {
  final ProgramSettingsEntity programSettings;
  const WorkoutSetupWidget({
    super.key,
    required this.programSettings,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ProgramInformationWidget(
                image: AppPngs.seats,
                text: 'Seats',
                textInt:
                    SharedPrefsWidget.prefs.getString(AppConsts.seats) ?? '',
              ),
              SizedBox(width: (screenWidth > 600) ? 100 : null),
              ProgramInformationWidget(
                image: AppPngs.body,
                text: 'Back',
                textInt:
                    SharedPrefsWidget.prefs.getString(AppConsts.back) ?? '',
              ),
            ],
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ProgramInformationWidget(
                image: AppPngs.pin,
                text: 'Pin',
                textInt: SharedPrefsWidget.prefs.getString(AppConsts.pin) ?? '',
              ),
              SizedBox(width: (screenWidth > 600) ? 100 : null),
              ProgramInformationWidget(
                image: AppPngs.handle,
                text: 'Handle',
                textInt:
                    SharedPrefsWidget.prefs.getString(AppConsts.handle) ?? '',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

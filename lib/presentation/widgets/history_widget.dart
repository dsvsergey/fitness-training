import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/resources/themes/app_colors.dart';
import '../../core/resources/themes/app_fonts.dart';
import '../../core/utils/device_info.dart';
import '../../domain/entities/fitness/fitness.dart';

class HistoryWidget extends StatelessWidget {
  final ProgramMachineEntity? programMachine;

  const HistoryWidget({super.key, required this.programMachine});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    String formatDuration(Duration duration) {
      return '${duration.inHours}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
    }

    final history = programMachine?.workouts.toList();
    history?.sort((a, b) => b.id!.compareTo(a.id!));

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
              left: DeviceInfo.isTablet(context) ? 10 : 10,
              right: DeviceInfo.isTablet(context) ? 10 : 10),
          child: Table(
            columnWidths: const {
              0: FractionColumnWidth(.33),
              1: FractionColumnWidth(.33),
              2: FractionColumnWidth(.33),
            },
            children: [
              ...List.generate(
                  history?.length ?? 0,
                  (index) => TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: history?[index].dateSession == null
                                ? Text(
                                    "next workout",
                                    style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: DeviceInfo.isTablet(context)
                                            ? 24
                                            : 14,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.colorMain),
                                  )
                                : Text(
                                    DateFormat.yMd()
                                        .format(history![index].dateSession!),
                                    style: screenWidth > 600
                                        ? AppFonts.w500s24
                                        : AppFonts.w500s18,
                                  ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Text(
                              '${history?[index].weight ?? ''} lb',
                              style: screenWidth > 600
                                  ? AppFonts.w500s24
                                  : AppFonts.w500s18black,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: history?[index].sessionTime == null
                                ? const Text('')
                                : Text(
                                    formatDuration(Duration(
                                        seconds:
                                            history?[index].sessionTime ?? 0)),
                                    style: screenWidth > 600
                                        ? AppFonts.w500s24
                                        : AppFonts.w500s18,
                                  ),
                          ),
                        ],
                      )),
            ],
          ),
        ),
      ],
    );
  }
}

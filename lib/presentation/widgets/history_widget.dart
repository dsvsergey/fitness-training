import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/fitness/fitness.dart';

class HistoryWidget extends StatelessWidget {
  final ProgramMachineEntity? programMachine;

  const HistoryWidget({super.key, required this.programMachine});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    String formatDuration(Duration duration) {
      return '${duration.inHours}:'
          '${(duration.inMinutes % 60).toString().padLeft(2, '0')}:'
          '${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
    }

    final history = programMachine?.workouts.toList();
    history?.sort((a, b) => b.id!.compareTo(a.id!));

    final cellStyle = isTablet
        ? context.theme.typography.xl2.copyWith(fontWeight: FontWeight.w500)
        : context.theme.typography.md.copyWith(fontWeight: FontWeight.w500);

    final mutedStyle = isTablet
        ? context.theme.typography.xl2.copyWith(
            color: context.theme.colors.mutedForeground,
            fontWeight: FontWeight.w500,
          )
        : context.theme.typography.md.copyWith(
            color: context.theme.colors.mutedForeground,
            fontWeight: FontWeight.w500,
          );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Table(
        columnWidths: const {
          // Date label needs more room than weight/time (e.g. "4/28/2026").
          0: FractionColumnWidth(.42),
          1: FractionColumnWidth(.28),
          2: FractionColumnWidth(.30),
        },
        children: List.generate(
          history?.length ?? 0,
          (index) => TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: history?[index].dateSession == null
                    ? Text(
                        'Upcoming',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: cellStyle.copyWith(
                          color: context.theme.colors.primary,
                        ),
                      )
                    : Text(
                        DateFormat.yMd()
                            .format(history![index].dateSession!),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: cellStyle,
                      ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  '${history?[index].weight ?? ''} lb',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: cellStyle,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: history?[index].sessionTime == null
                    ? const Text('')
                    : Text(
                        formatDuration(Duration(
                            seconds: history?[index].sessionTime ?? 0)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: mutedStyle,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

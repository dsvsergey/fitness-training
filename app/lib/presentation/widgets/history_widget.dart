import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/fitness/fitness.dart';

class HistoryWidget extends StatelessWidget {
  final ProgramMachineEntity? programMachine;

  /// Called from the "+" next to the upcoming session's weight, so the coach
  /// can change it without opening the full settings editor.
  final void Function(WorkoutSessionEntity session)? onEditWeight;

  const HistoryWidget({
    super.key,
    required this.programMachine,
    this.onEditWeight,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    String formatDuration(Duration duration) {
      return '${duration.inHours}:'
          '${(duration.inMinutes % 60).toString().padLeft(2, '0')}:'
          '${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
    }

    // Only the last month is shown; the upcoming (undated) session always stays.
    final now = DateTime.now();
    final monthAgo = DateTime(now.year, now.month - 1, now.day);
    final history = programMachine?.workouts
        .where((w) =>
            w.dateSession == null || !w.dateSession!.isBefore(monthAgo))
        .toList();
    history?.sort((a, b) => b.id!.compareTo(a.id!));

    final cellStyle = isTablet
        ? context.theme.typography.lg.copyWith(fontWeight: FontWeight.w500)
        : context.theme.typography.md.copyWith(fontWeight: FontWeight.w500);

    final mutedStyle = isTablet
        ? context.theme.typography.lg.copyWith(
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
          0: FractionColumnWidth(.34),
          1: FractionColumnWidth(.42),
          2: FractionColumnWidth(.24),
        },
        children: List.generate(
          history?.length ?? 0,
          (index) => TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: history?[index].dateSession == null
                    ? Text(
                        'Upcoming',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: cellStyle,
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
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Flexible(
                      // "280 / 380 lb" plus the "+" is too wide for a phone
                      // column; shrink it slightly rather than cut it off.
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${history?[index].weightLabel ?? ''} lb',
                          maxLines: 1,
                          style: cellStyle,
                        ),
                      ),
                    ),
                    if (onEditWeight != null &&
                        history?[index].dateSession == null)
                      _EditWeightButton(
                        large: isTablet,
                        onTap: () => onEditWeight!(history![index]),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
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

class _EditWeightButton extends StatelessWidget {
  const _EditWeightButton({required this.onTap, this.large = false});

  final VoidCallback onTap;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final size = large ? 28.0 : 24.0;
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Material(
        color: context.theme.colors.primary,
        shape: const CircleBorder(),
        child: InkWell(
          key: const ValueKey('edit-upcoming-weight'),
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(
              FIcons.plus,
              size: large ? 18 : 16,
              color: context.theme.colors.primaryForeground,
            ),
          ),
        ),
      ),
    );
  }
}

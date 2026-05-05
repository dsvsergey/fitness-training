import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../../domain/entities/fitness/fitness.dart';

class TrainingProgramWidget extends StatelessWidget {
  const TrainingProgramWidget({
    super.key,
    required this.programs,
    required this.onTap,
    required this.onDismissed,
    required this.onArchived,
    this.highlightedProgramId,
  });

  final List<ProgramFitnessEntity> programs;
  final Function(ProgramFitnessEntity) onTap;
  final Function(ProgramFitnessEntity) onDismissed;
  final Function(ProgramFitnessEntity) onArchived;
  final int? highlightedProgramId;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: programs.length,
      itemBuilder: (context, index) {
        final item = programs[index];
        final dateLabel = item.workoutDate != null
            ? '${item.workoutDate!.month.toString().padLeft(2, '0')}/'
                '${item.workoutDate!.day.toString().padLeft(2, '0')}/'
                '${item.workoutDate!.year}'
            : null;
        final isHighlighted =
            highlightedProgramId != null && item.id == highlightedProgramId;

        return Dismissible(
          key: Key(item.id.toString()),
          onDismissed: (_) {
            onArchived(item);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  item.isArchive ?? false
                      ? '${item.name} unarchived'
                      : '${item.name} archived',
                ),
              ),
            );
          },
          background: ColoredBox(
            color: context.theme.colors.secondary,
            child: const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 20),
                child: Icon(FIcons.archive, color: Colors.white),
              ),
            ),
          ),
          secondaryBackground: ColoredBox(
            color: context.theme.colors.secondary,
            child: const Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.only(right: 20),
                child: Icon(FIcons.archive, color: Colors.white),
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
            child: FTile(
              prefix: isHighlighted
                  ? Icon(
                      FIcons.calendar,
                      color: context.theme.colors.primary,
                    )
                  : null,
              title: Text(
                item.name ?? '',
                style: context.theme.typography.sm.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isHighlighted
                      ? context.theme.colors.primary
                      : null,
                ),
              ),
              details: dateLabel != null ? Text(dateLabel) : null,
              suffix: const Icon(FIcons.chevronRight),
              onPress: () => onTap(item),
            ),
          ),
        );
      },
    );
  }
}

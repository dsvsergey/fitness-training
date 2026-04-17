import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/fitness/fitness.dart';

class GridCalendarWidget extends StatelessWidget {
  const GridCalendarWidget({
    required this.onTap,
    required this.appointment,
    super.key,
  });
  final WorkoutAppointmentEntity appointment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final avatarSize = isPortrait ? 80.0 : 120.0;
    final isCompleted =
        appointment.status == AppointmentStatusEnumEntity.completed;

    final initials = appointment.trainee.fullName
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0] : '')
        .take(2)
        .join();

    final avatar = appointment.trainee.photoUrl != null
        ? FAvatar(
            image: NetworkImage(appointment.trainee.photoUrl!),
            fallback: Text(initials),
            size: avatarSize,
          )
        : FAvatar.raw(
            size: avatarSize,
            child: Text(
              initials,
              style: context.theme.typography.xl2
                  .copyWith(fontWeight: FontWeight.bold),
            ),
          );

    final nameColor =
        isCompleted ? context.theme.colors.mutedForeground : null;
    final timeColor =
        isCompleted ? context.theme.colors.mutedForeground : null;

    final timeStr =
        '${appointment.startAt.hour.toString().padLeft(2, '0')}:${appointment.startAt.minute.toString().padLeft(2, '0')}'
        ' - '
        '${appointment.endAt.hour.toString().padLeft(2, '0')}:${appointment.endAt.minute.toString().padLeft(2, '0')}';

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            avatar,
            const SizedBox(height: 5),
            Text(
              appointment.trainee.fullName,
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: context.theme.typography.xl2.copyWith(
                fontWeight: FontWeight.w500,
                color: nameColor,
              ),
            ),
            Text(
              appointment.coach.lastName!
                  .trimLeft()
                  .replaceAll('@', '')
                  .trim(),
              style: context.theme.typography.md.copyWith(
                color: context.theme.colors.mutedForeground,
                fontWeight: FontWeight.w300,
              ),
            ),
            Text(
              DateFormat.yMd().format(appointment.startAt),
              style: context.theme.typography.lg.copyWith(
                fontWeight: FontWeight.w700,
                color: timeColor,
              ),
            ),
            Text(
              timeStr,
              style: context.theme.typography.lg.copyWith(
                fontWeight: FontWeight.w700,
                color: timeColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

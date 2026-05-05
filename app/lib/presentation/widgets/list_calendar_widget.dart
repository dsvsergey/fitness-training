import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/fitness/fitness.dart';
import 'user_avatar_widget.dart';

class ListCalendarWidget extends StatelessWidget {
  const ListCalendarWidget({
    required this.onTap,
    required this.appointment,
    super.key,
  });
  final VoidCallback onTap;
  final WorkoutAppointmentEntity appointment;

  @override
  Widget build(BuildContext context) {
    final fullName = appointment.trainee.fullName.trim();
    final isCompleted =
        appointment.status == AppointmentStatusEnumEntity.completed;

    final initials = fullName
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0] : '')
        .take(2)
        .join();

    final avatar = UserAvatarWidget(
      photoUrl: appointment.trainee.photoUrl,
      initials: initials.isEmpty ? 'NA' : initials,
      size: 48,
      textStyle: context.theme.typography.sm
          .copyWith(fontWeight: FontWeight.bold),
    );

    final coachName = appointment.coach.lastName
            ?.trimLeft()
            .replaceAll('@', '')
            .trim() ??
        '';

    final timeStr =
        '${appointment.startAt.hour.toString().padLeft(2, '0')}:${appointment.startAt.minute.toString().padLeft(2, '0')}'
        ' - '
        '${appointment.endAt.hour.toString().padLeft(2, '0')}:${appointment.endAt.minute.toString().padLeft(2, '0')}';

    final dateStr = DateFormat.yMd().format(appointment.startAt);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: FTile(
        prefix: avatar,
        title: Text(
          fullName.isEmpty ? 'No Name' : fullName,
          overflow: TextOverflow.ellipsis,
          style: context.theme.typography.md.copyWith(
            fontWeight: FontWeight.w500,
            color: isCompleted ? context.theme.colors.mutedForeground : null,
          ),
        ),
        subtitle: Text(
          '$dateStr ($timeStr)${coachName.isNotEmpty ? '  •  $coachName' : ''}',
          overflow: TextOverflow.ellipsis,
          style: context.theme.typography.xs.copyWith(
            color: context.theme.colors.mutedForeground,
          ),
        ),
        suffix: const Icon(FIcons.chevronRight),
        onPress: onTap,
      ),
    );
  }
}

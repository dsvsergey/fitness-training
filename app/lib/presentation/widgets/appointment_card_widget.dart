import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../../domain/entities/fitness/fitness.dart';
import 'user_avatar_widget.dart';

/// Agenda-style card for a single workout appointment: large start time,
/// status-coloured accent, trainee, coach and notes. Used on both phone
/// (list) and tablet (grid) layouts of the History screen.
class AppointmentCardWidget extends StatelessWidget {
  const AppointmentCardWidget({
    required this.appointment,
    required this.onTap,
    super.key,
  });

  final WorkoutAppointmentEntity appointment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final status = AppointmentStatusStyle.of(appointment.status);
    final isCompleted =
        appointment.status == AppointmentStatusEnumEntity.completed;

    final fullName = appointment.trainee.fullName.trim();
    final initials = fullName
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .take(2)
        .join();
    final coachName =
        appointment.coach.lastName?.replaceAll('@', '').trim() ?? '';
    final minutes = appointment.endAt.difference(appointment.startAt).inMinutes;
    final notes = appointment.notes?.trim() ?? '';

    return Material(
      color: colors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: colors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 5, color: status.color),
              // ── Time column ────────────────────────────────────────────
              SizedBox(
                width: 84,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _hm(appointment.startAt),
                        style: typography.xl.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isCompleted
                              ? colors.mutedForeground
                              : colors.foreground,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      if (minutes > 0) ...[
                        const SizedBox(height: 2),
                        Text(
                          '$minutes min',
                          style: typography.xs.copyWith(
                            color: colors.mutedForeground,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              VerticalDivider(width: 1, color: colors.border),
              // ── Trainee / coach / notes ────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 8, 14),
                  child: Row(
                    children: [
                      UserAvatarWidget(
                        photoUrl: appointment.trainee.photoUrl,
                        initials: initials.isEmpty ? 'NA' : initials,
                        size: 48,
                        textStyle: typography.sm
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              fullName.isEmpty ? 'No Name' : fullName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: typography.md.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colors.foreground,
                              ),
                            ),
                            if (coachName.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(FIcons.user,
                                      size: 13,
                                      color: colors.mutedForeground),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      coachName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: typography.xs.copyWith(
                                        color: colors.mutedForeground,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            if (notes.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                notes,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: typography.xs.copyWith(
                                  color: colors.mutedForeground,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      _StatusChip(style: status),
                      Icon(FIcons.chevronRight,
                          size: 18, color: colors.mutedForeground),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _hm(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.style});

  final AppointmentStatusStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: style.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        style.label,
        style: context.theme.typography.xs.copyWith(
          color: style.color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Label + colour for an appointment status.
class AppointmentStatusStyle {
  const AppointmentStatusStyle(this.label, this.color);

  final String label;
  final Color color;

  static AppointmentStatusStyle of(AppointmentStatusEnumEntity? status) {
    switch (status) {
      case AppointmentStatusEnumEntity.completed:
        return const AppointmentStatusStyle('Done', Color(0xFF2E7D32));
      case AppointmentStatusEnumEntity.arrived:
        return const AppointmentStatusStyle('Arrived', Color(0xFF6A1B9A));
      case AppointmentStatusEnumEntity.confirmed:
        return const AppointmentStatusStyle('Confirmed', Color(0xFF1565C0));
      case AppointmentStatusEnumEntity.booked:
        return const AppointmentStatusStyle('Booked', Color(0xFF1565C0));
      case AppointmentStatusEnumEntity.requested:
        return const AppointmentStatusStyle('Requested', Color(0xFFEF6C00));
      case AppointmentStatusEnumEntity.noShow:
        return const AppointmentStatusStyle('No-show', Color(0xFFC62828));
      default:
        return const AppointmentStatusStyle('Scheduled', Color(0xFF757575));
    }
  }
}

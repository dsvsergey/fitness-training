import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../../domain/entities/fitness/fitness.dart';
import '../utils/string_utils.dart';
import 'contact_actions_menu.dart';
import 'user_avatar_widget.dart';

/// Contact card used in the tablet grid layout.
class GridContactsWidget extends StatelessWidget {
  const GridContactsWidget({
    super.key,
    required this.model,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  final TraineeEntity model;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    final initials = model.fullName
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .take(2)
        .join();

    final stats = [
      if (model.weight != null) '${_format(model.weight!)} kg',
      if (model.height != null) '${_format(model.height!)} cm',
    ].join(' · ');
    final email = model.email?.trim() ?? '';
    final phone = model.mobilePhone?.trim() ?? '';

    return Material(
      color: colors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 20, 12, 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  UserAvatarWidget(
                    photoUrl: model.photoUrl,
                    initials: initials,
                    size: 72,
                    textStyle: typography.lg
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    model.fullName,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: typography.md.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.foreground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stats.isEmpty ? 'No body metrics' : stats,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: typography.xs.copyWith(
                      color: colors.mutedForeground,
                    ),
                  ),
                  for (final line in [
                    if (email.isNotEmpty) email,
                    if (phone.isNotEmpty) phone.formatPhone(),
                  ]) ...[
                    const SizedBox(height: 2),
                    Text(
                      line,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: typography.xs.copyWith(
                        color: colors.mutedForeground,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (onEdit != null || onDelete != null)
              Positioned(
                top: 0,
                right: 0,
                child: ContactActionsMenu(onEdit: onEdit, onDelete: onDelete),
              ),
          ],
        ),
      ),
    );
  }

  static String _format(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);
}

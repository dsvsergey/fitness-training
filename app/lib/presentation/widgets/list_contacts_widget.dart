import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../../domain/entities/fitness/fitness.dart';
import 'contact_actions_menu.dart';
import 'user_avatar_widget.dart';

class ListContactsWidget extends StatelessWidget {
  const ListContactsWidget({
    super.key,
    required this.client,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  final TraineeEntity client;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final initials = client.fullName
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0] : '')
        .take(2)
        .join();

    final avatar = UserAvatarWidget(
      photoUrl: client.photoUrl,
      initials: initials,
      size: 48,
      textStyle: context.theme.typography.sm
          .copyWith(fontWeight: FontWeight.bold),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: FTile(
        prefix: avatar,
        title: Text(
          client.fullName,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          'Weight: ${client.weight != null ? '${client.weight} kg' : 'N/A'}'
          '   Height: ${client.height?.toString() ?? 'N/A'}',
          style: context.theme.typography.xs.copyWith(
            color: context.theme.colors.mutedForeground,
          ),
        ),
        suffix: (onEdit != null || onDelete != null)
            ? ContactActionsMenu(onEdit: onEdit, onDelete: onDelete)
            : const Icon(FIcons.chevronRight),
        onPress: onTap,
      ),
    );
  }
}

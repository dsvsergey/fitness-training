import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../../domain/entities/fitness/fitness.dart';

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

    final avatar = client.photoUrl != null
        ? FAvatar(
            image: NetworkImage(client.photoUrl!),
            fallback: Text(initials),
            size: 48,
          )
        : FAvatar.raw(
            size: 48,
            child: Text(
              initials,
              style: context.theme.typography.sm
                  .copyWith(fontWeight: FontWeight.bold),
            ),
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
            ? PopupMenuButton<_Action>(
                icon: const Icon(Icons.more_vert, size: 20),
                onSelected: (action) {
                  if (action == _Action.edit) onEdit?.call();
                  if (action == _Action.delete) onDelete?.call();
                },
                itemBuilder: (_) => [
                  if (onEdit != null)
                    const PopupMenuItem(
                      value: _Action.edit,
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18),
                          SizedBox(width: 10),
                          Text('Edit'),
                        ],
                      ),
                    ),
                  if (onDelete != null)
                    const PopupMenuItem(
                      value: _Action.delete,
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline,
                              size: 18, color: Color(0xFFD32F2F)),
                          SizedBox(width: 10),
                          Text('Delete',
                              style: TextStyle(color: Color(0xFFD32F2F))),
                        ],
                      ),
                    ),
                ],
              )
            : const Icon(FIcons.chevronRight),
        onPress: onTap,
      ),
    );
  }
}

enum _Action { edit, delete }

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../../domain/entities/fitness/fitness.dart';

class ListContactsWidget extends StatelessWidget {
  const ListContactsWidget({
    super.key,
    required this.client,
    required this.onTap,
  });

  final TraineeEntity client;
  final VoidCallback onTap;

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
        suffix: const Icon(FIcons.chevronRight),
        onPress: onTap,
      ),
    );
  }
}

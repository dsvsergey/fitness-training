import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../../domain/entities/fitness/coach_entity.dart';

class UserInfoWidget extends StatelessWidget {
  final CoachEntity? coach;

  const UserInfoWidget({super.key, this.coach});

  @override
  Widget build(BuildContext context) {
    final fullName = coach?.fullName.trim() ?? 'N/A';

    return FCard(
      title: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Text(
          fullName,
          textAlign: TextAlign.center,
          style: context.theme.typography.lg.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      child: FTileGroup(
        divider: FItemDivider.indented,
        children: [
          FTile(
            prefix: const Icon(FIcons.phone),
            title: const Text('Phone number'),
            details: Text(coach?.mobilePhone ?? 'N/A'),
          ),
          FTile(
            prefix: const Icon(FIcons.mail),
            title: const Text('Email'),
            details: Text(
              coach?.email ?? 'N/A',
              overflow: TextOverflow.ellipsis,
            ),
          ),
          FTile(
            prefix: const Icon(FIcons.notebookPen),
            title: const Text('Notes'),
            subtitle: coach?.note?.trim().isNotEmpty == true
                ? Text(coach!.note!.trim())
                : null,
          ),
        ],
      ),
    );
  }
}

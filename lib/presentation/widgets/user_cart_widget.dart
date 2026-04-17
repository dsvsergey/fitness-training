import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../../domain/entities/fitness/fitness.dart';

class UserCardWidget extends StatelessWidget {
  const UserCardWidget({super.key, required this.model});

  final TraineeEntity model;

  @override
  Widget build(BuildContext context) {
    final age = model.birthDate != null
        ? '${((DateTime.now().difference(model.birthDate!).inDays) / 365).floor()} y'
        : '—';
    final weight = model.weight?.toString() ?? '—';
    final height = model.height?.toString() ?? '—';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: FCard(
        title: Text(
          model.fullName,
          textAlign: TextAlign.center,
          style: context.theme.typography.lg
              .copyWith(fontWeight: FontWeight.w600),
        ),
        child: FTileGroup(
          divider: FItemDivider.indented,
          children: [
            FTile(
              prefix: const Icon(FIcons.phone),
              title: const Text('Phone'),
              details: Text(model.mobilePhone ?? '—'),
            ),
            FTile(
              prefix: const Icon(FIcons.cake),
              title: const Text('Age'),
              details: Text(age),
            ),
            FTile(
              prefix: const Icon(FIcons.weight),
              title: const Text('Weight'),
              details: Text(weight),
            ),
            FTile(
              prefix: const Icon(FIcons.ruler),
              title: const Text('Height'),
              details: Text(height),
            ),
            if (model.notes?.trim().isNotEmpty == true)
              FTile(
                prefix: const Icon(FIcons.notebookPen),
                title: const Text('Notes'),
                subtitle: Text(model.notes!.trim()),
              ),
          ],
        ),
      ),
    );
  }
}

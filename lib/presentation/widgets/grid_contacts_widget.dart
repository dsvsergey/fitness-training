import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../../domain/entities/fitness/fitness.dart';
import 'user_avatar_widget.dart';

class GridContactsWidget extends StatelessWidget {
  const GridContactsWidget({
    super.key,
    required this.model,
    required this.onTap,
  });

  final TraineeEntity model;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final avatarSize = isPortrait ? 72.0 : 96.0;

    final initials = model.fullName
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0] : '')
        .take(2)
        .join();

    final avatar = UserAvatarWidget(
      photoUrl: model.photoUrl,
      initials: initials,
      size: avatarSize,
      textStyle: context.theme.typography.lg
          .copyWith(fontWeight: FontWeight.bold),
    );

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          avatar,
          const SizedBox(height: 8),
          Text(
            model.fullName,
            maxLines: 1,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: context.theme.typography.sm
                .copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

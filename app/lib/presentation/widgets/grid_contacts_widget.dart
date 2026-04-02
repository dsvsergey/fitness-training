import 'package:colorize_text_avatar/colorize_text_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/resources/themes/app_fonts.dart';
import '../../domain/entities/fitness/fitness.dart';

class GridContactsWidget extends StatelessWidget {
  const GridContactsWidget({
    required this.onTap,
    required this.model,
    super.key,
  });
  final TraineeEntity model;
  final Function() onTap;
  @override
  Widget build(BuildContext context) {
    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    var avatarSize = isPortrait ? 80.r : 120.r;

    return Center(
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            model.photoUrl == null
                ? TextAvatar(
                    size: avatarSize,
                    shape: Shape.Circular,
                    text: model.fullName,
                    fontSize: 40,
                    numberLetters: 2,
                  )
                : ClipOval(
                    child: Image.network(
                      model.photoUrl!,
                      width: avatarSize,
                      height: avatarSize,
                      fit: BoxFit.cover,
                    ),
                  ),
            const SizedBox(height: 15),
            Text(
              maxLines: 1,
              textAlign: TextAlign.center,
              model.fullName,
              style: AppFonts.w500s24,
            )
          ],
        ),
      ),
    );
  }
}

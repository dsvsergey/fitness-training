import 'package:colorize_text_avatar/colorize_text_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/resources/themes/app_colors.dart';
import '../../core/resources/themes/app_fonts.dart';
import '../../domain/entities/fitness/fitness.dart';

class ListContactsWidget extends StatelessWidget {
  const ListContactsWidget({
    required this.onTap,
    super.key,
    required this.client,
  });

  final TraineeEntity client;
  final Function() onTap;
  @override
  Widget build(BuildContext context) {
    // final mediaQuery = MediaQuery.of(context);
    // final screenWidth = mediaQuery.size.width;
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 10.w,
        horizontal: 5.h,
      ),
      child: Stack(
        children: [
          InkWell(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              height: 109.h,
              padding: const EdgeInsets.all(20),
              decoration: ShapeDecoration(
                color: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                shadows: const [
                  BoxShadow(
                    color: AppColors.shadows,
                    blurRadius: 4,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // TextAvatar(
                  //   size: 50.r,
                  //   shape: Shape.Circular,
                  //   text: client.fullName,
                  // ),
                  client.photoUrl == null
                      ? TextAvatar(
                          size: 50,
                          shape: Shape.Circular,
                          text: client.fullName,
                        )
                      : ClipOval(
                          child: Image.network(
                            client.photoUrl!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                  SizedBox(width: 10.w),
                  Flexible(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          client.fullName,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.w500s18.copyWith(
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Text(
                              "Weight ${client.weight != null ? '${client.weight}.tb' : 'N/A'}",
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: AppFonts.w400s16,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              "Height ${client.height?.toString() ?? 'N/A'}",
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: AppFonts.w400s16,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Material(
          //   color: Colors.transparent,
          //   child: InkWell(
          //     borderRadius: BorderRadius.circular(13),
          //     onTap: onTap,
          //   ),
          // ),
        ],
      ),
    );
  }
}

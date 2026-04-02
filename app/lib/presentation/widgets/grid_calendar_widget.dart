import 'dart:core';

import 'package:colorize_text_avatar/colorize_text_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../core/resources/themes/app_colors.dart';
import '../../core/resources/themes/app_fonts.dart';
import '../../domain/entities/fitness/fitness.dart';

class GridCalendarWidget extends StatelessWidget {
  const GridCalendarWidget({
    required this.onTap,
    required this.appointment,
    super.key,
  });
  final WorkoutAppointmentEntity appointment;
  final Function() onTap;
  @override
  Widget build(BuildContext context) {
    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    var avatarSize = isPortrait ? 80.r : 120.r;

    return Expanded(
      child: Center(
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              appointment.trainee.photoUrl == null
                  ? TextAvatar(
                      size: avatarSize,
                      shape: Shape.Circular,
                      numberLetters: 2,
                      fontSize: 40,
                      text: appointment.trainee.fullName,
                    )
                  : ClipOval(
                      child: Image.network(
                        appointment.trainee.photoUrl!,
                        width: avatarSize,
                        height: avatarSize,
                        fit: BoxFit.cover,
                      ),
                    ),
              SizedBox(height: 5.h),
              Text(
                maxLines: 1,
                textAlign: TextAlign.center,
                appointment.trainee.fullName,
                style:
                    appointment.status != AppointmentStatusEnumEntity.completed
                        ? AppFonts.w500s24
                        : AppFonts.w500s24.copyWith(
                            color: AppColors.grey,
                          ),
              ),
              SizedBox(width: 5.h),
              Text(
                  appointment.coach.lastName!
                      .trimLeft()
                      .replaceAll('@', '')
                      .trim(),
                  style: const TextStyle(
                    color: Color(0xFFA3A3A3),
                    fontSize: 16,
                    fontFamily: "Inter",
                    fontWeight: FontWeight.w300,
                    height: 0,
                  )),
              Text(
                  DateFormat.yMd().format(appointment
                      .startAt), // Use DateFormat for short date format
                  style: appointment.status !=
                          AppointmentStatusEnumEntity.completed
                      ? AppFonts.w700s19
                      : AppFonts.w700s19.copyWith(
                          color: AppColors.grey,
                        )),
              // SizedBox(width: 5.h),
              Text(
                '${appointment.startAt.hour.toString().padLeft(2, '0')}:${appointment.startAt.minute.toString().padLeft(2, '0')} - ${appointment.endAt.hour.toString().padLeft(2, '0')}:${appointment.endAt.minute.toString().padLeft(2, '0')}',
                style:
                    appointment.status != AppointmentStatusEnumEntity.completed
                        ? AppFonts.w700s19
                        : AppFonts.w700s19.copyWith(color: AppColors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

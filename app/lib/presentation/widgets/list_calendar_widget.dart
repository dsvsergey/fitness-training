import 'package:colorize_text_avatar/colorize_text_avatar.dart';
import 'package:fitness_training/core/resources/themes/app_colors.dart';
import 'package:fitness_training/domain/entities/fitness/fitness.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ListCalendarWidget extends StatelessWidget {
  const ListCalendarWidget({
    required this.onTap,
    super.key,
    required this.appointment,
  });
  final Function() onTap;
  final WorkoutAppointmentEntity appointment;

  @override
  Widget build(BuildContext context) {
    final fullName = appointment.trainee.fullName.trim();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      child: Stack(
        children: [
          InkWell(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              height: 112,
              padding: const EdgeInsets.all(20),
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                shadows: const [
                  BoxShadow(
                    color: Color(0x26000000),
                    blurRadius: 4,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (appointment.trainee.photoUrl == null)
                    TextAvatar(
                      size: 50,
                      shape: Shape.Circular,
                      text: fullName.isEmpty ? 'NA' : fullName,
                    )
                  else
                    ClipOval(
                      child: Image.network(
                        appointment.trainee.photoUrl!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${DateFormat.yMd().format(appointment.startAt)} (${appointment.startAt.hour.toString().padLeft(2, '0')}:${appointment.startAt.minute.toString().padLeft(2, '0')} - ${appointment.endAt.hour.toString().padLeft(2, '0')}:${appointment.endAt.minute.toString().padLeft(2, '0')})',
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFFA3A3A3),
                            fontSize: 16,
                            fontFamily: "Inter",
                            fontWeight: FontWeight.w400,
                            height: 0,
                          ),
                        ),
                        Text(
                          appointment.coach.lastName
                                  ?.trimLeft()
                                  .replaceAll('@', '')
                                  .trim() ??
                              '',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFFA3A3A3),
                            fontSize: 14,
                            fontFamily: "Inter",
                            fontWeight: FontWeight.w300,
                            height: 0,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          fullName.isEmpty ? 'No Name' : fullName,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color:
                                appointment.status ==
                                    AppointmentStatusEnumEntity.completed
                                ? AppColors.grey
                                : const Color(0xFF1E1E1E),
                            fontSize: 18,
                            fontFamily: "Inter",
                            fontWeight: FontWeight.w500,
                            height: 0,
                          ),
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

import 'package:auto_route/auto_route.dart';
import 'package:colorize_text_avatar/colorize_text_avatar.dart';
import 'package:fitness_training/domain/entities/fitness/fitness.dart';
import 'package:flutter/material.dart';

import '../../../core/resources/resources.dart';
import '../../../core/resources/themes/app_colors.dart';
import '../../../core/resources/themes/app_fonts.dart';
import '../../widgets/text_parameters_user_widget.dart';

@RoutePage()
class CalendarInfoScreens extends StatelessWidget {
  const CalendarInfoScreens({
    super.key,
    required this.appointment,
  });
  final WorkoutAppointmentEntity appointment;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    return Scaffold(
      appBar: AppBar(
        leadingWidth: screenWidth > 600 ? 100 : 80,
        leading: IconButton(
          icon: Image.asset(
            AppPngs.back,
          ),
          onPressed: () {
            context.router.maybePop();
            // StackRouter.of(context).pop(const ContactsRoute());
          },
        ),
      ),
      body: Column(
        children: [
          TextAvatar(
            size: screenWidth > 600 ? 160 : 130,
            shape: Shape.Circular,
            text: appointment.trainee.fullName,
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth > 600 ? 40 : 20,
            ),
            child: Container(
              width: double.infinity,
              height: 180,
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
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    appointment.trainee.fullName,
                    textAlign: TextAlign.center,
                    style:
                        screenWidth > 600 ? AppFonts.w800s40 : AppFonts.w800s30,
                  ),
                  TextParametersUserWidget(
                    textOne: 'Phone number ',
                    textTwo: appointment.trainee.mobilePhone ?? '-',
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth > 600 ? 180 : 5,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextParametersUserWidget(
                          textOne: 'Age ',
                          textTwo: appointment.trainee.birthDate != null
                              ? '${(appointment.trainee.birthDate!.difference(DateTime.now()).inDays / 365).floor()} y'
                              : 'N/A',
                        ),
                        TextParametersUserWidget(
                          textOne: 'Weight ',
                          textTwo:
                              appointment.trainee.weight?.toString() ?? 'N/A',
                        ),
                        TextParametersUserWidget(
                          textOne: 'Height ',
                          textTwo:
                              appointment.trainee.height?.toString() ?? 'N/A',
                        ),
                      ],
                    ),
                  ),
                  Text(
                    appointment.trainee.notes ?? '-',
                    textAlign: TextAlign.center,
                    style:
                        screenWidth > 600 ? AppFonts.w400s24 : AppFonts.w400s18,
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

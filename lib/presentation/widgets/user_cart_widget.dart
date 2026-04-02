import 'package:flutter/material.dart';

import '../../core/resources/themes/app_colors.dart';
import '../../core/resources/themes/app_fonts.dart';
import '../../domain/entities/fitness/fitness.dart';
import 'text_parameters_user_widget.dart';

class UserCardWidget extends StatelessWidget {
  const UserCardWidget({
    super.key,
    required this.model,
  });

  final TraineeEntity model;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth > 600 ? 40 : 20,
      ),
      child: Container(
        width: double.infinity,
        // height: 180,
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
          children: [
            Text(model.fullName,
                textAlign: TextAlign.center,
                // style: const TextStyle(
                //   color: Colors.black,
                //   fontSize: 30,
                // ),
                style: screenWidth > 600
                    ? AppFonts.w400s30.copyWith(
                        color: Colors.black,
                      )
                    : AppFonts.w400s20),
            TextParametersUserWidget(
              textOne: 'Phone number ',
              textTwo: model.mobilePhone ?? '...',
            ),
            SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextParametersUserWidget(
                        textOne: 'Age ',
                        textTwo: model.birthDate != null
                            ? '${(model.birthDate!.difference(DateTime.now()).inDays / 365).floor()} y'
                            : '...',
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      TextParametersUserWidget(
                        textOne: 'Weight ',
                        textTwo: model.weight?.toString() ?? '...',
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      TextParametersUserWidget(
                        textOne: 'Height ',
                        textTwo: model.height?.toString() ?? '...',
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                          maxHeight:
                              100), // Adjust this value to fit 4 lines of text
                      child: SingleChildScrollView(
                        child: Text(
                          model.notes ?? '',
                          textAlign: TextAlign.justify,
                          softWrap: true,
                          style: screenWidth > 600
                              ? AppFonts.w400s20
                              : AppFonts.w400s16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            //
          ],
        ),
      ),
    );
  }
}

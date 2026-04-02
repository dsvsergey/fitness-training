import 'package:flutter/material.dart';

import '../../core/resources/themes/app_fonts.dart';
import '../../domain/entities/fitness/coach_entity.dart';

class UserInfoWidget extends StatelessWidget {
  final CoachEntity? coach;

  const UserInfoWidget({
    super.key,
    this.coach,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final fullName = coach?.fullName.trim() ?? 'N/A';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth > 600 ? 40 : 20),
      child: Container(
        width: double.infinity,
        height: 230,
        padding: const EdgeInsets.symmetric(horizontal: 20),
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
              spreadRadius: 0,
            )
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                fullName,
                textAlign: TextAlign.center,
                style: screenWidth > 600
                    ? AppFonts.w500s30.copyWith(
                        color: Colors.black,
                      )
                    : AppFonts.w400s20,
              ),
              const SizedBox(height: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Phone number',
                        style: TextStyle(
                          color: Color(0xFFA3A3A3),
                          fontSize: 18,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          height: 0,
                        ),
                      ),
                      SizedBox(width: screenWidth > 600 ? 20 : 10),
                      Text(
                        coach?.mobilePhone ?? 'N/A',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          height: 0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 11),
                  Row(
                    children: [
                      const Text(
                        'Email',
                        style: TextStyle(
                          color: Color(0xFFA3A3A3),
                          fontSize: 18,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          height: 0,
                        ),
                      ),
                      SizedBox(width: screenWidth > 600 ? 20 : 10),
                      Expanded(
                        child: Text(
                          coach?.email ?? 'N/A',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            height: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 11),
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notes',
                        style: TextStyle(
                          color: Color(0xFFA3A3A3),
                          fontSize: 18,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          height: 0,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight: 140,
                      ),
                      child: Text(
                        coach?.note?.trim() ?? '',
                        textAlign: TextAlign.justify,
                        softWrap: true,
                        style: screenWidth > 600
                            ? AppFonts.w400s24.copyWith(
                                color: Colors.black,
                              )
                            : AppFonts.w400s18.copyWith(
                                color: Colors.black,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

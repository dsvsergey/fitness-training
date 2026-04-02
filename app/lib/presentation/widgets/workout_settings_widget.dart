import 'package:flutter/material.dart';

class WorkoutSettingsWidget extends StatelessWidget {
  const WorkoutSettingsWidget({
    super.key,
    required this.textOne,
    required this.textProgramOne,
    required this.textTwo,
    required this.textProgramTwo,
  });
  final String textOne;
  final String textProgramOne;
  final String textTwo;
  final String textProgramTwo;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 150,
                  child: Row(
                    children: [
                      Text(
                        textOne,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          fontSize: 21.0,
                          color: Colors.grey,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        textProgramOne,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontSize: 21.0,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 150,
                  child: Row(
                    children: [
                      Text(
                        textTwo,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          fontSize: 21.0,
                          color: Colors.grey,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        textProgramTwo,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontSize: 21.0,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:fitness_training/domain/entities/fitness/fitness.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TrainingProgramWidget extends StatelessWidget {
  const TrainingProgramWidget({
    super.key,
    required this.programs,
    required this.onTap,
    required this.onDismissed,
    required this.onArchived,
  });
  final List<ProgramFitnessEntity> programs;
  final Function(ProgramFitnessEntity) onTap;
  final Function(ProgramFitnessEntity) onDismissed;
  final Function(ProgramFitnessEntity) onArchived;
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final size = screenWidth > 600;
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      shrinkWrap: true,
      itemCount: programs.length,
      itemBuilder: (context, index) {
        final item = programs[index];
        return Dismissible(
          key: Key(
            item.id.toString(),
          ), // assuming that each item has a unique id
          onDismissed: (direction) {
            // if (direction == DismissDirection.endToStart) {
            //   onDismissed(item);
            //   ScaffoldMessenger.of(context).showSnackBar(
            //     SnackBar(content: Text('${item.name} dismissed')),
            //   );
            // } else {
            onArchived(item);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  item.isArchive ?? false
                      ? '${item.name} unarchived'
                      : '${item.name} archived',
                ),
              ),
            );
            // }
          },
          background: Container(
            color: Colors.green,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20),
            child: const Icon(Icons.archive),
          ),
          secondaryBackground: Container(
            color: Colors.green,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.archive),
          ),
          // secondaryBackground: Container(
          //   color: Colors.red,
          //   alignment: Alignment.centerRight,
          //   padding: const EdgeInsets.only(right: 20),
          //   child: const Icon(Icons.delete),
          // ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Center(
              child: InkWell(
                onTap: () => onTap(item),
                child: Container(
                  width: size ? 240.w : double.infinity,
                  height: size ? 70.h : 50.h,
                  padding: const EdgeInsets.all(10),
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
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.name ?? '',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xFF1E1E1E),
                            fontSize: size ? 13.sp : 15.sp,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w800,
                            height: 0,
                          ),
                        ),
                        if (item.workoutDate != null)
                          Text(
                            '${item.workoutDate!.month.toString().padLeft(2, '0')}/${item.workoutDate!.day.toString().padLeft(2, '0')}/${item.workoutDate!.year}',
                            style: const TextStyle(
                              color: Color(0xFF1E1E1E),
                              fontSize: 18,
                              fontFamily: "Inter",
                              fontWeight: FontWeight.w500,
                              height: 0,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../../../domain/entities/fitness/fitness.dart';
import '../../widgets/user_cart_widget.dart';

@RoutePage()
class CalendarInfoScreens extends StatelessWidget {
  const CalendarInfoScreens({
    super.key,
    required this.appointment,
  });
  final WorkoutAppointmentEntity appointment;

  @override
  Widget build(BuildContext context) {
    final trainee = appointment.trainee;
    final initials = trainee.fullName
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0] : '')
        .take(2)
        .join();

    final avatar = trainee.photoUrl != null
        ? FAvatar(
            image: NetworkImage(trainee.photoUrl!),
            fallback: Text(initials),
            size: 120,
          )
        : FAvatar.raw(
            size: 120,
            child: Text(
              initials,
              style: context.theme.typography.xl3
                  .copyWith(fontWeight: FontWeight.bold),
            ),
          );

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          backgroundColor: context.theme.colors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: Icon(FIcons.arrowLeft, color: context.theme.colors.foreground),
            onPressed: () => context.router.maybePop(),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Center(child: avatar),
            const SizedBox(height: 16),
            UserCardWidget(model: trainee),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

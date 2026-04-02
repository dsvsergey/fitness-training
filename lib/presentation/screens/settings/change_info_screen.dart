import 'package:auto_route/auto_route.dart';
import 'package:colorize_text_avatar/colorize_text_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';

import '../../../core/bloc/bloc_application/application_bloc.dart';
import '../../../core/resources/resources.dart';
import '../../../core/router/router.dart';
import '../../../domain/entities/fitness/coach_entity.dart';
import '../../../domain/usecases/fitness/fitness.dart';
import '../../widgets/button_widget.dart';
import '../../widgets/image_user_widget.dart';
import '../../widgets/user_info_text_field_widget.dart';

@RoutePage()
class ChangeInfoScreen extends StatefulWidget {
  final CoachEntity coach;

  const ChangeInfoScreen({super.key, required this.coach});

  @override
  State<ChangeInfoScreen> createState() => _ChangeInfoScreenState();
}

class _ChangeInfoScreenState extends State<ChangeInfoScreen> {
  CoachEntity? _coach;

  // @override
  // void initState() {
  //   super.initState();
  //   _coach = widget.coach;
  // }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leadingWidth: 70,
        leading: IconButton(
          icon: Image.asset(
            AppPngs.back,
          ),
          onPressed: () {
            AutoRouter.of(context).pop(const ContactsRoute());
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                widget.coach.imageUrl == null
                    ? TextAvatar(
                        fontSize: 80,
                        numberLetters: 2,
                        size: 180.r,
                        shape: Shape.Circular,
                        text:
                            widget.coach.fullName.split(' ').take(2).join(' '),
                      )
                    : ClipOval(
                        child: Image.network(
                          widget.coach.imageUrl!,
                          width: 180.r,
                          height: 180.r,
                          fit: BoxFit.cover,
                        ),
                      ),
                const Positioned(
                  right: 10,
                  bottom: 0,
                  child: ImageUserWidget(),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: screenHeight > 750 ? 80.h : 0.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UserInfoTextFieldWidget(
                      text: 'Your Name',
                      initialValue: widget.coach.firstName,
                      hintText: '',
                      onChanged: (value) => setState(() => _coach =
                          widget.coach.rebuild((p0) => p0..firstName = value))),
                  const SizedBox(height: 10),
                  UserInfoTextFieldWidget(
                    text: 'Your Surname',
                    initialValue: widget.coach.lastName ?? '',
                    hintText: 'Your Surname',
                    onChanged: (value) => setState(() => _coach =
                        widget.coach.rebuild((p0) => p0..lastName = value)),
                  ),
                  const SizedBox(height: 10),
                  UserInfoTextFieldWidget(
                    text: 'Phone number',
                    initialValue: widget.coach.mobilePhone ?? '',
                    hintText: 'Phone number',
                    onChanged: (value) => setState(() => _coach =
                        widget.coach.rebuild((p0) => p0..mobilePhone = value)),
                  ),
                  const SizedBox(height: 10),
                  UserInfoTextFieldWidget(
                    text: 'Email',
                    initialValue: widget.coach.email ?? '',
                    hintText: 'Email',
                    onChanged: (value) => setState(() => _coach =
                        widget.coach.rebuild((p0) => p0..email = value)),
                  ),
                  const SizedBox(height: 10),
                  UserInfoTextFieldWidget(
                    text: 'Notes',
                    initialValue: widget.coach.note ?? '',
                    hintText: '',
                    onChanged: (value) => setState(() => _coach =
                        widget.coach.rebuild((p0) => p0..note = value)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ButtonWidget(
                onPressed: _coach != null
                    ? () {
                        GetIt.I<CoachUsecase>()
                            .updateCoach(_coach!.id!, _coach!)
                            .then((value) {
                          context
                              .read<ApplicationBloc>()
                              .add(UpdateCoachInfoEvent(coach: _coach!));
                          AutoRouter.of(context).pop();
                        });
                        AutoRouter.of(context).pop();
                      }
                    : null,
                title: 'Change Info',
              ),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}

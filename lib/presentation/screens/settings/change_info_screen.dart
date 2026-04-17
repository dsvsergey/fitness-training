import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:get_it/get_it.dart';

import '../../../core/bloc/bloc_application/application_bloc.dart';
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final initials = widget.coach.fullName
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0] : '')
        .join();

    final avatar = widget.coach.imageUrl != null
        ? FAvatar(
            image: NetworkImage(widget.coach.imageUrl!),
            fallback: Text(initials),
            size: 180,
          )
        : FAvatar.raw(
            size: 180,
            child: Text(
              initials,
              style: context.theme.typography.xl3
                  .copyWith(fontWeight: FontWeight.bold),
            ),
          );

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: FHeader.nested(
          title: const SizedBox.shrink(),
          prefixes: [
            FHeaderAction.back(
              onPress: () =>
                  AutoRouter.of(context).pop(const ContactsRoute()),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  avatar,
                  const Positioned(
                    right: 0,
                    bottom: 0,
                    child: ImageUserWidget(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth > 750 ? 80 : 0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UserInfoTextFieldWidget(
                    text: 'Your Name',
                    initialValue: widget.coach.firstName,
                    hintText: '',
                    onChanged: (value) => setState(() => _coach =
                        widget.coach
                            .rebuild((p0) => p0..firstName = value)),
                  ),
                  const SizedBox(height: 10),
                  UserInfoTextFieldWidget(
                    text: 'Your Surname',
                    initialValue: widget.coach.lastName ?? '',
                    hintText: 'Your Surname',
                    onChanged: (value) => setState(() => _coach =
                        widget.coach
                            .rebuild((p0) => p0..lastName = value)),
                  ),
                  const SizedBox(height: 10),
                  UserInfoTextFieldWidget(
                    text: 'Phone number',
                    initialValue: widget.coach.mobilePhone ?? '',
                    hintText: 'Phone number',
                    onChanged: (value) => setState(() => _coach =
                        widget.coach
                            .rebuild((p0) => p0..mobilePhone = value)),
                  ),
                  const SizedBox(height: 10),
                  UserInfoTextFieldWidget(
                    text: 'Email',
                    initialValue: widget.coach.email ?? '',
                    hintText: 'Email',
                    onChanged: (value) => setState(() => _coach =
                        widget.coach
                            .rebuild((p0) => p0..email = value)),
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
                            .then((_) {
                          context.read<ApplicationBloc>().add(
                              UpdateCoachInfoEvent(coach: _coach!));
                          AutoRouter.of(context).pop();
                        });
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

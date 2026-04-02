import 'package:auto_route/auto_route.dart';
import 'package:colorize_text_avatar/colorize_text_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/bloc/bloc_application/application_bloc.dart';
import '../../../core/router/router.dart';
import '../../widgets/button_widget.dart';
import '../../widgets/user_info_widget.dart';

@RoutePage()
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: BlocBuilder<ApplicationBloc, ApplicationState>(
              builder: (context, state) {
                final fullName = (state.user?.coach?.fullName ?? '').trim();
                final initials = fullName.isEmpty
                    ? 'NA'
                    : fullName.split(' ').take(2).join(' ');

                return Column(
                  children: [
                    SizedBox(
                      height: 20.h,
                    ),
                    Stack(
                      children: [
                        if (state.user?.coach?.imageUrl == null)
                          TextAvatar(
                            size: 180.r,
                            fontSize: 80,
                            shape: Shape.Circular,
                            numberLetters: 2,
                            text: initials,
                          )
                        else
                          ClipOval(
                            child: Image.network(
                              state.user!.coach!.imageUrl!,
                              width: 180.r,
                              height: 180.r,
                              fit: BoxFit.cover,
                            ),
                          ),
                        Positioned(
                          right: 10,
                          bottom: 0,
                          child: CircleAvatar(
                            radius: 19,
                            backgroundColor: const Color(0xFFC8CE37),
                            child: IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 31),
                    UserInfoWidget(
                      coach: state.user?.coach,
                    ),
                    const SizedBox(height: 28),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ButtonWidget(
                        onPressed: () {
                          if (state.user?.coach != null) {
                            AutoRouter.of(context).push(
                              ChangeInfoRoute(coach: state.user!.coach!),
                            );
                          }
                        },
                        title: 'Change Info',
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        BlocProvider.of<ApplicationBloc>(context)
                            .add(LogoutEvent());
                        AutoRouter.of(context).replaceAll([const LoginRoute()]);
                      },
                      child: const Text(
                        'Log Out',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

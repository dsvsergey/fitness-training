import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';

import '../../../core/bloc/bloc_application/application_bloc.dart';
import '../../../core/bloc/bloc_theme/theme_cubit.dart';
import '../../../core/router/router.dart';
import '../../../domain/entities/fitness/coach_entity.dart';
import '../../widgets/button_widget.dart';
import '../../widgets/user_avatar_widget.dart';
import '../../widgets/user_info_widget.dart';

@RoutePage()
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
                    : fullName.split(' ').map((w) => w[0]).take(2).join();

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          UserAvatarWidget(
                            photoUrl: state.user?.coach?.imageUrl,
                            initials: initials,
                            size: 120,
                            textStyle: context.theme.typography.xl2
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: context.theme.colors.primary,
                              child: IconButton(
                                onPressed: () {},
                                padding: EdgeInsets.zero,
                                icon: Icon(
                                  Icons.camera_alt,
                                  color: context.theme.colors.primaryForeground,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      UserInfoWidget(coach: state.user?.coach),
                      const SizedBox(height: 20),
                      ButtonWidget(
                        onPressed: () {
                          AutoRouter.of(context).push(
                            ChangeInfoRoute(
                              coach: state.user?.coach ?? CoachEntity(),
                            ),
                          );
                        },
                        title: 'Change Info',
                      ),
                      const SizedBox(height: 20),
                      const _ThemeSelector(),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            BlocProvider.of<ApplicationBloc>(
                              context,
                            ).add(LogoutEvent());
                            AutoRouter.of(
                              context,
                            ).replaceAll([const LoginRoute()]);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFD32F2F),
                            side: const BorderSide(color: Color(0xFFD32F2F)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Log Out',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  const _ThemeSelector();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, mode) {
        final cubit = context.read<ThemeCubit>();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Appearance',
              style: context.theme.typography.md.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _ThemeOption(
                    label: 'Auto',
                    selected: mode == ThemeMode.system,
                    onTap: () => cubit.setMode(ThemeMode.system),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ThemeOption(
                    label: 'Light',
                    selected: mode == ThemeMode.light,
                    onTap: () => cubit.setMode(ThemeMode.light),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ThemeOption(
                    label: 'Dark',
                    selected: mode == ThemeMode.dark,
                    onTap: () => cubit.setMode(ThemeMode.dark),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FButton(
      onPress: onTap,
      variant: selected ? FButtonVariant.primary : FButtonVariant.outline,
      child: Text(label),
    );
  }
}

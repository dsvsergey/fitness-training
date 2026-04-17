import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/fitness/fitness.dart';
import '../../presentation/screens/calendar/calendar_info_screens.dart';
import '../../presentation/screens/calendar/calendar_screen.dart';
import '../../presentation/screens/calendar/table_calendar_screen.dart';
import '../../presentation/screens/contacts/contacts_screen.dart';
import '../../presentation/screens/google_oauth_screen.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/login_screen.dart';
import '../../presentation/screens/machines_program/machines_program_screen.dart';
import '../../presentation/screens/photo_screen.dart';
import '../../presentation/screens/programs/archieve_program_screen.dart';
import '../../presentation/screens/programs/create_program/create_program_screen.dart';
import '../../presentation/screens/programs/program_screen/program_screen.dart';
import '../../presentation/screens/programs/select_training_screens.dart';
import '../../presentation/screens/register_screen.dart';
import '../../presentation/screens/settings/change_info_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/settings_program/settings_program_screen.dart';
import '../../presentation/screens/splash_screen.dart';
import '../../presentation/screens/stopwatch_timer/stopwatch_timer_screens.dart';

part 'router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: SplashRoute.page, path: '/'),
        AutoRoute(page: PhotoRoute.page, path: '/photo'),
        AutoRoute(page: LoginRoute.page, path: '/login'),
        AutoRoute(page: RegisterRoute.page, path: '/register'),
        AutoRoute(page: GoogleOAuthRoute.page, path: '/googleOAuth'),
        AutoRoute(
          page: HomeRoute.page,
          path: '/home',
          children: [
            AutoRoute(page: CalendarRoute.page, path: 'calendar'),
            AutoRoute(page: ContactsRoute.page, path: 'contacts'),
            AutoRoute(page: SettingsRoute.page, path: 'settings'),
          ],
        ),
        AutoRoute(page: ProgramRoute.page, path: '/program'),
        AutoRoute(page: TableCalendarRoute.page, path: '/tableCalendar'),
        AutoRoute(page: CreateProgramRoute.page, path: '/createProgram'),
        AutoRoute(page: SelectTrainingRoute.page, path: '/selectTraining'),
        AutoRoute(page: SettingsProgramRoute.page, path: '/settingsProgram'),
        AutoRoute(page: ChangeInfoRoute.page, path: '/changeInfo'),
        AutoRoute(page: ArchieveProgramRoute.page, path: '/archieveProgram'),
        AutoRoute(page: CalendarInfoRoutes.page, path: '/calendarInfo'),
        AutoRoute(page: MachinesProgramRoute.page, path: '/machinesProgram'),
        AutoRoute(
          page: StopwatchTimerRoutes.page,
          path: '/stopwatchTimerRoutes',
        ),
      ];
}

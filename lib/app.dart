import 'package:fitness_training/core/resources/localization/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:forui/forui.dart';
import 'package:get_it/get_it.dart';

import 'core/bloc/bloc_application/application_bloc.dart';
import 'core/dio_settings/dio_settings.dart';
import 'core/router/router.dart';
import 'domain/usecases/appointment_usecase.dart';
import 'domain/usecases/user_usecase.dart';
import 'presentation/screens/calendar/bloc/calendar_bloc.dart';
import 'presentation/screens/contacts/bloc/contacts_bloc.dart';
import 'presentation/screens/machines_program/bloc/machines_program_screen_bloc.dart';
import 'presentation/screens/programs/create_program/bloc/create_program_bloc.dart';
import 'presentation/screens/programs/program_screen/bloc/program_screen_bloc.dart';
import 'presentation/widgets/shared_prefs_widget.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _appRouter = AppRouter();

  // ForUI theme with app's color palette
  static final _forUiTheme = FThemes.zinc.light.touch.copyWith(
    colors: FThemes.zinc.light.touch.colors.copyWith(
      primary: const Color(0xFF1E1E1E),
      primaryForeground: Colors.white,
      secondary: const Color(0xFFF5F5F5),
      secondaryForeground: const Color(0xFF1E1E1E),
    ),
  );
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => DioSettings(),
        ),
        RepositoryProvider(
          create: (context) => AppointmentUsecase(
            dio: RepositoryProvider.of<DioSettings>(context).dio,
          ),
        ),
        RepositoryProvider(
          create: (context) => UserUsecase(
            dio: RepositoryProvider.of<DioSettings>(context).dio,
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => GetIt.I<ApplicationBloc>(),
          ),
          BlocProvider(
              create: (context) => ContactsBloc()..add(GetContactsList())),
          BlocProvider(
              create: (context) => CalendarBloc()
                ..add(
                  FilterListAppointments(
                      selectedDay: DateTime(DateTime.now().year,
                          DateTime.now().month, DateTime.now().day)),
                )),
          BlocProvider(create: (context) => ProgramScreenBloc()),
          BlocProvider(create: (context) => MachinesProgramScreenBloc()),
          BlocProvider(create: (context) => CreateProgramBloc())
        ],
        child: TextFieldUnfocus(
            child: SharedPrefsWidget(
          child: ScreenUtilInit(
              designSize: const Size(360, 800),
              minTextAdapt: true,
              splitScreenMode: true,
              builder: (context, child) {
                return MaterialApp.router(
                  debugShowCheckedModeBanner: false,
                  localizationsDelegates: [
                    AppLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                    ...FLocalizations.localizationsDelegates,
                  ],
                  supportedLocales: AppLocalizations.supportedLocales,
                  title: 'Fitness Training',
                  theme: _forUiTheme.toApproximateMaterialTheme(),
                  routerDelegate: _appRouter.delegate(),
                  routeInformationParser: _appRouter.defaultRouteParser(),
                  builder: (context, child) {
                    final easyLoadingBuilder = EasyLoading.init();
                    return FTheme(
                      data: _forUiTheme,
                      child: FToaster(
                        child: FTooltipGroup(
                          child: easyLoadingBuilder(context, child),
                        ),
                      ),
                    );
                  },
                );
              }),
        )),
      ),
    );
  }
}

class TextFieldUnfocus extends StatelessWidget {
  const TextFieldUnfocus({required this.child, super.key});
  final Widget child;
  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          final FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus &&
              currentFocus.focusedChild != null) {
            currentFocus.focusedChild!.unfocus();
          }
        },
        child: child,
      );
}

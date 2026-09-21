// The stopwatch keeps running after its screen is left, and a bar under
// every screen leads back to it.

import 'package:auto_route/auto_route.dart';
import 'package:fitness_training/core/resources/localization/l10n/app_localizations.dart';
import 'package:fitness_training/core/router/router.dart';
import 'package:fitness_training/domain/entities/fitness/fitness.dart';
import 'package:fitness_training/domain/usecases/fitness/workout_session_usecase.dart';
import 'package:fitness_training/presentation/screens/stopwatch_timer/active_stopwatch.dart';
import 'package:fitness_training/presentation/widgets/active_stopwatch_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:get_it/get_it.dart';

const _home = PageRouteInfo<void>('TestHome');

class _TestRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(
          page: PageInfo('TestHome', builder: (_) => const Text('home')),
          path: '/',
          initial: true,
        ),
        AutoRoute(page: StopwatchTimerRoutes.page, path: '/stopwatch'),
      ];
}

class _FakeWorkoutSessionUsecase implements WorkoutSessionUsecase {
  final updates = <WorkoutSessionEntity>[];
  final creates = <WorkoutSessionEntity>[];

  @override
  Future<WorkoutSessionEntity> updateWorkoutSession(
    int sessionId,
    WorkoutSessionEntity session,
  ) async {
    updates.add(session);
    return session;
  }

  @override
  Future<WorkoutSessionEntity> createWorkoutSession(
    WorkoutSessionEntity session,
  ) async {
    creates.add(session);
    return session;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final _target = StopwatchTarget(
  workoutSession: WorkoutSessionEntity((b) => b
    ..id = 11
        ..programMachineId = 5
        ..traineeId = 2
        ..coachId = 1
    ..weight = 86
    ..weight2 = 106
    ..sessionStatus = SessionStatusEnumEntity.planned),
  machine: MachineEntity((b) => b
    ..id = 7
    ..name = 'H2'),
  traineeName: 'Ann Lee',
);

void main() {
  late DateTime now;
  late ActiveStopwatch stopwatch;
  late _TestRouter router;

  setUp(() async {
    await GetIt.I.reset();
    now = DateTime(2026, 9, 21, 10);
    stopwatch = ActiveStopwatch(now: () => now);
    GetIt.I.registerSingleton<ActiveStopwatch>(stopwatch);
    router = _TestRouter();
  });
  tearDown(() => GetIt.I.reset());

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(800, 1280);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp.router(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          ...FLocalizations.localizationsDelegates,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router.config(),
        builder: (context, child) => FTheme(
          data: FThemes.zinc.light.touch,
          child: ActiveStopwatchBar(router: router, child: child!),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openStopwatch(WidgetTester tester) async {
    stopwatch.open(_target);
    router.push(const StopwatchTimerRoutes());
    await tester.pumpAndSettle();
  }

  Finder bar() => find.byKey(const ValueKey('active-stopwatch-bar'));

  testWidgets('leaving a running stopwatch keeps it running, with a bar',
      (tester) async {
    await pumpApp(tester);
    await openStopwatch(tester);
    expect(bar(), findsNothing);

    await tester.tap(find.text('Start'));
    await tester.pump();
    now = now.add(const Duration(minutes: 1, seconds: 4));

    await router.maybePop();
    await tester.pumpAndSettle();

    expect(find.text('home'), findsOneWidget);
    expect(stopwatch.isRunning, isTrue);
    expect(bar(), findsOneWidget);

    now = now.add(const Duration(seconds: 1));
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      find.descendant(of: bar(), matching: find.text('01:05')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: bar(), matching: find.text('Ann Lee · H2')),
      findsOneWidget,
    );

    // The bar leads back to the same, still running stopwatch.
    await tester.tap(bar());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(router.topRoute.name, StopwatchTimerRoutes.name);
    expect(bar(), findsNothing);
    expect(find.text('Pause'), findsOneWidget);
    expect(find.text('01:05'), findsOneWidget);

    stopwatch.pause();
    await tester.pumpAndSettle();
  });

  testWidgets('leaving a stopwatch that was never started shows no bar',
      (tester) async {
    await pumpApp(tester);
    await openStopwatch(tester);

    await router.maybePop();
    await tester.pumpAndSettle();

    expect(bar(), findsNothing);
    expect(stopwatch.target, isNull);
  });

  testWidgets('a paused stopwatch still shows the bar', (tester) async {
    await pumpApp(tester);
    await openStopwatch(tester);
    await tester.tap(find.text('Start'));
    await tester.pump();
    now = now.add(const Duration(seconds: 20));
    await tester.tap(find.text('Pause'));
    await tester.pump();

    await router.maybePop();
    await tester.pumpAndSettle();

    expect(bar(), findsOneWidget);
    expect(find.descendant(of: bar(), matching: find.text('Paused')),
        findsOneWidget);
    expect(find.descendant(of: bar(), matching: find.text('00:20')),
        findsOneWidget);
  });

  testWidgets('save & end stores the time, plans the next set and clears',
      (tester) async {
    final sessions = _FakeWorkoutSessionUsecase();
    GetIt.I.registerSingleton<WorkoutSessionUsecase>(sessions);
    final completed = <StopwatchTarget>[];
    stopwatch.completed.listen(completed.add);

    await pumpApp(tester);
    await openStopwatch(tester);
    await tester.tap(find.text('Start'));
    await tester.pump();
    now = now.add(const Duration(minutes: 2, seconds: 30));
    await tester.tap(find.text('Pause'));
    await tester.pump();

    await tester.tap(find.text('Save & end'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yes'));
    await tester.pumpAndSettle();
    // Next-weight dialog: keep the suggested weights.
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(sessions.updates.single.sessionTime, 150);
    expect(sessions.updates.single.sessionStatus,
        SessionStatusEnumEntity.completed);
    expect(sessions.creates.single.sessionStatus,
        SessionStatusEnumEntity.planned);
    expect(
      (sessions.creates.single.weight, sessions.creates.single.weight2),
      (86, 106),
    );
    expect(completed.single.workoutSession.id, 11);
    expect(stopwatch.target, isNull);
    expect(router.topRoute.name, _home.routeName);
    expect(bar(), findsNothing);
  });
}

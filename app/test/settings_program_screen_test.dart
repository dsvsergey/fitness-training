// Regression tests for SettingsProgramScreen.

import 'package:built_collection/built_collection.dart';
import 'package:fitness_training/core/bloc/bloc_application/application_bloc.dart';
import 'package:fitness_training/core/resources/localization/l10n/app_localizations.dart';
import 'package:fitness_training/domain/entities/fitness/fitness.dart';
import 'package:fitness_training/domain/usecases/fitness/fitness.dart';
import 'package:fitness_training/domain/usecases/fitness/workout_session_usecase.dart';
import 'package:fitness_training/presentation/screens/settings_program/settings_program_screen.dart';
import 'package:fitness_training/presentation/screens/stopwatch_timer/active_stopwatch.dart';
import 'package:fitness_training/presentation/widgets/custom_timer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

class _FakeProgramMachineUsecase implements ProgramMachineUsecase {
  _FakeProgramMachineUsecase(this.programMachine);

  final ProgramMachineEntity? programMachine;
  int calls = 0;

  @override
  Future<ProgramMachineEntity?> getProgramMachineByProgramAndMachine(
    int programId,
    int machineId,
  ) async {
    calls++;
    return programMachine;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeWorkoutSessionUsecase implements WorkoutSessionUsecase {
  final updates = <(int, WorkoutSessionEntity)>[];

  @override
  Future<WorkoutSessionEntity> updateWorkoutSession(
    int sessionId,
    WorkoutSessionEntity session,
  ) async {
    updates.add((sessionId, session));
    return session;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final _machine = MachineEntity((b) => b
  ..id = 7
  ..name = 'Leg Press');

final _program = ProgramFitnessEntity((b) => b
  ..id = 3
  ..name = 'Program A');

WorkoutSessionEntity _session({
  DateTime? dateSession,
  SessionStatusEnumEntity status = SessionStatusEnumEntity.planned,
  int? weight = 40,
  int? weight2,
}) =>
    WorkoutSessionEntity((b) => b
      ..id = 11
      ..programMachineId = 5
      ..traineeId = 2
      ..coachId = 1
      ..weight = weight
      ..weight2 = weight2
      ..dateSession = dateSession
      ..sessionStatus = status);

ProgramMachineEntity _programMachine(List<WorkoutSessionEntity> workouts) =>
    ProgramMachineEntity((b) => b
      ..id = 5
      ..machineId = 7
      ..programId = 3
      ..seats = 1
      ..machine = _machine.toBuilder()
      ..workouts = ListBuilder<WorkoutSessionEntity>(workouts));

Future<void> _pumpScreen(WidgetTester tester) async {
  // The phone layout is chosen below 600dp wide; give it enough height that the
  // screen's own known overflow does not mask the assertions below.
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = const Size(400, 1600);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  // This screen has pre-existing RenderFlex overflows (see the `Fix overflows
  // in settings program screen` commit, still not fully resolved). They are
  // layout debt, unrelated to which buttons are enabled, and would otherwise
  // fail the test before a single assertion runs.
  final previousOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    if (details.exceptionAsString().contains('A RenderFlex overflowed')) return;
    previousOnError?.call(details);
  };
  addTearDown(() => FlutterError.onError = previousOnError);

  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        ...FLocalizations.localizationsDelegates,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => FTheme(
        data: FThemes.zinc.light.touch,
        child: child!,
      ),
      home: SettingsProgramScreen(program: _program, machine: _machine),
    ),
  );
  await tester.pump();
  await tester.pump();
}

CustomTimerWidget _cardTitled(WidgetTester tester, String title) {
  return tester
      .widgetList<CustomTimerWidget>(find.byType(CustomTimerWidget))
      .firstWhere((w) => w.title == title);
}

void main() {
  setUp(() => GetIt.I.reset());
  tearDown(() => GetIt.I.reset());

  void register(ProgramMachineEntity? programMachine) {
    GetIt.I.registerSingleton<ProgramMachineUsecase>(
      _FakeProgramMachineUsecase(programMachine),
    );
    // A real ApplicationBloc sitting in its initial state: authenticated flows
    // aside, `currentAppointment` is null here, exactly as it now always is
    // since the calendar was removed. No button may key off it.
    final applicationBloc = ApplicationBloc();
    addTearDown(applicationBloc.close);
    GetIt.I.registerSingleton<ApplicationBloc>(applicationBloc);
    GetIt.I.registerSingleton<ActiveStopwatch>(ActiveStopwatch());
    expect(applicationBloc.state.currentAppointment, isNull);
  }

  group('timer button', () {
    testWidgets('metronome button is gone', (tester) async {
      register(_programMachine([_session()]));
      await _pumpScreen(tester);

      expect(find.text('Metronome'), findsNothing);
    });

    testWidgets(
      'timer button is enabled for an unfinished session, no appointment needed',
      (tester) async {
        register(_programMachine([_session()]));
        await _pumpScreen(tester);

        expect(_cardTitled(tester, 'Timer').onPressed, isNotNull);
      },
    );

    testWidgets(
      'timer button is disabled when every session is already finished',
      (tester) async {
        register(
            _programMachine([_session(dateSession: DateTime(2026, 5, 1))]));
        await _pumpScreen(tester);

        expect(_cardTitled(tester, 'Timer').onPressed, isNull);
      },
    );
  });

  group('background stopwatch', () {
    testWidgets(
      'a stopwatch running for another set is offered, not replaced',
      (tester) async {
        register(_programMachine([_session()]));
        final stopwatch = GetIt.I<ActiveStopwatch>()
          ..open(StopwatchTarget(
            workoutSession: _session().rebuild((b) => b..id = 99),
            machine: MachineEntity((b) => b
              ..id = 8
              ..name = 'H2'),
            traineeName: 'Bob',
          ))
          ..start();
        addTearDown(stopwatch.clear);
        await _pumpScreen(tester);

        await tester.tap(find.text('Timer').first);
        await tester.pumpAndSettle();

        expect(find.text('Stopwatch is running'), findsOneWidget);
        expect(stopwatch.target!.workoutSession.id, 99);
      },
    );

    testWidgets('saving the stopwatch reloads the history', (tester) async {
      final usecase = _FakeProgramMachineUsecase(_programMachine([_session()]));
      register(null);
      GetIt.I.unregister<ProgramMachineUsecase>();
      GetIt.I.registerSingleton<ProgramMachineUsecase>(usecase);
      await _pumpScreen(tester);
      final loadsBefore = usecase.calls;

      final stopwatch = GetIt.I<ActiveStopwatch>()
        ..open(StopwatchTarget(
          workoutSession: _session(),
          machine: _machine,
          traineeName: '',
        ))
        ..start();
      stopwatch.complete();
      await tester.pump();
      await tester.pump();

      expect(usecase.calls, loadsBefore + 1);
    });
  });

  group('note', () {
    // Opening the keyboard changes MediaQuery and rebuilds the whole screen.
    // The note used to be reset from the saved value on every such rebuild,
    // wiping what the coach had typed and hiding the Save button.
    testWidgets('typed text survives a keyboard-driven rebuild',
        (tester) async {
      register(_programMachine([_session()]));
      await _pumpScreen(tester);

      await tester.enterText(find.byType(TextField), 'Slow eccentric');
      await tester.pump();
      expect(find.text('Save'), findsOneWidget);

      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetViewInsets);
      await tester.pump();

      expect(find.text('Slow eccentric'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });
  });

  group('phone settings values', () {
    testWidgets('each label shows its own field', (tester) async {
      register(ProgramMachineEntity((b) => b
        ..id = 5
        ..machineId = 7
        ..programId = 3
        ..handle = '11'
        ..pin = 12
        ..knees = '21'
        ..legs = '22'
        ..angal = '23'
        ..chest = '24'
        ..machine = _machine.toBuilder()
        ..workouts = ListBuilder<WorkoutSessionEntity>([_session()])));
      await _pumpScreen(tester);

      for (final v in ['21', '22', '23', '24']) {
        expect(find.text(v), findsOneWidget, reason: 'value $v');
      }
    });
  });

  group('weight row', () {
    // The row renders when `workouts.isNotEmpty`, but reads the weight with
    // `.where(planned).first`. Those are different predicates, so a machine
    // whose sessions are all completed satisfies the guard and then throws
    // `Bad state: No element` while building.
    testWidgets(
      'renders when no session is planned any more',
      (tester) async {
        register(_programMachine(
          [_session(status: SessionStatusEnumEntity.completed)],
        ));
        await _pumpScreen(tester);

        expect(tester.takeException(), isNull);
        expect(find.byType(CustomTimerWidget), findsWidgets);
      },
    );

    testWidgets(
      'shows the planned weight when one exists',
      (tester) async {
        register(_programMachine([_session(weight: 55)]));
        await _pumpScreen(tester);

        expect(tester.takeException(), isNull);
        expect(find.text('55'), findsOneWidget);
      },
    );
  });

  group('second weight', () {
    test('formats one or two weights', () {
      expect(formatWeights(280, null), '280');
      expect(formatWeights(280, 380), '280 / 380');
      expect(formatWeights(null, null), '');
    });

    testWidgets('weight row and history show both weights', (tester) async {
      register(_programMachine([_session(weight: 280, weight2: 380)]));
      await _pumpScreen(tester);

      expect(tester.takeException(), isNull);
      expect(find.text('280 / 380'), findsOneWidget);
      expect(find.text('280 / 380 lb'), findsOneWidget);
    });

    testWidgets('a single weight still renders as before', (tester) async {
      register(_programMachine([_session(weight: 280)]));
      await _pumpScreen(tester);

      expect(find.text('280'), findsOneWidget);
      expect(find.text('280 lb'), findsOneWidget);
    });
  });

  group('edit upcoming weight', () {
    testWidgets('"+" in history updates the planned session in place',
        (tester) async {
      register(_programMachine([_session(weight: 280)]));
      final sessions = _FakeWorkoutSessionUsecase();
      GetIt.I.registerSingleton<WorkoutSessionUsecase>(sessions);
      await _pumpScreen(tester);

      await tester.tap(find.byKey(const ValueKey('edit-upcoming-weight')));
      await tester.pumpAndSettle();

      final fields = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      );
      await tester.enterText(fields.first, '300');
      await tester.enterText(fields.last, '400');
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(sessions.updates, hasLength(1));
      final (id, updated) = sessions.updates.single;
      expect(id, 11);
      expect((updated.weight, updated.weight2), (300, 400));
    });

    testWidgets('no "+" for finished sessions', (tester) async {
      register(_programMachine(
        [_session(dateSession: DateTime(2026, 5, 1))],
      ));
      await _pumpScreen(tester);

      expect(find.byKey(const ValueKey('edit-upcoming-weight')), findsNothing);
    });
  });

  group('history period', () {
    final now = DateTime.now();
    final recent = _session(dateSession: now.subtract(const Duration(days: 5)))
        .rebuild((b) => b..id = 21);
    final old = _session(dateSession: now.subtract(const Duration(days: 60)))
        .rebuild((b) => b..id = 22);
    String dateOf(WorkoutSessionEntity s) =>
        DateFormat.yMd().format(s.dateSession!);

    testWidgets('shows the last 30 days by default, upcoming included',
        (tester) async {
      register(_programMachine([_session(), recent, old]));
      await _pumpScreen(tester);

      expect(find.text('30 days'), findsOneWidget);
      expect(find.text('Upcoming'), findsOneWidget);
      expect(find.text(dateOf(recent)), findsOneWidget);
      expect(find.text(dateOf(old)), findsNothing);
    });

    testWidgets('a longer period brings older sessions back', (tester) async {
      register(_programMachine([_session(), recent, old]));
      await _pumpScreen(tester);

      await tester.tap(find.byKey(const ValueKey('history-period')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('All time').last);
      await tester.pumpAndSettle();

      expect(find.text(dateOf(old)), findsOneWidget);
      expect(find.text(dateOf(recent)), findsOneWidget);
    });
  });
}

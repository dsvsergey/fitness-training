// Tests for the client comment on the trainee profile (UserCardWidget).

import 'package:fitness_training/core/resources/localization/l10n/app_localizations.dart';
import 'package:fitness_training/domain/entities/fitness/fitness.dart';
import 'package:fitness_training/presentation/widgets/user_cart_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';

Future<void> _pump(
  WidgetTester tester,
  TraineeEntity trainee, {
  ValueChanged<String>? onNotesEdited,
}) async {
  tester.view.physicalSize = const Size(1200, 1920);
  tester.view.devicePixelRatio = 1.5;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

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
      home: Scaffold(
        body: UserCardWidget(model: trainee, onNotesEdited: onNotesEdited),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  const hint = 'Add a comment about this client';

  testWidgets('empty comment shows a tappable placeholder when editable',
      (tester) async {
    String? saved;
    await _pump(
      tester,
      TraineeEntity((b) => b..id = 1),
      onNotesEdited: (v) => saved = v,
    );

    expect(find.text(hint), findsOneWidget);

    await tester.tap(find.text(hint));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText), 'Bad left knee');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(saved, 'Bad left knee');
  });

  testWidgets('existing comment is shown', (tester) async {
    await _pump(
      tester,
      TraineeEntity((b) => b
        ..id = 1
        ..notes = '  Bad left knee  '),
      onNotesEdited: (_) {},
    );

    expect(find.text('Bad left knee'), findsOneWidget);
    expect(find.text(hint), findsNothing);
  });

  testWidgets('read-only card hides an empty comment', (tester) async {
    await _pump(tester, TraineeEntity((b) => b..id = 1));

    expect(find.text(hint), findsNothing);
  });
}

// Smoke tests for CustomTimerWidget — the card used for the Timer and
// Metronome buttons.
//
// The widget encodes its enabled/disabled state purely through `onPressed`:
// a null callback must render muted and swallow taps, a non-null one must
// render in the primary colour and fire. SettingsProgramScreen relies on that
// contract, so it is pinned here.

import 'package:fitness_training/presentation/widgets/custom_timer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';

const _image = 'assets/svgs/timer.svg';

Future<void> _pump(WidgetTester tester, CustomTimerWidget widget) async {
  await tester.pumpWidget(
    FTheme(
      data: FThemes.zinc.light.touch,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Center(child: widget),
      ),
    ),
  );
}

void main() {
  testWidgets('renders its title', (tester) async {
    await _pump(
      tester,
      CustomTimerWidget(title: 'Timer', image: _image, onPressed: () {}),
    );

    expect(find.text('Timer'), findsOneWidget);
  });

  testWidgets('fires onPressed when enabled and tapped', (tester) async {
    var taps = 0;
    await _pump(
      tester,
      CustomTimerWidget(title: 'Timer', image: _image, onPressed: () => taps++),
    );

    await tester.tap(find.byType(CustomTimerWidget));
    await tester.pump();

    expect(taps, 1);
  });

  testWidgets('swallows taps when onPressed is null', (tester) async {
    await _pump(
      tester,
      const CustomTimerWidget(title: 'Timer', image: _image, onPressed: null),
    );

    // Must not throw: a null callback is the disabled state, not an error.
    await tester.tap(find.byType(CustomTimerWidget));
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('mutes its label when disabled', (tester) async {
    Color labelColour(WidgetTester tester) =>
        tester.widget<Text>(find.text('Timer')).style!.color!;

    await _pump(
      tester,
      CustomTimerWidget(title: 'Timer', image: _image, onPressed: () {}),
    );
    final enabled = labelColour(tester);

    await _pump(
      tester,
      const CustomTimerWidget(title: 'Timer', image: _image, onPressed: null),
    );
    final disabled = labelColour(tester);

    expect(disabled, isNot(enabled));
    expect(disabled, FThemes.zinc.light.touch.colors.mutedForeground);
    expect(enabled, FThemes.zinc.light.touch.colors.primary);
  });
}

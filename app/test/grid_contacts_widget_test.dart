import 'package:fitness_training/domain/entities/fitness/fitness.dart';
import 'package:fitness_training/presentation/widgets/grid_contacts_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';

void main() {
  testWidgets('grid card shows email and formatted phone without overflow',
      (tester) async {
    final trainee = TraineeEntity((b) => b
      ..id = 1
      ..firstName = 'Sara'
      ..lastName = 'Paone'
      ..email = 'spaone.with.a.very.long.address@rogers.com'
      ..mobilePhone = '4378816478'
      ..weight = 80
      ..height = 180);

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) =>
            FTheme(data: FThemes.zinc.dark.touch, child: child!),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              // Portrait tablet column width (3 columns) and grid extent.
              width: 150,
              height: 232,
              child: GridContactsWidget(model: trainee, onTap: () {}),
            ),
          ),
        ),
      ),
    );

    expect(find.text('spaone.with.a.very.long.address@rogers.com'),
        findsOneWidget);
    expect(find.text('(437) 881-6478'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

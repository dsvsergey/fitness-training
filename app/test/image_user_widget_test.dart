// Regression tests for ImageUserWidget.
//
// The bottom sheet's three options were previously declared as
// `onPressed: () {}` — drawn but inert, so a coach could never set an avatar.
// These tests fail against that implementation.

import 'package:fitness_training/presentation/widgets/image_user_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:image_picker/image_picker.dart';

Future<void> _pumpWidget(
  WidgetTester tester, {
  required ValueChanged<ImageSource> onSourceSelected,
  required VoidCallback onDelete,
  bool hasPhoto = false,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      builder: (context, child) => FTheme(
        data: FThemes.zinc.light.touch,
        child: child!,
      ),
      home: Scaffold(
        body: Center(
          child: ImageUserWidget(
            onSourceSelected: onSourceSelected,
            onDelete: onDelete,
            hasPhoto: hasPhoto,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _openSheet(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.camera_alt));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('gallery option reports ImageSource.gallery', (tester) async {
    final sources = <ImageSource>[];
    await _pumpWidget(
      tester,
      onSourceSelected: sources.add,
      onDelete: () {},
    );

    await _openSheet(tester);
    await tester.tap(find.text('Select from Gallery'));
    await tester.pumpAndSettle();

    expect(sources, [ImageSource.gallery]);
  });

  testWidgets('camera option reports ImageSource.camera', (tester) async {
    final sources = <ImageSource>[];
    await _pumpWidget(
      tester,
      onSourceSelected: sources.add,
      onDelete: () {},
    );

    await _openSheet(tester);
    await tester.tap(find.text('Open Camera'));
    await tester.pumpAndSettle();

    expect(sources, [ImageSource.camera]);
  });

  testWidgets('delete option invokes onDelete when a photo exists',
      (tester) async {
    var deleted = 0;
    await _pumpWidget(
      tester,
      onSourceSelected: (_) {},
      onDelete: () => deleted++,
      hasPhoto: true,
    );

    await _openSheet(tester);
    await tester.tap(find.text('Delete Photo'));
    await tester.pumpAndSettle();

    expect(deleted, 1);
  });

  testWidgets('delete option is hidden when there is no photo', (tester) async {
    await _pumpWidget(
      tester,
      onSourceSelected: (_) {},
      onDelete: () {},
    );

    await _openSheet(tester);

    expect(find.text('Delete Photo'), findsNothing);
    expect(find.text('Select from Gallery'), findsOneWidget);
  });

  testWidgets('choosing an option dismisses the sheet', (tester) async {
    await _pumpWidget(
      tester,
      onSourceSelected: (_) {},
      onDelete: () {},
    );

    await _openSheet(tester);
    await tester.tap(find.text('Select from Gallery'));
    await tester.pumpAndSettle();

    expect(find.text('Select from Gallery'), findsNothing);
  });
}

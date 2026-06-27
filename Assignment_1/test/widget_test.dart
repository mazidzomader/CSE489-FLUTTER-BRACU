import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cse489_assignment_01/main.dart';

void main() {
  testWidgets('VangtiChai keypad smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const VangtiChaiApp());

    // Verify that initial amount is 0.
    expect(find.text('0'), findsWidgets);

    // Tap '5' and '0' and trigger a frame.
    await tester.tap(find.widgetWithText(GestureDetector, '5'));
    await tester.pump();
    await tester.tap(find.widgetWithText(GestureDetector, '0'));
    await tester.pump();

    // Verify amount is 50 (top display + table denomination row).
    expect(find.text('50'), findsNWidgets(2));

    // Tap backspace icon button and trigger a frame.
    await tester.tap(find.byIcon(Icons.backspace_outlined));
    await tester.pump();

    // Verify amount is reduced to 5 (top display + table row + keypad button).
    expect(find.text('5'), findsNWidgets(3));
  });
}


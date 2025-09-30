import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:locker_app/src/features/lockscreen/lock_screen.dart';

void main() {
  testWidgets('LockScreen has a title and a button', (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(MaterialApp(
      home: LockScreen(onUnlocked: (_) {}),
    ));

    // Act
    final titleFinder = find.text('Services');
    final buttonFinder = find.text('Unlock');

    // Assert
    expect(titleFinder, findsOneWidget);
    expect(buttonFinder, findsOneWidget);
  });
}

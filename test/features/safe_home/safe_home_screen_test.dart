import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:locker_app/src/features/safe_home/safe_home_screen.dart';

import 'package:locker_app/src/core/services/safe_service.dart';

void main() {
  testWidgets('SafeHomeScreen has a title and a lock button', (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(MaterialApp(
      home: SafeHomeScreen(safeId: 1, onLock: () {}, safeService: SafeService()),
    ));

    // Act
    final titleFinder = find.text('Safe');
    final lockButtonFinder = find.byTooltip('Lock now');

    // Assert
    expect(titleFinder, findsOneWidget);
    expect(lockButtonFinder, findsOneWidget);
  });
}

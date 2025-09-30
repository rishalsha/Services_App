import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:locker_app/src/app.dart';

void main() {
  testWidgets('App starts with LockScreen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ServicesApp());

    // Verify that the LockScreen is shown.
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.text('Services'), findsOneWidget);
  });
}
// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:travel_itinerary_app/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    // Provide in-memory storage for SharedPreferences-dependent services
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App starts correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TravelItineraryApp());

    // Allow initial async work to complete without waiting for endless animations
    await tester.pump(const Duration(milliseconds: 100));

    // Verify that the app starts (basic smoke test)
    expect(find.byType(MaterialApp), findsOneWidget);

    // Let splash timers and animations finish to avoid pending timers
    await tester.pump(const Duration(seconds: 4));
  });

  testWidgets('Splash disposes cleanly after timers complete', (WidgetTester tester) async {
    await tester.pumpWidget(const TravelItineraryApp());

    // Advance time so the delayed navigation logic can complete
    await tester.pump(const Duration(seconds: 4));

    // Dispose the widget tree to ensure cleanup succeeds
    await tester.pumpWidget(Container());
    await tester.pump();

    expect(tester.binding.hasScheduledFrame, isFalse);
  });
}

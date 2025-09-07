import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:notably/main.dart';

void main() {
  testWidgets('Notably app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: NotablyApp()));

    // Wait for the app to settle
    await tester.pumpAndSettle();

    // Verify that the app loads without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('Notably app structure test', (WidgetTester tester) async {
    // Build our app with provider scope
    await tester.pumpWidget(const ProviderScope(child: NotablyApp()));

    // Wait for the app to settle
    await tester.pumpAndSettle();

    // Verify Material App is present
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
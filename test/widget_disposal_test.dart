import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notably/widgets/live_cursors.dart';
import 'package:notably/widgets/safe_widget_wrapper.dart';
import 'package:notably/models/workspace_member.dart';

void main() {
  group('Widget Disposal Tests', () {
    testWidgets('LiveCursorsOverlay disposes properly', (WidgetTester tester) async {
      final textController = TextEditingController(text: 'Test content');
      final users = [
        WorkspaceMember(
          id: '1',
          userId: 'user1',
          workspaceId: 'ws1',
          name: 'User 1',
          email: 'user1@test.com',
          role: MemberRole.member,
          joinedAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LiveCursorsOverlay(
              textController: textController,
              activeUsers: users,
            ),
          ),
        ),
      );

      // Verify widget is rendered
      expect(find.byType(LiveCursorsOverlay), findsOneWidget);

      // Dispose the widget and verify no errors
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      await tester.pump(const Duration(seconds: 1));

      textController.dispose();
    });

    testWidgets('SafeWidgetWrapper handles errors gracefully', (WidgetTester tester) async {
      bool errorHandled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: SafeWidgetWrapper(
            onError: () => errorHandled = true,
            child: const Text('Test widget'),
          ),
        ),
      );

      expect(find.text('Test widget'), findsOneWidget);
      expect(errorHandled, false);
    });

    testWidgets('Animation controllers disposal stress test', (WidgetTester tester) async {
      // Test rapid creation and disposal of animation controllers
      for (int i = 0; i < 3; i++) {
        final textController = TextEditingController(text: 'Test $i');
        final users = List.generate(3, (index) => WorkspaceMember(
          id: '$i-$index',
          userId: 'user$i-$index',
          workspaceId: 'ws1',
          name: 'User $i-$index',
          email: 'user$i-$index@test.com',
          role: MemberRole.member,
          joinedAt: DateTime.now(),
        ));

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: LiveCursorsOverlay(
                textController: textController,
                activeUsers: users,
              ),
            ),
          ),
        );

        await tester.pump(const Duration(milliseconds: 10));

        // Update with fewer users to trigger disposal
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: LiveCursorsOverlay(
                textController: textController,
                activeUsers: users.take(1).toList(),
              ),
            ),
          ),
        );

        await tester.pump(const Duration(milliseconds: 10));

        // Complete dispose
        await tester.pumpWidget(const MaterialApp(home: Scaffold()));
        await tester.pump(const Duration(milliseconds: 10));

        textController.dispose();
      }

      // Should not have any dependency errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('Multiple widget creation and disposal', (WidgetTester tester) async {
      for (int i = 0; i < 5; i++) {
        final textController = TextEditingController(text: 'Test $i');
        final users = [
          WorkspaceMember(
            id: '$i',
            userId: 'user$i',
            workspaceId: 'ws1',
            name: 'User $i',
            email: 'user$i@test.com',
            role: MemberRole.member,
            joinedAt: DateTime.now(),
          ),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: LiveCursorsOverlay(
                textController: textController,
                activeUsers: users,
              ),
            ),
          ),
        );

        await tester.pump(const Duration(milliseconds: 50));

        // Dispose
        await tester.pumpWidget(const MaterialApp(home: Scaffold()));
        await tester.pump(const Duration(milliseconds: 50));

        textController.dispose();
      }

      // Final check - should not have any errors
      expect(tester.takeException(), isNull);
    });
  });
}
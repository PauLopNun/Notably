import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Simple model tests that don't require Supabase
import 'package:notably/models/note.dart';
import 'package:notably/models/block.dart';

void main() {
  group('Model Tests', () {
    test('Note model creation', () {
      final note = Note(
        id: 'test-id',
        userId: 'user-123',
        title: 'Test Note',
        content: ['Hello', 'World'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(note.id, 'test-id');
      expect(note.title, 'Test Note');
      expect(note.content.length, 2);
    });

    test('BlockType enum functionality', () {
      expect(BlockType.paragraph.name, 'paragraph');
      expect(BlockType.heading1.displayName, 'Heading 1');
      expect(BlockType.bulletedList.isListBlock, true);
      expect(BlockType.paragraph.isListBlock, false);
      expect(BlockType.paragraph.isTextBlock, true);
    });

    test('PageBlock model creation', () {
      final block = PageBlock(
        id: 'block-1',
        type: BlockType.paragraph,
        content: 'Test content',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(block.id, 'block-1');
      expect(block.type, BlockType.paragraph);
      expect(block.content, 'Test content');
    });
  });

  group('Widget Tests', () {
    testWidgets('Basic widget test', (WidgetTester tester) async {
      // Test a simple widget that doesn't require Supabase
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: Text('Test')),
            body: Center(child: Text('Hello World')),
          ),
        ),
      );

      expect(find.text('Test'), findsOneWidget);
      expect(find.text('Hello World'), findsOneWidget);
    });
  });
}
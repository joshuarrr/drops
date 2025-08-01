import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/shader_demo/widgets/text_input_field.dart';

void main() {
  group('TextInputField Tests', () {
    testWidgets('TextInputField should maintain text state correctly', (
      WidgetTester tester,
    ) async {
      String currentValue = 'Initial Text';
      String? changedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextInputField(
              label: 'Test Label',
              value: currentValue,
              onChanged: (value) {
                changedValue = value;
              },
              textColor: Colors.black,
            ),
          ),
        ),
      );

      // Find the text field
      final textField = find.byType(TextFormField);
      expect(textField, findsOneWidget);

      // Verify initial text is displayed
      expect(find.text('Initial Text'), findsOneWidget);

      // Type new text
      await tester.enterText(textField, 'New Text');
      await tester.pump();

      // Verify the onChanged callback was called
      expect(changedValue, equals('New Text'));
    });

    testWidgets('TextInputField should handle external value updates', (
      WidgetTester tester,
    ) async {
      String currentValue = 'Initial Text';

      Widget buildWidget(String value) {
        return MaterialApp(
          home: Scaffold(
            body: TextInputField(
              key: const ValueKey('test_field'),
              label: 'Test Label',
              value: value,
              onChanged: (newValue) {
                currentValue = newValue;
              },
              textColor: Colors.black,
            ),
          ),
        );
      }

      // Build initial widget
      await tester.pumpWidget(buildWidget(currentValue));

      // Verify initial text
      expect(find.text('Initial Text'), findsOneWidget);

      // Update the value externally
      currentValue = 'Updated Text';
      await tester.pumpWidget(buildWidget(currentValue));
      await tester.pump();

      // Verify the text field shows the updated value
      expect(find.text('Updated Text'), findsOneWidget);
    });

    testWidgets('TextInputField should handle multiline text', (
      WidgetTester tester,
    ) async {
      String currentValue = 'Line 1\nLine 2';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextInputField(
              label: 'Multiline Test',
              value: currentValue,
              onChanged: (value) {},
              textColor: Colors.black,
              multiline: true,
              maxLines: 5,
            ),
          ),
        ),
      );

      // Find the text field
      final textField = find.byType(TextFormField);
      expect(textField, findsOneWidget);

      // Verify multiline text is displayed
      expect(find.text('Line 1\nLine 2'), findsOneWidget);
    });
  });
}

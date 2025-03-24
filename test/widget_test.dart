import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_coinbox/my_app.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Create test widget
    await tester.pumpWidget(
      MaterialApp(
        home: CounterScreen(),
      ),
    );

    // Initial state
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Act
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Assert
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}

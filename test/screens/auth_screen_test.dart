import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ai_coinbox/screens/auth/auth_screen.dart';

@GenerateMocks([FirebaseAuth])
void main() {
  testWidgets('AuthScreen displays sign-in form by default', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: AuthScreen()));

    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
  });

  testWidgets('Switching to sign-up form works', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: AuthScreen()));

    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();

    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('Sign In'), findsNothing);
  });

  testWidgets('Submitting sign-in form calls _submit', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: AuthScreen()));

    await tester.enterText(find.byKey(const Key('email')), 'test@example.com');
    await tester.enterText(find.byKey(const Key('password')), 'Password123!');
    await tester.tap(find.text('Sign In'));
    await tester.pump();

    // Add assertions for expected behavior (e.g., navigation or API calls)
  });
}

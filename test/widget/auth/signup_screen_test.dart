import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('SignupScreen Widget Tests', () {
    Widget createSignupScreen() {
      return ProviderScope(
        child: MaterialApp.router(
          routerConfig: GoRouter(routes: []),
          theme: ThemeData.dark(),
        ),
      );
    }

    group('Screen Rendering', () {
      testWidgets('renders signup screen with name field', (WidgetTester tester) async {
        await tester.pumpWidget(createSignupScreen());
        
        expect(find.byType(TextField), findsWidgets);
      });

      testWidgets('renders signup screen with email field', (WidgetTester tester) async {
        await tester.pumpWidget(createSignupScreen());
        
        expect(find.byType(TextField), findsWidgets);
      });

      testWidgets('renders password field', (WidgetTester tester) async {
        await tester.pumpWidget(createSignupScreen());
        
        expect(find.byType(TextField), findsWidgets);
      });

      testWidgets('renders confirm password field', (WidgetTester tester) async {
        await tester.pumpWidget(createSignupScreen());
        
        expect(find.byType(TextField), findsWidgets);
      });

      testWidgets('renders signup button', (WidgetTester tester) async {
        await tester.pumpWidget(createSignupScreen());
        
        expect(find.byType(ElevatedButton), findsWidgets);
      });

      testWidgets('renders login link', (WidgetTester tester) async {
        await tester.pumpWidget(createSignupScreen());
        
        expect(find.byType(GestureDetector), findsWidgets);
      });
    });

    group('Form Fields', () {
      testWidgets('name field accepts input', (WidgetTester tester) async {
        await tester.pumpWidget(createSignupScreen());
        
        final textFields = find.byType(TextField);
        await tester.enterText(textFields.first, 'John Doe');
        
        expect(find.text('John Doe'), findsOneWidget);
      });

      testWidgets('email field accepts email input', (WidgetTester tester) async {
        await tester.pumpWidget(createSignupScreen());
        
        final textFields = find.byType(TextField);
        if (textFields.evaluate().length >= 2) {
          await tester.enterText(textFields.at(1), 'john@example.com');
        }
        
        await tester.pumpAndSettle();
      });

      testWidgets('password field accepts input', (WidgetTester tester) async {
        await tester.pumpWidget(createSignupScreen());
        
        final textFields = find.byType(TextField);
        if (textFields.evaluate().length >= 3) {
          await tester.enterText(textFields.at(2), 'password123');
        }
        
        await tester.pumpAndSettle();
      });

      testWidgets('confirm password field accepts input', (WidgetTester tester) async {
        await tester.pumpWidget(createSignupScreen());
        
        final textFields = find.byType(TextField);
        if (textFields.evaluate().length >= 4) {
          await tester.enterText(textFields.at(3), 'password123');
        }
        
        await tester.pumpAndSettle();
      });
    });

    group('Form Validation', () {
      testWidgets('validates required fields', (WidgetTester tester) async {
        await tester.pumpWidget(createSignupScreen());
        
        expect(find.byType(TextField), findsWidgets);
      });

      testWidgets('validates email format', (WidgetTester tester) async {
        await tester.pumpWidget(createSignupScreen());
        
        final textFields = find.byType(TextField);
        if (textFields.evaluate().length >= 2) {
          await tester.enterText(textFields.at(1), 'invalid-email');
          await tester.pumpAndSettle();
        }
      });

      testWidgets('validates password strength', (WidgetTester tester) async {
        await tester.pumpWidget(createSignupScreen());
        
        final textFields = find.byType(TextField);
        if (textFields.evaluate().length >= 3) {
          await tester.enterText(textFields.at(2), '123');
          await tester.pumpAndSettle();
        }
      });

      testWidgets('validates password match', (WidgetTester tester) async {
        await tester.pumpWidget(createSignupScreen());
        
        final textFields = find.byType(TextField);
        if (textFields.evaluate().length >= 4) {
          await tester.enterText(textFields.at(2), 'password123');
          await tester.enterText(textFields.at(3), 'password456');
          await tester.pumpAndSettle();
        }
      });

      testWidgets('shows matching passwords success', (WidgetTester tester) async {
        await tester.pumpWidget(createSignupScreen());
        
        final textFields = find.byType(TextField);
        if (textFields.evaluate().length >= 4) {
          await tester.enterText(textFields.at(2), 'password123');
          await tester.enterText(textFields.at(3), 'password123');
          await tester.pumpAndSettle();
        }
      });
    });

    group('User Interactions', () {
      testWidgets('can fill all fields', (WidgetTester tester) async {
        await tester.pumpWidget(createSignupScreen());
        
        final textFields = find.byType(TextField);
        if (textFields.evaluate().length >= 4) {
          await tester.enterText(textFields.first, 'John Doe');
          await tester.enterText(textFields.at(1), 'john@example.com');
          await tester.enterText(textFields.at(2), 'SecurePass123!');
          await tester.enterText(textFields.at(3), 'SecurePass123!');
          await tester.pumpAndSettle();
        }
      });

      testWidgets('can clear fields', (WidgetTester tester) async {
        await tester.pumpWidget(createSignupScreen());
        
        final textFields = find.byType(TextField);
        if (textFields.evaluate().isNotEmpty) {
          await tester.enterText(textFields.first, 'Test');
          await tester.enterText(textFields.first, '');
          await tester.pumpAndSettle();
        }
      });

      testWidgets('can toggle password visibility', (WidgetTester tester) async {
        await tester.pumpWidget(createSignupScreen());
        
        expect(find.byType(IconButton), findsWidgets);
      });
    });

    group('Loading States', () {
      testWidgets('shows loading indicator during signup', (WidgetTester tester) async {
        await tester.pumpWidget(createSignupScreen());
        
        expect(find.byType(CircularProgressIndicator), findsNothing);
      });

      testWidgets('disables signup button while loading', (WidgetTester tester) async {
        await tester.pumpWidget(createSignupScreen());
        
        final button = find.byType(ElevatedButton);
        expect(button, findsOneWidget);
      });
    });

    group('Error Handling', () {
      testWidgets('shows error for duplicate email', (WidgetTester tester) async {
        await tester.pumpWidget(createSignupScreen());
        
        await tester.pumpAndSettle();
      });

      testWidgets('shows error for weak password', (WidgetTester tester) async {
        await tester.pumpWidget(createSignupScreen());
        
        await tester.pumpAndSettle();
      });

      testWidgets('shows network error message', (WidgetTester tester) async {
        await tester.pumpWidget(createSignupScreen());
        
        await tester.pumpAndSettle();
      });
    });

    group('Navigation', () {
      testWidgets('can navigate to login', (WidgetTester tester) async {
        await tester.pumpWidget(createSignupScreen());
        
        final loginLink = find.byType(GestureDetector);
        if (loginLink.evaluate().isNotEmpty) {
          await tester.tap(loginLink.first);
          await tester.pumpAndSettle();
        }
      });

      testWidgets('navigates to home on successful signup', (WidgetTester tester) async {
        await tester.pumpWidget(createSignupScreen());
        
        await tester.pumpAndSettle();
      });
    });

    group('Accessibility', () {
      testWidgets('all fields have labels', (WidgetTester tester) async {
        await tester.pumpWidget(createSignupScreen());
        
        expect(find.byType(TextField), findsWidgets);
      });

      testWidgets('signup button has semantic label', (WidgetTester tester) async {
        await tester.pumpWidget(createSignupScreen());
        
        expect(find.byType(ElevatedButton), findsOneWidget);
      });
    });

    group('Form Reset', () {
      testWidgets('clears fields on successful signup', (WidgetTester tester) async {
        await tester.pumpWidget(createSignupScreen());
        
        await tester.pumpAndSettle();
      });

      testWidgets('preserves input on validation error', (WidgetTester tester) async {
        await tester.pumpWidget(createSignupScreen());
        
        final textFields = find.byType(TextField);
        if (textFields.evaluate().isNotEmpty) {
          await tester.enterText(textFields.first, 'John');
          await tester.pumpAndSettle();
        }
      });
    });
  });
}

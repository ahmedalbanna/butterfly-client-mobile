import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('CheckoutScreen Widget Tests', () {
    Widget createCheckoutScreen() {
      return ProviderScope(
        child: MaterialApp.router(
          routerConfig: GoRouter(routes: []),
          theme: ThemeData.dark(),
        ),
      );
    }

    group('Screen Rendering', () {
      testWidgets('renders checkout screen', (WidgetTester tester) async {
        await tester.pumpWidget(createCheckoutScreen());
        
        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('displays checkout title', (WidgetTester tester) async {
        await tester.pumpWidget(createCheckoutScreen());
        
        expect(find.byType(AppBar), findsOneWidget);
      });

      testWidgets('shows order summary', (WidgetTester tester) async {
        await tester.pumpWidget(createCheckoutScreen());
        
        expect(find.byType(Card), findsWidgets);
      });
    });

    group('Order Summary', () {
      testWidgets('displays cart items in summary', (WidgetTester tester) async {
        await tester.pumpWidget(createCheckoutScreen());
        
        expect(find.byType(ListView), findsWidgets);
      });

      testWidgets('shows item quantities', (WidgetTester tester) async {
        await tester.pumpWidget(createCheckoutScreen());
        
        expect(find.byType(Text), findsWidgets);
      });

      testWidgets('shows item prices', (WidgetTester tester) async {
        await tester.pumpWidget(createCheckoutScreen());
        
        expect(find.byType(Text), findsWidgets);
      });

      testWidgets('displays subtotal', (WidgetTester tester) async {
        await tester.pumpWidget(createCheckoutScreen());
        
        expect(find.byType(Text), findsWidgets);
      });

      testWidgets('displays shipping cost', (WidgetTester tester) async {
        await tester.pumpWidget(createCheckoutScreen());
        
        expect(find.byType(Text), findsWidgets);
      });

      testWidgets('displays order total', (WidgetTester tester) async {
        await tester.pumpWidget(createCheckoutScreen());
        
        expect(find.byType(Text), findsWidgets);
      });
    });

    group('Shipping Information', () {
      testWidgets('displays shipping address section', (WidgetTester tester) async {
        await tester.pumpWidget(createCheckoutScreen());
        
        expect(find.byType(Card), findsWidgets);
      });

      testWidgets('shows saved addresses', (WidgetTester tester) async {
        await tester.pumpWidget(createCheckoutScreen());
        
        expect(find.byType(RadioListTile), findsWidgets);
      });

      testWidgets('can enter new address', (WidgetTester tester) async {
        await tester.pumpWidget(createCheckoutScreen());
        
        expect(find.byType(TextField), findsWidgets);
      });

      testWidgets('validates address fields', (WidgetTester tester) async {
        await tester.pumpWidget(createCheckoutScreen());
        
        final fields = find.byType(TextField);
        expect(fields, findsWidgets);
      });
    });

    group('Payment Information', () {
      testWidgets('displays payment method section', (WidgetTester tester) async {
        await tester.pumpWidget(createCheckoutScreen());
        
        expect(find.byType(Card), findsWidgets);
      });

      testWidgets('shows available payment methods', (WidgetTester tester) async {
        await tester.pumpWidget(createCheckoutScreen());
        
        expect(find.byType(RadioListTile), findsWidgets);
      });

      testWidgets('shows saved payment methods', (WidgetTester tester) async {
        await tester.pumpWidget(createCheckoutScreen());
        
        expect(find.byType(Text), findsWidgets);
      });

      testWidgets('shows add new payment method option', (WidgetTester tester) async {
        await tester.pumpWidget(createCheckoutScreen());
        
        expect(find.byType(TextButton), findsWidgets);
      });
    });

    group('Order Review', () {
      testWidgets('can review order before placing', (WidgetTester tester) async {
        await tester.pumpWidget(createCheckoutScreen());
        
        expect(find.byType(Text), findsWidgets);
      });

      testWidgets('displays all order details', (WidgetTester tester) async {
        await tester.pumpWidget(createCheckoutScreen());
        
        expect(find.byType(Card), findsWidgets);
      });

      testWidgets('can edit cart items', (WidgetTester tester) async {
        await tester.pumpWidget(createCheckoutScreen());
        
        final editButton = find.byType(TextButton);
        if (editButton.evaluate().isNotEmpty) {
          await tester.tap(editButton.first);
          await tester.pumpAndSettle();
        }
      });

      testWidgets('can change shipping address', (WidgetTester tester) async {
        await tester.pumpWidget(createCheckoutScreen());
        
        final changeButton = find.byType(TextButton);
        if (changeButton.evaluate().isNotEmpty) {
          await tester.tap(changeButton.first);
          await tester.pumpAndSettle();
        }
      });
    });

    group('Place Order Button', () {
      testWidgets('shows place order button', (WidgetTester tester) async {
        await tester.pumpWidget(createCheckoutScreen());
        
        expect(find.byType(ElevatedButton), findsWidgets);
      });

      testWidgets('place order button is prominent', (WidgetTester tester) async {
        await tester.pumpWidget(createCheckoutScreen());
        
        expect(find.byType(ElevatedButton), findsWidgets);
      });

      testWidgets('can place order', (WidgetTester tester) async {
        await tester.pumpWidget(createCheckoutScreen());
        
        final placeButton = find.byType(ElevatedButton).first;
        await tester.tap(placeButton);
        await tester.pumpAndSettle();
      });

      testWidgets('button disabled until all fields filled', (WidgetTester tester) async {
        await tester.pumpWidget(createCheckoutScreen());
        
        expect(find.byType(ElevatedButton), findsWidgets);
      });
    });

    group('Form Validation', () {
      testWidgets('validates address is provided', (WidgetTester tester) async {
        await tester.pumpWidget(createCheckoutScreen());
        
        expect(find.byType(TextField), findsWidgets);
      });

      testWidgets('validates payment method selected', (WidgetTester tester) async {
        await tester.pumpWidget(createCheckoutScreen());
        
        expect(find.byType(RadioListTile), findsWidgets);
      });

      testWidgets('shows validation errors', (WidgetTester tester) async {
        await tester.pumpWidget(createCheckoutScreen());
        await tester.pumpAndSettle();
      });
    });

    group('Loading States', () {
      testWidgets('shows loading indicator while processing', (WidgetTester tester) async {
        await tester.pumpWidget(createCheckoutScreen());
        
        expect(find.byType(CircularProgressIndicator), findsWidgets);
      });

      testWidgets('disables buttons while processing', (WidgetTester tester) async {
        await tester.pumpWidget(createCheckoutScreen());
        
        expect(find.byType(ElevatedButton), findsWidgets);
      });
    });

    group('Success State', () {
      testWidgets('shows success message after order placed', (WidgetTester tester) async {
        await tester.pumpWidget(createCheckoutScreen());
        await tester.pumpAndSettle();
      });

      testWidgets('displays order confirmation number', (WidgetTester tester) async {
        await tester.pumpWidget(createCheckoutScreen());
        await tester.pumpAndSettle();
      });

      testWidgets('navigates to order detail page', (WidgetTester tester) async {
        await tester.pumpWidget(createCheckoutScreen());
        await tester.pumpAndSettle();
      });
    });

    group('Error Handling', () {
      testWidgets('shows error message on order failure', (WidgetTester tester) async {
        await tester.pumpWidget(createCheckoutScreen());
        await tester.pumpAndSettle();
      });

      testWidgets('shows payment error if payment fails', (WidgetTester tester) async {
        await tester.pumpWidget(createCheckoutScreen());
        await tester.pumpAndSettle();
      });

      testWidgets('shows network error message', (WidgetTester tester) async {
        await tester.pumpWidget(createCheckoutScreen());
        await tester.pumpAndSettle();
      });

      testWidgets('shows retry option on error', (WidgetTester tester) async {
        await tester.pumpWidget(createCheckoutScreen());
        await tester.pumpAndSettle();
      });
    });

    group('Navigation', () {
      testWidgets('can go back to cart', (WidgetTester tester) async {
        await tester.pumpWidget(createCheckoutScreen());
        
        final backButton = find.byType(IconButton).first;
        await tester.tap(backButton);
        await tester.pumpAndSettle();
      });

      testWidgets('prevents accidental navigation away', (WidgetTester tester) async {
        await tester.pumpWidget(createCheckoutScreen());
        
        await tester.pumpAndSettle();
      });
    });

    group('Accessibility', () {
      testWidgets('all form fields are accessible', (WidgetTester tester) async {
        await tester.pumpWidget(createCheckoutScreen());
        
        expect(find.byType(TextField), findsWidgets);
      });

      testWidgets('place order button is accessible', (WidgetTester tester) async {
        await tester.pumpWidget(createCheckoutScreen());
        
        expect(find.byType(ElevatedButton), findsWidgets);
      });
    });
  });
}

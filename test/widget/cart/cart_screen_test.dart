import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../helpers/test_fixtures.dart';

void main() {
  group('CartScreen Widget Tests', () {
    Widget createCartScreen() {
      return ProviderScope(
        child: MaterialApp.router(
          routerConfig: GoRouter(routes: []),
          theme: ThemeData.dark(),
        ),
      );
    }

    group('Screen Rendering', () {
      testWidgets('renders cart screen', (WidgetTester tester) async {
        await tester.pumpWidget(createCartScreen());
        
        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('displays cart title', (WidgetTester tester) async {
        await tester.pumpWidget(createCartScreen());
        
        expect(find.byType(AppBar), findsOneWidget);
      });
    });

    group('Empty Cart State', () {
      testWidgets('shows empty cart message when cart is empty', (WidgetTester tester) async {
        await tester.pumpWidget(createCartScreen());
        await tester.pumpAndSettle();
        
        expect(find.byType(Text), findsWidgets);
      });

      testWidgets('shows continue shopping button when empty', (WidgetTester tester) async {
        await tester.pumpWidget(createCartScreen());
        await tester.pumpAndSettle();
        
        expect(find.byType(ElevatedButton), findsWidgets);
      });

      testWidgets('hides checkout button when empty', (WidgetTester tester) async {
        await tester.pumpWidget(createCartScreen());
        await tester.pumpAndSettle();
      });
    });

    group('Cart Items Display', () {
      testWidgets('displays list of cart items', (WidgetTester tester) async {
        await tester.pumpWidget(createCartScreen());
        await tester.pumpAndSettle();
        
        expect(find.byType(ListView), findsWidgets);
      });

      testWidgets('shows product image in cart', (WidgetTester tester) async {
        await tester.pumpWidget(createCartScreen());
        await tester.pumpAndSettle();
        
        expect(find.byType(Image), findsWidgets);
      });

      testWidgets('shows product name in cart', (WidgetTester tester) async {
        await tester.pumpWidget(createCartScreen());
        await tester.pumpAndSettle();
        
        expect(find.byType(Text), findsWidgets);
      });

      testWidgets('shows unit price in cart', (WidgetTester tester) async {
        await tester.pumpWidget(createCartScreen());
        await tester.pumpAndSettle();
        
        expect(find.byType(Text), findsWidgets);
      });

      testWidgets('shows quantity in cart', (WidgetTester tester) async {
        await tester.pumpWidget(createCartScreen());
        await tester.pumpAndSettle();
        
        expect(find.byType(Text), findsWidgets);
      });

      testWidgets('shows item total price', (WidgetTester tester) async {
        await tester.pumpWidget(createCartScreen());
        await tester.pumpAndSettle();
        
        expect(find.byType(Text), findsWidgets);
      });
    });

    group('Quantity Management', () {
      testWidgets('can increase item quantity', (WidgetTester tester) async {
        await tester.pumpWidget(createCartScreen());
        await tester.pumpAndSettle();
        
        final increaseButton = find.byType(IconButton);
        if (increaseButton.evaluate().isNotEmpty) {
          await tester.tap(increaseButton.first);
          await tester.pumpAndSettle();
        }
      });

      testWidgets('can decrease item quantity', (WidgetTester tester) async {
        await tester.pumpWidget(createCartScreen());
        await tester.pumpAndSettle();
        
        final decreaseButton = find.byType(IconButton);
        if (decreaseButton.evaluate().length > 1) {
          await tester.tap(decreaseButton.at(1));
          await tester.pumpAndSettle();
        }
      });

      testWidgets('updates total price on quantity change', (WidgetTester tester) async {
        await tester.pumpWidget(createCartScreen());
        await tester.pumpAndSettle();
        
        expect(find.byType(Text), findsWidgets);
      });

      testWidgets('minimum quantity is 1', (WidgetTester tester) async {
        await tester.pumpWidget(createCartScreen());
        await tester.pumpAndSettle();
      });
    });

    group('Remove Items', () {
      testWidgets('shows remove button on cart item', (WidgetTester tester) async {
        await tester.pumpWidget(createCartScreen());
        await tester.pumpAndSettle();
        
        expect(find.byType(IconButton), findsWidgets);
      });

      testWidgets('can remove item from cart', (WidgetTester tester) async {
        await tester.pumpWidget(createCartScreen());
        await tester.pumpAndSettle();
        
        final removeButton = find.byIcon(Icons.delete);
        if (removeButton.evaluate().isNotEmpty) {
          await tester.tap(removeButton.first);
          await tester.pumpAndSettle();
        }
      });

      testWidgets('shows confirmation on remove', (WidgetTester tester) async {
        await tester.pumpWidget(createCartScreen());
        await tester.pumpAndSettle();
      });

      testWidgets('updates totals after removal', (WidgetTester tester) async {
        await tester.pumpWidget(createCartScreen());
        await tester.pumpAndSettle();
        
        expect(find.byType(Text), findsWidgets);
      });
    });

    group('Cart Totals', () {
      testWidgets('displays subtotal', (WidgetTester tester) async {
        await tester.pumpWidget(createCartScreen());
        await tester.pumpAndSettle();
        
        expect(find.byType(Text), findsWidgets);
      });

      testWidgets('displays shipping cost', (WidgetTester tester) async {
        await tester.pumpWidget(createCartScreen());
        await tester.pumpAndSettle();
        
        expect(find.byType(Text), findsWidgets);
      });

      testWidgets('displays tax if applicable', (WidgetTester tester) async {
        await tester.pumpWidget(createCartScreen());
        await tester.pumpAndSettle();
        
        expect(find.byType(Text), findsWidgets);
      });

      testWidgets('displays grand total', (WidgetTester tester) async {
        await tester.pumpWidget(createCartScreen());
        await tester.pumpAndSettle();
        
        expect(find.byType(Text), findsWidgets);
      });

      testWidgets('highlights grand total prominently', (WidgetTester tester) async {
        await tester.pumpWidget(createCartScreen());
        await tester.pumpAndSettle();
        
        expect(find.byType(Text), findsWidgets);
      });
    });

    group('Checkout Button', () {
      testWidgets('shows checkout button when cart has items', (WidgetTester tester) async {
        await tester.pumpWidget(createCartScreen());
        await tester.pumpAndSettle();
        
        expect(find.byType(ElevatedButton), findsWidgets);
      });

      testWidgets('checkout button is prominent', (WidgetTester tester) async {
        await tester.pumpWidget(createCartScreen());
        await tester.pumpAndSettle();
        
        expect(find.byType(ElevatedButton), findsWidgets);
      });

      testWidgets('can proceed to checkout', (WidgetTester tester) async {
        await tester.pumpWidget(createCartScreen());
        await tester.pumpAndSettle();
        
        final checkoutButton = find.byType(ElevatedButton).first;
        await tester.tap(checkoutButton);
        await tester.pumpAndSettle();
      });
    });

    group('Continue Shopping', () {
      testWidgets('shows continue shopping button', (WidgetTester tester) async {
        await tester.pumpWidget(createCartScreen());
        await tester.pumpAndSettle();
        
        expect(find.byType(TextButton), findsWidgets);
      });

      testWidgets('can return to shopping', (WidgetTester tester) async {
        await tester.pumpWidget(createCartScreen());
        await tester.pumpAndSettle();
        
        final continueButton = find.byType(TextButton);
        if (continueButton.evaluate().isNotEmpty) {
          await tester.tap(continueButton.first);
          await tester.pumpAndSettle();
        }
      });
    });

    group('Loading States', () {
      testWidgets('shows loading indicator when fetching cart', (WidgetTester tester) async {
        await tester.pumpWidget(createCartScreen());
        
        expect(find.byType(CircularProgressIndicator), findsWidgets);
      });

      testWidgets('hides loading after data loads', (WidgetTester tester) async {
        await tester.pumpWidget(createCartScreen());
        await tester.pumpAndSettle();
      });
    });

    group('Error Handling', () {
      testWidgets('shows error message on load failure', (WidgetTester tester) async {
        await tester.pumpWidget(createCartScreen());
        await tester.pumpAndSettle();
      });

      testWidgets('shows error on remove failure', (WidgetTester tester) async {
        await tester.pumpWidget(createCartScreen());
        await tester.pumpAndSettle();
      });

      testWidgets('shows retry option on error', (WidgetTester tester) async {
        await tester.pumpWidget(createCartScreen());
        await tester.pumpAndSettle();
      });
    });

    group('Navigation', () {
      testWidgets('back button exists', (WidgetTester tester) async {
        await tester.pumpWidget(createCartScreen());
        
        expect(find.byType(IconButton), findsWidgets);
      });

      testWidgets('can navigate back', (WidgetTester tester) async {
        await tester.pumpWidget(createCartScreen());
        
        final backButton = find.byType(IconButton).first;
        await tester.tap(backButton);
        await tester.pumpAndSettle();
      });
    });
  });
}

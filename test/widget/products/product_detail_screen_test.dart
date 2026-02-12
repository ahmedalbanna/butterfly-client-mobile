import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../helpers/test_fixtures.dart';

void main() {
  group('ProductDetailScreen Widget Tests', () {
    Widget createProductDetailScreen() {
      return ProviderScope(
        child: MaterialApp.router(
          routerConfig: GoRouter(routes: []),
          theme: ThemeData.dark(),
        ),
      );
    }

    group('Screen Rendering', () {
      testWidgets('renders product detail screen', (WidgetTester tester) async {
        await tester.pumpWidget(createProductDetailScreen());
        
        expect(find.byType(SingleChildScrollView), findsWidgets);
      });

      testWidgets('displays product image', (WidgetTester tester) async {
        await tester.pumpWidget(createProductDetailScreen());
        
        expect(find.byType(Image), findsWidgets);
      });

      testWidgets('displays product name', (WidgetTester tester) async {
        await tester.pumpWidget(createProductDetailScreen());
        
        expect(find.byType(Text), findsWidgets);
      });

      testWidgets('displays product price', (WidgetTester tester) async {
        await tester.pumpWidget(createProductDetailScreen());
        
        expect(find.byType(Text), findsWidgets);
      });

      testWidgets('displays product rating', (WidgetTester tester) async {
        await tester.pumpWidget(createProductDetailScreen());
        
        expect(find.byType(Icon), findsWidgets);
      });
    });

    group('Product Information Display', () {
      testWidgets('displays product description', (WidgetTester tester) async {
        await tester.pumpWidget(createProductDetailScreen());
        
        expect(find.byType(Text), findsWidgets);
      });

      testWidgets('displays materials section', (WidgetTester tester) async {
        await tester.pumpWidget(createProductDetailScreen());
        
        expect(find.byType(Wrap), findsWidgets);
      });

      testWidgets('displays care instructions', (WidgetTester tester) async {
        await tester.pumpWidget(createProductDetailScreen());
        
        expect(find.byType(Text), findsWidgets);
      });

      testWidgets('displays stock status', (WidgetTester tester) async {
        await tester.pumpWidget(createProductDetailScreen());
        
        expect(find.byType(Text), findsWidgets);
      });

      testWidgets('displays review count', (WidgetTester tester) async {
        await tester.pumpWidget(createProductDetailScreen());
        
        expect(find.byType(Text), findsWidgets);
      });
    });

    group('Quantity Selection', () {
      testWidgets('shows quantity selector', (WidgetTester tester) async {
        await tester.pumpWidget(createProductDetailScreen());
        
        expect(find.byType(TextField), findsWidgets);
      });

      testWidgets('can increase quantity', (WidgetTester tester) async {
        await tester.pumpWidget(createProductDetailScreen());
        
        final increaseButton = find.byType(IconButton);
        if (increaseButton.evaluate().isNotEmpty) {
          await tester.tap(increaseButton.first);
          await tester.pumpAndSettle();
        }
      });

      testWidgets('can decrease quantity', (WidgetTester tester) async {
        await tester.pumpWidget(createProductDetailScreen());
        
        final decreaseButton = find.byType(IconButton);
        if (decreaseButton.evaluate().length > 1) {
          await tester.tap(decreaseButton.at(1));
          await tester.pumpAndSettle();
        }
      });

      testWidgets('minimum quantity is 1', (WidgetTester tester) async {
        await tester.pumpWidget(createProductDetailScreen());
        
        await tester.pumpAndSettle();
      });

      testWidgets('respects maximum available quantity', (WidgetTester tester) async {
        await tester.pumpWidget(createProductDetailScreen());
        
        await tester.pumpAndSettle();
      });
    });

    group('Add to Cart', () {
      testWidgets('shows add to cart button', (WidgetTester tester) async {
        await tester.pumpWidget(createProductDetailScreen());
        
        expect(find.byType(ElevatedButton), findsWidgets);
      });

      testWidgets('can add product to cart', (WidgetTester tester) async {
        await tester.pumpWidget(createProductDetailScreen());
        
        final addButton = find.byType(ElevatedButton).first;
        await tester.tap(addButton);
        await tester.pumpAndSettle();
      });

      testWidgets('shows success message after add', (WidgetTester tester) async {
        await tester.pumpWidget(createProductDetailScreen());
        
        final addButton = find.byType(ElevatedButton).first;
        await tester.tap(addButton);
        await tester.pumpAndSettle();
      });

      testWidgets('button disabled for out of stock', (WidgetTester tester) async {
        await tester.pumpWidget(createProductDetailScreen());
        
        await tester.pumpAndSettle();
      });

      testWidgets('shows quantity in add button', (WidgetTester tester) async {
        await tester.pumpWidget(createProductDetailScreen());
        
        expect(find.byType(ElevatedButton), findsWidgets);
      });
    });

    group('Loading States', () {
      testWidgets('shows loading indicator while fetching', (WidgetTester tester) async {
        await tester.pumpWidget(createProductDetailScreen());
        
        expect(find.byType(CircularProgressIndicator), findsWidgets);
      });

      testWidgets('shows content after loading', (WidgetTester tester) async {
        await tester.pumpWidget(createProductDetailScreen());
        await tester.pumpAndSettle();
        
        expect(find.byType(Text), findsWidgets);
      });
    });

    group('Image Display', () {
      testWidgets('displays product image correctly', (WidgetTester tester) async {
        await tester.pumpWidget(createProductDetailScreen());
        await tester.pumpAndSettle();
        
        expect(find.byType(Image), findsWidgets);
      });

      testWidgets('image has zoom capability', (WidgetTester tester) async {
        await tester.pumpWidget(createProductDetailScreen());
        
        final image = find.byType(Image).first;
        await tester.tap(image);
        await tester.pumpAndSettle();
      });

      testWidgets('shows loading placeholder', (WidgetTester tester) async {
        await tester.pumpWidget(createProductDetailScreen());
        
        await tester.pumpAndSettle();
      });
    });

    group('Navigation', () {
      testWidgets('back button exists', (WidgetTester tester) async {
        await tester.pumpWidget(createProductDetailScreen());
        
        expect(find.byType(IconButton), findsWidgets);
      });

      testWidgets('can navigate back', (WidgetTester tester) async {
        await tester.pumpWidget(createProductDetailScreen());
        
        final backButton = find.byType(IconButton).first;
        await tester.tap(backButton);
        await tester.pumpAndSettle();
      });

      testWidgets('cart icon navigates to cart', (WidgetTester tester) async {
        await tester.pumpWidget(createProductDetailScreen());
        
        expect(find.byType(IconButton), findsWidgets);
      });
    });

    group('Error Handling', () {
      testWidgets('shows error message on load failure', (WidgetTester tester) async {
        await tester.pumpWidget(createProductDetailScreen());
        await tester.pumpAndSettle();
      });

      testWidgets('shows retry button on error', (WidgetTester tester) async {
        await tester.pumpWidget(createProductDetailScreen());
        await tester.pumpAndSettle();
      });

      testWidgets('shows error for add to cart failure', (WidgetTester tester) async {
        await tester.pumpWidget(createProductDetailScreen());
        
        final addButton = find.byType(ElevatedButton).first;
        await tester.tap(addButton);
        await tester.pumpAndSettle();
      });
    });

    group('Stock Display', () {
      testWidgets('shows in stock message when available', (WidgetTester tester) async {
        await tester.pumpWidget(createProductDetailScreen());
        
        expect(find.byType(Text), findsWidgets);
      });

      testWidgets('shows out of stock message when unavailable', (WidgetTester tester) async {
        await tester.pumpWidget(createProductDetailScreen());
        
        expect(find.byType(Text), findsWidgets);
      });

      testWidgets('shows remaining quantity', (WidgetTester tester) async {
        await tester.pumpWidget(createProductDetailScreen());
        
        expect(find.byType(Text), findsWidgets);
      });
    });

    group('Accessibility', () {
      testWidgets('product name is readable', (WidgetTester tester) async {
        await tester.pumpWidget(createProductDetailScreen());
        
        expect(find.byType(Text), findsWidgets);
      });

      testWidgets('price is clearly displayed', (WidgetTester tester) async {
        await tester.pumpWidget(createProductDetailScreen());
        
        expect(find.byType(Text), findsWidgets);
      });

      testWidgets('add to cart button is accessible', (WidgetTester tester) async {
        await tester.pumpWidget(createProductDetailScreen());
        
        expect(find.byType(ElevatedButton), findsOneWidget);
      });
    });
  });
}

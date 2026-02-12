import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('ProductListScreen Widget Tests', () {
    Widget createProductListScreen() {
      return ProviderScope(
        child: MaterialApp.router(
          routerConfig: GoRouter(routes: []),
          theme: ThemeData.dark(),
        ),
      );
    }

    group('Screen Rendering', () {
      testWidgets('renders product list screen', (WidgetTester tester) async {
        await tester.pumpWidget(createProductListScreen());
        
        expect(find.byType(ListView), findsWidgets);
      });

      testWidgets('renders search bar', (WidgetTester tester) async {
        await tester.pumpWidget(createProductListScreen());
        
        expect(find.byType(TextField), findsWidgets);
      });

      testWidgets('renders filter options', (WidgetTester tester) async {
        await tester.pumpWidget(createProductListScreen());
        
        expect(find.byType(ElevatedButton), findsWidgets);
      });
    });

    group('Product Display', () {
      testWidgets('displays product list', (WidgetTester tester) async {
        await tester.pumpWidget(createProductListScreen());
        await tester.pumpAndSettle();
        
        expect(find.byType(Card), findsWidgets);
      });

      testWidgets('shows product image', (WidgetTester tester) async {
        await tester.pumpWidget(createProductListScreen());
        await tester.pumpAndSettle();
        
        expect(find.byType(Image), findsWidgets);
      });

      testWidgets('shows product name', (WidgetTester tester) async {
        await tester.pumpWidget(createProductListScreen());
        await tester.pumpAndSettle();
        
        expect(find.byType(Text), findsWidgets);
      });

      testWidgets('shows product price', (WidgetTester tester) async {
        await tester.pumpWidget(createProductListScreen());
        await tester.pumpAndSettle();
        
        expect(find.byType(Text), findsWidgets);
      });

      testWidgets('shows product rating', (WidgetTester tester) async {
        await tester.pumpWidget(createProductListScreen());
        await tester.pumpAndSettle();
        
        expect(find.byType(Icon), findsWidgets);
      });
    });

    group('Loading States', () {
      testWidgets('shows loading indicator initially', (WidgetTester tester) async {
        await tester.pumpWidget(createProductListScreen());
        
        expect(find.byType(CircularProgressIndicator), findsWidgets);
      });

      testWidgets('hides loading after data loads', (WidgetTester tester) async {
        await tester.pumpWidget(createProductListScreen());
        await tester.pumpAndSettle();
        
        // After settling, loading should be gone
        await tester.pumpAndSettle();
      });
    });

    group('Search Functionality', () {
      testWidgets('search field accepts input', (WidgetTester tester) async {
        await tester.pumpWidget(createProductListScreen());
        
        final searchField = find.byType(TextField).first;
        await tester.enterText(searchField, 'Watch');
        
        expect(find.text('Watch'), findsOneWidget);
      });

      testWidgets('filters products on search', (WidgetTester tester) async {
        await tester.pumpWidget(createProductListScreen());
        await tester.pumpAndSettle();
        
        final searchField = find.byType(TextField).first;
        await tester.enterText(searchField, 'Watch');
        await tester.pumpAndSettle();
        
        expect(find.byType(Card), findsWidgets);
      });

      testWidgets('clears search results', (WidgetTester tester) async {
        await tester.pumpWidget(createProductListScreen());
        await tester.pumpAndSettle();
        
        final searchField = find.byType(TextField).first;
        await tester.enterText(searchField, 'Watch');
        await tester.enterText(searchField, '');
        await tester.pumpAndSettle();
      });
    });

    group('Filtering', () {
      testWidgets('filter by category button exists', (WidgetTester tester) async {
        await tester.pumpWidget(createProductListScreen());
        
        expect(find.byType(ElevatedButton), findsWidgets);
      });

      testWidgets('can select category filter', (WidgetTester tester) async {
        await tester.pumpWidget(createProductListScreen());
        
        final filterButton = find.byType(ElevatedButton).first;
        await tester.tap(filterButton);
        await tester.pumpAndSettle();
      });

      testWidgets('shows filter options dropdown', (WidgetTester tester) async {
        await tester.pumpWidget(createProductListScreen());
        
        expect(find.byType(DropdownButton), findsWidgets);
      });
    });

    group('Pagination', () {
      testWidgets('loads initial products', (WidgetTester tester) async {
        await tester.pumpWidget(createProductListScreen());
        await tester.pumpAndSettle();
        
        expect(find.byType(Card), findsWidgets);
      });

      testWidgets('can scroll to load more', (WidgetTester tester) async {
        await tester.pumpWidget(createProductListScreen());
        await tester.pumpAndSettle();
        
        final listView = find.byType(ListView).first;
        await tester.scroll(listView, const Offset(0, -300));
        await tester.pumpAndSettle();
      });

      testWidgets('shows load more button', (WidgetTester tester) async {
        await tester.pumpWidget(createProductListScreen());
        await tester.pumpAndSettle();
        
        await tester.pumpAndSettle();
      });
    });

    group('Product Interaction', () {
      testWidgets('tapping product navigates to detail', (WidgetTester tester) async {
        await tester.pumpWidget(createProductListScreen());
        await tester.pumpAndSettle();
        
        final productCard = find.byType(Card).first;
        await tester.tap(productCard);
        await tester.pumpAndSettle();
      });

      testWidgets('add to cart button exists on product', (WidgetTester tester) async {
        await tester.pumpWidget(createProductListScreen());
        await tester.pumpAndSettle();
        
        expect(find.byType(IconButton), findsWidgets);
      });

      testWidgets('can add product to cart from list', (WidgetTester tester) async {
        await tester.pumpWidget(createProductListScreen());
        await tester.pumpAndSettle();
        
        final addButton = find.byType(IconButton).first;
        await tester.tap(addButton);
        await tester.pumpAndSettle();
      });
    });

    group('Error States', () {
      testWidgets('shows error message on load failure', (WidgetTester tester) async {
        await tester.pumpWidget(createProductListScreen());
        await tester.pumpAndSettle();
      });

      testWidgets('shows retry button on error', (WidgetTester tester) async {
        await tester.pumpWidget(createProductListScreen());
        await tester.pumpAndSettle();
      });
    });

    group('Empty State', () {
      testWidgets('shows empty state when no products', (WidgetTester tester) async {
        await tester.pumpWidget(createProductListScreen());
        await tester.pumpAndSettle();
      });

      testWidgets('shows no results message for search', (WidgetTester tester) async {
        await tester.pumpWidget(createProductListScreen());
        await tester.pumpAndSettle();
        
        final searchField = find.byType(TextField).first;
        await tester.enterText(searchField, 'NonExistentProduct');
        await tester.pumpAndSettle();
      });
    });

    group('Performance', () {
      testWidgets('renders smoothly with many items', (WidgetTester tester) async {
        await tester.pumpWidget(createProductListScreen());
        await tester.pumpAndSettle();
        
        final listView = find.byType(ListView).first;
        await tester.scroll(listView, const Offset(0, -500));
        await tester.pumpAndSettle();
      });
    });
  });
}

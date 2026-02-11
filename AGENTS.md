# LuxeFinds Admin Application - Developer Guide

Welcome! This document provides essential information for developers working on the **LuxeFinds Admin** project—a Flutter-based admin application for managing products, orders, categories, and more for the LuxeFinds e-commerce platform.

## 📋 Quick Facts

- **Project Name:** LuxeFinds Admin Application
- **Type:** Admin dashboard for e-commerce management
- **Language:** Dart
- **Framework:** Flutter (latest)
- **State Management:** Riverpod
- **Navigation:** GoRouter
- **HTTP Client:** Dio
- **Location:** This directory

## 🎯 Project Purpose

LuxeFinds Admin is a **Flutter-based administrative interface** for the LuxeFinds luxury e-commerce platform. It enables admins to:
- Manage product catalog (create, edit, delete products)
- Manage product categories
- View and track customer orders
- Access order details and manage fulfillment
- View analytics and business metrics on the dashboard

## 🛠️ Tech Stack

### Core Framework & Language
- **Language:** Dart (>=3.0.0 <4.0.0)
- **Framework:** Flutter (latest)
- **Build Tools:** Flutter SDK with Riverpod code generation

### State Management
- **flutter_riverpod:** ^2.4.0 (reactive state management)
- **riverpod_annotation:** ^2.3.0 (code generation support)
- **riverpod_generator:** ^2.3.0 (dev dependency for code generation)

### Networking & Storage
- **dio:** ^5.3.1 (HTTP client with interceptors)
- **flutter_secure_storage:** ^9.0.0 (secure token storage)

### Navigation
- **go_router:** ^13.0.0 (declarative routing)

### UI & Forms
- **flutter_form_builder:** ^9.1.0 (forms)
- **form_builder_validators:** ^10.0.0 (form validation)
- **cached_network_image:** ^3.3.0 (image caching)
- **shimmer:** ^3.0.0 (loading placeholders)
- **fl_chart:** ^0.64.0 (charts and data visualization)
- **intl:** ^0.19.0 (internationalization)

### Code Generation & Serialization
- **freezed_annotation:** ^2.4.1 (immutable model generation)
- **freezed:** ^2.4.1 (dev dependency)
- **json_serializable:** ^6.7.1 (JSON serialization)
- **json_annotation:** ^4.8.1 (JSON annotations)
- **build_runner:** ^2.4.6 (code generation)

### Utilities
- **logger:** ^2.0.0 (logging)

## 📂 Project Structure

```
lib/
├── main.dart                      # App entry point
├── config/
│   ├── app_config.dart           # Configuration constants (API URL, timeouts, cache settings)
│   ├── router.dart               # GoRouter setup with route definitions
│   └── theme.dart                # Theme configuration (colors, typography, styles)
├── screens/
│   ├── auth/
│   │   └── login_screen.dart     # Login screen
│   ├── dashboard/
│   │   └── dashboard_screen.dart # Main dashboard with analytics
│   ├── products/
│   │   ├── products_screen.dart  # Product list and management
│   │   └── product_form_screen.dart # Add/edit product form
│   ├── orders/
│   │   ├── orders_screen.dart    # Order list view
│   │   └── order_detail_screen.dart # Order detail page
│   └── categories/
│       └── categories_screen.dart # Category management
└── services/
    ├── auth_service.dart         # Authentication logic and state
    ├── http_client.dart          # HTTP client wrapper with interceptors
    ├── product_service.dart      # Product API operations
    └── order_service.dart        # Order API operations
```

## 🔑 Key Files & Modules

### Configuration (`lib/config/`)

#### `app_config.dart`
- Centralized configuration constants
- API base URL (defaults to `http://localhost:9002/api`)
- Request timeouts: 30 seconds for connect and receive
- Pagination settings: default 20 items per page, max 100
- Cache expiration: 1 hour
- Storage keys for tokens and user data

#### `router.dart`
- GoRouter setup with Riverpod integration
- Route definitions for all screens
- Authentication guard: redirects to login if user is null
- Admin verification: checks `isAdmin` flag before allowing access
- Initial location logic: loads auth state first

**Routes:**
- `/login` - Login screen
- `/dashboard` - Main dashboard
- `/products` - Product list
- `/products/new` - Create new product
- `/products/:id/edit` - Edit product
- `/orders` - Orders list
- `/orders/:id` - Order detail
- `/categories` - Categories management

#### `theme.dart`
- **Colors:**
  - Primary: Golden Yellow (`#FFD700`) - luxury aesthetic
  - Background: Deep Black (`#000000`)
  - Surface: Dark gray (`#1A1A1A`) for cards/containers
  - Text: White (`#FFFFFF`)
  - Secondary text: Light gray (`#B0B0B0`)
  - Error: Red (`#EF5350`)
  - Success: Green (`#66BB6A`)
  - Warning: Orange (`#FFA726`)
- **Typography:** Alegreya font family (serif, high-fashion aesthetic)
- **Component themes:** AppBar, buttons, input fields, cards with consistent dark theme
- Uses Material 3 design system

### Services (`lib/services/`)

#### `auth_service.dart`
- Authentication state management via Riverpod
- User login/logout operations
- Token management
- Auth state provider for global access
- User data persistence

#### `http_client.dart`
- Dio HTTP client wrapper
- Automatic token injection in request headers
- Request/response/error interceptors
- Token management (save, clear, retrieve)
- Secure storage integration
- Logging of all requests and responses

**Methods:**
- `get<T>()`, `post<T>()`, `put<T>()`, `delete<T>()` - HTTP operations
- `getAccessToken()`, `getRefreshToken()` - Token retrieval
- `saveTokens()` - Save both access and refresh tokens
- `clearTokens()` - Clear stored tokens

#### `product_service.dart`
- Product CRUD operations
- Fetches product list from API
- Creates, updates, deletes products
- May include image upload support

#### `order_service.dart`
- Order retrieval and management
- Fetches order list
- Retrieves order details
- May handle order status updates

### App Entry Point (`lib/main.dart`)
- Initializes Flutter
- Wraps app with `ProviderScope` (Riverpod)
- Defines `LuxeFindsAdminApp` as `ConsumerWidget`
- Watches `goRouterProvider` for dynamic routing based on auth state
- Sets up theme and disables debug banner

## 🔐 Security & Authorization

### Admin Access Control
- All routes (except login) require authenticated user
- Admin pages require `isAdmin: true` flag in user record
- GoRouter redirect logic in `router.dart` enforces this
- Users without admin access are redirected to login

### Authentication Flow
1. User navigates to `/login`
2. `AuthService` handles login credentials
3. Backend returns access and refresh tokens
4. Tokens stored securely in `FlutterSecureStorage`
5. `HttpClient` interceptor adds token to all requests
6. GoRouter redirects to `/dashboard` on successful login

### Token Management
- **Access Token Storage:** `FlutterSecureStorage` with key `admin_auth_token`
- **Refresh Token Storage:** `FlutterSecureStorage` with key `admin_refresh_token`
- **Token Injection:** Automatic via `HttpClient` interceptor
- **Token Lifecycle:** Handled by `AuthService` and `HttpClient`

## 🎨 UI/UX Conventions

### Typography & Aesthetics
- **Primary Font:** Alegreya (serif, luxury fashion aesthetic)
- **Theme:** Dark mode with golden accents
- **Color Contrast:** White text on deep black background for maximum readability
- **Interactive Elements:** Golden yellow buttons and highlights

### Component Patterns
- Use Flutter Material 3 components
- Consistent button styling (golden background, black text)
- Consistent input field styling (dark background, light borders)
- Cards with elevation for depth
- Loading states with shimmer effect
- Error states with red accent color
- Success states with green accent color

### Form Validation
- `flutter_form_builder` for complex forms
- `form_builder_validators` for validation rules
- Real-time validation feedback
- Descriptive error messages for users

## 🚀 Development Workflow

### Setup
```bash
# Install dependencies
flutter pub get

# Generate code (Riverpod, Freezed, JSON serialization)
dart run build_runner build

# Run the app
flutter run
```

### Development Commands
- `flutter run` - Run app in debug mode
- `flutter run -d <device>` - Run on specific device
- `dart run build_runner build` - Generate code
- `dart run build_runner watch` - Watch mode for continuous generation
- `flutter analyze` - Run linter and analyzer
- `flutter test` - Run unit and widget tests

### Code Generation
After modifying:
- Riverpod providers
- Freezed model classes
- JSON serializable models

Run: `dart run build_runner build --delete-conflicting-outputs`

### Build Configuration

#### `analysis_options.yaml`
- Includes Flutter lint rules via `package:flutter_lints/flutter.yaml`
- Standard Dart analyzer configuration
- Customizable lint rules (see file for examples)

## 📋 API Integration

### API Configuration
- Base URL from environment: `API_URL` (defaults to `http://localhost:9002/api`)
- All requests include bearer token authentication
- Request/response logging via Logger
- Automatic error handling in interceptors

### HTTP Interceptors
1. **Request:** Adds `Authorization: Bearer {token}` header
2. **Response:** Logs response status and path
3. **Error:** Logs error details, handles 401 auth failures

### Making API Calls
1. Inject `httpClientProvider` (from `HttpClient`)
2. Use methods: `get()`, `post()`, `put()`, `delete()`
3. Provide full path relative to base URL
4. Type responses for safety: `response.data as ModelType`

Example:
```dart
final httpClient = ref.watch(httpClientProvider);
final response = await httpClient.get('/products');
```

## 🔄 State Management with Riverpod

### Key Providers
- `authStateProvider` - Current user and auth state
- `goRouterProvider` - Router instance with auth-based routing
- `httpClientProvider` - HTTP client instance

### Using Providers in Widgets
```dart
// In ConsumerWidget
final authState = ref.watch(authStateProvider);
final user = authState.user;
final isLoading = authState.isLoading;

// Listen for changes
ref.listen(authStateProvider, (previous, next) {
  // Handle state changes
});

// Trigger async operations
await ref.read(authStateProvider.notifier).login(email, password);
```

### Riverpod Code Generation
- Annotate providers with `@riverpod`
- Use `riverpod_generator` package
- Generated code goes to `.g.dart` files
- Run `dart run build_runner build` to generate

## 📱 Screen Architecture

### Screen Naming Convention
- Use `<noun>_screen.dart` for main screens
- Use `<noun>_form_screen.dart` for data entry screens
- Use `<noun>_detail_screen.dart` for detail/view-only screens

### Screen Template
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExampleScreen extends ConsumerWidget {
  const ExampleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch providers
    final state = ref.watch(exampleProvider);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Example')),
      body: Center(
        child: state.when(
          data: (data) => Text(data),
          loading: () => const CircularProgressIndicator(),
          error: (error, stack) => Text('Error: $error'),
        ),
      ),
    );
  }
}
```

### Navigation
- Use `GoRouter` for all navigation
- Access via: `context.go('/path')` or `context.goNamed('routeName')`
- Parameters: `context.goNamed('product_edit', pathParameters: {'id': productId})`

## 📦 Building & Deployment

### Debug Build
```bash
flutter build apk --debug  # Android debug APK
flutter build ios          # iOS debug build
```

### Release Build
```bash
flutter build apk --release    # Android release APK
flutter build appbundle       # Android App Bundle (Play Store)
flutter build ios --release   # iOS release build
flutter build web             # Web build
```

## 🔗 Related Projects

This admin app connects to the **LuxeFinds** backend:
- Backend repository: Butterfly (Next.js 15, located in parent directory)
- Shared API base URL: `http://localhost:9002/api`
- API documentation: See backend project docs

## 📝 Code Conventions

### Naming
- **Files:** `snake_case` (e.g., `product_service.dart`)
- **Classes:** `PascalCase` (e.g., `ProductService`)
- **Variables/Functions:** `camelCase` (e.g., `fetchProducts()`)
- **Constants:** `camelCase` (e.g., `defaultPageSize`)
- **Private members:** Prefix with `_` (e.g., `_secureStorage`)

### Dart/Flutter Style
- Use `const` for constant values and widgets
- Prefer `final` over `var`
- Use trailing commas in multi-line constructs
- Keep lines under 100 characters when possible
- Use meaningful variable names (avoid single letters except in loops)

### Widget Guidelines
- Extract large widgets into separate files
- Use `ConsumerWidget` for widgets that need provider access
- Use `ConsumerStatefulWidget` for stateful widgets with providers
- Always provide `Key` parameter (even if `null`)
- Use `const` constructor when possible

### Async Operations
```dart
// Wrap in try-catch
try {
  final result = await httpClient.get('/api/path');
  // Handle result
} catch (e) {
  // Handle error
  print('Error: $e');
}
```

### Error Handling
- Always catch and log errors
- Use logger for debug output: `Logger().d('message')`
- Show user-friendly error messages in UI
- Include context in error logs (what operation failed)

## 🧪 Testing

### Running Tests
```bash
flutter test                    # Run all tests
flutter test test/widget_test.dart
flutter test --coverage         # Generate coverage report
```

### Test File Location
- Unit tests: `test/unit/`
- Widget tests: `test/widget/`
- Integration tests: `test/integration/`

### Test Template
```dart
void main() {
  group('Feature Name', () {
    test('should do something', () {
      // Arrange
      // Act
      // Assert
    });
  });
}
```

## 🐛 Common Issues & Solutions

### HTTP/Network Issues
- **401 Unauthorized:** Token expired or invalid, try logging in again
- **Connection refused:** Ensure backend is running on `localhost:9002`
- **CORS errors:** Check backend CORS configuration

### Build Issues
- **Code generation not running:** Run `dart run build_runner build --delete-conflicting-outputs`
- **Dependency conflicts:** Run `flutter pub upgrade`
- **Device not found:** Run `flutter devices` to list available devices

### State Management Issues
- **Provider not updating:** Ensure you're using `ref.watch()` not `ref.read()` for updates
- **Infinite loops:** Check for provider dependencies that create circular references
- **Stale data:** Clear cache by restarting the app or using `ref.refresh()`

### Authentication Issues
- **Login fails:** Check API base URL in `AppConfig`
- **Token not persisting:** Verify `FlutterSecureStorage` permissions
- **Redirects to login:** Check user's `isAdmin` flag in database

## 📞 Getting Help

1. **Check existing screens** - Look for similar implementations
2. **Review service classes** - Understand auth and HTTP client patterns
3. **Check analysis_options.yaml** - For lint rule questions
4. **Flutter documentation** - https://flutter.dev/docs
5. **Riverpod documentation** - https://riverpod.dev
6. **Backend documentation** - See parent directory `/docs`

## 🎓 Best Practices Observed in Codebase

1. **ConsumerWidget Pattern** - UI components watch providers for reactive updates
2. **Service Layer Abstraction** - API calls isolated in service classes
3. **GoRouter Integration** - Declarative routing with auth guards
4. **Secure Storage** - Tokens stored in secure storage, never in shared preferences
5. **Dio Interceptors** - Automatic token injection and logging
6. **Config Externalization** - All constants in `AppConfig` class
7. **Theme Consistency** - Centralized theme in `AppTheme` class
8. **Environment Configuration** - API URL from environment variable
9. **Error Logging** - Logger utility for debugging
10. **Code Generation** - Riverpod, Freezed, and JSON serialization for less boilerplate

## 📊 Architecture Overview

```
User Interface (Screens)
    ↓
State Management (Riverpod Providers)
    ↓
Services (Auth, HTTP, Product, Order)
    ↓
HTTP Client (Dio with interceptors)
    ↓
Backend API (http://localhost:9002/api)
    ↓
LuxeFinds Database
```

## 🔄 Development Environment

### Requirements
- Flutter SDK (latest stable)
- Dart SDK (>=3.0.0)
- Android SDK (for Android development)
- Xcode (for iOS development)
- Backend server running on `localhost:9002`

### Environment Variables
Create `.env` file or pass via command line:
```bash
flutter run --dart-define=API_URL=http://your-api-url/api
```

### Local Backend Setup
Backend runs on `http://localhost:9002/api` by default.
See parent directory documentation for backend setup instructions.

---

**Last Updated:** February 11, 2026
**Project Version:** 0.1.0

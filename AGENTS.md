# LuxeFinds Mobile Client - Developer Guide

## 🎯 Project Overview

**LuxeFinds Mobile Client** is a premium Flutter mobile application for an elite digital boutique specializing in luxury accessories. It provides a cinematic shopping experience with seamless product browsing, cart management, and secure checkout functionality.

- **Project Name:** LuxeFinds Mobile Client
- **Type:** Cross-platform mobile e-commerce application
- **Language:** Dart 3.0+
- **Framework:** Flutter 3.x
- **State Management:** Flutter Riverpod 2.4.0
- **Version:** 0.1.0

## 📋 Quick Reference

| Aspect | Details |
|--------|---------|
| **Entry Point** | `lib/main.dart` |
| **Navigation** | Go Router with deep linking support |
| **HTTP Client** | Dio with JWT authentication |
| **Data Models** | Freezed (immutable, with JSON serialization) |
| **Secure Storage** | flutter_secure_storage for tokens |
| **API Base URL** | `http://localhost:9002/api` (configurable) |
| **Form Validation** | flutter_form_builder + form_builder_validators |
| **Backend Framework** | Next.js 15 (separate butterfly/ directory) |

## 📂 Project Structure

```
lib/
├── main.dart                          # App entry point
├── config/
│   ├── app_config.dart               # Configuration constants
│   ├── router.dart                   # Go Router setup with auth guards
│   └── theme.dart                    # App theme, colors, typography
├── models/
│   ├── user.dart                     # User & AuthResponse (Freezed)
│   ├── product.dart                  # Product, Category, PaginationInfo
│   ├── cart.dart                     # Cart models
│   ├── order.dart                    # Order models
│   └── *.freezed.dart, *.g.dart      # Generated code (DO NOT EDIT)
├── services/
│   ├── http_client.dart              # Dio HTTP client with JWT handling
│   ├── auth_service.dart             # Authentication logic & Riverpod providers
│   ├── product_service.dart          # Product fetching & caching
│   ├── cart_service.dart             # Cart operations
│   └── order_service.dart            # Order management
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── signup_screen.dart
│   ├── home/
│   │   └── home_screen.dart
│   ├── products/
│   │   ├── product_list_screen.dart
│   │   └── product_detail_screen.dart
│   ├── cart/
│   │   └── cart_screen.dart
│   ├── checkout/
│   │   └── checkout_screen.dart
│   ├── orders/
│   │   ├── orders_screen.dart
│   │   └── order_detail_screen.dart
│   └── profile/
│       └── profile_screen.dart
├── assets/
│   ├── images/                       # Product images, illustrations
│   ├── icons/                        # App icons
│   └── fonts/
│       └── Alegreya-*.ttf            # Primary serif font
└── test/
    └── widget_test.dart
```

## 🎨 Design System

### Colors
- **Primary:** Golden Yellow (`#FFD700`) - luxury accent
- **Background:** Deep Black (`#000000`) - premium aesthetic
- **Surface:** Dark Gray (`#1A1A1A`) - card backgrounds
- **Text:** White (`#FFFFFF`) - primary text
- **Text Secondary:** Gray (`#B0B0B0`) - secondary text
- **Error:** Red (`#EF5350`)
- **Success:** Green (`#66BB6A`)

### Typography
- **Primary Font:** Alegreya (Serif) - high-fashion aesthetic
- **Font Family Constant:** `'Alegreya'` (use in TextStyle)
- **Predefined Text Styles:** Use from `AppTheme.textTheme`
  - Display styles (displayLarge, displayMedium, displaySmall)
  - Heading styles (headlineMedium, headlineSmall)
  - Body styles (bodyLarge, bodyMedium, bodySmall)
  - Label styles (labelLarge, labelMedium, labelSmall)

### Theme Configuration
- All theme customizations in `lib/config/theme.dart`
- Button styles pre-configured (ElevatedButton, OutlinedButton)
- Input decoration theme with focus states
- Card theme with rounded corners (12px)
- Use `AppTheme` static properties for consistency

## 🔐 Authentication & Security

### Token Management
- **Access Token:** Short-lived JWT token
- **Refresh Token:** Long-lived JWT token for renewal
- **Storage:** flutter_secure_storage (platform-native secure storage)
- **HTTP Header:** `Authorization: Bearer {token}`
- **Cookie Handling:** Managed via HTTP interceptors

### Auth Service Architecture
- `authServiceProvider` - Riverpod provider for auth service
- `authStateProvider` - Stream of auth state changes
- `getCurrentUserProvider` - Get current authenticated user
- `authExceptionNotifierProvider` - Error state management

### HttpClient Integration
- Automatic token injection in request interceptor
- Handles 401 responses (token refresh logic in auth_service)
- Secure token storage/retrieval via FlutterSecureStorage
- Methods: `getAccessToken()`, `getRefreshToken()`, `saveTokens()`, `clearTokens()`

### Key Auth Functions
```dart
// In AuthService
Future<void> login(String email, String password)
Future<void> signup(String email, String password, String name)
Future<void> logout()
Future<void> refreshToken()
```

## 📡 API Integration

### HTTP Client (`HttpClient`)
- **Base URL:** Configurable via `AppConfig.apiBaseUrl`
- **Default:** `http://localhost:9002/api`
- **Timeout:** 30 seconds (connection & receive)
- **Methods:** `get<T>()`, `post<T>()`, `put<T>()`, `delete<T>()`
- **Interceptors:**
  - Request: Auto-injects auth token
  - Response: Logs response status
  - Error: Logs errors, triggers token refresh on 401

### API Endpoints
| Endpoint | Service | Method |
|----------|---------|--------|
| `/auth/login` | AuthService | POST |
| `/auth/signup` | AuthService | POST |
| `/auth/refresh` | AuthService | POST |
| `/products` | ProductService | GET |
| `/products/:id` | ProductService | GET |
| `/categories` | ProductService | GET |
| `/cart` | CartService | GET/POST |
| `/orders` | OrderService | GET/POST |
| `/user/profile` | AuthService | GET |

### Response Format
All API responses follow a standard format:
```dart
{
  "success": bool,
  "data": T,  // Response-specific data
  "pagination": {  // Optional, for list endpoints
    "page": int,
    "limit": int,
    "total": int,
    "pages": int
  }
}
```

## 🔄 State Management with Riverpod

### Architecture Patterns
1. **Service Providers:** Singleton services (HttpClient, AuthService)
2. **Future Providers:** Async data fetching (products, orders)
3. **Family Providers:** Parameterized futures (product details by ID)
4. **Stream Providers:** Real-time data (auth state)
5. **State Notifier:** Mutable state for cart operations

### Common Providers

#### Authentication
```dart
final authServiceProvider = Provider<AuthService>(...)
final authStateProvider = StreamProvider<AuthState>(...)
final currentUserProvider = FutureProvider<User>(...)
```

#### Products
```dart
final productsProvider = FutureProvider<List<Product>>(...)
final productDetailsProvider = FutureProvider.family<Product, String>(...)
final categoriesProvider = FutureProvider<List<Category>>(...)
```

#### Cart & Orders
```dart
final cartProvider = FutureProvider<Cart>(...)
final ordersProvider = FutureProvider<List<Order>>(...)
final orderDetailsProvider = FutureProvider.family<Order, String>(...)
```

### Using Providers in Widgets
```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(someProvider);
    
    return asyncValue.when(
      data: (data) => Text('Success: $data'),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}
```

## 📦 Data Models

### Model Generation
All models use Freezed annotation for immutability and JSON serialization:
```dart
@freezed
class MyModel with _$MyModel {
  const factory MyModel({
    required String id,
    required String name,
  }) = _MyModel;
  
  factory MyModel.fromJson(Map<String, dynamic> json) => 
      _$MyModelFromJson(json);
}
```

### Generated Files
- `*.freezed.dart` - Immutability and equality
- `*.g.dart` - JSON serialization (fromJson, toJson)
- **Important:** Never manually edit generated files

### Core Models
| Model | Location | Purpose |
|-------|----------|---------|
| `User` | `models/user.dart` | User profile data |
| `Product` | `models/product.dart` | Product catalog items |
| `Category` | `models/product.dart` | Product categories |
| `Cart` | `models/cart.dart` | Shopping cart |
| `Order` | `models/order.dart` | Purchase orders |
| `AuthResponse` | `models/user.dart` | Login/signup response |
| `PaginationInfo` | `models/product.dart` | List pagination data |

## 🧭 Navigation

### Router Setup
- **Navigator:** Go Router with named routes
- **Auth Guards:** Automatic redirect based on auth state
- **Deep Linking:** Supported for all main routes
- **Entry:** `/login` (unauthenticated), `/home` (authenticated)

### Route Definitions
```dart
/login                    # Authentication
/signup                   # User registration
/home                     # Dashboard
/products                 # Product list (query params: categoryId)
/products/:id             # Product details
/cart                     # Shopping cart
/checkout                 # Checkout flow
/orders                   # Order history
/orders/:id               # Order details
/profile                  # User profile
```

### Programmatic Navigation
```dart
context.goNamed('product_detail', pathParameters: {'id': '123'});
context.go('/home');
context.push('/checkout');  // Maintains navigation stack
```

## 📋 Development Workflow

### Setup & Installation
```bash
# Install dependencies
flutter pub get

# Generate code (Freezed, JSON serialization, Riverpod)
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode for development (re-generates on file changes)
flutter pub run build_runner watch --delete-conflicting-outputs

# Run app in debug mode
flutter run -d <device-id>

# Run web version
flutter run -d chrome

# Build for production
flutter build apk        # Android
flutter build ios        # iOS
flutter build web        # Web
```

### Code Generation
After modifying Freezed models or adding new Riverpod providers:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Or in watch mode for continuous development:
```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```

### Testing
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/widget_test.dart
```

### Linting
```bash
# Run analyzer
flutter analyze

# Format code
dart format lib/

# Fix formatting issues
dart format -w lib/
```

### Environment Configuration
- **File:** `.env` (not in Git - use `.env.example`)
- **Key Variables:**
  - `API_URL` - Backend API base URL
  - `FLUTTER_WEB_CANVASKIT_URL` - Web rendering library
- **Loading:** Via `AppConfig` using `String.fromEnvironment()`

## 🛠️ Common Development Tasks

### Adding a New Screen
1. Create file in `lib/screens/{feature}/` directory
2. Extend `ConsumerWidget` or `ConsumerStatefulWidget`
3. Add route in `lib/config/router.dart`
4. Use `go_router` for navigation

### Adding a New Service
1. Create file in `lib/services/` directory
2. Extend with Riverpod provider for dependency injection:
   ```dart
   final myServiceProvider = Provider<MyService>((ref) {
     return MyService(ref.watch(httpClientProvider));
   });
   ```
3. Implement methods using HttpClient
4. Handle errors with custom exceptions

### Adding a New Model
1. Create Freezed annotated class in `models/`
2. Run code generator
3. Use `fromJson` for API deserialization
4. Use immutable properties throughout app

### Integrating with Backend API
1. Add endpoint URL to service
2. Create request/response models (Freezed)
3. Implement API call with error handling
4. Create Riverpod provider for caching/state
5. Use in screens via `ref.watch(provider)`

## 🔍 Best Practices & Conventions

### Naming Conventions
- **Files:** `snake_case` (e.g., `login_screen.dart`)
- **Classes:** `PascalCase` (e.g., `LoginScreen`, `User`)
- **Variables/Functions:** `camelCase` (e.g., `getCurrentUser()`)
- **Constants:** `UPPER_SNAKE_CASE` or const variables
- **Private:** Prefix with underscore (e.g., `_initializeDio()`)

### Code Organization
- **One class per file** (except generated code)
- **Imports in order:** Dart → Flutter → Package → Relative
- **Use const constructors** for widgets
- **Separate concerns:** Services, screens, models
- **Reusable widgets:** Extract to separate files

### Error Handling
```dart
try {
  final data = await service.fetchData();
} on CustomException catch (e) {
  // Handle specific errors
  showErrorDialog(context, e.message);
} catch (e) {
  // Handle unexpected errors
  logger.e('Unexpected error: $e');
}
```

### Widget Best Practices
- Use `ConsumerWidget` for state access, not `StatefulWidget`
- Prefer composition over inheritance
- Memoize expensive widgets with `const` constructor
- Extract large widgets into separate files
- Use `key` for list items to maintain state

### Riverpod Best Practices
- Keep providers simple and single-responsibility
- Use `FutureProvider` for async data (auto-caching)
- Use `StateNotifierProvider` only for mutable state
- Avoid `ref.watch()` in try-catch (use `when()` instead)
- Cache results appropriately (set invalidation logic)

### Testing Guidelines
- Test services and business logic
- Mock HTTP client for API testing
- Use `ProviderContainer` for isolated Riverpod testing
- Widget tests: Focus on user interactions
- Keep tests focused and readable

## 🚀 Performance Optimization

### Image Loading
- Use `CachedNetworkImage` for product images
- Add shimmer loading skeleton
- Set appropriate image fit (BoxFit.cover, etc.)
- Lazy load images in lists

### List Performance
- Use `ListView.builder` for long lists
- Implement pagination for products/orders
- Cache API responses in Riverpod providers
- Use keys for list items

### State Management
- Leverage Riverpod auto-caching
- Only watch needed providers
- Invalidate cache when data changes
- Avoid rebuilding entire widget tree

## 📞 Integration with Backend

The LuxeFinds project has a backend in the `butterfly/` directory (Next.js 15):
- **Port:** 9002
- **API URL:** `http://localhost:9002/api`
- **Tech Stack:** Next.js 15, TypeScript, Prisma, PostgreSQL
- See `butterfly/README.md` for backend setup

## 📝 Important Notes

### Generated Code
- Never manually edit `*.freezed.dart` or `*.g.dart` files
- Always run code generator after model changes
- Include generated files in Git for reproducibility

### Secure Storage
- All tokens stored in secure platform storage
- Never log tokens or sensitive data
- Use `FlutterSecureStorage` for sensitive data
- Clear storage on logout

### API Response Handling
- Always check `success` flag in API responses
- Validate pagination info for list endpoints
- Handle network errors gracefully
- Show user-friendly error messages

### UI Consistency
- Use `AppTheme` for all colors and text styles
- Follow golden yellow (`#FFD700`) accent guidelines
- Maintain dark theme throughout app
- Keep spacing consistent with Material 3 specs

## 🔗 Useful Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Riverpod Documentation](https://riverpod.dev)
- [Go Router Documentation](https://pub.dev/packages/go_router)
- [Freezed Documentation](https://pub.dev/packages/freezed)
- [Dio Documentation](https://pub.dev/packages/dio)
- Backend: See `butterfly/README.md`

## 🐛 Debugging Tips

### Common Issues & Solutions

**Issue: Generated files not updating**
```bash
# Clean and regenerate
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

**Issue: Auth token not persisting**
- Check `FlutterSecureStorage` is initialized
- Verify platform-specific permissions (AndroidManifest.xml, Info.plist)
- Check token storage keys match in `AppConfig`

**Issue: API calls failing with 401**
- Verify token is being sent in Authorization header
- Check token expiration and refresh logic
- Ensure refresh token endpoint works

**Issue: Riverpod provider not updating**
- Use `ref.refresh(provider)` to invalidate cache
- Check widget is watching correct provider
- Verify `when()` method handles all states (data, loading, error)

**Issue: Navigation not working**
- Check route path matches in `router.dart`
- Verify auth guards logic
- Test with `context.go()` directly

---

**Last Updated:** February 10, 2026  
**Project Version:** 0.1.0

# 🛍️ LuxeFinds Mobile Client

A premium Flutter mobile application for an elite digital boutique specializing in luxury accessories. This client provides a cinematic shopping experience with seamless product browsing, cart management, and secure checkout functionality.

**Version:** 0.1.0  
**Language:** Dart 3.0+  
**Framework:** Flutter 3.x  
**License:** MIT

---

## 🎯 Project Overview

LuxeFinds Mobile Client is a cross-platform e-commerce application designed to deliver a sophisticated, luxury shopping experience. Built with Flutter and powered by a Next.js backend (LuxeFinds API), it combines elegant UI with robust state management and secure authentication.

### Key Features

- 🔐 **Secure Authentication** - JWT-based auth with automatic token refresh
- 🛒 **Smart Cart Management** - Real-time cart updates with persistent storage
- 📦 **Product Browsing** - Paginated product lists with filtering and search
- 💳 **Secure Checkout** - Safe payment processing with order confirmation
- 👤 **User Profiles** - Manage personal information and order history
- 🎨 **Luxury Design** - Premium dark theme with golden accents
- 📱 **Cross-Platform** - iOS, Android, and Web support

---

## 📋 Prerequisites

### System Requirements

- **Dart:** 3.0.0 or higher
- **Flutter:** 3.0.0 or higher
- **iOS:** Xcode 14+, iOS 12+
- **Android:** Android Studio, API level 21+
- **Web:** Modern browser (Chrome, Safari, Firefox, Edge)

### Backend Requirements

- **LuxeFinds API:** Must be running (see backend setup below)
- **Node.js:** 18+ (for running backend locally)
- **PostgreSQL:** 12+ (for backend database)
- **Redis:** 6+ (for backend caching)

### Development Tools

- Git
- Visual Studio Code or Android Studio
- Android emulator or physical Android device
- iOS simulator or physical iPhone

---

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/luxefinds-mobile-client.git
cd luxefinds-mobile-client
```

### 2. Install Flutter Dependencies

```bash
# Get all dependencies
flutter pub get

# Generate code (Freezed, JSON serialization, Riverpod)
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode for development (re-generates on file changes)
flutter pub run build_runner watch --delete-conflicting-outputs
```

### 3. Configure Environment Variables

Create a `.env` file in the root directory:

```bash
cp .env.example .env
```

Edit `.env` with your configuration:

```env
# Backend API Configuration
API_URL=http://localhost:9002/api

# Web-specific configuration
FLUTTER_WEB_CANVASKIT_URL=/canvaskit/
```

### 4. Setup Backend (LuxeFinds API)

The app requires the LuxeFinds backend API to be running:

```bash
# Navigate to backend directory
cd ../butterfly  # Assuming backend is in parallel directory

# Install and setup backend
npm install
npm run db:generate
npm run db:push
npm run db:seed

# Start backend development server
npm run dev
```

Backend will run on `http://localhost:9002`

---

## 🏃 Running the Application

### Run on Android

```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device_id>

# Run on Android emulator (debug)
flutter run
```

### Run on iOS

```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device_id>

# Run on iOS simulator
flutter run
```

### Run on Web

```bash
# Enable web (one-time setup)
flutter config --enable-web

# Run web version
flutter run -d chrome

# Or specify other browser
flutter run -d safari
flutter run -d firefox
```

### Run with Specific Configuration

```bash
# Development
flutter run --debug

# Production
flutter run --release

# Profile (performance analysis)
flutter run --profile
```

---

## 🧪 Testing

### Run All Tests

```bash
flutter test
```

### Run Specific Test File

```bash
flutter test test/unit/services/http_client_test.dart
```

### Run Tests with Coverage

```bash
flutter test --coverage
```

### View Coverage Report

```bash
# Install coverage reporting tool
pub global activate coverage

# Generate coverage report
coverage run --function-coverage -o coverage/lcov.info

# View in browser
open coverage/lcov-report/index.html
```

---

## 🔨 Building for Production

### Android Build

```bash
# Build APK
flutter build apk

# Build App Bundle (for Google Play)
flutter build appbundle

# Output locations:
# APK: build/app/outputs/flutter-apk/app-release.apk
# Bundle: build/app/outputs/bundle/release/app-release.aab
```

### iOS Build

```bash
# Build iOS app
flutter build ios

# Build for physical device
flutter build ios --release

# Output: build/ios/iphoneos/Runner.app
```

### Web Build

```bash
# Build web version
flutter build web

# Output: build/web/
```

---

## 📝 Code Quality & Linting

### Run Analyzer

```bash
flutter analyze
```

### Format Code

```bash
# Format all Dart files
dart format lib/

# Format with write changes
dart format -w lib/
```

### Custom Linting

The project includes Flutter linting rules in `analysis_options.yaml`. Code should follow:

- Effective Dart style guide
- Flutter best practices
- Project-specific linting rules

---

## 🏗️ Architecture

### Project Structure

```
lib/
├── main.dart                    # App entry point
├── config/
│   ├── app_config.dart         # Configuration constants
│   ├── router.dart             # Go Router navigation setup
│   └── theme.dart              # App theme and styling
├── models/
│   ├── user.dart               # User & auth models (Freezed)
│   ├── product.dart            # Product catalog models
│   ├── cart.dart               # Shopping cart models
│   ├── order.dart              # Order models
│   └── *.freezed.dart, *.g.dart # Generated code (DO NOT EDIT)
├── screens/
│   ├── auth/                   # Authentication screens
│   ├── products/               # Product browsing
│   ├── cart/                   # Shopping cart
│   ├── checkout/               # Checkout flow
│   ├── orders/                 # Order management
│   ├── home/                   # Home screen
│   └── profile/                # User profile
├── services/
│   ├── http_client.dart        # HTTP client with Dio
│   ├── auth_service.dart       # Authentication logic
│   ├── product_service.dart    # Product API calls
│   ├── cart_service.dart       # Cart operations
│   └── order_service.dart      # Order management
└── assets/
    ├── images/                 # Product images
    ├── icons/                  # App icons
    └── fonts/                  # Custom fonts (Alegreya)
```

### State Management

**Riverpod** is used for state management:

- **FutureProviders** - Async data fetching (products, orders)
- **StateNotifierProviders** - Mutable state (cart, auth)
- **StreamProviders** - Real-time data
- **Family Providers** - Parameterized providers (pagination, filtering)

### Authentication Flow

```
Login Screen
    ↓
AuthService.login()
    ↓
API call to /auth/login
    ↓
Save tokens (secure storage)
    ↓
Update AuthState
    ↓
Navigate to Home
```

### Token Refresh

```
API Request
    ↓
401 Error (expired token)
    ↓
Attempt refresh with refresh token
    ↓
Save new tokens
    ↓
Retry original request
    ↓
Return result
```

---

## 🔐 Authentication & Security

### Token Management

- **Access Token:** JWT token with 7-day expiration
- **Refresh Token:** JWT token with 30-day expiration
- **Storage:** Secure platform storage (Keychain on iOS, Keystore on Android)
- **Transmission:** Authorization header (`Bearer {token}`)

### Automatic Token Refresh

When an API request receives a 401 (Unauthorized) response:

1. Check if refresh token is available
2. If refresh in progress, queue the request
3. Call `/auth/refresh` endpoint with refresh token
4. Save new tokens on success
5. Retry the original request
6. On failure, clear tokens and redirect to login

### Security Best Practices

- Never log tokens or sensitive data
- Use HTTPS in production
- Clear tokens on logout
- Validate JWT signatures on backend
- Use httpOnly cookies if possible

---

## 🚨 Troubleshooting

### Common Issues

#### "Command not found: flutter"

```bash
# Add Flutter to PATH
export PATH="$PATH:/path/to/flutter/bin"

# Or install via system package manager
# macOS:
brew install flutter

# Verify installation
flutter doctor
```

#### "Android SDK not found"

```bash
# Run Flutter setup
flutter doctor --android-licenses

# Or manually set Android SDK path
export ANDROID_SDK_ROOT=/path/to/android-sdk
```

#### "Pods stuck in bad state" (iOS)

```bash
# Clean iOS build
cd ios
rm -rf Pods Podfile.lock
cd ..
flutter clean
flutter pub get
flutter run
```

#### "Generated files not updating"

```bash
# Clean and regenerate
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

#### "API connection refused"

```bash
# Verify backend is running
curl http://localhost:9002/api/health

# Check .env file has correct API_URL
cat .env

# Try using device IP instead of localhost
# Edit .env: API_URL=http://192.168.x.x:9002/api
```

#### "Secure storage not working"

**iOS:** Add Keychain capabilities in Xcode  
**Android:** Ensure AndroidManifest.xml permissions are set

---

## 📚 Development Workflow

### Feature Development Workflow

1. **Create feature branch**
   ```bash
   git checkout -b feature/feature-name
   ```

2. **Make changes**
   - Update models if needed
   - Implement service methods
   - Create/update screens
   - Update routing if needed

3. **Generate code**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Test changes**
   ```bash
   flutter analyze
   dart format -w lib/
   flutter test
   flutter run
   ```

5. **Commit and push**
   ```bash
   git add .
   git commit -m "feat: description of changes"
   git push origin feature/feature-name
   ```

6. **Create Pull Request** on GitHub

### Adding New Features

#### Add a new screen

1. Create file: `lib/screens/feature/feature_screen.dart`
2. Extend `ConsumerWidget` or `ConsumerStatefulWidget`
3. Add route in `lib/config/router.dart`
4. Import and use in navigation

#### Add a new service

1. Create file: `lib/services/feature_service.dart`
2. Implement service class with API calls
3. Create Riverpod provider
4. Handle errors with custom exceptions
5. Use in screens via `ref.watch()`

#### Add a new model

1. Create file: `lib/models/feature.dart`
2. Use Freezed annotations
3. Run code generator
4. Update imports in services
5. Use for type-safe API responses

---

## 📖 Additional Documentation

For more detailed documentation, see:

- **[API Integration](docs/api-integration.md)** - How to integrate with backend
- **[State Management](docs/state-management.md)** - Riverpod patterns and examples
- **[Navigation](docs/navigation.md)** - Go Router setup and routing
- **[Styling](docs/styling.md)** - Theme system and UI components
- **[Testing](docs/testing.md)** - Testing strategies and examples

---

## 🤝 Contributing

Contributions are welcome! Please follow these guidelines:

1. Follow the code style (Effective Dart)
2. Add tests for new features
3. Update documentation
4. Create meaningful commit messages
5. Submit pull requests with detailed descriptions

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 🔗 Related Projects

- **[LuxeFinds Backend](https://github.com/yourusername/luxefinds-backend)** - Next.js API server
- **[LuxeFinds Admin](https://github.com/yourusername/luxefinds-admin)** - Admin dashboard

---

## 📞 Support

For issues, questions, or suggestions:

- **Issues:** GitHub Issues
- **Email:** support@luxefinds.com
- **Discord:** Join our community

---

## 🎨 Credits

Built with ❤️ using:

- [Flutter](https://flutter.dev) - UI framework
- [Riverpod](https://riverpod.dev) - State management
- [Dio](https://pub.dev/packages/dio) - HTTP client
- [Go Router](https://pub.dev/packages/go_router) - Navigation
- [Freezed](https://pub.dev/packages/freezed) - Code generation
- [ShadCN UI](https://shadcn-ui.com) - Design inspiration

---

**Last Updated:** February 11, 2026  
**Version:** 0.1.0

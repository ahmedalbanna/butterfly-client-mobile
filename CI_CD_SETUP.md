# CI/CD Setup Guide - Flutter Admin App

**Date:** February 11, 2026  
**Project:** LuxeFinds Flutter Admin App  
**Platforms:** GitHub Actions, GitLab CI, Manual Setup

---

## 📋 Overview

This guide provides CI/CD configuration for automated testing, building, and deployment of the Flutter admin app.

---

## 🚀 GitHub Actions Setup

### Create Workflow File

**File:** `.github/workflows/flutter_ci.yml`

```yaml
name: Flutter CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  test:
    name: Test Flutter App
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
          channel: 'stable'
      
      - name: Get dependencies
        run: flutter pub get
        working-directory: flutter_admin
      
      - name: Run analyzer
        run: flutter analyze
        working-directory: flutter_admin
      
      - name: Run unit tests
        run: flutter test --coverage
        working-directory: flutter_admin
      
      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v3
        with:
          files: flutter_admin/coverage/lcov.info
          fail_ci_if_error: true
  
  integration_test:
    name: Integration Tests
    runs-on: ubuntu-latest
    needs: test
    
    services:
      backend:
        image: node:18
        ports:
          - 9002:9002
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
          channel: 'stable'
      
      - name: Start backend server
        run: |
          cd butterfly
          npm install
          npm run dev &
          sleep 10
      
      - name: Get dependencies
        run: flutter pub get
        working-directory: flutter_admin
      
      - name: Run integration tests
        run: flutter test integration_test/
        working-directory: flutter_admin
        env:
          FLUTTER_TEST_API_URL: http://localhost:9002/api
          FLUTTER_TEST_USE_REAL_BACKEND: true
  
  build_android:
    name: Build Android APK
    runs-on: ubuntu-latest
    needs: test
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
          channel: 'stable'
      
      - name: Setup Java
        uses: actions/setup-java@v3
        with:
          distribution: 'zulu'
          java-version: '17'
      
      - name: Get dependencies
        run: flutter pub get
        working-directory: flutter_admin
      
      - name: Build APK
        run: flutter build apk --release
        working-directory: flutter_admin
      
      - name: Upload APK artifact
        uses: actions/upload-artifact@v3
        with:
          name: android-apk
          path: flutter_admin/build/app/outputs/flutter-apk/app-release.apk
  
  build_ios:
    name: Build iOS App
    runs-on: macos-latest
    needs: test
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
          channel: 'stable'
      
      - name: Get dependencies
        run: flutter pub get
        working-directory: flutter_admin
      
      - name: Build iOS (no codesign)
        run: flutter build ios --release --no-codesign
        working-directory: flutter_admin
  
  build_web:
    name: Build Web App
    runs-on: ubuntu-latest
    needs: test
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
          channel: 'stable'
      
      - name: Get dependencies
        run: flutter pub get
        working-directory: flutter_admin
      
      - name: Build web
        run: flutter build web --release
        working-directory: flutter_admin
      
      - name: Upload web artifact
        uses: actions/upload-artifact@v3
        with:
          name: web-build
          path: flutter_admin/build/web/
```

---

## 🦊 GitLab CI Setup

### Create CI Configuration

**File:** `.gitlab-ci.yml`

```yaml
image: cirrusci/flutter:stable

stages:
  - test
  - build
  - deploy

variables:
  FLUTTER_VERSION: "3.16.0"

before_script:
  - cd flutter_admin
  - flutter pub get

test:unit:
  stage: test
  script:
    - flutter analyze
    - flutter test --coverage
  coverage: '/lines\.*: \d+\.\d+%/'
  artifacts:
    reports:
      coverage_report:
        coverage_format: cobertura
        path: coverage/lcov.info

test:integration:
  stage: test
  services:
    - name: node:18
      alias: backend
  before_script:
    - cd butterfly
    - npm install
    - npm run dev &
    - sleep 10
    - cd ../flutter_admin
    - flutter pub get
  script:
    - flutter test integration_test/
  only:
    - main
    - develop

build:android:
  stage: build
  image: cirrusci/flutter:stable
  before_script:
    - cd flutter_admin
    - flutter pub get
  script:
    - flutter build apk --release
  artifacts:
    paths:
      - flutter_admin/build/app/outputs/flutter-apk/app-release.apk
    expire_in: 1 week
  only:
    - main
    - tags

build:ios:
  stage: build
  tags:
    - macos
  before_script:
    - cd flutter_admin
    - flutter pub get
  script:
    - flutter build ios --release --no-codesign
  only:
    - main
    - tags

build:web:
  stage: build
  before_script:
    - cd flutter_admin
    - flutter pub get
  script:
    - flutter build web --release
  artifacts:
    paths:
      - flutter_admin/build/web/
    expire_in: 1 week
  only:
    - main
    - tags

deploy:web:
  stage: deploy
  dependencies:
    - build:web
  script:
    - echo "Deploy to web hosting"
    # Add your deployment commands here
  only:
    - main
  when: manual
```

---

## 🔧 Manual CI/CD Setup

### Prerequisites

1. **Flutter SDK:** Install Flutter 3.16.0 or later
2. **Git:** Version control
3. **Node.js:** For backend (if running integration tests)

### Local CI Script

Create `flutter_admin/ci_local.sh`:

```bash
#!/bin/bash
set -e

echo "=========================================="
echo "  Flutter Admin - Local CI Pipeline"
echo "=========================================="

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Navigate to flutter_admin
cd "$(dirname "$0")"

# 1. Get dependencies
echo ""
echo "📦 Getting dependencies..."
flutter pub get

# 2. Analyze code
echo ""
echo "🔍 Analyzing code..."
if flutter analyze; then
  echo -e "${GREEN}✅ Analysis passed${NC}"
else
  echo -e "${RED}❌ Analysis failed${NC}"
  exit 1
fi

# 3. Run tests
echo ""
echo "🧪 Running unit tests..."
if flutter test --coverage; then
  echo -e "${GREEN}✅ Tests passed${NC}"
else
  echo -e "${RED}❌ Tests failed${NC}"
  exit 1
fi

# 4. Generate coverage report
echo ""
echo "📊 Generating coverage report..."
if command -v genhtml &> /dev/null; then
  genhtml coverage/lcov.info -o coverage/html
  echo -e "${GREEN}Coverage report: coverage/html/index.html${NC}"
fi

# 5. Build (optional)
read -p "Build app? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo ""
  echo "🏗️  Building app..."
  flutter build apk --release
  echo -e "${GREEN}✅ Build complete${NC}"
fi

echo ""
echo "=========================================="
echo -e "${GREEN}✅ CI Pipeline Complete!${NC}"
echo "=========================================="
```

Make executable:
```bash
chmod +x flutter_admin/ci_local.sh
```

Run:
```bash
./ci_local.sh
```

---

## 📊 Code Coverage

### Codecov Integration

Add to GitHub Actions workflow:

```yaml
- name: Upload coverage to Codecov
  uses: codecov/codecov-action@v3
  with:
    files: flutter_admin/coverage/lcov.info
    fail_ci_if_error: true
    token: ${{ secrets.CODECOV_TOKEN }}
```

### Coverage Badge

Add to `README.md`:

```markdown
[![codecov](https://codecov.io/gh/yourusername/yourrepo/branch/main/graph/badge.svg)](https://codecov.io/gh/yourusername/yourrepo)
```

---

## 🚢 Deployment Automation

### Deploy to Firebase Hosting (Web)

```yaml
deploy:firebase:
  stage: deploy
  script:
    - npm install -g firebase-tools
    - firebase deploy --only hosting --token $FIREBASE_TOKEN
  only:
    - main
  when: manual
```

### Deploy to Google Play (Android)

```yaml
deploy:playstore:
  stage: deploy
  script:
    - bundle install
    - bundle exec fastlane deploy_playstore
  only:
    - tags
  when: manual
```

### Deploy to App Store (iOS)

```yaml
deploy:appstore:
  stage: deploy
  tags:
    - macos
  script:
    - bundle install
    - bundle exec fastlane deploy_appstore
  only:
    - tags
  when: manual
```

---

## 🔐 Secrets Management

### GitHub Secrets

Navigate to: **Settings → Secrets and variables → Actions**

Add:
- `CODECOV_TOKEN` - Codecov token
- `FIREBASE_TOKEN` - Firebase CI token
- `PLAY_STORE_KEY` - Google Play service account JSON
- `APP_STORE_CONNECT_KEY` - App Store Connect API key

### GitLab CI/CD Variables

Navigate to: **Settings → CI/CD → Variables**

Add same secrets as above.

---

## 🧪 Test Automation

### Pre-commit Hooks

Create `.git/hooks/pre-commit`:

```bash
#!/bin/sh

cd flutter_admin

echo "Running Flutter analyzer..."
flutter analyze

if [ $? -ne 0 ]; then
  echo "❌ Analysis failed. Commit aborted."
  exit 1
fi

echo "Running tests..."
flutter test

if [ $? -ne 0 ]; then
  echo "❌ Tests failed. Commit aborted."
  exit 1
fi

echo "✅ All checks passed!"
exit 0
```

Make executable:
```bash
chmod +x .git/hooks/pre-commit
```

---

## 📈 Monitoring & Notifications

### Slack Notifications (GitHub Actions)

```yaml
- name: Slack Notification
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    text: 'Flutter CI Pipeline'
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
  if: always()
```

### Email Notifications (GitLab)

Configure in GitLab: **Settings → Integrations → Emails on push**

---

## ✅ Best Practices

1. **Run tests on every PR**
2. **Require CI to pass before merge**
3. **Use semantic versioning for releases**
4. **Tag releases in Git**
5. **Generate changelog automatically**
6. **Monitor test coverage (aim for >80%)**
7. **Run integration tests on staging**
8. **Use feature branches**
9. **Squash commits on merge**
10. **Keep CI pipeline fast (<10 min)**

---

## 🎯 Next Steps

1. Choose CI/CD platform (GitHub Actions recommended)
2. Create workflow file
3. Configure secrets
4. Run initial pipeline
5. Add status badge to README
6. Set up code coverage
7. Configure deployment automation
8. Enable notifications

---

**Last Updated:** February 11, 2026  
**Maintained by:** Development Team

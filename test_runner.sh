#!/bin/bash

# Flutter Admin Test Runner
# Runs unit tests and integration tests for the Flutter admin app

set -e

echo "════════════════════════════════════════════════════════════════"
echo "  Flutter Admin Test Runner"
echo "════════════════════════════════════════════════════════════════"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Parse arguments
RUN_UNIT=true
RUN_INTEGRATION=false
DEVICE=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --integration)
      RUN_INTEGRATION=true
      shift
      ;;
    --unit-only)
      RUN_INTEGRATION=false
      shift
      ;;
    --device)
      DEVICE="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: $0 [--integration] [--unit-only] [--device <device-id>]"
      exit 1
      ;;
  esac
done

# Get dependencies
echo -e "${YELLOW}📦 Getting Flutter dependencies...${NC}"
flutter pub get
echo ""

# Run unit tests
if [ "$RUN_UNIT" = true ]; then
  echo -e "${YELLOW}🧪 Running Unit Tests...${NC}"
  echo "────────────────────────────────────────────────────────────────"
  
  if flutter test --coverage; then
    echo -e "${GREEN}✅ Unit tests passed!${NC}"
  else
    echo -e "${RED}❌ Unit tests failed!${NC}"
    exit 1
  fi
  echo ""
  
  # Generate coverage report
  if command -v lcov &> /dev/null; then
    echo -e "${YELLOW}📊 Generating coverage report...${NC}"
    genhtml coverage/lcov.info -o coverage/html
    echo -e "${GREEN}Coverage report: coverage/html/index.html${NC}"
    echo ""
  fi
fi

# Run integration tests
if [ "$RUN_INTEGRATION" = true ]; then
  echo -e "${YELLOW}🔗 Running Integration Tests...${NC}"
  echo "────────────────────────────────────────────────────────────────"
  
  # Check if backend is running
  echo "Checking if backend is available at http://localhost:9002..."
  if curl -s http://localhost:9002/api/health > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Backend is running${NC}"
  else
    echo -e "${YELLOW}⚠️  Backend not detected - tests may use mocks${NC}"
  fi
  echo ""
  
  # Run integration tests
  if [ -n "$DEVICE" ]; then
    echo "Running on device: $DEVICE"
    flutter test integration_test/auth_flow_test.dart -d "$DEVICE"
  else
    echo "Running on default device..."
    flutter test integration_test/auth_flow_test.dart
  fi
  
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Integration tests passed!${NC}"
  else
    echo -e "${RED}❌ Integration tests failed!${NC}"
    exit 1
  fi
  echo ""
fi

echo "════════════════════════════════════════════════════════════════"
echo -e "${GREEN}✅ All tests completed successfully!${NC}"
echo "════════════════════════════════════════════════════════════════"

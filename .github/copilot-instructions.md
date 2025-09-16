# MzadQatar Car Deals - Flutter App

A Flutter mobile application that analyzes and browses car deals from mzadqatar.com. The app fetches car listings via API, stores data locally with SQLite, and provides market analysis features with a clean UI.

Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.

## Working Effectively

### Prerequisites and Installation
- Install Flutter SDK:
  - Download from https://docs.flutter.dev/get-started/install/linux
  - Extract and add to PATH: `export PATH="$PATH:$HOME/flutter/bin"`
  - Run `flutter doctor` to verify installation
- Install dependencies for Android development:
  - Android Studio or VS Code with Flutter extension
  - Android SDK (API level 33 or higher recommended)
- For Linux development: `sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev`

### Bootstrap and Build Process
- Clone repository and navigate to project root
- **IMPORTANT**: This repository contains only the lib/ source code. Complete Flutter project setup:
  ```bash
  flutter create --project-name mzadqatar_car_deals .
  ```
  - This creates platform directories (android/, ios/, linux/, web/, etc.)
  - Takes 2-5 minutes. NEVER CANCEL. Set timeout to 10+ minutes.
- Install Flutter dependencies:
  ```bash
  flutter pub get
  ```
  - Takes 1-3 minutes normally. NEVER CANCEL. Set timeout to 5+ minutes.
- Verify project health:
  ```bash
  flutter doctor
  flutter analyze
  ```

### Build Commands
- **Debug build**: `flutter build apk --debug` -- takes 3-8 minutes. NEVER CANCEL. Set timeout to 15+ minutes.
- **Release build**: `flutter build apk --release` -- takes 5-12 minutes. NEVER CANCEL. Set timeout to 20+ minutes.
- **Linux desktop**: `flutter build linux` -- takes 4-10 minutes. NEVER CANCEL. Set timeout to 15+ minutes.

### Running the Application
- **Mobile (Android)**: `flutter run` (requires connected device or emulator)
- **Desktop**: `flutter run -d linux` (for Linux desktop)
- **Web**: `flutter run -d chrome` (for web development)

### Testing
- Run unit tests: `flutter test` -- takes 30 seconds to 2 minutes. Set timeout to 5+ minutes.
- Widget tests are located in `test/` directory (if present)
- Integration tests: `flutter drive --target=test_driver/app.dart` (if present)

## Validation

### Manual Testing Scenarios
After making any changes, ALWAYS test these scenarios to ensure functionality:

1. **App Launch and Data Loading**:
   - Launch the app
   - Verify the car listings screen loads
   - Check that the loading indicator appears while fetching data
   - Confirm car listings display with images, titles, and prices

2. **Market Analysis Feature**:
   - Tap the analytics button (chart icon) in the app bar
   - Verify the market analysis dialog shows:
     - Total listings count
     - Average price
     - Lowest price  
     - Highest price

3. **Car Detail View**:
   - Tap on any car listing
   - Verify detail screen loads with:
     - Car image (if available)
     - Full title and description
     - Price in QAR
     - Posted date
     - "View Original Listing" button

4. **Database Functionality**:
   - Verify data persists between app restarts
   - Check that SQLite database operations work correctly

### Network Connectivity
- **IMPORTANT**: The app uses a placeholder API endpoint `https://api.npoint.io/4712ebcd2f3f5859c2e3`
- In network-restricted environments, the API calls may fail
- Always test with actual network connectivity when possible
- Document any API failures as expected behavior in restricted environments

### Pre-commit Validation
Always run these commands before committing changes:
- `flutter analyze` -- static analysis, takes 30-60 seconds
- `flutter test` -- run all tests if present
- `flutter format lib/` -- code formatting
- Build and test manually as described above

## Codebase Navigation

### Key Project Structure
```
lib/
├── main.dart                    # App entry point
├── models/
│   └── car_listing.dart         # CarListing data model
├── api/
│   └── mzadqatar_api.dart       # API client for fetching data
├── db/
│   └── database_helper.dart     # SQLite database operations
├── screens/
│   ├── listing_screen.dart      # Main screen with car list
│   └── detail_screen.dart       # Car detail view
└── utils/
    └── analysis.dart            # Price analysis utilities
```

### Important Files to Check After Changes
- Always check `lib/models/car_listing.dart` after modifying API responses
- Always verify `lib/db/database_helper.dart` after changing data models
- Always test `lib/api/mzadqatar_api.dart` functionality after network-related changes

### Dependencies (pubspec.yaml)
- `http: ^1.1.0` - HTTP requests for API calls
- `sqflite: ^2.3.0` - SQLite database for local storage
- `path: ^1.9.0` - Path manipulation utilities
- `flutter_lints: ^3.0.0` - Linting rules (dev dependency)

## Common Tasks

### Adding New Features
1. Create model classes in `lib/models/` if needed
2. Add database schema changes in `database_helper.dart`
3. Update API client in `mzadqatar_api.dart` if fetching new data
4. Create/modify screens in `lib/screens/`
5. Add utility functions in `lib/utils/` as needed

### Debugging Network Issues
- Check API endpoint accessibility: `curl https://api.npoint.io/4712ebcd2f3f5859c2e3`
- Verify HTTP package is properly imported
- Test with Flutter's debug tools: `flutter logs`

### Database Debugging
- Use `flutter logs` to see database operations
- Check SQLite schema in `database_helper.dart`
- Verify data persistence with app restart testing

## Troubleshooting

### Network Restrictions
- If `flutter create` or `flutter pub get` fail due to network restrictions:
  - Try using a different network or VPN
  - Check corporate firewall settings
  - Use `flutter pub get --offline` if packages are cached
- API endpoint testing: `curl https://api.npoint.io/4712ebcd2f3f5859c2e3`

### Flutter Installation Issues  
- Verify PATH includes Flutter bin directory: `echo $PATH | grep flutter`
- Check Flutter installation: `flutter doctor -v`
- Ensure minimum Dart SDK version 3.0.0: `dart --version`

### Build Failures
- Clear Flutter cache: `flutter clean && flutter pub get`
- Update Flutter: `flutter upgrade` (may take 10+ minutes)
- Check for conflicting global packages: `flutter pub deps`

### Platform-Specific Issues
- **Android**: Ensure Android SDK is installed and ANDROID_HOME is set
- **Linux**: Install required system packages: `sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev`
- **Web**: Modern web browser required for testing

## Platform Support
- **Primary target**: Android mobile devices (after running `flutter create .`)
- **Secondary targets**: Linux desktop, Web (after setup)
- **Requires additional setup**: iOS (requires macOS and Xcode), Windows, macOS
- **Platform directories created by**: `flutter create .` command

## Known Limitations
- **Repository Setup**: This repository contains only `lib/` source code and `pubspec.yaml`. Platform directories must be created with `flutter create .` before first use.
- **Missing Platform Files**: No Android, iOS, Linux, or Web platform configurations are included in the repository
- API endpoint is a placeholder - replace with actual mzadqatar.com API when available
- No authentication mechanism implemented
- Limited error handling for network failures
- URL launcher functionality commented out in detail screen
- **Missing .gitignore**: After running `flutter create .`, add generated platform files to .gitignore to avoid committing build artifacts

## Post-Setup .gitignore Additions
After running `flutter create .`, ensure these entries are in .gitignore:
```
# Build artifacts
build/
.dart_tool/
.packages
.pub-cache/
.pub/
.fvm/

# Platform specific
android/.gradle/
android/app/debug/
android/app/profile/
android/app/release/
ios/Pods/
ios/Runner.xcworkspace/
linux/build/
web/build/
```

## Build Time Expectations
- **Initial `flutter pub get`**: 1-3 minutes
- **Debug build**: 3-8 minutes for first build, 30 seconds-2 minutes for incremental
- **Release build**: 5-12 minutes
- **Tests**: 30 seconds-2 minutes
- **Analysis/Linting**: 30-60 seconds

**CRITICAL**: NEVER CANCEL long-running builds. Flutter builds can take significant time, especially on first run or after clean. Always set timeouts of 15+ minutes for builds and wait for completion.

## Quick Command Reference

### Essential Setup Commands
```bash
# Initial setup (run once)
flutter create --project-name mzadqatar_car_deals .  # 2-5 min, timeout 10+ min
flutter pub get                                      # 1-3 min, timeout 5+ min

# Verification
flutter doctor                                       # 30 sec
flutter analyze                                      # 30-60 sec
```

### Development Commands  
```bash
# Running
flutter run                                          # Mobile/default device
flutter run -d linux                                # Linux desktop
flutter run -d chrome                               # Web browser

# Building
flutter build apk --debug                           # 3-8 min, timeout 15+ min  
flutter build apk --release                         # 5-12 min, timeout 20+ min
flutter build linux                                 # 4-10 min, timeout 15+ min

# Testing and Quality
flutter test                                         # 30 sec-2 min, timeout 5+ min
flutter format lib/                                 # 10-30 sec
flutter clean                                       # 10-30 sec
```

### Debugging Commands
```bash
flutter logs                                        # View app logs
flutter doctor -v                                   # Detailed environment info
flutter pub deps                                    # Dependency tree
```
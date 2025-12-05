# Development Guide

## Getting Started with Development

### Environment Setup

1. **Install Flutter**
   - Download from [flutter.dev](https://flutter.dev)
   - Add Flutter to your PATH
   - Run `flutter doctor` to verify installation

2. **IDE Setup**
   - VS Code with Flutter extension (recommended)
   - Or Android Studio with Flutter plugin

3. **Platform-Specific Tools**
   
   **For Android:**
   - Android Studio
   - Android SDK (API level 21+)
   - Android Emulator or physical device
   
   **For iOS:**
   - macOS required
   - Xcode 14+
   - iOS Simulator or physical device
   - CocoaPods (`sudo gem install cocoapods`)
   
   **For Windows:**
   - Visual Studio 2022
   - Desktop development with C++ workload
   - Windows 10 SDK

### First Run

```bash
# Get dependencies
flutter pub get

# Run code generation (if needed)
flutter pub run build_runner build

# Run on connected device
flutter run

# Or specify platform
flutter run -d windows
flutter run -d android
flutter run -d ios
```

## Project Architecture

### Core Principles

1. **Separation of Concerns**: Business logic separated from UI
2. **Platform Abstraction**: Abstract interfaces with platform-specific implementations
3. **State Management**: Provider pattern for reactive state
4. **Dependency Injection**: Services injected via Provider

### Key Components

#### 1. Speech Recognition Service
- Abstract interface: `SpeechRecognitionService`
- Default implementation: `DefaultSpeechRecognition` (uses speech_to_text package)
- Platform-specific implementations can be added

#### 2. Transcription Manager
- Manages transcription state
- Handles text buffering and formatting
- Maintains history
- Coordinates with speech recognition service

#### 3. Clipboard Manager
- Cross-platform clipboard operations
- Simple interface for copy/paste

### Adding New Features

#### Example: Adding a new language

1. **Update TranscriptionManager**:
```dart
// Add language to available languages
final languages = await speechService.getAvailableLanguages();
```

2. **Update UI**:
```dart
// Add language selector in settings
DropdownButton<String>(
  value: _selectedLanguage,
  items: languages.map((lang) => 
    DropdownMenuItem(value: lang, child: Text(lang))
  ).toList(),
  onChanged: (lang) => manager.setLanguageCode(lang),
)
```

#### Example: Adding export functionality

1. **Create new service**:
```dart
// lib/core/services/export_service.dart
class ExportService {
  Future<void> exportAsPdf(String text) async {
    // Implementation
  }
}
```

2. **Add to UI**:
```dart
// Add export button in action buttons
_ActionButton(
  icon: Icons.download,
  label: 'Export',
  onPressed: () => _exportText(),
)
```

## Testing

### Unit Tests

```bash
flutter test
```

### Integration Tests

```bash
flutter test integration_test/
```

### Platform-Specific Testing

```bash
# Test on specific platform
flutter test --platform=windows
flutter test --platform=android
```

## Building for Production

### Android

```bash
# Build APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release

# Outputs to: build/app/outputs/flutter-apk/app-release.apk
```

**Signing for Release:**
1. Create keystore:
```bash
keytool -genkey -v -keystore wordflow-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias wordflow
```

2. Create `android/key.properties`:
```properties
storePassword=your_password
keyPassword=your_password
keyAlias=wordflow
storeFile=../wordflow-key.jks
```

3. Update `android/app/build.gradle`:
```gradle
android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

### iOS

```bash
# Build for iOS
flutter build ios --release

# Or build IPA
flutter build ipa
```

**App Store Setup:**
1. Open `ios/Runner.xcworkspace` in Xcode
2. Configure signing & capabilities
3. Set up provisioning profile
4. Archive and upload to App Store Connect

### Windows

```bash
flutter build windows --release

# Output: build/windows/runner/Release/
```

**Creating Installer:**
Use Inno Setup or MSIX for Windows installer:
```bash
flutter pub run msix:create
```

## Performance Optimization

### Reducing App Size

```bash
# Split APKs by ABI
flutter build apk --split-per-abi

# Obfuscate code
flutter build apk --obfuscate --split-debug-info=build/debug-info
```

### Memory Optimization

- Dispose controllers properly
- Cancel subscriptions in dispose()
- Use const constructors where possible
- Avoid rebuilding large widgets

### Battery Optimization

- Stop speech recognition when app is in background
- Use efficient audio processing
- Minimize wake locks

## Debugging

### Common Issues

1. **Speech recognition not starting**
   - Check permissions are granted
   - Verify microphone is available
   - Check platform-specific logs

2. **App crashes on specific platform**
   - Check platform-specific dependencies
   - Review native logs (logcat for Android, Console.app for iOS)

3. **Performance issues**
   - Use Flutter DevTools
   - Profile with `flutter run --profile`
   - Check for memory leaks

### Platform-Specific Debugging

**Android:**
```bash
# View logs
adb logcat | grep flutter

# Debug on device
flutter run --debug
```

**iOS:**
```bash
# View logs
xcrun simctl spawn booted log stream --predicate 'process == "Runner"'

# Debug on simulator
flutter run -d ios
```

**Windows:**
```bash
# Run with verbose logging
flutter run -d windows --verbose
```

## Code Style

### Dart Style Guide

Follow [Effective Dart](https://dart.dev/guides/language/effective-dart):

- Use `lowerCamelCase` for variables and functions
- Use `UpperCamelCase` for classes
- Use `lowercase_with_underscores` for libraries and imports
- Prefer `final` over `var`
- Use trailing commas for better formatting

### Linting

```bash
# Analyze code
flutter analyze

# Fix auto-fixable issues
dart fix --apply
```

## Continuous Integration

### GitHub Actions Example

```yaml
name: Build and Test

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      - run: flutter pub get
      - run: flutter test
      - run: flutter analyze
```

## Contributing Guidelines

1. **Fork** the repository
2. Create a **feature branch** from `develop`
3. Follow **code style** guidelines
4. Write **tests** for new features
5. Update **documentation**
6. Submit a **pull request**

### Commit Message Format

```
type(scope): subject

body

footer
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

Example:
```
feat(speech): add support for Spanish language

- Added Spanish language pack
- Updated language selector UI
- Added tests for Spanish recognition

Closes #123
```

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Flutter Cookbook](https://docs.flutter.dev/cookbook)
- [speech_to_text Package](https://pub.dev/packages/speech_to_text)
- [Provider Package](https://pub.dev/packages/provider)

## Getting Help

- GitHub Issues: Report bugs and request features
- Discussions: Ask questions and share ideas
- Stack Overflow: Tag questions with `flutter` and `wordflow`

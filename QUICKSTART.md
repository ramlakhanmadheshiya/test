# Quick Start Guide

## Setup Instructions

### Step 1: Install Flutter

1. **Download Flutter SDK**
   - Visit [https://flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install)
   - Choose your operating system (Windows, macOS, or Linux)
   - Download the Flutter SDK

2. **Extract and Add to PATH**
   
   **Windows (PowerShell):**
   ```powershell
   # Extract to C:\src\flutter
   # Add to PATH (System Environment Variables)
   $env:Path += ";C:\src\flutter\bin"
   ```

   **macOS/Linux:**
   ```bash
   # Extract to ~/development/flutter
   export PATH="$PATH:~/development/flutter/bin"
   # Add to ~/.bashrc or ~/.zshrc for persistence
   ```

3. **Verify Installation**
   ```bash
   flutter doctor
   ```

### Step 2: Platform Setup

Choose the platform(s) you want to develop for:

#### Windows Development

1. **Install Visual Studio 2022**
   - Download from [visualstudio.microsoft.com](https://visualstudio.microsoft.com/)
   - Select "Desktop development with C++"
   - Install Windows 10 SDK

2. **Enable Developer Mode**
   - Settings > Update & Security > For developers
   - Enable "Developer Mode"

3. **Verify**
   ```bash
   flutter doctor
   # Should show ✓ for Windows toolchain
   ```

#### Android Development

1. **Install Android Studio**
   - Download from [developer.android.com](https://developer.android.com/studio)
   - Install Android SDK (API 33+)
   - Install Android SDK Command-line Tools

2. **Accept Licenses**
   ```bash
   flutter doctor --android-licenses
   ```

3. **Create Virtual Device**
   - Open Android Studio
   - Tools > Device Manager
   - Create Virtual Device (Pixel 5 recommended)

4. **Verify**
   ```bash
   flutter doctor
   # Should show ✓ for Android toolchain
   ```

#### iOS Development (macOS only)

1. **Install Xcode**
   - Install from Mac App Store (Xcode 14+)
   - Open Xcode and accept license
   ```bash
   sudo xcodebuild -license accept
   ```

2. **Install CocoaPods**
   ```bash
   sudo gem install cocoapods
   pod setup
   ```

3. **Install Xcode Command Line Tools**
   ```bash
   xcode-select --install
   ```

4. **Verify**
   ```bash
   flutter doctor
   # Should show ✓ for Xcode
   ```

### Step 3: Get the Project

```bash
# Clone or navigate to the project
cd d:\wordflow

# Get dependencies
flutter pub get
```

### Step 4: Run the App

#### Windows
```bash
flutter run -d windows
```

#### Android (Emulator)
```bash
# Start emulator
flutter emulators --launch <emulator_id>

# Run app
flutter run -d android
```

#### Android (Physical Device)
```bash
# Enable USB debugging on device
# Connect device via USB
flutter devices  # Verify device is detected
flutter run -d <device_id>
```

#### iOS (Simulator)
```bash
open -a Simulator
flutter run -d ios
```

#### iOS (Physical Device)
```bash
# Connect device
# Trust computer on device
flutter run -d <device_id>
```

## First Time Setup

When you first run the app:

1. **Grant Permissions**
   - Allow microphone access when prompted
   - Allow speech recognition access (iOS)

2. **Test Microphone**
   - Tap the microphone button
   - Speak: "Hello, this is a test"
   - Text should appear in real-time

3. **Explore Features**
   - Tap "Copy" to copy text
   - Tap "History" to see past transcriptions
   - Tap "Clear" to remove current text

## Common Issues

### Issue: "flutter: command not found"
**Solution:** Add Flutter to PATH
```bash
# Windows (PowerShell - Admin)
[System.Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\src\flutter\bin", "Machine")

# macOS/Linux
echo 'export PATH="$PATH:~/development/flutter/bin"' >> ~/.bashrc
source ~/.bashrc
```

### Issue: "No connected devices"
**Solution:**
- Windows: Check Windows developer mode is enabled
- Android: Enable USB debugging, check ADB connection
- iOS: Trust computer on device

### Issue: Android licenses not accepted
**Solution:**
```bash
flutter doctor --android-licenses
# Press 'y' to accept all licenses
```

### Issue: Microphone not working
**Solution:**
1. Check system microphone permissions
2. Grant app microphone permission
3. Restart the app
4. Check microphone is not used by another app

### Issue: iOS build fails
**Solution:**
```bash
cd ios
pod install
cd ..
flutter clean
flutter run -d ios
```

## Next Steps

- Read [ARCHITECTURE.md](ARCHITECTURE.md) to understand the project structure
- Read [DEVELOPMENT.md](DEVELOPMENT.md) for development guidelines
- Check [README.md](README.md) for feature documentation

## Getting Help

- Check Flutter documentation: [docs.flutter.dev](https://docs.flutter.dev)
- Review error messages carefully
- Run `flutter doctor -v` for detailed diagnostics
- Open an issue on GitHub if problems persist

## Quick Commands Reference

```bash
# Check Flutter installation
flutter doctor -v

# Get dependencies
flutter pub get

# Run app
flutter run

# Build release
flutter build apk          # Android
flutter build ios          # iOS
flutter build windows      # Windows

# Clean build cache
flutter clean

# Update dependencies
flutter pub upgrade

# Analyze code
flutter analyze

# Format code
dart format .

# Run tests
flutter test
```

## Development Workflow

1. **Make Changes**
   - Edit code in VS Code or Android Studio
   - Hot reload: Press `r` in terminal or save file (if using IDE)
   - Hot restart: Press `R` in terminal

2. **Test Changes**
   - Test on all target platforms
   - Run `flutter analyze` before committing

3. **Build Release**
   - Test release build before distribution
   - Follow platform-specific release guidelines

Happy coding! 🚀

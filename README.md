# WordFlow

A cross-platform speech-to-text application for Windows, Android, and iOS.

## Features

- 🎤 **Real-time Speech Recognition** - Continuous listening and transcription
- 📝 **English Language Support** - Optimized for English speech recognition
- 📋 **Universal Clipboard** - Copy transcribed text with one tap
- 💾 **History** - Access your previous transcriptions
- 🌙 **Dark Mode** - Automatic theme switching
- 🔒 **Privacy-Focused** - On-device recognition (no data sent to cloud by default)

## Screenshots

_Coming soon..._

## Installation

### Prerequisites

- Flutter SDK (3.2.0 or higher)
- For Android: Android Studio with SDK
- For iOS: Xcode 14 or higher
- For Windows: Visual Studio 2022 with C++ tools

### Setup

1. Clone the repository:
```bash
git clone https://github.com/yourusername/wordflow.git
cd wordflow
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run on your desired platform:

```bash
# Android
flutter run -d android

# iOS
flutter run -d ios

# Windows
flutter run -d windows
```

## Platform-Specific Setup

### Android

The app requires the following permissions:
- Microphone access (for audio recording)
- Internet access (for cloud-based recognition, if enabled)

These are automatically requested when you first use the app.

### iOS

The app requires:
- Microphone usage permission
- Speech recognition permission

These are automatically requested on first use.

### Windows

Microphone access is handled through Windows system permissions. You may need to enable microphone access in Windows Settings > Privacy > Microphone.

## Usage

1. **Start Recording**: Tap the microphone button to start listening
2. **Speak**: Speak clearly in English
3. **Stop Recording**: Tap the microphone button again to stop
4. **Copy Text**: Tap the "Copy" button to copy text to clipboard
5. **Clear**: Tap "Clear" to remove current transcription
6. **View History**: Tap "History" to see previous transcriptions

## Architecture

This app is built using:

- **Flutter** - Cross-platform UI framework
- **speech_to_text** package - For native speech recognition
- **Provider** - State management
- **Hive** - Local data storage

For detailed architecture information, see [ARCHITECTURE.md](ARCHITECTURE.md).

## Development

### Project Structure

```
lib/
├── main.dart                           # App entry point
├── core/
│   └── services/                       # Core business logic
│       ├── speech_recognition_service.dart
│       ├── transcription_manager.dart
│       └── clipboard_manager.dart
├── features/
│   └── home/                          # Home screen
│       └── home_screen.dart
├── platform/                          # Platform-specific implementations
│   ├── speech_recognition_factory.dart
│   └── default/
│       └── default_speech_recognition.dart
└── widgets/                           # Reusable UI components
    ├── transcription_display.dart
    ├── microphone_button.dart
    └── action_buttons.dart
```

### Building for Release

#### Android APK
```bash
flutter build apk --release
```

#### iOS
```bash
flutter build ios --release
```

#### Windows
```bash
flutter build windows --release
```

## Troubleshooting

### Microphone Permission Denied
- **Android**: Go to Settings > Apps > WordFlow > Permissions and enable Microphone
- **iOS**: Go to Settings > WordFlow > Microphone and enable it
- **Windows**: Go to Settings > Privacy > Microphone and enable for desktop apps

### Speech Recognition Not Working
1. Ensure you have an active internet connection (for cloud-based recognition)
2. Check that your microphone is properly connected
3. Verify that you've granted microphone permissions
4. Try restarting the app

### App Crashes on Startup
1. Clear app data/cache
2. Reinstall the app
3. Check that your OS version is supported

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## Roadmap

- [ ] Support for more languages (Spanish, French, German, etc.)
- [ ] Offline mode with downloadable language models
- [ ] Text editing and formatting tools
- [ ] Export to various formats (PDF, TXT, DOCX)
- [ ] Voice commands for punctuation
- [ ] Custom vocabulary/dictionary
- [ ] Cloud sync for history
- [ ] macOS and Linux support
- [ ] Web version

## Privacy Policy

WordFlow respects your privacy. By default, all speech recognition is performed on your device. We do not collect, store, or transmit your voice recordings or transcriptions to any external servers.

If you enable cloud-based recognition features, your voice data will be sent to the respective service provider (Google, Apple, etc.) according to their privacy policies.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [speech_to_text](https://pub.dev/packages/speech_to_text) package by Baha-Razzaq
- Flutter team for the amazing framework
- All contributors who help improve this project

## Support

If you find this project helpful, please give it a ⭐️ on GitHub!

For issues and feature requests, please use the [GitHub Issues](https://github.com/yourusername/wordflow/issues) page.

---

Made with ❤️ using Flutter

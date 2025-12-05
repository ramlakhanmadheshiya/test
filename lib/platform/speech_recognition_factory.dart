import 'dart:io';
import 'package:flutter/foundation.dart';
import '../core/services/speech_recognition_service.dart';
import 'default/default_speech_recognition.dart';

// Platform-specific imports will be added later
// import 'windows/windows_speech_recognition.dart';
// import 'android/android_speech_recognition.dart';
// import 'ios/ios_speech_recognition.dart';

/// Factory to create platform-specific speech recognition service
class SpeechRecognitionFactory {
  static SpeechRecognitionService create() {
    // For now, we'll use the default implementation
    // which uses the speech_to_text package (works across all platforms)
    return DefaultSpeechRecognition();

    // Platform-specific implementations can be enabled later:
    /*
    if (kIsWeb) {
      throw UnsupportedError('Web platform is not supported yet');
    }

    if (Platform.isWindows) {
      return WindowsSpeechRecognition();
    } else if (Platform.isAndroid) {
      return AndroidSpeechRecognition();
    } else if (Platform.isIOS || Platform.isMacOS) {
      return IOSSpeechRecognition();
    } else {
      return DefaultSpeechRecognition();
    }
    */
  }
}

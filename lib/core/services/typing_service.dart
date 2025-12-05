import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TypingMode {
  appOnly,        // Transcribe in app only
  realTimeTyping, // Type to active window in real-time
  both,           // Both in-app and real-time typing
}

class TypingService extends ChangeNotifier {
  static const MethodChannel _channel = MethodChannel('com.wordflow/typing');
  TypingMode _typingMode = TypingMode.appOnly;
  bool _isPlatformSupported = false;
  
  static const String _modePrefsKey = 'typing_mode';

  TypingMode get typingMode => _typingMode;
  bool get isPlatformSupported => _isPlatformSupported;
  bool get isRealTimeEnabled => 
      _typingMode == TypingMode.realTimeTyping || _typingMode == TypingMode.both;

  Future<void> initialize() async {
    // Check platform support
    _isPlatformSupported = !kIsWeb && (defaultTargetPlatform == TargetPlatform.windows);
    
    if (_isPlatformSupported) {
      try {
        final result = await _channel.invokeMethod('checkSupport');
        _isPlatformSupported = result as bool? ?? false;
      } catch (e) {
        debugPrint('Platform channel not available: $e');
        _isPlatformSupported = false;
      }
    }

    // Load saved typing mode
    await _loadTypingMode();
    
    debugPrint('TypingService initialized. Platform supported: $_isPlatformSupported');
  }

  Future<void> _loadTypingMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final modeIndex = prefs.getInt(_modePrefsKey);
      if (modeIndex != null && modeIndex < TypingMode.values.length) {
        _typingMode = TypingMode.values[modeIndex];
      }
    } catch (e) {
      debugPrint('Error loading typing mode: $e');
    }
  }

  Future<void> setTypingMode(TypingMode mode) async {
    _typingMode = mode;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_modePrefsKey, mode.index);
    } catch (e) {
      debugPrint('Error saving typing mode: $e');
    }
  }

  /// Type text to the active window (Windows only)
  Future<bool> typeToActiveWindow(String text) async {
    if (!_isPlatformSupported || !isRealTimeEnabled) {
      return false;
    }

    try {
      final result = await _channel.invokeMethod('typeText', {'text': text});
      return result as bool? ?? false;
    } catch (e) {
      debugPrint('Error typing to active window: $e');
      return false;
    }
  }

  /// Type a single character to the active window (for real-time streaming)
  Future<bool> typeCharacter(String char) async {
    if (!_isPlatformSupported || !isRealTimeEnabled || char.isEmpty) {
      return false;
    }

    try {
      final result = await _channel.invokeMethod('typeChar', {'char': char});
      return result as bool? ?? false;
    } catch (e) {
      debugPrint('Error typing character: $e');
      return false;
    }
  }

  /// Simulate backspace key (for corrections)
  Future<bool> backspace({int count = 1}) async {
    if (!_isPlatformSupported || !isRealTimeEnabled) {
      return false;
    }

    try {
      final result = await _channel.invokeMethod('backspace', {'count': count});
      return result as bool? ?? false;
    } catch (e) {
      debugPrint('Error sending backspace: $e');
      return false;
    }
  }

  String getTypingModeDescription(TypingMode mode) {
    switch (mode) {
      case TypingMode.appOnly:
        return 'Transcribe in app only';
      case TypingMode.realTimeTyping:
        return 'Type to active window in real-time';
      case TypingMode.both:
        return 'Both in-app and real-time typing';
    }
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum HotkeyBehavior {
  toggle,        // Press once to start, press again to stop
  holdToSpeak,   // Press and hold to record, release to stop
  pushToTalk,    // Single press starts, auto-stops after silence
}

class HotkeyService extends ChangeNotifier {
  HotKey? _currentHotkey;
  VoidCallback? _onHotkeyPressed;
  VoidCallback? _onHotkeyReleased;
  bool _isHotkeyPressed = false;
  bool _isListeningActive = false;  // Track if listening is currently active
  HotkeyBehavior _hotkeyBehavior = HotkeyBehavior.holdToSpeak;

  static const String _hotkeyPrefsKey = 'custom_hotkey';
  static const String _behaviorPrefsKey = 'hotkey_behavior';
  
  // Default hotkey: Win + Shift + W
  static final HotKey _defaultHotkey = HotKey(
    key: PhysicalKeyboardKey.keyW,
    modifiers: [HotKeyModifier.shift, HotKeyModifier.meta],
    scope: HotKeyScope.system,
  );

  bool get isHotkeyPressed => _isHotkeyPressed;
  HotKey get currentHotkey => _currentHotkey ?? _defaultHotkey;
  KeyboardKey get currentKey => currentHotkey.key;
  List<HotKeyModifier> get currentModifiers => currentHotkey.modifiers ?? [];
  HotkeyBehavior get hotkeyBehavior => _hotkeyBehavior;

  Future<void> initialize({
    required VoidCallback onPressed,
    required VoidCallback onReleased,
  }) async {
    _onHotkeyPressed = onPressed;
    _onHotkeyReleased = onReleased;

    // Load saved hotkey or use default
    await _loadSavedHotkey();
    await _loadHotkeyBehavior();
    await _registerHotkey();
  }

  Future<void> _loadHotkeyBehavior() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final behaviorIndex = prefs.getInt(_behaviorPrefsKey);
      if (behaviorIndex != null && behaviorIndex < HotkeyBehavior.values.length) {
        _hotkeyBehavior = HotkeyBehavior.values[behaviorIndex];
      }
    } catch (e) {
      debugPrint('Error loading hotkey behavior: $e');
    }
  }

  Future<void> setHotkeyBehavior(HotkeyBehavior behavior) async {
    _hotkeyBehavior = behavior;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_behaviorPrefsKey, behavior.index);
    } catch (e) {
      debugPrint('Error saving hotkey behavior: $e');
    }
  }

  Future<void> _loadSavedHotkey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedHotkey = prefs.getString(_hotkeyPrefsKey);
      
      if (savedHotkey != null) {
        // Parse saved hotkey (format: "key:modifiers" or "name:keyName:modifiers")
        final parts = savedHotkey.split(':');
        if (parts.length >= 2) {
          final modifiersList = parts.last.split(',').where((m) => m.isNotEmpty).toList();
          final modifiers = modifiersList.map((m) {
            switch (m) {
              case 'shift':
                return HotKeyModifier.shift;
              case 'control':
                return HotKeyModifier.control;
              case 'alt':
                return HotKeyModifier.alt;
              case 'meta':
                return HotKeyModifier.meta;
              default:
                return null;
            }
          }).whereType<HotKeyModifier>().toList();

          PhysicalKeyboardKey? key;
          
          if (parts[0] == 'name' && parts.length == 3) {
            // New format: name:keyName:modifiers
            final keyName = parts[1];
            // Try to find the key by name
            // For common keys, map them manually
            final keyMap = {
              'Key W': PhysicalKeyboardKey.keyW,
              'Key R': PhysicalKeyboardKey.keyR,
              'Key A': PhysicalKeyboardKey.keyA,
              'Key S': PhysicalKeyboardKey.keyS,
              'Key D': PhysicalKeyboardKey.keyD,
              'Key F': PhysicalKeyboardKey.keyF,
              // Add more as needed
            };
            key = keyMap[keyName];
          } else {
            // Old format: keyCode:modifiers
            final keyCode = int.tryParse(parts[0]);
            if (keyCode != null) {
              key = PhysicalKeyboardKey.findKeyByCode(keyCode);
            }
          }
          
          if (key != null) {
            _currentHotkey = HotKey(
              key: key,
              modifiers: modifiers,
              scope: HotKeyScope.system,
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading hotkey: $e');
    }

    _currentHotkey ??= _defaultHotkey;
  }

  Future<void> _registerHotkey() async {
    try {
      // Check if platform supports hotkeys
      if (kIsWeb) {
        debugPrint('Hotkeys are not supported on web platform');
        return;
      }

      // Unregister previous hotkey if exists
      if (_currentHotkey != null) {
        try {
          await hotKeyManager.unregister(_currentHotkey!);
        } catch (e) {
          debugPrint('Error unregistering hotkey: $e');
        }
      }

      // Register new hotkey
      await hotKeyManager.register(
        _currentHotkey!,
        keyDownHandler: (hotKey) {
          debugPrint('Hotkey pressed: ${_currentHotkey!.key.keyLabel}');
          _isHotkeyPressed = true;
          _handleHotkeyPress();
          notifyListeners();
        },
        keyUpHandler: (hotKey) {
          debugPrint('Hotkey released: ${_currentHotkey!.key.keyLabel}');
          _isHotkeyPressed = false;
          _handleHotkeyRelease();
          notifyListeners();
        },
      );
      
      debugPrint('Hotkey registered successfully: ${getHotkeyDisplayString()}');
    } catch (e) {
      debugPrint('Error registering hotkey: $e');
    }
  }

  void _handleHotkeyPress() {
    switch (_hotkeyBehavior) {
      case HotkeyBehavior.toggle:
        // Toggle mode: press once to start/stop
        if (_isListeningActive) {
          _isListeningActive = false;
          _onHotkeyReleased?.call();
        } else {
          _isListeningActive = true;
          _onHotkeyPressed?.call();
        }
        break;
      
      case HotkeyBehavior.holdToSpeak:
        // Hold to speak: start listening on press
        _isListeningActive = true;
        _onHotkeyPressed?.call();
        break;
      
      case HotkeyBehavior.pushToTalk:
        // Push to talk: single press starts, will auto-stop after silence
        if (!_isListeningActive) {
          _isListeningActive = true;
          _onHotkeyPressed?.call();
        }
        break;
    }
  }

  void _handleHotkeyRelease() {
    switch (_hotkeyBehavior) {
      case HotkeyBehavior.toggle:
        // Do nothing on release in toggle mode
        break;
      
      case HotkeyBehavior.holdToSpeak:
        // Hold to speak: stop listening on release
        _isListeningActive = false;
        _onHotkeyReleased?.call();
        break;
      
      case HotkeyBehavior.pushToTalk:
        // Do nothing on release in push-to-talk mode (will auto-stop)
        break;
    }
  }

  // Call this when transcription stops (for push-to-talk mode)
  void notifyListeningStopped() {
    _isListeningActive = false;
    notifyListeners();
  }

  Future<bool> updateHotkey({
    required PhysicalKeyboardKey key,
    required List<HotKeyModifier> modifiers,
  }) async {
    try {
      // Unregister old hotkey
      if (_currentHotkey != null) {
        await hotKeyManager.unregister(_currentHotkey!);
      }

      // Create new hotkey
      _currentHotkey = HotKey(
        key: key,
        modifiers: modifiers,
        scope: HotKeyScope.system,
      );

      // Save to preferences
      final prefs = await SharedPreferences.getInstance();
      final modifierStrings = modifiers.map((m) {
        switch (m) {
          case HotKeyModifier.shift:
            return 'shift';
          case HotKeyModifier.control:
            return 'control';
          case HotKeyModifier.alt:
            return 'alt';
          case HotKeyModifier.meta:
            return 'meta';
          default:
            return '';
        }
      }).join(',');
      
      // Use the USB HID code to save the key, or use debugName as fallback
      int? keyCode;
      try {
        keyCode = key.usbHidUsage;
      } catch (e) {
        debugPrint('Error getting usbHidUsage: $e');
      }
      
      if (keyCode == null || keyCode == 0) {
        // Fallback: save the key's debugName
        final keyName = key.debugName ?? 'unknown';
        await prefs.setString(_hotkeyPrefsKey, 'name:$keyName:$modifierStrings');
        debugPrint('Saved hotkey using debugName: $keyName');
      } else {
        await prefs.setString(_hotkeyPrefsKey, '$keyCode:$modifierStrings');
        debugPrint('Saved hotkey using keyCode: $keyCode');
      }

      // Register new hotkey
      await _registerHotkey();
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error updating hotkey: $e');
      return false;
    }
  }

  Future<void> dispose() async {
    if (_currentHotkey != null) {
      await hotKeyManager.unregister(_currentHotkey!);
    }
    super.dispose();
  }

  String getHotkeyDisplayString() {
    if (_currentHotkey == null) return 'Not set';
    
    final modifiers = _currentHotkey!.modifiers?.map((m) {
      switch (m) {
        case HotKeyModifier.shift:
          return 'Shift';
        case HotKeyModifier.control:
          return 'Ctrl';
        case HotKeyModifier.alt:
          return 'Alt';
        case HotKeyModifier.meta:
          return 'Win';
        default:
          return '';
      }
    }).where((s) => s.isNotEmpty).join(' + ') ?? '';

    final keyName = _currentHotkey!.key.keyLabel.toUpperCase();
    
    return modifiers.isNotEmpty ? '$modifiers + $keyName' : keyName;
  }
}

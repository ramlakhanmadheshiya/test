# Windows Platform Channel Implementation

This document describes how to implement the real-time typing feature for Windows.

## Method Channel

Channel name: `com.wordflow/typing`

## Methods

### 1. checkSupport
Checks if the platform supports real-time typing.

**Returns**: `bool` - true if supported

### 2. typeText
Types a complete string to the active window.

**Parameters**:
- `text` (String): The text to type

**Returns**: `bool` - true if successful

### 3. typeChar
Types a single character to the active window.

**Parameters**:
- `char` (String): Single character to type

**Returns**: `bool` - true if successful

### 4. backspace
Simulates backspace key press(es).

**Parameters**:
- `count` (int): Number of backspaces to send

**Returns**: `bool` - true if successful

## Windows Implementation

Add this to `windows/runner/flutter_window.cpp`:

```cpp
#include <windows.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

// Add typing channel implementation
void RegisterTypingChannel(flutter::PluginRegistrar* registrar) {
  const static std::string channel_name("com.wordflow/typing");
  auto channel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      registrar->messenger(), channel_name,
      &flutter::StandardMethodCodec::GetInstance());

  channel->SetMethodCallHandler(
      [](const flutter::MethodCall<flutter::EncodableValue>& call,
         std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        
        if (call.method_name().compare("checkSupport") == 0) {
          result->Success(flutter::EncodableValue(true));
        }
        else if (call.method_name().compare("typeText") == 0) {
          const auto* arguments = std::get_if<flutter::EncodableMap>(call.arguments());
          if (arguments) {
            auto text_it = arguments->find(flutter::EncodableValue("text"));
            if (text_it != arguments->end()) {
              std::string text = std::get<std::string>(text_it->second);
              
              // Convert to wide string for Windows
              int size_needed = MultiByteToWideChar(CP_UTF8, 0, text.c_str(), (int)text.length(), NULL, 0);
              std::wstring wtext(size_needed, 0);
              MultiByteToWideChar(CP_UTF8, 0, text.c_str(), (int)text.length(), &wtext[0], size_needed);
              
              // Type each character
              for (wchar_t ch : wtext) {
                INPUT input = {0};
                input.type = INPUT_KEYBOARD;
                input.ki.wVk = 0;
                input.ki.wScan = ch;
                input.ki.dwFlags = KEYEVENTF_UNICODE;
                SendInput(1, &input, sizeof(INPUT));
                
                // Key up
                input.ki.dwFlags = KEYEVENTF_UNICODE | KEYEVENTF_KEYUP;
                SendInput(1, &input, sizeof(INPUT));
                
                Sleep(5); // Small delay between characters
              }
              
              result->Success(flutter::EncodableValue(true));
              return;
            }
          }
          result->Error("INVALID_ARGUMENT", "Text parameter required");
        }
        else if (call.method_name().compare("typeChar") == 0) {
          const auto* arguments = std::get_if<flutter::EncodableMap>(call.arguments());
          if (arguments) {
            auto char_it = arguments->find(flutter::EncodableValue("char"));
            if (char_it != arguments->end()) {
              std::string char_str = std::get<std::string>(char_it->second);
              if (!char_str.empty()) {
                // Convert to wide char
                int size_needed = MultiByteToWideChar(CP_UTF8, 0, char_str.c_str(), (int)char_str.length(), NULL, 0);
                std::wstring wchar(size_needed, 0);
                MultiByteToWideChar(CP_UTF8, 0, char_str.c_str(), (int)char_str.length(), &wchar[0], size_needed);
                
                if (!wchar.empty()) {
                  INPUT input = {0};
                  input.type = INPUT_KEYBOARD;
                  input.ki.wVk = 0;
                  input.ki.wScan = wchar[0];
                  input.ki.dwFlags = KEYEVENTF_UNICODE;
                  SendInput(1, &input, sizeof(INPUT));
                  
                  input.ki.dwFlags = KEYEVENTF_UNICODE | KEYEVENTF_KEYUP;
                  SendInput(1, &input, sizeof(INPUT));
                  
                  result->Success(flutter::EncodableValue(true));
                  return;
                }
              }
            }
          }
          result->Error("INVALID_ARGUMENT", "Char parameter required");
        }
        else if (call.method_name().compare("backspace") == 0) {
          const auto* arguments = std::get_if<flutter::EncodableMap>(call.arguments());
          int count = 1;
          if (arguments) {
            auto count_it = arguments->find(flutter::EncodableValue("count"));
            if (count_it != arguments->end()) {
              count = std::get<int>(count_it->second);
            }
          }
          
          for (int i = 0; i < count; i++) {
            INPUT input = {0};
            input.type = INPUT_KEYBOARD;
            input.ki.wVk = VK_BACK;
            SendInput(1, &input, sizeof(INPUT));
            
            input.ki.dwFlags = KEYEVENTF_KEYUP;
            SendInput(1, &input, sizeof(INPUT));
            
            Sleep(5);
          }
          
          result->Success(flutter::EncodableValue(true));
        }
        else {
          result->NotImplemented();
        }
      });
}
```

Then call `RegisterTypingChannel(registrar)` in your plugin registration code.

## Usage in Dart

```dart
final typingService = context.read<TypingService>();

// Type complete text
await typingService.typeToActiveWindow('Hello, world!');

// Type single character (for real-time)
await typingService.typeCharacter('a');

// Backspace
await typingService.backspace(count: 5);
```

## Future Enhancements

1. Add support for special keys (Enter, Tab, etc.)
2. Add cursor position detection
3. Add window focus management
4. Add clipboard integration
5. Add typing speed control

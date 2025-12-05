#include "typing_channel.h"

#include <windows.h>
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>
#include <memory>
#include <string>

void RegisterTypingChannel(flutter::PluginRegistrarWindows* registrar) {
  const static std::string channel_name("com.wordflow/typing");
  
  auto channel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      registrar->messenger(), channel_name,
      &flutter::StandardMethodCodec::GetInstance());

  channel->SetMethodCallHandler(
      [](const flutter::MethodCall<flutter::EncodableValue>& call,
         std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        
        if (call.method_name() == "checkSupport") {
          // Always supported on Windows
          result->Success(flutter::EncodableValue(true));
        }
        else if (call.method_name() == "typeText") {
          const auto* arguments = std::get_if<flutter::EncodableMap>(call.arguments());
          if (arguments) {
            auto text_it = arguments->find(flutter::EncodableValue("text"));
            if (text_it != arguments->end()) {
              std::string text = std::get<std::string>(text_it->second);
              
              // Convert UTF-8 to wide string for Windows
              int size_needed = MultiByteToWideChar(CP_UTF8, 0, text.c_str(), (int)text.length(), NULL, 0);
              std::wstring wtext(size_needed, 0);
              MultiByteToWideChar(CP_UTF8, 0, text.c_str(), (int)text.length(), &wtext[0], size_needed);
              
              // Type each character using Unicode input
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
                
                Sleep(3); // Small delay for reliability
              }
              
              result->Success(flutter::EncodableValue(true));
              return;
            }
          }
          result->Error("INVALID_ARGUMENT", "Text parameter required");
        }
        else if (call.method_name() == "typeChar") {
          const auto* arguments = std::get_if<flutter::EncodableMap>(call.arguments());
          if (arguments) {
            auto char_it = arguments->find(flutter::EncodableValue("char"));
            if (char_it != arguments->end()) {
              std::string char_str = std::get<std::string>(char_it->second);
              if (!char_str.empty()) {
                // Convert UTF-8 to wide char
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
                  
                  // Key up
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
        else if (call.method_name() == "backspace") {
          const auto* arguments = std::get_if<flutter::EncodableMap>(call.arguments());
          int count = 1;
          if (arguments) {
            auto count_it = arguments->find(flutter::EncodableValue("count"));
            if (count_it != arguments->end()) {
              count = std::get<int>(count_it->second);
            }
          }
          
          // Send backspace key presses
          for (int i = 0; i < count; i++) {
            INPUT input = {0};
            input.type = INPUT_KEYBOARD;
            input.ki.wVk = VK_BACK;
            input.ki.dwFlags = 0;
            SendInput(1, &input, sizeof(INPUT));
            
            // Key up
            input.ki.dwFlags = KEYEVENTF_KEYUP;
            SendInput(1, &input, sizeof(INPUT));
            
            Sleep(3);
          }
          
          result->Success(flutter::EncodableValue(true));
        }
        else {
          result->NotImplemented();
        }
      });
}

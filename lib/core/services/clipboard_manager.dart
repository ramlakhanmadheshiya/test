import 'package:flutter/services.dart';
import 'package:clipboard/clipboard.dart';

/// Manages clipboard operations across platforms
class ClipboardManager {
  /// Copy text to clipboard
  Future<bool> copyToClipboard(String text) async {
    try {
      await FlutterClipboard.copy(text);
      return true;
    } catch (e) {
      // Fallback to Flutter's clipboard
      try {
        await Clipboard.setData(ClipboardData(text: text));
        return true;
      } catch (e) {
        return false;
      }
    }
  }

  /// Get text from clipboard
  Future<String?> getFromClipboard() async {
    try {
      return await FlutterClipboard.paste();
    } catch (e) {
      // Fallback to Flutter's clipboard
      try {
        final data = await Clipboard.getData(Clipboard.kTextPlain);
        return data?.text;
      } catch (e) {
        return null;
      }
    }
  }

  /// Check if clipboard has text
  Future<bool> hasText() async {
    try {
      final text = await getFromClipboard();
      return text != null && text.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}

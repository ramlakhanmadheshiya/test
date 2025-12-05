import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'speech_recognition_service.dart';
import 'grammar_service.dart';
import 'typing_service.dart';
import 'clipboard_manager.dart';
import '../models/transcription_item.dart';

/// Manages transcription state, buffering, and formatting
class TranscriptionManager extends ChangeNotifier {
  final SpeechRecognitionService speechService;
  final GrammarService grammarService = GrammarService();
  TypingService? _typingService;
  ClipboardManager? _clipboardManager;
  
  Box<TranscriptionItem>? _historyBox;
  
  // Current transcription text
  String _currentText = '';
  
  // Buffer for partial results
  String _partialText = '';
  
  // Track if text is being manually edited
  bool _isEditing = false;
  bool get isEditing => _isEditing;
  
  // Combined text for display
  String get currentText {
    if (_partialText.isEmpty) {
      return _currentText;
    }
    if (_currentText.isEmpty) {
      return _partialText;
    }
    return '$_currentText $_partialText';
  }

  // Allow manual text editing
  void updateCurrentText(String text) {
    _currentText = text;
    _isEditing = true;
    notifyListeners();
  }

  // History of transcriptions
  List<TranscriptionItem> get history {
    if (_historyBox == null) return [];
    return _historyBox!.values.toList().reversed.toList();
  }

  // Listening state
  bool _isListening = false;
  bool get isListening => _isListening;

  // Error state
  String? _lastError;
  String? get lastError => _lastError;

  // Settings
  String _languageCode = 'en-US';
  String get languageCode => _languageCode;

  bool _autoCopy = false;
  bool get autoCopy => _autoCopy;

  bool _autoPunctuation = true;
  bool get autoPunctuation => _autoPunctuation;

  StreamSubscription<TranscriptionResult>? _transcriptionSubscription;

  TranscriptionManager({required this.speechService});

  /// Initialize Hive boxes and set typing service
  Future<void> initialize({
    TypingService? typingService,
    ClipboardManager? clipboardManager,
  }) async {
    _historyBox = await Hive.openBox<TranscriptionItem>('transcription_history');
    _typingService = typingService;
    _clipboardManager = clipboardManager;
  }

  /// Start listening and transcribing
  Future<void> startListening() async {
    if (_isListening) return;

    try {
      _lastError = null;
      
      // Clear previous transcription when starting fresh
      _currentText = '';
      _partialText = '';
      _isEditing = false;
      
      final available = await speechService.isAvailable();
      
      if (!available) {
        _lastError = 'Speech recognition is not available';
        notifyListeners();
        return;
      }

      final initialized = await speechService.initialize();
      if (!initialized) {
        _lastError = 'Failed to initialize speech recognition';
        notifyListeners();
        return;
      }

      _isListening = true;
      notifyListeners();

      final stream = speechService.startListening(
        languageCode: _languageCode,
        partialResults: true,
      );

      _transcriptionSubscription = stream.listen(
        _onTranscriptionResult,
        onError: _onTranscriptionError,
        onDone: _onTranscriptionDone,
      );
    } catch (e) {
      _lastError = 'Error starting speech recognition: $e';
      _isListening = false;
      notifyListeners();
    }
  }

  /// Stop listening
  Future<void> stopListening() async {
    if (!_isListening) return;

    try {
      await _transcriptionSubscription?.cancel();
      await speechService.stopListening();
      
      // Merge partial text if exists
      if (_partialText.isNotEmpty) {
        if (_currentText.isEmpty) {
          _currentText = _partialText;
        } else {
          _currentText += ' $_partialText';
        }
        _partialText = '';
      }
      
      // Save to history if there's text
      if (_currentText.trim().isNotEmpty) {
        final correctedText = grammarService.correctPunctuation(_currentText);
        _currentText = correctedText;
        
        // Auto-copy to clipboard if enabled
        if (_autoCopy && _clipboardManager != null) {
          await _clipboardManager!.copyToClipboard(correctedText);
        }
        
        final item = TranscriptionItem.create(correctedText);
        await _historyBox?.add(item);
        
        // Keep only last 100 entries
        if (_historyBox != null && _historyBox!.length > 100) {
          await _historyBox!.deleteAt(0);
        }
      }
      
      _isListening = false;
      notifyListeners();
    } catch (e) {
      _lastError = 'Error stopping speech recognition: $e';
      notifyListeners();
    }
  }

  /// Clear current transcription
  void clearText() {
    _currentText = '';
    _partialText = '';
    _isEditing = false;
    notifyListeners();
  }

  /// Update a history item
  Future<void> updateHistoryItem(int index, String newText) async {
    if (_historyBox == null || index < 0 || index >= _historyBox!.length) return;
    
    final item = _historyBox!.getAt(index);
    if (item != null) {
      item.text = newText;
      await item.save();
      notifyListeners();
    }
  }

  /// Delete a history item
  Future<void> deleteHistoryItem(int index) async {
    if (_historyBox == null || index < 0 || index >= _historyBox!.length) return;
    await _historyBox!.deleteAt(index);
    notifyListeners();
  }

  /// Set language code
  void setLanguageCode(String code) {
    _languageCode = code;
    notifyListeners();
  }

  /// Toggle auto-copy
  void setAutoCopy(bool value) {
    _autoCopy = value;
    notifyListeners();
  }

  /// Toggle auto-punctuation
  void setAutoPunctuation(bool value) {
    _autoPunctuation = value;
    notifyListeners();
  }

  /// Handle transcription results
  void _onTranscriptionResult(TranscriptionResult result) async {
    if (result.isFinal) {
      // Final result - append to current text with grammar correction
      String newText = grammarService.processTranscription(result.text, isFinal: true);
      
      String textToAdd = newText;
      if (_currentText.isEmpty) {
        _currentText = newText;
      } else {
        // Smart concatenation - check if we need punctuation
        String separator = ' ';
        if (_currentText.trim().isNotEmpty && 
            !_currentText.trim().endsWith('.') && 
            !_currentText.trim().endsWith('!') && 
            !_currentText.trim().endsWith('?') &&
            !_currentText.trim().endsWith(':')) {
          // Add period before continuing if the previous sentence was complete
          if (newText.trim().isNotEmpty && 
              newText.trim()[0] == newText.trim()[0].toUpperCase()) {
            separator = '. ';
          }
        }
        textToAdd = separator + newText;
        _currentText += textToAdd;
      }
      
      // Type to active window if real-time typing is enabled (only for final results)
      if (_typingService != null && _typingService!.isRealTimeEnabled) {
        await _typingService!.typeToActiveWindow(textToAdd);
      }
      
      // Clear partial text after final result
      _partialText = '';
    } else {
      // Partial result - store separately for preview (don't type these)
      _partialText = grammarService.processTranscription(result.text, isFinal: false);
    }
    
    notifyListeners();
  }

  /// Handle transcription errors
  void _onTranscriptionError(dynamic error) {
    _lastError = 'Transcription error: $error';
    _isListening = false;
    notifyListeners();
  }

  /// Handle transcription stream completion
  void _onTranscriptionDone() {
    _isListening = false;
    notifyListeners();
  }

  /// Apply basic punctuation rules
  String _applyPunctuation(String text) {
    if (text.isEmpty) return text;

    String result = text;

    // Capitalize first letter
    if (result.isNotEmpty) {
      result = result[0].toUpperCase() + result.substring(1);
    }

    // Add period at the end if not present
    if (!result.endsWith('.') && !result.endsWith('!') && !result.endsWith('?')) {
      result += '.';
    }

    // Replace common voice commands with punctuation
    result = result
        .replaceAll(RegExp(r'\bperiod\b', caseSensitive: false), '.')
        .replaceAll(RegExp(r'\bquestion mark\b', caseSensitive: false), '?')
        .replaceAll(RegExp(r'\bexclamation mark\b', caseSensitive: false), '!')
        .replaceAll(RegExp(r'\bcomma\b', caseSensitive: false), ',')
        .replaceAll(RegExp(r'\bnew line\b', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'\bnew paragraph\b', caseSensitive: false), '\n\n');

    return result;
  }

  @override
  void dispose() {
    _transcriptionSubscription?.cancel();
    speechService.dispose();
    super.dispose();
  }
}

/// Abstract interface for speech recognition services across platforms
abstract class SpeechRecognitionService {
  /// Initialize the speech recognition service
  /// Returns true if initialization was successful
  Future<bool> initialize();

  /// Check if speech recognition is available on this device
  Future<bool> isAvailable();

  /// Start listening for speech input
  /// Returns a stream of transcription results
  /// [languageCode] - Language code (default: 'en-US')
  /// [partialResults] - Whether to return partial (interim) results
  Stream<TranscriptionResult> startListening({
    String languageCode = 'en-US',
    bool partialResults = true,
  });

  /// Stop listening for speech input
  Future<void> stopListening();

  /// Cancel current listening session
  Future<void> cancel();

  /// Get list of available languages for recognition
  Future<List<String>> getAvailableLanguages();

  /// Get current listening state
  bool get isListening;

  /// Dispose resources
  void dispose();
}

/// Result from speech recognition
class TranscriptionResult {
  /// The recognized text
  final String text;

  /// Whether this is a final result (true) or partial/interim (false)
  final bool isFinal;

  /// Confidence score (0.0 to 1.0), if available
  final double? confidence;

  /// Timestamp when the result was created
  final DateTime timestamp;

  TranscriptionResult({
    required this.text,
    required this.isFinal,
    this.confidence,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() {
    return 'TranscriptionResult(text: "$text", isFinal: $isFinal, confidence: $confidence)';
  }
}

/// Exception thrown when speech recognition encounters an error
class SpeechRecognitionException implements Exception {
  final String message;
  final String? code;

  SpeechRecognitionException(this.message, {this.code});

  @override
  String toString() => 'SpeechRecognitionException: $message${code != null ? ' (code: $code)' : ''}';
}

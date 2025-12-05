import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../core/services/speech_recognition_service.dart';

/// Default cross-platform speech recognition using speech_to_text package
/// Works on Android, iOS, and Windows
class DefaultSpeechRecognition implements SpeechRecognitionService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  StreamController<TranscriptionResult>? _controller;

  @override
  bool get isListening => _isListening;

  @override
  Future<bool> initialize() async {
    try {
      return await _speech.initialize(
        onError: (error) {
          _handleError(error);
        },
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            _isListening = false;
            _controller?.close();
          }
        },
      );
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> isAvailable() async {
    return await _speech.initialize();
  }

  @override
  Stream<TranscriptionResult> startListening({
    String languageCode = 'en-US',
    bool partialResults = true,
  }) {
    _controller = StreamController<TranscriptionResult>.broadcast();
    _isListening = true;

    _speech.listen(
      onResult: (result) {
        final transcription = TranscriptionResult(
          text: result.recognizedWords,
          isFinal: result.finalResult,
          confidence: result.hasConfidenceRating ? result.confidence : null,
        );
        _controller?.add(transcription);
      },
      localeId: languageCode,
      partialResults: partialResults,
      listenMode: stt.ListenMode.confirmation,
      cancelOnError: false,
      listenFor: const Duration(minutes: 10), // Long listening duration
    );

    return _controller!.stream;
  }

  @override
  Future<void> stopListening() async {
    _isListening = false;
    await _speech.stop();
    await _controller?.close();
    _controller = null;
  }

  @override
  Future<void> cancel() async {
    _isListening = false;
    await _speech.cancel();
    await _controller?.close();
    _controller = null;
  }

  @override
  Future<List<String>> getAvailableLanguages() async {
    final locales = await _speech.locales();
    return locales.map((locale) => locale.localeId).toList();
  }

  void _handleError(dynamic error) {
    _controller?.addError(
      SpeechRecognitionException(
        error.toString(),
        code: error.errorMsg,
      ),
    );
  }

  @override
  void dispose() {
    _speech.stop();
    _controller?.close();
  }
}

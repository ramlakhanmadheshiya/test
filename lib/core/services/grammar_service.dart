import 'package:flutter/foundation.dart';

class GrammarService {
  // Enhanced punctuation correction with intelligent formatting
  String correctPunctuation(String text) {
    if (text.isEmpty) return text;

    String corrected = text.trim();

    // Remove multiple spaces
    corrected = corrected.replaceAll(RegExp(r'\s+'), ' ');

    // Handle common voice commands first
    corrected = _replaceVoiceCommands(corrected);
    
    // Format numbered/bulleted lists
    corrected = _formatLists(corrected);

    // Fix spacing before punctuation
    corrected = _fixPunctuationSpacing(corrected);

    // Handle question words and add question marks
    corrected = _handleQuestions(corrected);

    // Capitalize sentences
    corrected = _capitalizeSentences(corrected);

    // Add final punctuation if missing
    corrected = _addFinalPunctuation(corrected);

    return corrected;
  }

  // Detect and format numbered/bulleted lists
  String _formatLists(String text) {
    // Detect list patterns like "first one is AB second one is BC"
    final listPatterns = [
      RegExp(r'\b(first|1st)\s+(one\s+is|is)\s+([^,\.]+?)[\s,]+(second|2nd)\s+(one\s+is|is)\s+([^,\.]+)', caseSensitive: false),
      RegExp(r'\b(\d+(?:st|nd|rd|th))\s+(one\s+is|is)\s+([^,\.]+)', caseSensitive: false),
      RegExp(r'\bfirst\b[^\n]*?\bsecond\b', caseSensitive: false),
    ];

    for (final pattern in listPatterns) {
      if (pattern.hasMatch(text)) {
        return _convertToFormattedList(text);
      }
    }

    return text;
  }

  String _convertToFormattedList(String text) {
    // Pattern for "first one is A second one is B third one is C"
    final listPattern = RegExp(
      r'(.*?)\s*(first|1st)\s+one\s+is\s+([a-zA-Z])\s+(second|2nd)\s+one\s+is\s+([a-zA-Z])(?:\s+(third|3rd|3rd|forth|fourth|4th)\s+one\s+is\s+([a-zA-Z]))?(?:\s+(forth|fourth|4th|fifth|5th)\s+one\s+is\s+([a-zA-Z]))?',
      caseSensitive: false,
    );
    
    final match = listPattern.firstMatch(text.toLowerCase());
    if (match != null) {
      final intro = match.group(1)?.trim() ?? '';
      final items = <String>[];
      
      // Extract items from the match groups
      if (match.group(3) != null) items.add(match.group(3)!.toUpperCase());
      if (match.group(5) != null) items.add(match.group(5)!.toUpperCase());
      if (match.group(7) != null) items.add(match.group(7)!.toUpperCase());
      if (match.group(9) != null) items.add(match.group(9)!.toUpperCase());
      
      if (items.length >= 2) {
        final buffer = StringBuffer();
        if (intro.isNotEmpty) {
          buffer.writeln('$intro:');
        }
        for (int i = 0; i < items.length; i++) {
          buffer.writeln('${i + 1}. ${items[i]}');
        }
        return buffer.toString().trim();
      }
    }
    
    // Try more flexible pattern
    final items = <String>[];
    final numberWords = {
      'first': 1, '1st': 1,
      'second': 2, '2nd': 2,
      'third': 3, '3rd': 3,
      'forth': 4, 'fourth': 4, '4th': 4,
      'fifth': 5, '5th': 5,
      'sixth': 6, '6th': 6,
      'seventh': 7, '7th': 7,
      'eighth': 8, '8th': 8,
      'ninth': 9, '9th': 9,
      'tenth': 10, '10th': 10,
    };
    
    String lowerText = text.toLowerCase();
    String? intro;
    
    // Find all occurrences of "number one is X"
    for (final entry in numberWords.entries) {
      final pattern = RegExp(
        '${entry.key}\\s+one\\s+is\\s+([a-zA-Z]+)',
        caseSensitive: false,
      );
      final matches = pattern.allMatches(lowerText);
      
      for (final match in matches) {
        final item = match.group(1);
        if (item != null) {
          // Get intro from before first item
          if (intro == null) {
            intro = text.substring(0, match.start).trim();
          }
          items.add(item.toUpperCase());
        }
      }
    }
    
    if (items.length >= 2) {
      final buffer = StringBuffer();
      if (intro != null && intro.isNotEmpty) {
        buffer.writeln('$intro:');
      }
      for (int i = 0; i < items.length; i++) {
        buffer.writeln('${i + 1}. ${items[i]}');
      }
      return buffer.toString().trim();
    }

    return text;
  }

  // Add intelligent punctuation based on context
  String _addIntelligentPunctuation(String text) {
    // Add commas in lists
    text = text.replaceAllMapped(
      RegExp(r'\b(and|or)\b(?!\s*$)', caseSensitive: false),
      (match) {
        // Check if there should be a comma before 'and' or 'or'
        final beforeAnd = text.substring(0, match.start);
        if (beforeAnd.split(' ').length > 3 && !beforeAnd.trimRight().endsWith(',')) {
          return ', ${match.group(0)}';
        }
        return match.group(0)!;
      },
    );

    // Add commas after transition words
    final transitionWords = [
      'however', 'therefore', 'furthermore', 'moreover', 'nevertheless',
      'consequently', 'meanwhile', 'additionally', 'similarly', 'likewise',
      'first', 'second', 'third', 'finally', 'lastly'
    ];
    
    for (final word in transitionWords) {
      text = text.replaceAllMapped(
        RegExp('\\b$word\\b(?!,)', caseSensitive: false),
        (match) => '${match.group(0)},',
      );
    }

    return text;
  }

  String _replaceVoiceCommands(String text) {
    // Replace common dictation commands
    text = text
        .replaceAllMapped(RegExp(r'\b(period|full stop)\b', caseSensitive: false), (m) => '.')
        .replaceAllMapped(RegExp(r'\bquestion mark\b', caseSensitive: false), (m) => '?')
        .replaceAllMapped(RegExp(r'\bexclamation (mark|point)\b', caseSensitive: false), (m) => '!')
        .replaceAllMapped(RegExp(r'\bcomma\b', caseSensitive: false), (m) => ',')
        .replaceAllMapped(RegExp(r'\bcolon\b', caseSensitive: false), (m) => ':')
        .replaceAllMapped(RegExp(r'\bsemicolon\b', caseSensitive: false), (m) => ';')
        .replaceAllMapped(RegExp(r'\bnew line\b', caseSensitive: false), (m) => '\n')
        .replaceAllMapped(RegExp(r'\bnew paragraph\b', caseSensitive: false), (m) => '\n\n');
    
    return text;
  }

  String _capitalizeSentences(String text) {
    // Capitalize first letter
    if (text.isNotEmpty) {
      text = text[0].toUpperCase() + text.substring(1);
    }

    // Capitalize after sentence-ending punctuation
    final sentenceEnders = ['. ', '! ', '? '];
    for (final ender in sentenceEnders) {
      final parts = text.split(ender);
      text = parts.asMap().entries.map((entry) {
        if (entry.key < parts.length - 1 && entry.value.isNotEmpty) {
          return entry.value[0].toUpperCase() + entry.value.substring(1);
        }
        return entry.value;
      }).join(ender);
    }

    return text;
  }

  String _addFinalPunctuation(String text) {
    text = text.trim();
    if (text.isEmpty) return text;

    final lastChar = text[text.length - 1];
    if (!['.', '!', '?', ',', ';', ':'].contains(lastChar)) {
      // Check if it's a question
      if (_isQuestion(text)) {
        text += '?';
      } else {
        text += '.';
      }
    }

    return text;
  }

  String _fixPunctuationSpacing(String text) {
    // Remove spaces before punctuation
    text = text.replaceAllMapped(
      RegExp(r'\s+([.,!?;:])'),
      (match) => match.group(1)!,
    );

    // Add space after punctuation if missing (except at end)
    text = text.replaceAllMapped(
      RegExp(r'([.,!?;:])([^\s\d])'),
      (match) => '${match.group(1)} ${match.group(2)}',
    );

    // Fix multiple spaces
    text = text.replaceAll(RegExp(r'\s+'), ' ');

    return text;
  }

  String _handleQuestions(String text) {
    final questionWords = [
      'what', 'where', 'when', 'why', 'who', 'whom', 'whose',
      'which', 'how', 'can', 'could', 'would', 'should', 'is',
      'are', 'was', 'were', 'do', 'does', 'did', 'will', 'shall'
    ];

    // Split into sentences
    final sentences = text.split(RegExp(r'[.!?]')).where((s) => s.trim().isNotEmpty);
    final correctedSentences = <String>[];

    for (var sentence in sentences) {
      sentence = sentence.trim();
      if (sentence.isEmpty) continue;

      final firstWord = sentence.split(' ').first.toLowerCase();
      
      if (questionWords.contains(firstWord) && !sentence.endsWith('?')) {
        sentence += '?';
      } else if (!sentence.endsWith('.') && !sentence.endsWith('!') && !sentence.endsWith('?')) {
        sentence += '.';
      }

      correctedSentences.add(sentence);
    }

    return correctedSentences.join(' ');
  }

  bool _isQuestion(String text) {
    text = text.trim().toLowerCase();
    
    final questionWords = [
      'what', 'where', 'when', 'why', 'who', 'whom', 'whose',
      'which', 'how', 'can', 'could', 'would', 'should', 'is',
      'are', 'was', 'were', 'do', 'does', 'did', 'will', 'shall'
    ];

    final firstWord = text.split(' ').first;
    return questionWords.contains(firstWord);
  }

  // Process transcribed text in real-time
  String processTranscription(String text, {bool isFinal = false}) {
    if (!isFinal) {
      // For partial results, just basic cleanup
      return text.trim();
    }

    // For final results, apply full grammar correction
    return correctPunctuation(text);
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'features/main_layout.dart';
import 'core/services/speech_recognition_service.dart';
import 'core/services/transcription_manager.dart';
import 'core/services/clipboard_manager.dart';
import 'core/services/hotkey_service.dart';
import 'core/services/typing_service.dart';
import 'core/models/transcription_item.dart';
import 'core/models/snippet.dart';
import 'core/models/note.dart';
import 'platform/speech_recognition_factory.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for local storage
  await Hive.initFlutter();
  
  // Register Hive adapters
  Hive.registerAdapter(TranscriptionItemAdapter());
  Hive.registerAdapter(SnippetAdapter());
  Hive.registerAdapter(NoteAdapter());
  
  runApp(const WordFlowApp());
}

class WordFlowApp extends StatefulWidget {
  const WordFlowApp({super.key});

  @override
  State<WordFlowApp> createState() => _WordFlowAppState();
}

class _WordFlowAppState extends State<WordFlowApp> {
  late TranscriptionManager _transcriptionManager;
  late HotkeyService _hotkeyService;
  late TypingService _typingService;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    _typingService = TypingService();
    await _typingService.initialize();

    final clipboardManager = ClipboardManager();
    
    _transcriptionManager = TranscriptionManager(
      speechService: SpeechRecognitionFactory.create(),
    );
    await _transcriptionManager.initialize(
      typingService: _typingService,
      clipboardManager: clipboardManager,
    );

    _hotkeyService = HotkeyService();
    await _hotkeyService.initialize(
      onPressed: () {
        _transcriptionManager.startListening();
      },
      onReleased: () {
        _transcriptionManager.stopListening();
      },
    );

    setState(() {
      _initialized = true;
    });
  }

  @override
  void dispose() {
    _hotkeyService.dispose();
    _transcriptionManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Initializing WordFlow...'),
              ],
            ),
          ),
        ),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<TranscriptionManager>.value(
          value: _transcriptionManager,
        ),
        ChangeNotifierProvider<HotkeyService>.value(
          value: _hotkeyService,
        ),
        ChangeNotifierProvider<TypingService>.value(
          value: _typingService,
        ),
        Provider<ClipboardManager>(
          create: (_) => ClipboardManager(),
        ),
      ],
      child: MaterialApp(
        title: 'WordFlow',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6366F1), // Indigo
            brightness: Brightness.light,
            primary: const Color(0xFF6366F1),
            secondary: const Color(0xFF8B5CF6), // Purple accent
            surface: const Color(0xFFFAFAFA),
            surfaceContainerHighest: const Color(0xFFF5F5F5),
          ),
          scaffoldBackgroundColor: const Color(0xFFFAFAFA),
          textTheme: GoogleFonts.interTextTheme().copyWith(
            displayLarge: GoogleFonts.inter(fontWeight: FontWeight.bold, letterSpacing: -0.5),
            displayMedium: GoogleFonts.inter(fontWeight: FontWeight.bold, letterSpacing: -0.5),
            displaySmall: GoogleFonts.inter(fontWeight: FontWeight.w600, letterSpacing: -0.25),
            headlineLarge: GoogleFonts.inter(fontWeight: FontWeight.bold, letterSpacing: -0.5),
            headlineMedium: GoogleFonts.inter(fontWeight: FontWeight.w600),
            titleLarge: GoogleFonts.inter(fontWeight: FontWeight.w600),
            titleMedium: GoogleFonts.inter(fontWeight: FontWeight.w500),
          ),
          cardTheme: CardTheme(
            elevation: 0,
            color: Colors.white,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: Colors.grey.shade100, width: 1),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
          appBarTheme: AppBarTheme(
            elevation: 0,
            centerTitle: false,
            backgroundColor: const Color(0xFFFAFAFA),
            surfaceTintColor: Colors.transparent,
            titleTextStyle: GoogleFonts.inter(
              color: Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6366F1),
            brightness: Brightness.dark,
            primary: const Color(0xFF818CF8),
            secondary: const Color(0xFFA78BFA),
            surface: const Color(0xFF1E1E1E),
            surfaceContainerHighest: const Color(0xFF2D2D2D),
          ),
          scaffoldBackgroundColor: const Color(0xFF121212),
          textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
            displayLarge: GoogleFonts.inter(fontWeight: FontWeight.bold, letterSpacing: -0.5),
            displayMedium: GoogleFonts.inter(fontWeight: FontWeight.bold, letterSpacing: -0.5),
            displaySmall: GoogleFonts.inter(fontWeight: FontWeight.w600, letterSpacing: -0.25),
            headlineLarge: GoogleFonts.inter(fontWeight: FontWeight.bold, letterSpacing: -0.5),
            headlineMedium: GoogleFonts.inter(fontWeight: FontWeight.w600),
            titleLarge: GoogleFonts.inter(fontWeight: FontWeight.w600),
            titleMedium: GoogleFonts.inter(fontWeight: FontWeight.w500),
          ),
          cardTheme: CardTheme(
            elevation: 0,
            color: const Color(0xFF1E1E1E),
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: Colors.grey.shade900, width: 1),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF2D2D2D),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade800),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade800),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF818CF8), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
          appBarTheme: AppBarTheme(
            elevation: 0,
            centerTitle: false,
            backgroundColor: const Color(0xFF121212),
            surfaceTintColor: Colors.transparent,
            titleTextStyle: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        themeMode: ThemeMode.system,
        home: const MainLayout(),
      ),
    );
  }
}

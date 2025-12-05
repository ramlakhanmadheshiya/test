import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/services/transcription_manager.dart';
import '../core/services/clipboard_manager.dart';
import '../widgets/app_sidebar.dart';
import 'home/home_screen.dart';
import 'history/history_screen.dart';
import 'snippets/snippets_screen.dart';
import 'notes/notes_screen.dart';
import 'settings/settings_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const HistoryScreen(),
    const SnippetsScreen(),
    const NotesScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          AppSidebar(
            selectedIndex: _selectedIndex < 4 ? _selectedIndex : 0,
            onItemSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
    );
  }
}

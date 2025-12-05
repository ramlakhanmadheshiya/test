import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import '../../core/services/hotkey_service.dart';
import '../../core/services/transcription_manager.dart';
import '../../core/services/typing_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            context,
            title: 'Hotkey Settings',
            children: [
              Consumer<HotkeyService>(
                builder: (context, hotkeyService, _) {
                  return ListTile(
                    title: const Text('Global Hotkey'),
                    subtitle: Text(hotkeyService.getHotkeyDisplayString()),
                    trailing: ElevatedButton(
                      onPressed: () => _showHotkeyCustomizationDialog(context),
                      child: const Text('Change'),
                    ),
                  );
                },
              ),
              Consumer<HotkeyService>(
                builder: (context, hotkeyService, _) {
                  return ListTile(
                    title: const Text('Hotkey Behavior'),
                    subtitle: Text(_getHotkeyBehaviorDescription(hotkeyService.hotkeyBehavior)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showHotkeyBehaviorDialog(context),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: 'Output Settings',
            children: [
              Consumer<TypingService>(
                builder: (context, typingService, _) {
                  return ListTile(
                    title: const Text('Typing Mode'),
                    subtitle: Text(typingService.getTypingModeDescription(typingService.typingMode)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: typingService.isPlatformSupported
                        ? () => _showTypingModeDialog(context)
                        : null,
                    enabled: typingService.isPlatformSupported,
                  );
                },
              ),
              Consumer<TypingService>(
                builder: (context, typingService, _) {
                  if (!typingService.isPlatformSupported) {
                    return ListTile(
                      leading: Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: const Text('Real-time typing not available'),
                      subtitle: const Text('This feature requires Windows desktop'),
                      dense: true,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: 'Transcription Settings',
            children: [
              Consumer<TranscriptionManager>(
                builder: (context, manager, _) {
                  return SwitchListTile(
                    title: const Text('Auto Punctuation'),
                    subtitle: const Text('Automatically add punctuation to transcriptions'),
                    value: manager.autoPunctuation,
                    onChanged: (value) => manager.setAutoPunctuation(value),
                  );
                },
              ),
              Consumer<TranscriptionManager>(
                builder: (context, manager, _) {
                  return SwitchListTile(
                    title: const Text('Auto Copy'),
                    subtitle: const Text('Automatically copy transcriptions to clipboard'),
                    value: manager.autoCopy,
                    onChanged: (value) => manager.setAutoCopy(value),
                  );
                },
              ),
              Consumer<TranscriptionManager>(
                builder: (context, manager, _) {
                  return ListTile(
                    title: const Text('Language'),
                    subtitle: Text(manager.languageCode),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showLanguageSelector(context),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: 'About',
            children: [
              const ListTile(
                title: Text('Version'),
                subtitle: Text('1.0.0'),
              ),
              ListTile(
                title: const Text('Help & Support'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Help coming soon!')),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required List<Widget> children}) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  void _showHotkeyCustomizationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const HotkeyCustomizationDialog(),
    );
  }

  String _getHotkeyBehaviorDescription(HotkeyBehavior behavior) {
    switch (behavior) {
      case HotkeyBehavior.toggle:
        return 'Toggle: Press once to start, press again to stop';
      case HotkeyBehavior.holdToSpeak:
        return 'Hold to speak: Press and hold to record, release to stop';
      case HotkeyBehavior.pushToTalk:
        return 'Push to talk: Single press starts, auto-stops after silence';
    }
  }

  void _showHotkeyBehaviorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hotkey Behavior'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Consumer<HotkeyService>(
              builder: (context, hotkeyService, _) {
                return Column(
                  children: [
                    RadioListTile<HotkeyBehavior>(
                      title: const Text('Toggle Mode'),
                      subtitle: const Text('Press once to start, press again to stop'),
                      value: HotkeyBehavior.toggle,
                      groupValue: hotkeyService.hotkeyBehavior,
                      onChanged: (value) {
                        if (value != null) {
                          hotkeyService.setHotkeyBehavior(value);
                        }
                      },
                    ),
                    RadioListTile<HotkeyBehavior>(
                      title: const Text('Hold to Speak'),
                      subtitle: const Text('Press and hold to record, release to stop'),
                      value: HotkeyBehavior.holdToSpeak,
                      groupValue: hotkeyService.hotkeyBehavior,
                      onChanged: (value) {
                        if (value != null) {
                          hotkeyService.setHotkeyBehavior(value);
                        }
                      },
                    ),
                    RadioListTile<HotkeyBehavior>(
                      title: const Text('Push to Talk'),
                      subtitle: const Text('Single press starts, auto-stops after silence'),
                      value: HotkeyBehavior.pushToTalk,
                      groupValue: hotkeyService.hotkeyBehavior,
                      onChanged: (value) {
                        if (value != null) {
                          hotkeyService.setHotkeyBehavior(value);
                        }
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTypingModeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Typing Mode'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Consumer<TypingService>(
              builder: (context, typingService, _) {
                return Column(
                  children: [
                    RadioListTile<TypingMode>(
                      title: const Text('App Only'),
                      subtitle: const Text('Transcribe in the app only'),
                      value: TypingMode.appOnly,
                      groupValue: typingService.typingMode,
                      onChanged: (value) {
                        if (value != null) {
                          typingService.setTypingMode(value);
                        }
                      },
                    ),
                    RadioListTile<TypingMode>(
                      title: const Text('Real-Time Typing'),
                      subtitle: const Text('Type directly to active window'),
                      value: TypingMode.realTimeTyping,
                      groupValue: typingService.typingMode,
                      onChanged: (value) {
                        if (value != null) {
                          typingService.setTypingMode(value);
                        }
                      },
                    ),
                    RadioListTile<TypingMode>(
                      title: const Text('Both'),
                      subtitle: const Text('Show in app AND type to active window'),
                      value: TypingMode.both,
                      groupValue: typingService.typingMode,
                      onChanged: (value) {
                        if (value != null) {
                          typingService.setTypingMode(value);
                        }
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLanguageSelector(BuildContext context) {
    final languages = {
      'en-US': 'English (US)',
      'en-GB': 'English (UK)',
      'es-ES': 'Spanish',
      'fr-FR': 'French',
      'de-DE': 'German',
      'it-IT': 'Italian',
      'pt-BR': 'Portuguese (Brazil)',
      'zh-CN': 'Chinese (Simplified)',
      'ja-JP': 'Japanese',
      'ko-KR': 'Korean',
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: languages.length,
            itemBuilder: (context, index) {
              final code = languages.keys.elementAt(index);
              final name = languages[code]!;
              
              return ListTile(
                title: Text(name),
                onTap: () {
                  context.read<TranscriptionManager>().setLanguageCode(code);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class HotkeyCustomizationDialog extends StatefulWidget {
  const HotkeyCustomizationDialog({super.key});

  @override
  State<HotkeyCustomizationDialog> createState() => _HotkeyCustomizationDialogState();
}

class _HotkeyCustomizationDialogState extends State<HotkeyCustomizationDialog> {
  PhysicalKeyboardKey? _selectedKey;
  final Set<HotKeyModifier> _selectedModifiers = {};
  bool _isListening = false;
  String _displayText = 'Click "Record" and press your desired key combination';

  @override
  void initState() {
    super.initState();
    // Initialize with current hotkey
    final hotkeyService = context.read<HotkeyService>();
    final currentKey = hotkeyService.currentKey;
    if (currentKey is PhysicalKeyboardKey) {
      _selectedKey = currentKey;
    }
    _selectedModifiers.addAll(hotkeyService.currentModifiers);
    _updateDisplayText();
  }

  void _updateDisplayText() {
    if (_selectedKey == null) {
      _displayText = 'Click "Record" and press your desired key combination';
      return;
    }

    final modifierNames = <String>[];
    if (_selectedModifiers.contains(HotKeyModifier.control)) modifierNames.add('Ctrl');
    if (_selectedModifiers.contains(HotKeyModifier.shift)) modifierNames.add('Shift');
    if (_selectedModifiers.contains(HotKeyModifier.alt)) modifierNames.add('Alt');
    if (_selectedModifiers.contains(HotKeyModifier.meta)) modifierNames.add('Win');

    final keyName = _selectedKey!.debugName?.replaceAll('Key ', '') ?? '';
    _displayText = [...modifierNames, keyName].join(' + ');
  }

  void _startRecording() {
    setState(() {
      _selectedKey = null;
      _selectedModifiers.clear();
      _isListening = true;
      _displayText = 'Press your desired key combination...';
    });
  }

  void _stopRecording() {
    setState(() {
      _isListening = false;
      if (_selectedKey != null && _selectedModifiers.isNotEmpty) {
        _updateDisplayText();
      } else {
        _displayText = 'Click "Record" and press your desired key combination';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: _isListening,
      onKeyEvent: _isListening ? _handleKeyEvent : null,
      child: AlertDialog(
        title: const Text('Customize Hotkey'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Current Hotkey',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isListening 
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _isListening 
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isListening ? Icons.radio_button_checked : Icons.keyboard,
                    color: _isListening 
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _displayText,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: _isListening ? FontWeight.bold : FontWeight.normal,
                        color: _isListening 
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _isListening ? _stopRecording : _startRecording,
              icon: Icon(_isListening ? Icons.stop : Icons.fiber_manual_record),
              label: Text(_isListening ? 'Stop Recording' : 'Record Hotkey'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _isListening 
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tip: Hold modifier keys (Ctrl, Shift, Alt, Win) and press a letter key',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _selectedKey != null && _selectedModifiers.isNotEmpty
                ? () async {
                    final hotkeyService = context.read<HotkeyService>();
                    final success = await hotkeyService.updateHotkey(
                      key: _selectedKey!,
                      modifiers: _selectedModifiers.toList(),
                    );
                    
                    if (success && context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Hotkey saved successfully!'),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } else if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Failed to save hotkey. Please try again.'),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                : null,
            child: const Text('Save Hotkey'),
          ),
        ],
      ),
    );
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (!_isListening) return KeyEventResult.ignored;
    
    if (event is KeyDownEvent) {
      final key = event.physicalKey;

      // Check if it's a modifier key
      if (key == PhysicalKeyboardKey.controlLeft || key == PhysicalKeyboardKey.controlRight) {
        if (!_selectedModifiers.contains(HotKeyModifier.control)) {
          setState(() {
            _selectedModifiers.add(HotKeyModifier.control);
            _updateDisplayText();
          });
        }
      } else if (key == PhysicalKeyboardKey.shiftLeft || key == PhysicalKeyboardKey.shiftRight) {
        if (!_selectedModifiers.contains(HotKeyModifier.shift)) {
          setState(() {
            _selectedModifiers.add(HotKeyModifier.shift);
            _updateDisplayText();
          });
        }
      } else if (key == PhysicalKeyboardKey.altLeft || key == PhysicalKeyboardKey.altRight) {
        if (!_selectedModifiers.contains(HotKeyModifier.alt)) {
          setState(() {
            _selectedModifiers.add(HotKeyModifier.alt);
            _updateDisplayText();
          });
        }
      } else if (key == PhysicalKeyboardKey.metaLeft || key == PhysicalKeyboardKey.metaRight) {
        if (!_selectedModifiers.contains(HotKeyModifier.meta)) {
          setState(() {
            _selectedModifiers.add(HotKeyModifier.meta);
            _updateDisplayText();
          });
        }
      } else {
        // It's a regular key - only accept if we have at least one modifier
        if (_selectedModifiers.isNotEmpty) {
          setState(() {
            _selectedKey = key;
            _updateDisplayText();
            _isListening = false;
          });
        }
      }

      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }
}

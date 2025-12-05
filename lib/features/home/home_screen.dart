import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/transcription_manager.dart';
import '../../core/services/clipboard_manager.dart';
import '../../core/services/hotkey_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late TextEditingController _textController;
  bool _isEditingManually = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Section
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'WordFlow',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Voice to Text Transcription',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Consumer2<HotkeyService, TranscriptionManager>(
                    builder: (context, hotkeyService, manager, _) {
                      return InkWell(
                        onTap: () {
                          if (manager.isListening) {
                            manager.stopListening();
                          } else {
                            manager.startListening();
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: manager.isListening 
                                ? Colors.red.withOpacity(0.1)
                                : theme.colorScheme.primaryContainer.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: manager.isListening
                                  ? Colors.red.withOpacity(0.3)
                                  : theme.colorScheme.primary.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                manager.isListening ? Icons.mic : Icons.keyboard_outlined,
                                size: 18,
                                color: manager.isListening ? Colors.red : theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                hotkeyService.getHotkeyDisplayString(),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: manager.isListening ? Colors.red : theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 24),

              // Main Transcription Card
              Expanded(
                child: Consumer<TranscriptionManager>(
                  builder: (context, manager, _) {
                    // Update text controller when transcription changes
                    if (!_isEditingManually && _textController.text != manager.currentText) {
                      _textController.text = manager.currentText;
                      _textController.selection = TextSelection.fromPosition(
                        TextPosition(offset: _textController.text.length),
                      );
                    }

                    return Card(
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Status indicator
                            Row(
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: manager.isListening 
                                        ? Colors.red 
                                        : Colors.green,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  manager.isListening ? 'Listening...' : 'Ready',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                if (_textController.text.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${_textController.text.split(' ').where((w) => w.isNotEmpty).length} words',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Editable transcription text area
                            Expanded(
                              child: TextField(
                                controller: _textController,
                                maxLines: null,
                                expands: true,
                                enabled: !manager.isListening,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  height: 1.7,
                                  fontSize: 16,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Press your hotkey (${context.read<HotkeyService>().getHotkeyDisplayString()}) to start recording...',
                                  hintStyle: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                                    height: 1.7,
                                  ),
                                  border: InputBorder.none,
                                  filled: false,
                                  contentPadding: const EdgeInsets.all(16),
                                ),
                                onChanged: (text) {
                                  _isEditingManually = true;
                                  manager.updateCurrentText(text);
                                },
                                onTap: () {
                                  setState(() {
                                    _isEditingManually = true;
                                  });
                                },
                              ),
                            ),
                            
                            if (manager.lastError != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.red.shade200),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        manager.lastError!,
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: Colors.red.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            
                            const SizedBox(height: 16),
                            
                            // Action buttons
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _textController.text.isEmpty ? null : () {
                                      final clipboardManager = context.read<ClipboardManager>();
                                      clipboardManager.copyToClipboard(_textController.text);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: const Text('Copied to clipboard!'),
                                          behavior: SnackBarBehavior.floating,
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.copy, size: 18),
                                    label: const Text('Copy'),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _textController.text.isEmpty ? null : () {
                                      setState(() {
                                        _textController.clear();
                                        _isEditingManually = false;
                                      });
                                      manager.clearText();
                                    },
                                    icon: const Icon(Icons.clear, size: 18),
                                    label: const Text('Clear'),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
    required bool isPrimary,
  }) {
    final theme = Theme.of(context);
    
    if (isPrimary) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
    
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.3),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> _toggleListening(TranscriptionManager manager) async {
    setState(() {
      _isEditingManually = false;
    });
    
    if (manager.isListening) {
      await manager.stopListening();
    } else {
      await manager.startListening();
    }
  }

  Future<void> _copyText(ClipboardManager clipboardManager) async {
    final text = _textController.text;
    if (text.isEmpty) return;

    final success = await clipboardManager.copyToClipboard(text);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text(success ? 'Copied to clipboard!' : 'Failed to copy'),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _clearText(TranscriptionManager manager) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Clear Transcription'),
        content: const Text('Are you sure you want to clear the current transcription?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              _textController.clear();
              manager.clearText();
              setState(() {
                _isEditingManually = false;
              });
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

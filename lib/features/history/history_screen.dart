import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/services/transcription_manager.dart';
import '../../core/services/clipboard_manager.dart';
import '../../core/models/transcription_item.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => _showClearHistoryDialog(context),
            tooltip: 'Clear All History',
          ),
        ],
      ),
      body: Consumer<TranscriptionManager>(
        builder: (context, manager, _) {
          final history = manager.history;

          if (history.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No transcription history',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your transcriptions will appear here',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            );
          }

          // Group history by date
          final groupedHistory = _groupHistoryByDate(history);

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: groupedHistory.length,
            itemBuilder: (context, index) {
              final entry = groupedHistory.entries.elementAt(index);
              final dateLabel = entry.key;
              final items = entry.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (index > 0) const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Text(
                      dateLabel,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...items.map((item) => _buildHistoryCard(context, item)),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, TranscriptionItem item) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: InkWell(
        onTap: () => _showTranscriptionDetail(context, item),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.mic,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('HH:mm').format(item.timestamp),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 18),
                    onPressed: () => _copyText(context, item.text),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Copy',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                item.text,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, List<TranscriptionItem>> _groupHistoryByDate(List<TranscriptionItem> history) {
    final grouped = <String, List<TranscriptionItem>>{};
    final now = DateTime.now();

    for (final item in history) {
      final difference = now.difference(item.timestamp);
      String label;

      if (difference.inDays == 0) {
        label = 'TODAY';
      } else if (difference.inDays == 1) {
        label = 'YESTERDAY';
      } else if (difference.inDays < 7) {
        label = '${difference.inDays} DAYS AGO';
      } else {
        label = DateFormat('MMMM d, yyyy').format(item.timestamp).toUpperCase();
      }

      grouped.putIfAbsent(label, () => []).add(item);
    }

    return grouped;
  }

  void _showTranscriptionDetail(BuildContext context, TranscriptionItem item) {
    final textController = TextEditingController(text: item.text);
    bool isEditing = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.mic),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  DateFormat('MMM d, yyyy HH:mm').format(item.timestamp),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              IconButton(
                icon: Icon(isEditing ? Icons.check : Icons.edit),
                onPressed: () async {
                  if (isEditing) {
                    // Save changes
                    final manager = context.read<TranscriptionManager>();
                    final index = manager.history.indexOf(item);
                    if (index >= 0) {
                      await manager.updateHistoryItem(
                        manager.history.length - 1 - index, // Reverse index
                        textController.text,
                      );
                    }
                  }
                  setState(() {
                    isEditing = !isEditing;
                  });
                },
                tooltip: isEditing ? 'Save' : 'Edit',
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: isEditing
                  ? TextField(
                      controller: textController,
                      maxLines: null,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Edit transcription...',
                      ),
                    )
                  : SelectableText(item.text),
            ),
          ),
          actions: [
            if (!isEditing)
              TextButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Transcription'),
                      content: const Text('Are you sure you want to delete this transcription?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  
                  if (confirm == true && context.mounted) {
                    final manager = context.read<TranscriptionManager>();
                    final index = manager.history.indexOf(item);
                    if (index >= 0) {
                      await manager.deleteHistoryItem(manager.history.length - 1 - index);
                      if (context.mounted) Navigator.pop(context);
                    }
                  }
                },
                icon: const Icon(Icons.delete),
                label: const Text('Delete'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            if (!isEditing)
              TextButton(
                onPressed: () {
                  _copyText(context, item.text);
                  Navigator.pop(context);
                },
                child: const Text('Copy'),
              ),
          ],
        ),
      ),
    );
  }

  void _copyText(BuildContext context, String text) {
    final clipboardManager = context.read<ClipboardManager>();
    clipboardManager.copyToClipboard(text);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _showClearHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text('Are you sure you want to clear all transcription history? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement clear history
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('History cleared')),
              );
            },
            child: Text(
              'Clear',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

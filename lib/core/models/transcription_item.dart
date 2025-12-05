import 'package:hive/hive.dart';

part 'transcription_item.g.dart';

@HiveType(typeId: 0)
class TranscriptionItem extends HiveObject {
  @HiveField(0)
  String text;

  @HiveField(1)
  DateTime timestamp;

  @HiveField(2)
  String? id;

  TranscriptionItem({
    required this.text,
    required this.timestamp,
    this.id,
  });

  factory TranscriptionItem.create(String text) {
    return TranscriptionItem(
      text: text,
      timestamp: DateTime.now(),
      id: DateTime.now().millisecondsSinceEpoch.toString(),
    );
  }

  String get formattedTimestamp {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      // Today
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}

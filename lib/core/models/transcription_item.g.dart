// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transcription_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TranscriptionItemAdapter extends TypeAdapter<TranscriptionItem> {
  @override
  final int typeId = 0;

  @override
  TranscriptionItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TranscriptionItem(
      text: fields[0] as String,
      timestamp: fields[1] as DateTime,
      id: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TranscriptionItem obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.text)
      ..writeByte(1)
      ..write(obj.timestamp)
      ..writeByte(2)
      ..write(obj.id);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranscriptionItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
